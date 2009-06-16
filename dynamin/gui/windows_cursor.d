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
	bool isBuiltin = false;
	this(HCURSOR h) {
		_handle = h;
		isBuiltin = true;
	}
static:
	void backend_SetCurrent(Control c, Cursor cur) {
		assert(cur.isBuiltin); // TODO: allow custom cursors
		SetCursor(cur._handle);
	}
	Cursor none = null;
	Cursor arrow = null;
	Cursor waitArrow = null;
	Cursor wait = null;
	Cursor text = null;
	Cursor hand = null;
	Cursor move = null;
	Cursor resizeHoriz = null;
	Cursor resizeVert = null;
	Cursor resizeBackslash = null;
	Cursor resizeSlash = null;
	Cursor drag = null; // from resource
	Cursor invalidDrag = null;
	Cursor reversedArrow = null; // from resource
	Cursor crosshair = null;

	Cursor backend_maybeLoad(Cursor* cache, int curRes) {
		if(*cache is null) {
			HCURSOR hcur = LoadImage(null, MAKEINTRESOURCE(curRes),
					IMAGE_CURSOR,  0, 0, LR_SHARED | LR_DEFAULTSIZE);
			if(hcur is null)
				Stdout.format("LoadImage() failed loading cursor {}", curRes).newline;
			else
				*cache = new Cursor(hcur);
		}
		return *cache;
	}
	Cursor backend_maybeLoad(Cursor* cache, wchar[] name) {
		if(*cache is null) {
			HCURSOR hcur = LoadImage(GetModuleHandle(null), name.ptr,
				IMAGE_CURSOR, 0, 0, LR_DEFAULTSIZE);
			if(hcur is null)
				Stdout.format("LoadImage() failed loading cursor {}", name).newline;
			else
				*cache = new Cursor(hcur);
		}
		return *cache;
	}
	Cursor backend_None() {
		if(none is null)
			none = new Cursor(cast(HCURSOR)null);
		return none;
	}
	Cursor backend_Arrow() {
		return backend_maybeLoad(&arrow, OCR_NORMAL);
	}
	Cursor backend_WaitArrow() {
		return backend_maybeLoad(&waitArrow, OCR_APPSTARTING);
	}
	Cursor backend_Wait() {
		return backend_maybeLoad(&wait, OCR_WAIT);
	}
	Cursor backend_Text() {
		return backend_maybeLoad(&text, OCR_IBEAM);
	}
	Cursor backend_Hand() {
		return backend_maybeLoad(&hand, OCR_HAND); // Windows 98 & newer
	}
	Cursor backend_Move() {
		return backend_maybeLoad(&move, OCR_SIZEALL);
	}
	Cursor backend_ResizeHoriz() {
		return backend_maybeLoad(&resizeHoriz, OCR_SIZEWE);
	}
	Cursor backend_ResizeVert() {
		return backend_maybeLoad(&resizeVert, OCR_SIZENS);
	}
	Cursor backend_ResizeBackslash() {
		return backend_maybeLoad(&resizeBackslash, OCR_SIZENWSE);
	}
	Cursor backend_ResizeSlash() {
		return backend_maybeLoad(&resizeSlash, OCR_SIZENESW);
	}
	Cursor backend_Drag() {
		if(checkWindowsVersion(WindowsVersion.WindowsVista))
			return backend_maybeLoad(&drag, "AeroDragCur");
		else
			return backend_maybeLoad(&drag, "DragCur");
	}
	Cursor backend_InvalidDrag() {
		return backend_maybeLoad(&invalidDrag, OCR_NO);
	}
	Cursor backend_ReversedArrow() {
		if(checkWindowsVersion(WindowsVersion.WindowsVista))
			return backend_maybeLoad(&drag, "AeroReversedArrowCur");
		else
			return backend_maybeLoad(&drag, "ReversedArrowCur");
	}
	Cursor backend_Crosshair() {
		return backend_maybeLoad(&crosshair, OCR_CROSS);
	}
}

