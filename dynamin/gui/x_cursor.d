// Written in the D programming language
// www.digitalmars.com/d/

module dynamin.gui.x_cursor;

public import tango.io.Stdout;
public import dynamin.gui.control;

template CursorBackend() {
	XCursor _handle;
	this(XCursor h) {
		_handle = h;
	}
	public XCursor handle() { return _handle; }
static:
	Cursor getCursor(uint shape) {
		return new Cursor(XCreateFontCursor(display, shape));
	}
	Cursor backend_None() {
		auto p = XCreateBitmapFromData(display, msgWin,
			"\0\0\0\0\0\0\0\0", 1, 1);
		XColor color;
		return new Cursor(XCreatePixmapCursor(display, p, p, &color, &color,
			1, 1));
	}
	Cursor backend_Arrow() {
		return getCursor(XC_left_ptr);
	}
	Cursor backend_WaitArrow() {
		return getCursor(XC_watch);
	}
	Cursor backend_Wait() {
		return getCursor(XC_watch);
	}
	Cursor backend_Text() {
		return getCursor(XC_xterm);
	}
	Cursor backend_Hand() {
		return getCursor(XC_hand2);
	}
	Cursor backend_Move() {
		return getCursor(XC_fleur);
	}
	Cursor backend_ResizeHoriz() {
		return getCursor(XC_left_side);
	}
	Cursor backend_ResizeVert() {
		return getCursor(XC_top_side);
	}
	Cursor backend_ResizeBackslash() {
		return getCursor(XC_top_left_corner);
	}
	Cursor backend_ResizeSlash() {
		return getCursor(XC_top_right_corner);
	}
	Cursor backend_Drag() {
		return getCursor(XC_fleur); // not the best
	}
	Cursor backend_InvalidDrag() {
		return getCursor(XC_fleur); // bad, but what Linux does
	}
	Cursor backend_ReversedArrow() {
		return getCursor(XC_right_ptr);
	}
	Cursor backend_Crosshair() {
		return getCursor(XC_crosshair);
	}
}

