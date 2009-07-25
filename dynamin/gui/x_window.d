// Written in the D programming language
// www.digitalmars.com/d/

/*
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the Dynamin library.
 *
 * The Initial Developer of the Original Code is Jordan Miner.
 * Portions created by the Initial Developer are Copyright (C) 2007-2009
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Jordan Miner <jminer7@gmail.com>
 *
 */

module dynamin.gui.x_window;

public import dynamin.core.string;
public import dynamin.core.global;
public import dynamin.core.math;
public import dynamin.gui.window;
public import dynamin.gui.key;
public import dynamin.c.xlib;
public import dynamin.c.xlib : XWindow = Window;
public import dynamin.c.xmu;
public import dynamin.c.cairo;
public import dynamin.c.cairo_xlib;
public import tango.stdc.string;
public import tango.io.Stdout;

/*
** Window property:
** _NET_FRAME_EXTENTS(CARDINAL) = 4, 4, 23, 4
**    left, right, top and bottom border sizes
*/

Window[XWindow] windows;
void setControl(XWindow handle, Window win) {
	if(win is null)
		windows.remove(handle);
	else
		windows[handle] = win;
}

Window getControl(XWindow handle) {
	auto tmp = handle in windows;
	return tmp is null ? null : *tmp;
}

/**
 * A simpler method that returns all the data in a property.
 * NOTE: the returned data still has to be freed with XFree()
 */
void* getXWindowProperty(XDisplay* d, XWindow w, XAtom prop, int* numRet = null) {
	XAtom actualType;
	int actualFormat;
	uint nitems, bytesAfter;
	void* ptr;
	XGetWindowProperty(d, w, prop,
		0, 0xFFFFFFFF, false, AnyPropertyType,
		&actualType, &actualFormat, &nitems, &bytesAfter,
		&ptr);
	if(numRet) *numRet = nitems;
	return ptr;
}
bool isWMPropertySupported(XAtom prop) {
	int count;
	XAtom* atoms = cast(XAtom*)getXWindowProperty(display,
		root, XA._NET_SUPPORTED, &count);
	scope(exit) XFree(atoms);
	for(int i = 0; i < count; ++i)
		if(atoms[i] == prop)
			return true;
	return false;
}
bool isTopLevelReparented(XWindow w) {
	XWindow root, parent;
	XWindow* children;
	uint numChildren;
	XQueryTree(display, w,
		&root, &parent, &children, &numChildren);
	return parent != root;
}

