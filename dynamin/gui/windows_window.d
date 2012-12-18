
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.gui.windows_window;

public import dynamin.c.windows;
public import dynamin.c.cairo;
public import dynamin.c.cairo_win32;
public import dynamin.all_core;
public import dynamin.all_gui;
public import dynamin.gui.window;
public import dynamin.gui.key;
public import dynamin.all_painting;
public import tango.io.Stdout;
public import tango.core.sync.Semaphore;

///
enum WindowsVersion {
	///
	Windows95,   ///
	Windows98,   ///
	WindowsMe,   ///
	Windows2000, ///
	WindowsXP,   ///
	WindowsVista,///
	Windows7
}
/**
 * Returns true if the version of Windows that is runninng now is the
 * specified version or newer.
 */
bool checkWindowsVersion(WindowsVersion ver) {
	// Windows Server "Longhorn" is 6.0
	// Windows Vista is 6.0
	// Windows Server 2003 is 5.2
	// Windows XP is 5.1
	// Windows Me is 4.90
	// Windows 98 is 4.10
	// Windows 95 is 4.0
	// Windows NT is 4.0
	OSVERSIONINFO info;
	info.dwOSVersionInfoSize = OSVERSIONINFO.sizeof;
	GetVersionEx(&info);
	DWORD major, minor;
	final switch(ver) {
	case WindowsVersion.Windows95:    major = 4; minor = 0; break;
	case WindowsVersion.Windows98:    major = 4; minor = 10; break;
	case WindowsVersion.WindowsMe:    major = 4; minor = 90; break;
	case WindowsVersion.Windows2000:  major = 5; minor = 0; break;
	case WindowsVersion.WindowsXP:    major = 5; minor = 1; break;
	case WindowsVersion.WindowsVista: major = 6; minor = 0; break;
	case WindowsVersion.Windows7:     major = 6; minor = 1; break;
	}
	return info.dwMajorVersion > major ||
		(info.dwMajorVersion == major && info.dwMinorVersion >= minor);
}
/* unittest {
	Stdout.format("Windows95 or newer: {}", checkWindowsVersion(WindowsVersion.Windows95)).newline;
	Stdout.format("Windows98 or newer: {}", checkWindowsVersion(WindowsVersion.Windows98)).newline;
	Stdout.format("WindowsMe or newer: {}", checkWindowsVersion(WindowsVersion.WindowsMe)).newline;
	Stdout.format("Windows2000 or newer: {}", checkWindowsVersion(WindowsVersion.Windows2000)).newline;
	Stdout.format("WindowsXP or newer: {}", checkWindowsVersion(WindowsVersion.WindowsXP)).newline;
} */

// TODO: the way I have stored references using SetProp() will not work
// if/when D gets a copying collector. I will need to store a key with
// SetProp() and use that key to store the reference in either an
// array or a hashtable.
Window[HWND] windows;
void setControl(HWND hwnd, Window win) {
	if(win is null)
		windows.remove(hwnd);
	else
		windows[hwnd] = win;
}
/**
 * Returns: the Dynamin NativeControl that wraps the specified handle
 */
// TODO: change return type to NativeControl
Window getControl(HWND hwnd) {
	assert(IsWindow(hwnd), "Invalid HWND");
	auto tmp = hwnd in windows;
	return tmp is null ? null : *tmp;
}

