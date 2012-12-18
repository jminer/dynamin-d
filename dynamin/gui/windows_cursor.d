
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.gui.windows_cursor;

public import dynamin.c.windows;
public import tango.io.Stdout;
public import dynamin.gui.control;

// TODO: use import("AeroMouseDrag.png"), import("MouseDrag.png"), etc.
// to embed png into executable. Then, use lodepng to decode it and use
// CreateIconIndirect to create a cusor from them if possible.

template CursorBackend() {
	HCURSOR _handle;
	this(HCURSOR h) {
		_handle = h;
	}
	public HCURSOR handle() { return _handle; }
static:
	Cursor backend_getCursor(int curRes) {
		HCURSOR hcur = LoadImage(null, MAKEINTRESOURCE(curRes),
				IMAGE_CURSOR,  0, 0, LR_SHARED | LR_DEFAULTSIZE);
		if(hcur is null)
			Stdout.format("LoadImage() failed loading cursor {}", curRes).newline;
		return new Cursor(hcur);
	}
	Cursor backend_getCursor(const(wchar)[] name) {
		HCURSOR hcur = LoadImage(GetModuleHandle(null), name.ptr,
			IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE);
		if(hcur is null)
			Stdout.format("LoadImage() failed loading cursor {}", name).newline;
		return new Cursor(hcur);
	}
	Cursor backend_None() {
		return new Cursor(cast(HCURSOR)null);
	}
	Cursor backend_Arrow() {
		return backend_getCursor(OCR_NORMAL);
	}
	Cursor backend_WaitArrow() {
		return backend_getCursor(OCR_APPSTARTING);
	}
	Cursor backend_Wait() {
		return backend_getCursor(OCR_WAIT);
	}
	Cursor backend_Text() {
		return backend_getCursor(OCR_IBEAM);
	}
	Cursor backend_Hand() {
		return backend_getCursor(OCR_HAND); // Windows 98 & newer
	}
	Cursor backend_Move() {
		return backend_getCursor(OCR_SIZEALL);
	}
	Cursor backend_ResizeHoriz() {
		return backend_getCursor(OCR_SIZEWE);
	}
	Cursor backend_ResizeVert() {
		return backend_getCursor(OCR_SIZENS);
	}
	Cursor backend_ResizeBackslash() {
		return backend_getCursor(OCR_SIZENWSE);
	}
	Cursor backend_ResizeSlash() {
		return backend_getCursor(OCR_SIZENESW);
	}
	Cursor backend_Drag() {
		if(checkWindowsVersion(WindowsVersion.WindowsVista))
			return backend_getCursor("rAeroDragCur");
		else
			return backend_getCursor("rDragCur");
	}
	Cursor backend_InvalidDrag() {
		return backend_getCursor(OCR_NO);
	}
	Cursor backend_ReversedArrow() {
		if(checkWindowsVersion(WindowsVersion.WindowsVista))
			return backend_getCursor("rAeroReversedArrowCur");
		else
			return backend_getCursor("rReversedArrowCur");
	}
	Cursor backend_Crosshair() {
		return backend_getCursor(OCR_CROSS);
	}
}

