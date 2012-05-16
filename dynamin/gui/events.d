
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.gui.events;

import dynamin.all_core;
import dynamin.all_painting;
import dynamin.all_gui;
import dynamin.gui.control;
import dynamin.gui.container;

///
enum MouseButton {
	None,     ///
	Left,     ///
	Right,    ///
	Middle,   ///
	XButton1, ///
	XButton2  ///
}

///
class PaintingEventArgs : EventArgs {
	Graphics g;
	//NativeGraphics ng;
public:
	///
	this(Graphics g) {
		this.g = g;
	}
	///
	Graphics graphics() { return g; }
}

///
class MouseEventArgs : StopEventArgs {
	Point _location;
	MouseButton _button;
public:
	///
	this(real x, real y, MouseButton b) {
		_location = Point(x, y);
		_button = b;
	}
	///
	Point location() { return _location; }
	///
	void location(Point pt) { _location = pt; }
	///
	real x() { return _location.x; }
	///
	real y() { return _location.y; }
	///
	MouseButton button() { return _button; }
	string toString() {
		return format("MouseEventArgs [x={}, y={}, button={}]",
			x, y, _button);
	}
}
///
class MouseTurnedEventArgs : StopEventArgs {
	double _scrollAmount;
	bool _scrollScreen;
public:
	this(double scrollAmount, bool scrollScreen) {
		_scrollAmount = scrollAmount;
		_scrollScreen = scrollScreen;
	}
	/**
	 * The amount that a control should scroll in response to this event.
	 * In a text control, this is the number of lines to scroll.
	 * This will be negative if the control should scroll upward and positive
	 * if the control should scroll downward. If the amount to be scrolled
	 * is more than what is visible on screen, only what is on screen
	 * should be scrolled.
	 *
	 * All users of this class should check scrollScreen to see whether to
	 * scroll one screen or to scroll the amount by this.
	 */
	double scrollAmount() { return _scrollAmount; }
	/**
	 * On some systems, such as Windows, there is the option of setting
	 * the mouse wheel to scroll a screen at a time, the same as the page up
	 * and page down keys do. If this option is turned on, scrollScreen will
	 * return true and scrollAmount will return ±3. If the option is turned off,
	 * scrollScreen will return false.
	 */
	bool scrollScreen() {
		return _scrollScreen;
	}
	string toString() {
		return format("MouseTurnedEventArgs [scrollAmount={}, scrollScreen={}]",
			_scrollAmount, _scrollScreen);
	}
}
///
class KeyEventArgs : StopEventArgs {
	Key _key;
	bool _repeat;
	bool _shiftDown, _controlDown, _altDown;
public:
	this(Key key, bool repeat, bool shift, bool ctrl, bool alt) {
		_key = key;
		_repeat = repeat;
		_shiftDown = shift;
		_controlDown = ctrl;
		_altDown = alt;
	}
	/**
	 * Returns: the key that was typed.
	 */
	Key key() { return _key; }
	/**
	 * Gets whether this key event was generated by the user holding
	 * down the key.
	 * Returns: true if the key was already down before this event, false
	 *          if the key was just pressed
	 */
	bool repeat() { return _repeat; }
	// Returns true if the shift key is currently down and false otherwise.
	bool shiftDown() { return _shiftDown; }
	// Returns true if the control key is currently down and false otherwise.
	bool controlDown() { return _controlDown; }
	// Returns true if the alt key is currently down and false otherwise.
	bool altDown() { return _altDown; }
	string toString() {
		return format("KeyEventArgs [key={}, repeat={}]", _key, _repeat);
	}
}
///
class KeyTypedEventArgs : StopEventArgs {
	dchar _ch;
	bool _repeat;
public:
	this(dchar c, bool repeat) {
		_ch = c;
		_repeat = repeat;
	}
	/**
	 * Gets whether this key event was generated from the user holding
	 * down the key.
	 * Returns: true if the key was already down before this event, false
	 *          if the key was just pressed
	 */
	bool repeat() { return _repeat; }
	/**
	 * Gets the character that was typed by the user. Many keys on the
	 * keyboard will not generate a KeyTyped event, as they do not represent
	 * characters. Shift, Insert, Home, F7, and Caps Lock are just some of
	 * the keys that do not represent characters.
	 */
	dchar character() { return _ch; }
}

///
class HierarchyEventArgs : EventArgs {
	int _levels = 0;
	Control _control;
public:
	this(Control c) {
		_control = c;
	}
	/**
	 * An immediate child would be a level of 0.
	 */
	int levels() { return _levels; }
	/// ditto
	void levels(int l) { _levels = l; }
	/**
	 *
	 */
	Control descendant() { return _control; }
	/**
	 *
	 */
	Container ancestor() { return cast(Container)_control; }
}

