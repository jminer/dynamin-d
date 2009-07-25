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
	Cursor backend_getCursor(wchar[] name) {
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
			return backend_getCursor("AeroDragCur");
		else
			return backend_getCursor("DragCur");
	}
	Cursor backend_InvalidDrag() {
		return backend_getCursor(OCR_NO);
	}
	Cursor backend_ReversedArrow() {
		if(checkWindowsVersion(WindowsVersion.WindowsVista))
			return backend_getCursor("AeroReversedArrowCur");
		else
			return backend_getCursor("ReversedArrowCur");
	}
	Cursor backend_Crosshair() {
		return backend_getCursor(OCR_CROSS);
	}
}