XDisplay* display;
XWindow root;
XWindow msgWin;
abstract class XA { // X atoms
static:
	XAtom _NET_SUPPORTED, _NET_WM_NAME, _NET_WORKAREA, _NET_FRAME_EXTENTS;
	XAtom _NET_REQUEST_FRAME_EXTENTS;
	XAtom _NET_MOVERESIZE_WINDOW;
	XAtom _NET_WM_WINDOW_TYPE;
	XAtom _NET_WM_WINDOW_TYPE_MENU, _NET_WM_WINDOW_TYPE_UTILITY;
	XAtom _NET_WM_WINDOW_TYPE_SPLASH;
	XAtom _NET_WM_WINDOW_TYPE_DIALOG, _NET_WM_WINDOW_TYPE_NORMAL;
	XAtom WM_PROTOCOLS, WM_DELETE_WINDOW, _NET_WM_SYNC_REQUEST;
	XAtom UTF8_STRING, ATOM;
	XAtom _MOTIF_WM_HINTS;
	XAtom CLIPBOARD, PRIMARY, TARGETS, CLIPBOARD_MANAGER, SAVE_TARGETS;
	XAtom DYNAMIN_SELECTION;
}
static this() {
	display = XOpenDisplay(null);
	if(!display)
		Stdout("XOpenDisplay() failed").newline;
	root = XRootWindow(display, XDefaultScreen(display));

	msgWin = XCreateSimpleWindow(display, root, 0, 0, 1, 1, 0, 0, 0);

	XA._NET_SUPPORTED   = XInternAtom(display, "_NET_SUPPORTED", false);
	XA._NET_WM_NAME     = XInternAtom(display, "_NET_WM_NAME", false);
	XA._NET_WORKAREA    = XInternAtom(display, "_NET_WORKAREA", false);
	XA._NET_FRAME_EXTENTS = XInternAtom(display, "_NET_FRAME_EXTENTS", false);
	XA._NET_REQUEST_FRAME_EXTENTS =
		XInternAtom(display, "_NET_REQUEST_FRAME_EXTENTS", false);
	XA._NET_MOVERESIZE_WINDOW =
		XInternAtom(display, "_NET_MOVERESIZE_WINDOW", false);
	XA._NET_WM_WINDOW_TYPE =
		XInternAtom(display, "_NET_WM_WINDOW_TYPE", false);
	XA._NET_WM_WINDOW_TYPE_MENU =
		XInternAtom(display, "_NET_WM_WINDOW_TYPE_MENU", false);
	XA._NET_WM_WINDOW_TYPE_UTILITY =
		XInternAtom(display, "_NET_WM_WINDOW_TYPE_UTILITY", false);
	XA._NET_WM_WINDOW_TYPE_SPLASH =
		XInternAtom(display, "_NET_WM_WINDOW_TYPE_SPLASH", false);
	XA._NET_WM_WINDOW_TYPE_DIALOG =
		XInternAtom(display, "_NET_WM_WINDOW_TYPE_DIALOG", false);
	XA._NET_WM_WINDOW_TYPE_NORMAL =
		XInternAtom(display, "_NET_WM_WINDOW_TYPE_NORMAL", false);
	XA.WM_PROTOCOLS     = XInternAtom(display, "WM_PROTOCOLS", false);
	XA.WM_DELETE_WINDOW = XInternAtom(display, "WM_DELETE_WINDOW", false);
	XA._NET_WM_SYNC_REQUEST =
		XInternAtom(display, "_NET_WM_SYNC_REQUEST", false);
	XA.UTF8_STRING      = XInternAtom(display, "UTF8_STRING", false);
	XA.ATOM = XInternAtom(display, "ATOM", false);
	XA._MOTIF_WM_HINTS  = XInternAtom(display, "_MOTIF_WM_HINTS", false);
	XA.CLIPBOARD = XInternAtom(display, "CLIPBOARD", false);
	XA.PRIMARY = XInternAtom(display, "PRIMARY", false);
	XA.TARGETS = XInternAtom(display, "TARGETS", false);
	XA.CLIPBOARD_MANAGER = XInternAtom(display, "CLIPBOARD_MANAGER", false);
	XA.SAVE_TARGETS = XInternAtom(display, "SAVE_TARGETS", false);

	XA.DYNAMIN_SELECTION = XInternAtom(display, "DYNAMIN_SELECTION", false);
	if(!isWMPropertySupported(XA._NET_WM_NAME))
		Stdout("warning: WM does not support _NET_WM_NAME").newline;
	if(!isWMPropertySupported(XA._NET_WORKAREA))
		Stdout("warning: WM does not support _NET_WORKAREA").newline;
	if(!isWMPropertySupported(XA._NET_FRAME_EXTENTS))
		Stdout("warning: WM does not support _NET_FRAME_EXTENTS").newline;
	if(!isWMPropertySupported(XA._NET_WORKAREA))
		Stdout("warning: WM does not support _NET_WORKAREA").newline;
}

struct _InvalidRect {
	XWindow window;
	int x, y, width, height;
	_InvalidRect getUnion(_InvalidRect rect) {
		auto x2 = min(x, rect.x);
		auto y2 = min(y, rect.y);
		_InvalidRect rect2;
		rect2.window = window;
		rect2.width = max(x+width, rect.x+rect.width)-x2;
		rect2.height = max(y+height, rect.y+rect.height)-y2;
		rect2.x = x2;
		rect2.y = y2;
		return rect2;
	}
}
/+struct InvalidRect {
	XWindow window;
	int x, y, width, height;
}

static class PaintQueue {
static:
	//LinkedList!(InvalidRect) rects;
	InvalidRect[] rects;
	static this() {
		//rects = new LinkedList!(InvalidRect)(20);
		rects.length = 20;
		rects.length = 0;
	}
	void add(XWindow win, int x, int y, int width, int height) {
		rects.length = rects.length + 1;
		rects[$-1].window = win;
		rects[$-1].x = x;
		rects[$-1].y = y;
		rects[$-1].width = width;
		rects[$-1].height = height;
	}
	bool shouldMerge(int x1, int y1, int width1, int height1,
		int x2, int y2, int width2, int height2) {
		return x2 <= x1 + width1 && y2 <= y1 + height1 &&
			x2 + width2 >= x1 && y2 + height2 >= y1;
	}
	void Union(inout int x, inout int y, inout int width, inout int height,
		int x2, int y2, int width2, int height2) {
	}
	void compress() {
	}
}+/

Key prevKey = Key.None;