template ApplicationBackend() {
	void backend_run(Window w) {
		bool isWindowVisible() {
			if(w is null) return true;
			return w.visible;
		}
		MSG msg;
		BOOL ret;
		while(isWindowVisible() && (ret = GetMessage(&msg, null, 0, 0)) != 0) {
			if(ret == -1)
				Stdout("GetMessage() failed!").newline;
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}
	void backend_invoke(void delegate() dg) {
		PostMessage(msgWnd, WM_USER + 7,
			cast(word)dg.ptr, cast(word)dg.funcptr);
	}
	void backend_invokeNow(void delegate() dg) {
		SendMessage(msgWnd, WM_USER + 7,
			cast(word)dg.ptr, cast(word)dg.funcptr);
	}

}
/*
 * The reason backends use the backend_ prefix and:
 * mixin Backend();
 * instead of using just the method name and
 * mixin Backend() backend;
 * is that D mistakenly calls the method in the class, rather than
 * the one mixed-in...causing infinite recursion/stack overflow
 */
//{{{ WindowBackend
template WindowBackend() {
	HWND _handle;
	bool backend_handleCreated() { return _handle !is null; }
	//WS_CAPTION == WS_BORDER | WS_DLGFRAME;
	void backend_recreateHandle() {
		LONG style, exStyle;
		backend_getWindowStyles(style, exStyle);
		style &= ~WS_VISIBLE; // don't create visible
		// TODO: set the owner with CreateWindowEx
		HWND newHandle = CreateWindowEx(exStyle, "DynaminWindow", _text.toWcharPtr(),
			style, cast(int)x, cast(int)y, cast(int)width, cast(int)height,
			null, null, GetModuleHandle(null), null);
		if(!newHandle)
			Stdout("CreateWindowEx() failed").newline;
		setControl(newHandle, this);

		// Windows does not completely obey the styles given in CreateWindowEx()
		SetWindowLong(newHandle, GWL_STYLE, style);
		SetWindowLong(newHandle, GWL_EXSTYLE, exStyle);
		SetWindowPos(newHandle, null, 0, 0, 0, 0,
			SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);

		if(handleCreated) {
			// TODO: move native children to new window?

			// set z-order to right above old window
			// SetWindowPos() puts the window above the specified
			// window in the z-order
			SetWindowPos(newHandle, _handle, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
			if(IsWindowVisible(_handle))
				ShowWindow(newHandle, SW_SHOWNA);
			DestroyWindow(_handle);
		}
		_handle = newHandle;
		backend_nativeToBorderSize();
	}
	extern(C) static void freeDC(void* hdc) {
		ReleaseDC(null, hdc);
	}
	Graphics backend_quickCreateGraphics() {
		HDC hdc = GetDC(handle);
		cairo_surface_t* surface = cairo_win32_surface_create(hdc);
		cairo_surface_set_user_data(surface, cast(cairo_user_data_key_t*)1,
			hdc, &freeDC);
		cairo_t* cr = cairo_create(surface);
		cairo_surface_destroy(surface);
		cairo_translate(cr, -borderSize.left, -borderSize.top);
		auto g = new Graphics(cr);
		cairo_destroy(cr);
		return g;
	}
	void backend_visible(bool b) {
		if(b)
			// visible has been set to true by now...use state() to show window
			backend_state = _state;
		else
			//if not created, create the handle by calling handle()
			ShowWindow(handle, SW_HIDE);
	}
	void backend_state(WindowState s) {
		if(!visible)
			return;
		//if not created, create the handle by calling handle()
		if(s == WindowState.Normal)
			ShowWindow(handle, SW_RESTORE);
		else if(s == WindowState.Minimized)
			ShowWindow(handle, SW_MINIMIZE);
		else if(s == WindowState.Maximized)
			ShowWindow(handle, SW_MAXIMIZE);
	}
	void backend_activate() {
		SetForegroundWindow(_handle);
	}
	void backend_borderStyle(WindowBorderStyle border) {
		backend_updateWindowStyles();
	}
	void backend_setCurrentCursor(Cursor cur) {
		SetCursor(cur.handle);
	}
	void backend_repaint(Rect rect) {
		RECT wrect;
		wrect.left = cast(int)(rect.x-_borderSize.left);
		wrect.top = cast(int)(rect.y-_borderSize.top);
		wrect.right = wrect.left+cast(int)rect.width;
		wrect.bottom = wrect.top+cast(int)rect.height;
		InvalidateRect(handle, &wrect, false);
	}
	void backend_resizable(bool b) {
		backend_updateWindowStyles();
	}
	void backend_contentMinSizeChanged() {
	}
	void backend_contentMaxSizeChanged() {
		backend_updateWindowStyles();
	}
	void backend_location(Point pt) {
		SetWindowPos(handle, null,
			cast(int)pt.x, cast(int)pt.y, 0, 0,
			SWP_NOACTIVATE | SWP_NOSIZE | SWP_NOZORDER);
	}
	void backend_size(Size size) {
		SetWindowPos(handle, null,
			0, 0, cast(int)size.width, cast(int)size.height,
			SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOZORDER);
	}
	void backend_text(string str) {
		SetWindowText(handle, str.toWcharPtr());
	}
	//{{{ backend specific

	void backend_nativeToLocationSize() {
		RECT winRect;
		GetWindowRect(handle, &winRect);
		_location.x = winRect.left;
		_location.y = winRect.top;
		_size.width = winRect.right-winRect.left;
		_size.height = winRect.bottom-winRect.top;
	}
	package void backend_nativeToBorderSize() {
		RECT clientRect, winRect;
		POINT clientLoc;
		GetClientRect(handle, &clientRect);
		GetWindowRect(handle, &winRect);
		ClientToScreen(handle, &clientLoc);
		_borderSize.left = clientLoc.x-winRect.left;
		_borderSize.top = clientLoc.y-winRect.top;
		_borderSize.right = winRect.right-clientLoc.x-clientRect.right;
		_borderSize.bottom = winRect.bottom-clientLoc.y-clientRect.bottom;
		backend_nativeToLocationSize();
	}
	void backend_getWindowStyles(out LONG style, out LONG exStyle) {
		if(handleCreated) {
			style = GetWindowLong(handle, GWL_STYLE);
			exStyle = GetWindowLong(handle, GWL_EXSTYLE);
		}
		void SetIf(LONG s, bool b) {
			// if condition satisfied, add style, otherwise clear style
			b ? (style |= s) : (style &= ~s);
		}
		SetIf(WS_DLGFRAME, borderStyle != WindowBorderStyle.None);
		SetIf(WS_BORDER, borderStyle != WindowBorderStyle.None);
		SetIf(WS_THICKFRAME,
			resizable && borderStyle != WindowBorderStyle.None);
		SetIf(WS_MINIMIZEBOX, borderStyle == WindowBorderStyle.Normal);
		SetIf(WS_MAXIMIZEBOX,
			borderStyle == WindowBorderStyle.Normal && resizable &&
			content.maxWidth == 0 && content.maxHeight == 0);
		SetIf(WS_SYSMENU, borderStyle != WindowBorderStyle.None);
		if(borderStyle == WindowBorderStyle.Tool)
			exStyle |= WS_EX_TOOLWINDOW;
		else
			exStyle &= ~WS_EX_TOOLWINDOW;
	}
	void backend_updateWindowStyles() {
		if(!handleCreated)
			return;
		LONG style, exStyle;
		backend_getWindowStyles(style, exStyle);
		SetWindowLong(handle, GWL_STYLE, style);
		SetWindowLong(handle, GWL_EXSTYLE, exStyle);
		SetWindowPos(handle, null, 0, 0, 0, 0,
			SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
	}
		//--FixedToorWindow--
		//Style: 0x16c80000
		//ExStyle:  0x10180
		//--SizableToorWindow--
		//Style: 0x16cc0000
		//ExStyle:  0x10180
		//--FixedDialog--
		//Style: 0x16c80000
		//ExStyle:  0x10101
		//--None--
		//Style: 0x16010000
		//ExStyle:  0x10000
		//--FixedSingle--
		//Style: 0x16c80000
		//ExStyle:  0x10100
		//--Sizable--
		//Style: 0x16cc0000
		//ExStyle:  0x10100
	//}}}
}
//}}}

//{{{ Ux class
class Ux {
static:
private:
	HMODULE uxLib = null;
	// TODO: these are the wrong calling convention!!
	extern(Windows) {
		BOOL function() _IsAppThemed;
		BOOL function() _IsThemeActive;
		HTHEME function(HWND hwnd, LPCWSTR pszClassList) _OpenThemeData;
		HRESULT function(HTHEME hTheme) _CloseThemeData;
		HRESULT function(HTHEME hTheme, HDC hdc, int iPartId, int iStateId,
			RECT* pRect, RECT* pClipRect) _DrawThemeBackground;
	}
	static this() {
		uxLib = LoadLibrary("uxtheme");
		if(uxLib) {
			_IsAppThemed = cast(typeof(_IsAppThemed))
				GetProcAddress(uxLib, "IsAppThemed");
			_IsThemeActive = cast(typeof(_IsThemeActive))
				GetProcAddress(uxLib, "IsThemeActive");
			_OpenThemeData = cast(typeof(_OpenThemeData))
				GetProcAddress(uxLib, "OpenThemeData");
			_CloseThemeData = cast(typeof(_CloseThemeData))
				GetProcAddress(uxLib, "CloseThemeData");
			_DrawThemeBackground = cast(typeof(_DrawThemeBackground))
				GetProcAddress(uxLib, "DrawThemeBackground");
		}
	}
	HTHEME[mstring] cache;
	// opens an HTHEME for the specified controlName and caches it
	// next time, just returns the HTHEME from the cache
	HTHEME getHTHEME(string controlName) {
		HTHEME* hthemePtr = controlName in cache;
		HTHEME htheme = controlName in cache;
		if(hthemePtr) {
			htheme = *hthemePtr;
		} else {
			htheme = _OpenThemeData(null, controlName.toWcharPtr());
			if(!htheme) {
				if(_IsThemeActive())
					throw new Exception("invalid uxtheme controlName");
				else
					throw new Exception("no theme active");
			}
			cache[controlName] = htheme;
		}
		return htheme;
	}
	// This is called when the WM_THEMECHANGED message is sent
	package void themeChanged() {
		foreach(htheme; cache.values)
			_CloseThemeData(htheme);
		cache = null;
		updateThemeActive = true;
	}
	bool themeActive;
	bool updateThemeActive = true;
public:
	// cache this value, as this function was showing up in profiles
	bool isThemeActive() {
		if(updateThemeActive) {
			themeActive = uxLib && _IsThemeActive() && _IsAppThemed();
			updateThemeActive = false;
		}
		return themeActive;
	}
	// draw directly onto the HDC with the uxTheme API if the following
	// three conditions are met:
	// - the Graphics must be drawing to an HDC (duh)
	// - there cannot be a scale or rotation...translation can be handled
	// - the clip must be a pixel-aligned rectangle
	bool drawBackground(Graphics g, Rect rect, string controlName, int part, int state) {
		if(!uxLib)
			throw new Exception("UxPaintBackground(): uxtheme library not found!");
		HTHEME htheme = getHTHEME(controlName);
		static if(true) {

		HDC hdc = cairo_win32_surface_get_dc(cairo_get_target(g.handle));
		//HDC hdc = null;
		bool isMatrixTranslationOnly() {
			cairo_matrix_t matrix;
			cairo_get_matrix(g.handle, &matrix);
			return matrix.xx == 1 && matrix.xy == 0 &&
				matrix.xy == 0 && matrix.yy == 1;
		}
		bool isClipIntegerRect(cairo_rectangle_list_t* list) {
			return list.status != CAIRO_STATUS_CLIP_NOT_REPRESENTABLE;
		}
		RECT locRect;
		auto list = cairo_copy_clip_rectangle_list(g.handle);
		scope(exit) cairo_rectangle_list_destroy(list);
		if(hdc && isMatrixTranslationOnly() && isClipIntegerRect(list)) {
			double x = rect.x, y = rect.y;
			double right = rect.right, bottom = rect.bottom;
			cairo_user_to_device(g.handle, &x, &y);
			cairo_user_to_device(g.handle, &right, &bottom);
			locRect.left = cast(int)x;
			locRect.top = cast(int)y;
			locRect.right = cast(int)right;
			locRect.bottom = cast(int)bottom;
			cairo_surface_flush(cairo_get_target(g.handle));

			RECT clip;
			for(int i = 0; i < list.num_rectangles; ++i) {
				cairo_user_to_device(g.handle, &(list.rectangles[i].x), &(list.rectangles[i].y));
				clip.left = cast(int)list.rectangles[i].x;
				clip.top = cast(int)list.rectangles[i].y;
				clip.right = clip.left + cast(int)list.rectangles[i].width;
				clip.bottom = clip.top + cast(int)list.rectangles[i].height;
				_DrawThemeBackground(htheme, hdc, part, state, &locRect, &clip);
			}

			cairo_surface_mark_dirty(cairo_get_target(g.handle));
		} else {
			assert(0, "So far, visual styles are supported only with no rotation, no scaling, a rectangular clip, and HDC surfaces.");
			static if(0) {
			BITMAPINFO bmi;
			bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
			bmi.bmiHeader.biWidth = width;
			bmi.bmiHeader.biHeight = -height; // top-down DIB
			bmi.bmiHeader.biPlanes = 1;
			bmi.bmiHeader.biBitCount = 32;
			bmi.bmiHeader.biCompression = BI_RGB;
			//bmi.bmiHeader.biSizeImage = width * height * 4;
			hbmpBlack = CreateDIBSection(hdc, &bmi, DIB_RGB_COLORS,
				&bmpBits, NULL, 0);
			hbmpWhite = CreateDIBSection(hdc, &bmi, DIB_RGB_COLORS,
				&bmpBits, NULL, 0);
			//draw on a black background and on a white background
			//calculate alpha and colors and draw that image with cairo
			// DO TESTS WITH ROTATION AND SCALING
			_DrawThemeBackground(htheme, hdc, part, state, null/*change*/, null);
			DeleteObject(hbmpBlack);
			DeleteObject(hbmpWhite);
			}
		}

		}
		return false;
	}
}
//}}}

//{{{ module constructor and destructor
HWND msgWnd;
static this() {
	assert(cairo_version() >= CAIRO_VERSION_ENCODE(1, 4, 0),
		"cairo version 1.4.0 or newer is required");

	/* create window classes */
	WNDCLASSEX wc;
	wc.cbSize = wc.sizeof;
	wc.style = 0;
	wc.hInstance = GetModuleHandle(null);

	wc.lpfnWndProc = &dynaminMsgWindowProc;
	wc.lpszClassName = "DynaminMsgWindow";
	if(!RegisterClassExW(&wc))
		Stdout("RegisterClassEx() failed registering class 'DynaminMsgWindow'").newline;

	wc.lpfnWndProc = &dynaminWindowProc;
	//wc.hbrBackground = cast(HBRUSH)16;

	wc.lpszClassName = "DynaminWindow";
	if(!RegisterClassEx(&wc))
		Stdout("RegisterClassEx() failed registering class 'DynaminWindow'").newline;

	wc.style = CS_SAVEBITS;
	wc.lpszClassName = "DynaminPopup";
	if(!RegisterClassExW(&wc))
		Stdout("RegisterClassEx() failed registering class 'DynaminPopup'").newline;


	msgWnd = CreateWindowEx(0, "DynaminMsgWindow", "",
		0,
		0, 0, 0, 0,
		null, null, GetModuleHandle(null), null);
	if(!msgWnd)
		Stdout("CreateWindowEx() failed").newline;

	/* initialize COM */
	auto ret = CoInitializeEx(null, COINIT_APARTMENTTHREADED);
	if(ret != S_OK && ret != S_FALSE)
		Stdout("Failed to initialize COM").newline;

}
static ~this() {
	CoUninitialize();
}
//}}}

//{{{ dynaminWindowProc()
extern(Windows)
LRESULT dynaminWindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
	//used in WM_MOVING
	static int dragX, dragY; //the cursor location in window coordinates when the drag was started
	static bool trackingMouseLeave = false;
	auto c = getControl(hwnd);
	//{{{ helper functions
	void createMouseEvent(MouseButton button, void delegate(MouseEventArgs args) func) {
		scope args = new MouseEventArgs(
			cast(short)LOWORD(lParam)+c.borderSize.left,
			cast(short)HIWORD(lParam)+c.borderSize.top, button);
		func(args);
	}
	void snapSide(ref int sideToSnap, float side1, float side2) {
		if(sideToSnap >= side1-c.snapDistance && sideToSnap <= side1+c.snapDistance)
			sideToSnap = cast(int)side1;
		if(sideToSnap >= side2-c.snapDistance && sideToSnap <= side2+c.snapDistance)
			sideToSnap = cast(int)side2;
	}
	void delegate(Rect snapRect) emptyFunc = (Rect snapRect) { };
	// used to snap vertical sides, left and right
	void snapVSide(ref int side, RECT* rect, void delegate(Rect snapRect) func = emptyFunc) {
		if(c.snapRects is null)
			return;
		foreach(snapRect; c.snapRects) {
			if(rect.bottom >= snapRect.y && rect.top <= snapRect.bottom) {
				snapSide(side, snapRect.x, snapRect.right);
				func(snapRect);
			}
		}
	}
	// used to snap horizontal sides, top and bottom
	void snapHSide(ref int side, RECT* rect, void delegate(Rect snapRect) func = emptyFunc) {
		if(c.snapRects is null)
			return;
		foreach(snapRect; c.snapRects) {
			if(rect.right >= snapRect.x && rect.left <= snapRect.right) {
				snapSide(side, snapRect.y, snapRect.bottom);
				func(snapRect);
			}
		}
	}
	MouseButton getFromXBUTTONX() {
		switch(HIWORD(wParam)) {
		case XBUTTON1: return MouseButton.XButton1;
		case XBUTTON2: return MouseButton.XButton2;
		default: return MouseButton.None;
		}
	}
	bool isKeyDown(int vk) {
		return cast(bool)HIWORD(GetKeyState(vk));
	}
	//}}}
	switch(uMsg) {
	case WM_ENTERSIZEMOVE: //when the user starts moving or resizing the window
		//{{{
		DWORD cur = GetMessagePos();
		short curX = cur & 0xFFFF;
		short curY = cur >> 16;
		RECT rect;
		GetWindowRect(hwnd, &rect);
		dragX = curX-rect.left;
		dragY = curY-rect.top;
		return 0;
		//}}}
	case WM_MOVING:
		//{{{
		if(c.snapRects is null || c.snapRects.length == 0)
			break;
		RECT* rect = cast(RECT*)lParam;
		int rectWidth = rect.right-rect.left;
		int rectHeight = rect.bottom-rect.top;
		DWORD cur = GetMessagePos();
		short curX = cur & 0xFFFF;
		short curY = cur >> 16;
		rect.left = curX-dragX;
		rect.top = curY-dragY;
		void updateRightAndBottom() {
			rect.right = rect.left+rectWidth;
			rect.bottom = rect.top+rectHeight;
		}
		updateRightAndBottom();
		snapVSide(rect.left, rect, (Rect snapRect) {
			snapSide(rect.left, snapRect.x-rectWidth, snapRect.right-rectWidth);
		});
		updateRightAndBottom();
		snapHSide(rect.top, rect, (Rect snapRect) {
			snapSide(rect.top, snapRect.y-rectHeight, snapRect.bottom-rectHeight);
		});
		updateRightAndBottom();
		snapVSide(rect.left, rect, (Rect snapRect) {
			snapSide(rect.left, snapRect.x-rectWidth, snapRect.right-rectWidth);
		});
		updateRightAndBottom();
		return true;
		//}}}
	case WM_SIZING:
		//{{{
		Size minSize = c.content.minSize+c.borderSize;
		Size maxSize = c.content.maxSize+c.borderSize;
		RECT* rect = cast(RECT*)lParam;
		switch(wParam) {
		case WMSZ_TOPLEFT:
			snapHSide(rect.top, rect);
			goto case WMSZ_LEFT;
		case WMSZ_BOTTOMLEFT:
			snapHSide(rect.bottom, rect);
		case WMSZ_LEFT:
			snapVSide(rect.left, rect);
			// adjust left according to min and max
			if(c.content.maxWidth != 0)
				rect.left = max(rect.left, rect.right-cast(int)maxSize.width);
			if(c.content.minWidth != 0)
				rect.left = min(rect.left, rect.right-cast(int)minSize.width);
			break;
		case WMSZ_TOPRIGHT:
			snapHSide(rect.top, rect);
			goto case WMSZ_RIGHT;
		case WMSZ_BOTTOMRIGHT:
			snapHSide(rect.bottom, rect);
		case WMSZ_RIGHT:
			snapVSide(rect.right, rect);
			// adjust right according to min and max
			if(c.content.maxWidth != 0)
				rect.right = min(rect.right, rect.left+cast(int)maxSize.width);
			if(c.content.minWidth != 0)
				rect.right = max(rect.right, rect.left+cast(int)minSize.width);
			break;
		default: break;
		}
		switch(wParam) {
		case WMSZ_TOPLEFT:  //already snapped left above
		case WMSZ_TOPRIGHT: //already snapped right above
		case WMSZ_TOP:
			snapHSide(rect.top, rect);
			// adjust top according to min and max
			if(c.content.maxHeight != 0)
				rect.top = max(rect.top, rect.bottom-cast(int)maxSize.height);
			if(c.content.minHeight != 0)
				rect.top = min(rect.top, rect.bottom-cast(int)minSize.height);
			break;
		case WMSZ_BOTTOMLEFT:  //already snapped left above
		case WMSZ_BOTTOMRIGHT: //already snapped right above
		case WMSZ_BOTTOM:
			snapHSide(rect.bottom, rect);
			// adjust bottom according to min and max
			if(c.content.maxHeight != 0)
				rect.bottom = min(rect.bottom, rect.top+cast(int)maxSize.height);
			if(c.content.minHeight != 0)
				rect.bottom = max(rect.bottom, rect.top+cast(int)minSize.height);
			break;
		default: break;
		}
		return true;
		//}}}
	case WM_MOVE:
		RECT rect;
		GetWindowRect(hwnd, &rect);
		c._location = Point(rect.left, rect.top);
		scope args = new EventArgs();
		c.moved(args);
		return 0;
	case WM_SIZE:
		if(wParam == SIZE_RESTORED)
			c._state = WindowState.Normal;
		else if(wParam == SIZE_MINIMIZED) {
			c._state = WindowState.Minimized;
			break;   // don't update size if minimized (would be wierd size)
		} else if(wParam == SIZE_MAXIMIZED)
			c._state = WindowState.Maximized;

		RECT rect;
		GetWindowRect(hwnd, &rect);
		c._size = Size(rect.right-rect.left, rect.bottom-rect.top);
		c.backend_nativeToBorderSize();
		scope args = new EventArgs();
		c.resized(args);
		return 0;
	case WM_ACTIVATE:
		scope e = new EventArgs;
		if(LOWORD(wParam) == WA_ACTIVE || LOWORD(wParam) == WA_CLICKACTIVE) {
			c._active = true;
			c.activated(e);
		} else if(LOWORD(wParam) == WA_INACTIVE) {
			c._active = false;
			c.deactivated(e);
		}
		return 0;
	case WM_MOUSEMOVE:
		if(!trackingMouseLeave) {
			TRACKMOUSEEVENT tme;
			tme.cbSize = TRACKMOUSEEVENT.sizeof;
			tme.dwFlags = TME_LEAVE;
			tme.hWndTrack = hwnd;
			tme.dwHoverTime = 0;
			TrackMouseEvent(&tme);
			trackingMouseLeave = true;
		}
		auto pt = Point(cast(short)LOWORD(lParam)+c.borderSize.left, cast(short)HIWORD(lParam)+c.borderSize.top);
		Control captor = getCaptorControl();
		if(captor)
			pt = c.contentToContent(pt, captor);
		else
			captor = c;
		scope args = new MouseEventArgs(
			pt.x, pt.y, MouseButton.None);
		if(wParam &
			(MK_LBUTTON | MK_MBUTTON | MK_RBUTTON |
			MK_XBUTTON1 | MK_XBUTTON2)) {
			captor.mouseDragged(args);
		} else {
			captor.mouseMoved(args);
		}
		return 0;
	case WM_MOUSELEAVE:
		trackingMouseLeave = false;
		setHotControl(null);
		return 0;
	case WM_LBUTTONDOWN:
		SetCapture(hwnd);
		createMouseEvent(MouseButton.Left, (MouseEventArgs args) {
			c.mouseDown(args);
		});
		return 0;
	case WM_MBUTTONDOWN:
		SetCapture(hwnd);
		createMouseEvent(MouseButton.Middle, (MouseEventArgs args) {
			c.mouseDown(args);
		});
		return 0;
	case WM_RBUTTONDOWN:
		SetCapture(hwnd);
		createMouseEvent(MouseButton.Right, (MouseEventArgs args) {
			c.mouseDown(args);
		});
		return 0;
	case WM_XBUTTONDOWN:
		SetCapture(hwnd);
		auto button = getFromXBUTTONX();
		if(!button) break;
		createMouseEvent(button, (MouseEventArgs args) {
			c.mouseDown(args);
		});
		return true;
	case WM_LBUTTONUP:
		ReleaseCapture();
		createMouseEvent(MouseButton.Left, (MouseEventArgs args) {
			c.mouseUp(args);
		});
		return 0;
	case WM_MBUTTONUP:
		ReleaseCapture();
		createMouseEvent(MouseButton.Middle, (MouseEventArgs args) {
			c.mouseUp(args);
		});
		return 0;
	case WM_RBUTTONUP:
		ReleaseCapture();
		createMouseEvent(MouseButton.Right, (MouseEventArgs args) {
			c.mouseUp(args);
		});
		return 0;
	case WM_XBUTTONUP:
		ReleaseCapture();
		auto button = getFromXBUTTONX();
		if(!button) break;
		createMouseEvent(button, (MouseEventArgs args) {
			c.mouseUp(args);
		});
		return true;
	case WM_MOUSEWHEEL:
		int scrollLines;
		SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0, &scrollLines, 0);
		bool sScreen = (scrollLines == 0xFFFFFFFF);
		if(sScreen)
			scrollLines = 3;
		int delta = -cast(short)HIWORD(wParam);
		auto screenPt = Point(LOWORD(lParam), HIWORD(lParam));
		auto des = c.getDescendantAtPoint(c.screenToContent(screenPt));
		scope args = new MouseTurnedEventArgs(delta*scrollLines/120.0, sScreen);
		des.mouseTurned(args);
		return 0;
	case WM_SYSKEYDOWN:
		//Stdout.format("WM_SYSKEYDOWN: {:x}", cast(int)wParam).newline;
		if(wParam == 0x79) return 0;
		break;
	case WM_KEYDOWN:
		//Stdout.format("WM_KEYDOWN:    {:x}", cast(int)wParam).newline;
		Control focused = c.focusedControl ? c.focusedControl : c;
		scope args = new KeyEventArgs(VKToKey(wParam),
			cast(bool)(lParam & (1 << 30)), isKeyDown(VK_SHIFT),
			isKeyDown(VK_CONTROL), isKeyDown(VK_MENU) );
		focused.keyDown(args);
		return 0;
	case WM_SYSKEYUP:
		//Stdout.format("WM_SYSKEYUP: {:x}", cast(int)wParam).newline;
		if(wParam == 0x79) return 0;
		break;
	case WM_KEYUP:
		//Stdout.format("WM_KEYUP:    {:x}", cast(int)wParam).newline;
		Control focused = c.focusedControl ? c.focusedControl : c;
		scope args = new KeyEventArgs( VKToKey(wParam), false,
			isKeyDown(VK_SHIFT), isKeyDown(VK_CONTROL), isKeyDown(VK_MENU) );
		focused.keyUp(args);
		return 0;
	case WM_CHAR:
		// DO NOT use the repeat count from the lParam to send multiple events
		// I hate when programs do that

		//stop backspace and escape and shift+enter
		if(wParam == 0x08 || wParam == 0x1B || wParam == 0x0A)
			break;
		// don't process characters typed while control is down
		if(HIBYTE(GetKeyState(VK_CONTROL)))
			break;
		if(wParam == 0x0D) // change \r to \n
			wParam = 0x0A;
		bool repeat;
		repeat = cast(bool)(lParam & (1 << 30));
		Control focused = c.focusedControl ? c.focusedControl : c;
		scope args = new KeyTypedEventArgs(cast(dchar)wParam, repeat);
		focused.keyTyped(args);
		return 0;
	case WM_PRINT:
		paintToHDC(cast(HDC)wParam, getControl(hwnd), null);
		return 0;
	case WM_PAINT:
		PAINTSTRUCT ps;
		BeginPaint(hwnd, &ps);
		RECT* clip = &ps.rcPaint;

		HDC hdcBuffer = CreateCompatibleDC(ps.hdc);
		HBITMAP hbmpBuffer = CreateCompatibleBitmap(ps.hdc,
			clip.right-clip.left, clip.bottom-clip.top);
		HBITMAP hbmpDefault = SelectObject(hdcBuffer, hbmpBuffer);

		paintToHDC(hdcBuffer, getControl(hwnd), clip);

		BitBlt(ps.hdc, clip.left, clip.top, clip.right-clip.left, clip.bottom-clip.top,
			hdcBuffer, 0, 0, SRCCOPY);
		SelectObject(hdcBuffer, hbmpDefault);
		DeleteDC(hdcBuffer);
		DeleteObject(hbmpBuffer);

		EndPaint(hwnd, &ps);
		return 0;
	case WM_CLOSE:
		c.visible = false;
		//DestroyWindow(hwnd);
		//PostQuitMessage(0);
		return 0;
	case WM_DESTROY:
		return 0;
	default:
		break;
	}
	return DefWindowProc(hwnd, uMsg, wParam, lParam);
}
//}}}

//{{{ paintToHDC()
void paintToHDC(HDC hdc, Window w, RECT* clip) {
	cairo_surface_t* surface = cairo_win32_surface_create(hdc);
	cairo_t* cr = cairo_create(surface);
	cairo_surface_destroy(surface);

	if(clip) {
		cairo_translate(cr,
			-clip.left-w.borderSize.left, -clip.top-w.borderSize.top);

		//cairo_rectangle(cr, clip.left, clip.top, clip.right-clip.left, clip.bottom-clip.top);
	}
	//if(w.Opaque) {
		//cairo_set_source_rgb(cr, w.content.backColor.R/255.0, w.content.backColor.G/255.0, w.content.backColor.B/255.0);
		//cairo_paint(cr);
	//}

	//cairo_set_source_rgb(cr, .3, .3, .3);
	//cairo_paint(cr);

	//cairo_set_operator(cr, CAIRO_OPERATOR_CLEAR);
	//cairo_paint(cr);
	//cairo_set_operator(cr, CAIRO_OPERATOR_OVER);

	cairo_set_source_rgb(cr, 0, 0, 0);
	cairo_set_line_width(cr, 1.0);

	//HBITMAP hbmp = LoadImage(null, cast(wchar*)cast(ushort)OIC_WARNING,
	//	IMAGE_ICON, 0, 0, LR_SHARED);
	//if(hbmp == null)
	//	Stdout.format("LoadImage failed. GetLastError()={}", GetLastError()).newline;

	//auto imgSurface = cairo_image_surface_create_for_data();
	//cairo_set_source_surface(cr, imgSurface, 50, 50);
	//cairo_paint(cr);
	//cairo_surface_destroy(imgSurface);

	auto g = new Graphics(cr);
	scope args = new PaintingEventArgs(g);
	w.painting(args);
	delete g;
	cairo_destroy(cr);
}
//}}}

//{{{ VKToKey()
Key VKToKey(int code) {
	switch(code) {
	case VK_F1:  return Key.F1;
	case VK_F2:  return Key.F2;
	case VK_F3:  return Key.F3;
	case VK_F4:  return Key.F4;
	case VK_F5:  return Key.F5;
	case VK_F6:  return Key.F6;
	case VK_F7:  return Key.F7;
	case VK_F8:  return Key.F8;
	case VK_F9:  return Key.F9;
	case VK_F10: return Key.F10;
	case VK_F11: return Key.F11;
	case VK_F12: return Key.F12;

	case VK_ESCAPE: return Key.Escape;
	case VK_TAB:    return Key.Tab;
	case VK_BACK:   return Key.Backspace;
	case VK_RETURN: return Key.Enter;
	case VK_SPACE:  return Key.Space;

	case VK_LEFT:  return Key.Left;
	case VK_RIGHT: return Key.Right;
	case VK_UP:    return Key.Up;
	case VK_DOWN:  return Key.Down;

	case VK_INSERT: return Key.Insert;
	case VK_DELETE: return Key.Delete;
	case VK_HOME:   return Key.Home;
	case VK_END:    return Key.End;
	case VK_PRIOR:  return Key.PageUp;
	case VK_NEXT:   return Key.PageDown;

	case VK_SNAPSHOT: return Key.PrintScreen;
	case VK_PAUSE:    return Key.Pause;

	case VK_CAPITAL: return Key.CapsLock;
	case VK_NUMLOCK: return Key.NumLock;
	case VK_SCROLL:  return Key.ScrollLock;

	case VK_NUMPAD0:  return Key.NumPad0;
	case VK_NUMPAD1:  return Key.NumPad1;
	case VK_NUMPAD2:  return Key.NumPad2;
	case VK_NUMPAD3:  return Key.NumPad3;
	case VK_NUMPAD4:  return Key.NumPad4;
	case VK_NUMPAD5:  return Key.NumPad5;
	case VK_NUMPAD6:  return Key.NumPad6;
	case VK_NUMPAD7:  return Key.NumPad7;
	case VK_NUMPAD8:  return Key.NumPad8;
	case VK_NUMPAD9:  return Key.NumPad9;
	case VK_DIVIDE:   return Key.NumPadDivide;
	case VK_MULTIPLY: return Key.NumPadMultiply;
	case VK_SUBTRACT: return Key.NumPadSubtract;
	case VK_ADD:      return Key.NumPadAdd;
	case VK_DECIMAL:  return Key.NumPadDecimal;

	case VK_OEM_3:      return Key.Backquote;
	case VK_OEM_MINUS:  return Key.Minus;
	case VK_OEM_PLUS:   return Key.Equals;
	case VK_OEM_4:      return Key.OpenBracket;
	case VK_OEM_6:      return Key.CloseBracket;
	case VK_OEM_5:      return Key.Backslash;
	case VK_OEM_1:      return Key.Semicolon;
	case VK_OEM_7:      return Key.Quote;
	case VK_OEM_COMMA:  return Key.Comma;
	case VK_OEM_PERIOD: return Key.Period;
	case VK_OEM_2:      return Key.Slash;

	//case VK_APPS: return Key.Menu;

	case VK_SHIFT:   return Key.Shift;
	case VK_CONTROL: return Key.Control;
	case VK_MENU:    return Key.Alt;

	//case VK_: return Key.;
	default:
		if(code >= 0x30 && code <= 0x39) // Key.D0 - Key.D9
			return cast(Key)code;
		if(code >= 0x41 && code <= 0x5A) // Key.A - Key.Z
			return cast(Key)code;
		return cast(Key)0;
	}
}
//}}}

// Use the msgWnd for the following:
// Timers
// Clipboard.DataChanged event
// Clipboard?
// Taskbar created event using RegisterWindowMessage("TaskbarCreated")
// different settings changed events?
// screen saver enabled?
extern(Windows)
LRESULT dynaminMsgWindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
	switch(uMsg) {
	case WM_THEMECHANGED:
		Ux.themeChanged();
		return 0;
	case WM_POWERBROADCAST:
		if(wParam == PBT_APMRESUMESUSPEND || wParam == PBT_APMRESUMECRITICAL)
			Environment.backend_increaseTimerRes();
		return 0;
	case WM_USER + 7:
		void delegate() dg;
		dg.ptr = cast(void*)wParam;
		dg.funcptr = cast(void function())lParam;
		dg();
		return 0;
	case WM_TIMER:
	case WM_CHANGECBCHAIN:
	case WM_DRAWCLIPBOARD:
	case WM_TIMECHANGE: //??
	default:
		break;
	}
	return DefWindowProc(hwnd, uMsg, wParam, lParam);
}

// TODO: backend tests
// test that setting window.content.size doesn't include borders (I just saw this bug)

