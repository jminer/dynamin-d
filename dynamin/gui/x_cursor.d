// Written in the D programming language
// www.digitalmars.com/d/

module dynamin.gui.x_cursor;

public import tango.io.Stdout;
public import dynamin.gui.control;

template CursorBackend() {
static:
	void backend_SetCurrent(Control c, Cursor cur) {
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

	Cursor backend_None() {
		return null;
	}
	Cursor backend_Arrow() {
		return null;
	}
	Cursor backend_WaitArrow() {
		return null;
	}
	Cursor backend_Wait() {
		return null;
	}
	Cursor backend_Text() {
		return null;
	}
	Cursor backend_Hand() {
		return null;
	}
	Cursor backend_Move() {
		return null;
	}
	Cursor backend_ResizeHoriz() {
		return null;
	}
	Cursor backend_ResizeVert() {
		return null;
	}
	Cursor backend_ResizeBackslash() {
		return null;
	}
	Cursor backend_ResizeSlash() {
		return null;
	}
	Cursor backend_Drag() {
		return null;
	}
	Cursor backend_InvalidDrag() {
		return null;
	}
	Cursor backend_ReversedArrow() {
		return null;
	}
	Cursor backend_Crosshair() {
		return null;
	}
}