//{{{ ApplicationBackend
template ApplicationBackend() {
	void backend_run(Window w) {
		bool isWindowVisible() {
			if(w is null) return true;
			return w.visible;
		}
		XEvent ev;
		while(isWindowVisible()) {
			if(XEventsQueued(display, QueuedAlready) == 0) {
				_InvalidRect[] rects = Window.invalidRects;
				Window.invalidRects.length = 0;
				while(rects.length > 0) {
					auto rect = rects[0];
					// TODO: fix this...right now it gens one Expose with
					// the union of invalid rects
					for(int i = rects.length-1; i >= 0; --i) {
						if(rect.window == rects[i].window) {
							rect = rect.getUnion(rects[i]);

							arrayCopy!(_InvalidRect)(rects, i+1, rects, i, rects.length-i-1);
							rects.length = rects.length-1;
						}
					}
					ev.xexpose.type = Expose;
					ev.xexpose.display = display;
					ev.xexpose.window = rect.window;
					ev.xexpose.x = rect.x;
					ev.xexpose.y = rect.y;
					ev.xexpose.width = rect.width;
					ev.xexpose.height = rect.height;
					ev.xexpose.count = -2; // came from here
					XPutBackEvent(display, &ev);
				}
			}
			XNextEvent(display, &ev);
			auto evDisplay = ev.xany.display;
			auto evWindow = ev.xany.window;
			Window c = getControl(evWindow);
			// c will be null for SelectionRequest events
			//if(c is null)
			//	continue;
			//{{{ helper functions
			void createMouseEvent(void delegate(MouseEventArgs args) func) {
				MouseButton button;
				auto buttonEv = ev.xbutton;
				switch(buttonEv.button) {
				case 1: button = MouseButton.Left; break;
				case 2: button = MouseButton.Middle; break;
				case 3: button = MouseButton.Right; break;
				default: return;
				}
				scope args = new MouseEventArgs(buttonEv.x+c._borderSize.left, buttonEv.y+c._borderSize.top, button);
				func(args);
			}
			bool isKeyDown(uint keycode) {
				ubyte[32] keys;
				XQueryKeymap(display, keys.ptr);
				return cast(bool)( (keys[keycode / 8] >> (keycode % 8)) & 1 );
			}
			//}}}
			switch(ev.type) {
			case MapNotify:
				c.mapped = true;
				break;
			case UnmapNotify:
				_InvalidRect[] rects = Window.invalidRects;
				for(int i = rects.length-1; i >= 0; --i) {
					if(rects[i].window == evWindow) {
						arrayCopy!(_InvalidRect)(
							rects, i+1, rects, i, rects.length-i-1);
						rects.length = rects.length-1;
					}
				}
				Window.invalidRects = rects;
				c.mapped = false;
				break;
			case DestroyNotify:
				setControl(evWindow, null);
				break;
			case ClientMessage:
				auto clientEv = ev.xclient;
				if(clientEv.message_type != XA.WM_PROTOCOLS)
					break;
				if(clientEv.data.l[0] == XA.WM_DELETE_WINDOW) {
					XDestroyWindow(evDisplay, evWindow);
					return; // TODO: check event, and figure out what to do
				}
				break;
			case KeyPress:
				auto sym = XLookupKeysym(&ev.xkey, 0);
				if(sym == NoSymbol)
					break;
				// Since X gives no way to tell if a KeyPress is generated by
				// auto-repeat, prevKey is used here to tell.
				auto k = KeysymToKey(sym);
				scope args = new KeyEventArgs(k, k == prevKey);
				prevKey = k;
				Control focused = c.focusedControl ? c.focusedControl : c;
				focused.keyDown(args);
				break;
			case KeyRelease:
				// When X does auto-repeat for a held down key, it sends
				// a KeyPress and KeyRelease every time, even though the key is
				// down constantly. Here we check if the key is down, and if so,
				// not send a keyUp event.
				if(isKeyDown(ev.xkey.keycode))
					break;
				auto sym = XLookupKeysym(&ev.xkey, 0);
				if(sym == NoSymbol)
					break;
				auto k = KeysymToKey(sym);
				if(k == prevKey)
					prevKey = Key.None; // can't repeat after released
				scope args = new KeyEventArgs(k, false);
				Control focused = c.focusedControl ? c.focusedControl : c;
				focused.keyUp(args);
				break;
			case ButtonPress:
				//Button4 is wheel scroll up
				//Button5 is wheel scroll down
				createMouseEvent((MouseEventArgs args) { c.mouseDown(args); });
				break;
			case ButtonRelease:
				createMouseEvent((MouseEventArgs args) { c.mouseUp(args); });
				break;
			case MotionNotify:
				auto motionEv = ev.xmotion;
				Control captor = getCaptorControl();
				Point pt = Point(motionEv.x+c.borderSize.left, motionEv.y+c.borderSize.top);
				if(captor)
					pt = c.contentToContent(pt, captor);
				else
					captor = c;
				scope args = new MouseEventArgs(pt.x, pt.y, MouseButton.None);
				if(motionEv.state &
					(Button1Mask | Button2Mask | Button3Mask)) {
					captor.mouseDragged(args);
				} else
					captor.mouseMoved(args);
				break;
			case EnterNotify:
				break;
			case LeaveNotify:
				break;
			case FocusIn:
				break;
			case FocusOut:
				break;
			case Expose:
				// TODO: move the painting code out of here and:
				//  make a PaintQueue class and put this here:
				//  PaintQueue.add(c, exposeEv.x, exposeEv.y, exposeEv.width, exposeEv.height);
				// then, in Window.repaint(), have this:
				//  PaintQueue.add(this, cast(int)x, cast(int)exposeEv.y, cast(int)exposeEv.width, cast(int)exposeEv.height);
				// Have a PaintQueue.Compress method that merges
				// all invalidated rects that touch or overlap.
				// In the if(!XPending(..)) above, just loop over all the
				// rects in the PaintQueue, painting them.
				auto exposeEv = ev.xexpose;
				if(exposeEv.count != -2) {
					c.repaint(exposeEv.x, exposeEv.y, exposeEv.width, exposeEv.height);
					break;
				}
				//printf("repainting x=%d, y=%d, width=%d, height=%d\n",
				//	exposeEv.x, exposeEv.y, exposeEv.width, exposeEv.height);

				auto surfaceWin = cairo_xlib_surface_create(
					evDisplay, evWindow,
					XDefaultVisual(evDisplay, XDefaultScreen(evDisplay)),
					cast(int)c.width, cast(int)c.height);
				// TODO: ^ should be contentWidth/height or got from evWindow
				auto crWin = cairo_create(surfaceWin);
				cairo_surface_destroy(surfaceWin);

				auto surfaceBuff = cairo_surface_create_similar(surfaceWin, CAIRO_CONTENT_COLOR, exposeEv.width, exposeEv.height);
				// TODO: use cairo_translate instead, I guess, as
				// I had to change the Windows backend to it...
				cairo_surface_set_device_offset(surfaceBuff, -exposeEv.x-c._borderSize.left, -exposeEv.y-c._borderSize.top);
				auto crBuff = cairo_create(surfaceBuff);
				cairo_surface_destroy(surfaceBuff);

				cairo_set_source_rgb(crBuff, w.content.backColor.R/255.0, w.content.backColor.G/255.0, w.content.backColor.B/255.0);
				cairo_paint(crBuff);

				cairo_set_source_rgb(crBuff, 0, 0, 0);
				cairo_set_line_width(crBuff, 1.0);

				auto g = new Graphics(crBuff);
				scope args = new PaintingEventArgs(g);
				c.painting(args);
				delete g;

				cairo_surface_set_device_offset(surfaceBuff, -exposeEv.x, -exposeEv.y);
				cairo_set_source_surface(crWin, surfaceBuff, 0, 0);
				cairo_rectangle(crWin, exposeEv.x, exposeEv.y, exposeEv.width, exposeEv.height);
				cairo_fill(crWin);

				cairo_destroy(crBuff);
				cairo_destroy(crWin);
				break;
			case PropertyNotify:
				auto propertyEv = ev.xproperty;
				if(propertyEv.atom == XA._NET_FRAME_EXTENTS &&
					propertyEv.state != PropertyDelete)
					c.backend_nativeToBorderSize();
				break;
			case ConfigureNotify:
				auto configureEv = ev.xconfigure;
				c.repaint();
				c.backend_nativeToLocationSize();
				break;
			case SelectionRequest:
				auto selReqEv = ev.xselectionrequest;
				XEvent fullEv;
				auto selEv = &fullEv.xselection;
				selEv.type = SelectionNotify;
				selEv.requestor = selReqEv.requestor;
				selEv.selection = selReqEv.selection;
				selEv.target = selReqEv.target;
				if(selReqEv.property != None)
					selEv.property = selReqEv.property;
				else
					selEv.property = XA.DYNAMIN_SELECTION;
				selEv.time = selReqEv.time;
				Stdout.format("requestor: {}", selReqEv.requestor).newline;
				Stdout.format("target: {}", selReqEv.target).newline;
				ClipboardData* data; // change to array when supporting multiple
				if(selReqEv.selection == XA.CLIPBOARD)
					data = &Clipboard.data;
				else if(selReqEv.selection == XA.PRIMARY)
					data = &Selection.data;
				else {
					selEv.property = None;
					XSendEvent(display, selEv.requestor, false, 0, &fullEv);
					break;
				}
				if(selReqEv.target == XA.TARGETS) {
					XChangeProperty(display, selEv.requestor, selEv.property,
						selEv.target, 32, PropModeReplace, &data.target, 1);
					XSendEvent(display, selEv.requestor, false, 0, &fullEv);
					break;
				} else if(selReqEv.target != data.target) {
					selEv.property = None;
					XSendEvent(display, selEv.requestor, false, 0, &fullEv);
					break;
				}
				XChangeProperty(display, selEv.requestor, selEv.property,
					data.target, 8, PropModeReplace, data.data, data.length);
				XSendEvent(display, selEv.requestor, false, 0, &fullEv);
				break;
			case MappingNotify:
				XRefreshKeyboardMapping(&ev.xmapping);
				break;
			default:
				break;
			}
		}
	}
	void backend_invoke(void delegate() dg) {
		// TODO:
	}
	void backend_invokeNow(void delegate() dg) {
		// TODO:
	}

}
//}}}

//{{{ KeysymToKey()
Key KeysymToKey(int sym) {
	switch(sym) {
	case XK_parenright:
	case XK_0: return Key.D0;
	case XK_exclam:
	case XK_1: return Key.D1;
	case XK_at:
	case XK_2: return Key.D2;
	case XK_numbersign:
	case XK_3: return Key.D3;
	case XK_dollar:
	case XK_4: return Key.D4;
	case XK_percent:
	case XK_5: return Key.D5;
	case XK_asciicircum:
	case XK_6: return Key.D6;
	case XK_ampersand:
	case XK_7: return Key.D7;
	case XK_asterisk:
	case XK_8: return Key.D8;
	case XK_parenleft:
	case XK_9: return Key.D9;

	case XK_F1: return Key.F1;
	case XK_F2: return Key.F2;
	case XK_F3: return Key.F3;
	case XK_F4: return Key.F4;
	case XK_F5: return Key.F5;
	case XK_F6: return Key.F6;
	case XK_F7: return Key.F7;
	case XK_F8: return Key.F8;
	case XK_F9: return Key.F9;
	case XK_F10: return Key.F10;
	case XK_F11: return Key.F11;
	case XK_F12: return Key.F12;

	case XK_Escape: return Key.Escape;
	case XK_Tab: return Key.Tab;
	case XK_BackSpace: return Key.Backspace;
	case XK_Return: return Key.Enter;
	case XK_KP_Enter: return Key.Enter;
	case XK_space: return Key.Space;

	case XK_KP_Left:
	case XK_Left: return Key.Left;
	case XK_KP_Right:
	case XK_Right: return Key.Right;
	case XK_KP_Up:
	case XK_Up: return Key.Up;
	case XK_KP_Down:
	case XK_Down: return Key.Down;

	case XK_KP_Insert:
	case XK_Insert: return Key.Insert;
	case XK_KP_Delete:
	case XK_Delete: return Key.Delete;
	case XK_KP_Home:
	case XK_Home: return Key.Home;
	case XK_KP_End:
	case XK_End: return Key.End;
	case XK_KP_Prior:
	case XK_Prior: return Key.PageUp;
	case XK_KP_Next:
	case XK_Next: return Key.PageDown;

	case XK_Print:
	case XK_Sys_Req: return Key.PrintScreen;
	case XK_Pause:
	case XK_Break: return Key.Pause;

	case XK_Caps_Lock: return Key.CapsLock;
	case XK_Num_Lock: return Key.NumLock;
	case XK_Scroll_Lock: return Key.ScrollLock;

	case XK_KP_0: return Key.NumPad0;
	case XK_KP_1: return Key.NumPad1;
	case XK_KP_2: return Key.NumPad2;
	case XK_KP_3: return Key.NumPad3;
	case XK_KP_4: return Key.NumPad4;
	case XK_KP_5: return Key.NumPad5;
	case XK_KP_6: return Key.NumPad6;
	case XK_KP_7: return Key.NumPad7;
	case XK_KP_8: return Key.NumPad8;
	case XK_KP_9: return Key.NumPad9;
	case XK_KP_Divide: return Key.NumPadDivide;
	case XK_KP_Multiply: return Key.NumPadMultiply;
	case XK_KP_Subtract: return Key.NumPadSubtract;
	case XK_KP_Add: return Key.NumPadAdd;
	case XK_KP_Decimal: return Key.NumPadDecimal;

	case XK_grave:
	case XK_asciitilde: return Key.Backquote;
	case XK_minus:
	case XK_underscore: return Key.Minus;
	case XK_equal:
	case XK_plus: return Key.Equals;
	case XK_bracketleft:
	case XK_braceleft: return Key.OpenBracket;
	case XK_bracketright:
	case XK_braceright: return Key.CloseBracket;
	case XK_backslash:
	case XK_bar: return Key.Backslash;
	case XK_semicolon:
	case XK_colon: return Key.Semicolon;
	case XK_apostrophe:
	case XK_quotedbl: return Key.Quote;
	case XK_comma:
	case XK_less: return Key.Comma;
	case XK_period:
	case XK_greater: return Key.Period;
	case XK_slash:
	case XK_question: return Key.Slash;

	//case XK_Menu: return Key.Menu;

	case XK_Shift_L:
	case XK_Shift_R: return Key.Shift;
	case XK_Control_L:
	case XK_Control_R: return Key.Control;
	case XK_Alt_L:
	case XK_Alt_R: return Key.Alt;

	//case XK_: return Key.;
	default:
		if(sym >= 0x41 && sym <= 0x5A) // Key.A - Key.Z
			return cast(Key)sym;
		if(sym >= 0x61 && sym <= 0x7A) // Key.A - Key.Z
			return cast(Key)(sym-32);
		return cast(Key)0;
	}
}
//}}}

public import tango.stdc.time;
template WindowBackend() {
	invariant {
		//if(_handle == 0)
		//	return;
		//XWindow root, parent;
		//XWindow* children;
		//uint numChildren;
		//XQueryTree(display, _handle,
		//	&root, &parent, &children, &numChildren);
		//XFree(children);
		//int x, y;
		//XWindow child;
		//XTranslateCoordinates(display, _handle, root, 0, 0, &x, &y, &child);
		//assert(_location.X == x-_borderSize.Left);
		//assert(_location.Y == y-_borderSize.Top);
		//XWindowAttributes attribs;
		//XGetWindowAttributes(display, _handle, &attribs);
	}
	XWindow _handle;
	bool mapped = false;
	bool backend_handleCreated() { return _handle > 0; }
	void backend_recreateHandle() {
		auto primaryScreenNum = XDefaultScreen(display);
		//XColor color;
		//color.red = 65535*backColor.R/255;
		//color.green = 65535*backColor.G/255;
		//color.blue = 65535*backColor.B/255;
		//if(XAllocColor(display, XDefaultColormap(display, primaryScreenNum), &color))
		//	printf("XAllocColor() failed\n");

		XSetWindowAttributes attribs;
		attribs.bit_gravity = NorthWestGravity;
		// TODO: should be backColor, and should change when backColor changes
		// call XSetWindowBackground() for this
		attribs.background_pixel = XWhitePixel(display, primaryScreenNum);
		attribs.event_mask =
			KeyPressMask |
			KeyReleaseMask |
			ButtonPressMask |
			ButtonReleaseMask |
			EnterWindowMask |
			LeaveWindowMask |
			PointerMotionMask |
			ButtonMotionMask |
			ExposureMask |
			FocusChangeMask |
			StructureNotifyMask |
			PropertyChangeMask;
		XWindow newHandle = XCreateWindow(
			display, root,
			cast(int)x, cast(int)y,
			backend_insideWidth, backend_insideHeight,
			0, CopyFromParent, InputOutput, null,
			CWBitGravity | CWBackPixel | CWEventMask, &attribs);

		setControl(newHandle, this);
		auto protocols = [XA.WM_DELETE_WINDOW];
		XSetWMProtocols(display, newHandle, protocols.ptr, protocols.length);
		if(handleCreated) {
			XDestroyWindow(display, _handle);
			XSync(display, false);
		}
		_handle = newHandle;
		text = _text; // move the text over to the new window
		visible = _visible;
		borderStyle = _borderStyle;
		//backend_nativeToBorderSize();
	}
	Graphics backend_quickCreateGraphics() {
		auto surface = cairo_xlib_surface_create(display, _handle,
			XDefaultVisual(display, XDefaultScreen(display)),
			cast(int)width, cast(int)height);
		auto cr = cairo_create(surface);
		cairo_surface_destroy(surface);
		cairo_translate(cr, -borderSize.left, -borderSize.top);
		auto g = new Graphics(cr);
		cairo_destroy(cr);
		return g;
	}
	void backend_visible(bool b) {
		if(b)
			// if not created, create the handle by calling handle()
			XMapWindow(display, handle);
		else
			XUnmapWindow(display, _handle);
	}
	void backend_borderStyle(WindowBorderStyle border) {
		backend_update_NET_WM_WINDOW_TYPE();
		backend_update_MOTIF_WM_HINTS();
		backend_nativeToBorderSize();
	}
	void backend_setCurrentCursor(Cursor cur) {
		XDefineCursor(display, _handle, cur.handle);
	}

	static _InvalidRect[] invalidRects;
	void backend_repaint(Rect rect) {
		invalidRects.length = invalidRects.length+1;
		invalidRects[$-1].window = _handle;
		invalidRects[$-1].x = cast(int)(rect.x-borderSize.left);
		invalidRects[$-1].y = cast(int)(rect.y-borderSize.top);
		invalidRects[$-1].width = cast(int)rect.width+1;
		invalidRects[$-1].height = cast(int)rect.height+1;
		//printf("invalidating x=%.1f, y=%.1f, width=%.1f, height=%.1f\n", rect.X, rect.Y, rect.width, rect.height);
	}
	void backend_resizable(bool b) {
		backend_updateWM_NORMAL_HINTS();
	}
	void backend_contentMinSizeChanged() {
		backend_updateWM_NORMAL_HINTS();
	}
	void backend_contentMaxSizeChanged() {
		backend_updateWM_NORMAL_HINTS();
	}
	void backend_location(Point pt) {
		backend_updateWM_NORMAL_HINTS();
		backend_locationSizeToNative();
	}
	void backend_size(Size size) {
		backend_updateWM_NORMAL_HINTS();
		backend_locationSizeToNative();
	}
	void backend_text(string str) {
		//auto tmp = str.ToCharPtr();
		//XTextProperty strProperty;
		//if(!XStringListToTextProperty(&tmp, 1, &strProperty))
			//printf("XStringListToTextProperty() failed - out of memory\n");
		//XSetWMName(display, _handle, &strProperty);
		XChangeProperty(display, _handle, XA._NET_WM_NAME, XA.UTF8_STRING, 8, PropModeReplace, str.ptr, str.length);
	}
	//{{{ backend specific
	void backend_updateWM_NORMAL_HINTS() {
		XSizeHints* sizeHints = XAllocSizeHints();
		scope(exit) XFree(sizeHints);
		sizeHints.flags = PMinSize | PMaxSize | PPosition | PSize;
		if(resizable) {
			sizeHints.min_width  = cast(int)content.minWidth;
			sizeHints.min_height = cast(int)content.minHeight;
			sizeHints.max_width  =
				content.maxWidth > 0 ? cast(int)content.maxWidth : 30_000;
			sizeHints.max_height =
				content.maxHeight > 0 ? cast(int)content.maxHeight : 30_000;
		} else {
			sizeHints.min_width  = sizeHints.max_width  = backend_insideWidth;
			sizeHints.min_height = sizeHints.max_height = backend_insideHeight;
		}
		sizeHints.x = cast(int)x;
		sizeHints.y = cast(int)y;
		sizeHints.width = backend_insideWidth;
		sizeHints.height = backend_insideHeight;
		XSetWMNormalHints(display, _handle, sizeHints);
	}
	void backend_update_MOTIF_WM_HINTS() {
		int[4] mwmHints;
		mwmHints[0] = 1 << 1;  // flags
		mwmHints[2] = borderStyle == WindowBorderStyle.None ? 0 : 1;  // decor
		XChangeProperty(display, _handle,
			XA._MOTIF_WM_HINTS, XA._MOTIF_WM_HINTS, 32, PropModeReplace, mwmHints.ptr, mwmHints.length);
	}
	void backend_update_NET_WM_WINDOW_TYPE() {
		XAtom[] atoms;
		// with Metacity, the decor is not being repainted from normal>dialog
		// because they are the same size
		if(borderStyle == WindowBorderStyle.Dialog)
			atoms = [XA._NET_WM_WINDOW_TYPE_DIALOG];
		else if(borderStyle == WindowBorderStyle.Tool)
			atoms = [XA._NET_WM_WINDOW_TYPE_UTILITY];
		else
			atoms = [XA._NET_WM_WINDOW_TYPE_NORMAL];
		XChangeProperty(display, _handle,
			XA._NET_WM_WINDOW_TYPE, XA.ATOM, 32, PropModeReplace, atoms.ptr, atoms.length);
	}
	// returns what width the x window should be...not including borders
	int backend_insideWidth() {
		return cast(int)(size.width-borderSize.left-borderSize.right);
	}
	// returns what height the x window should be...not including borders
	int backend_insideHeight() {
		return cast(int)(size.height-borderSize.top-borderSize.bottom);
	}
	// applies the currently set location and size to the native X Window
	void backend_locationSizeToNative() {
		Point pt = _location;
		if(!isTopLevelReparented(_handle)) {
			pt.x = pt.x + _borderSize.left;
			pt.y = pt.y + _borderSize.top;
		}
		XMoveResizeWindow(display, _handle, cast(int)pt.x, cast(int)pt.y,
			backend_insideWidth, backend_insideHeight);
		// XMoveWindow:
		//   Under Metacity, sets the location of the WM's frame.
		//   Under Compiz, sets the location of the window.
		// XResizeWindow:
		//   Under Metacity and Compiz, sets the size of the window not
		//   including the WM's frame.
	}
	// sets location and size based on where the native X Window is
	void backend_nativeToLocationSize() {
		XWindow root, parent;
		XWindow* children;
		uint numChildren;
		XQueryTree(display, _handle,
			&root, &parent, &children, &numChildren);
		XFree(children);

		int x, y;
		XWindow child;
		XTranslateCoordinates(display, _handle, root, 0, 0, &x, &y, &child);
		_location.x = x - _borderSize.left;
		_location.y = y - _borderSize.top;
		scope args = new EventArgs;
		moved(args);
		XWindowAttributes attribs;
		XGetWindowAttributes(display, _handle, &attribs);
		_size.width = attribs.width+_borderSize.left+_borderSize.right;
		_size.height = attribs.height+_borderSize.top+_borderSize.bottom;
		resized(args);

		//content._location = Point(_borderSize.Left, _borderSize.Top);
		//content._size = Size(attribs.width, attribs.height);
		//Stdout.format("location updated to {}", _location).newline;
		//Stdout.format("size updated to {}", _size).newline;
	}
	void backend_nativeToBorderSize() {
		_borderSize = backend_getBorderSize();
		//Stdout("borderSize updated to ", _borderSize).newline;
		backend_nativeToLocationSize();
	}
	BorderSize backend_getBorderSize() {
		if(!isWMPropertySupported(XA._NET_FRAME_EXTENTS) ||
			borderStyle == WindowBorderStyle.None)
			return BorderSize();
		// create handle if necessary
		auto reqHandle = handle;
		bool requested = false;

		//{{{ requestExtents()
		void requestExtents() {
			if(isWMPropertySupported(XA._NET_REQUEST_FRAME_EXTENTS)) {
				XEvent ev;
				ev.xclient.type = ClientMessage;
				ev.xclient.window = handle;
				ev.xclient.message_type = XA._NET_REQUEST_FRAME_EXTENTS;
				ev.xclient.format = 8;
				XSendEvent(display, root, false,
					SubstructureNotifyMask | SubstructureRedirectMask, &ev);
			} else { // compiz and beryl do not yet support requesting
				XSetWindowAttributes attribs;
				reqHandle = XCreateWindow(display,
					root, 0, 0, 1, 1,
					0, CopyFromParent, InputOnly, null, 0, &attribs);

				XWMHints* hints = XAllocWMHints();
				scope(exit) XFree(hints);
				hints.flags = InputHint;
				hints.input = false;
				XSetWMHints(display, reqHandle, hints);

				auto mainHandle = _handle;
				_handle = reqHandle;
				backend_updateWM_NORMAL_HINTS();
				backend_update_NET_WM_WINDOW_TYPE();
				backend_update_MOTIF_WM_HINTS();
				backend_visible = true;
				backend_visible = false;
				_handle = mainHandle;
			}
			requested = true;
		}
		//}}}

		if(!mapped)
			requestExtents();
		int* extents;
		while(true) {
			XSync(display, false);
			extents = cast(int*)getXWindowProperty(display, reqHandle,
				XA._NET_FRAME_EXTENTS);
			if(extents !is null)
				break;
			if(!requested)
				requestExtents();
		}
		scope(exit) XFree(extents);
		if(reqHandle != _handle)
			XDestroyWindow(display, reqHandle);
		return BorderSize(extents[0], extents[2], extents[1], extents[3]);
	}
	//}}}
}

