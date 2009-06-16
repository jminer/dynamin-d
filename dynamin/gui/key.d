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

module dynamin.gui.key;

import dynamin.core.string;

/**
 * No Menu key is included because Shift+F10 is used instead.
 * Note: Windows does not send KeyDown events for PrintScreen, only KeyUp.
 */
enum Key {
	None,
	Escape,
	Tab,
	Backspace,
	Enter,
	Space,

	Left,
	Right,
	Up,
	Down,

	Insert,
	Delete,
	Home,
	End,
	PageUp,
	PageDown,

	PrintScreen,
	Pause,

	CapsLock,
	NumLock,
	ScrollLock,

	NumPad0,
	NumPad1,
	NumPad2,
	NumPad3,
	NumPad4,
	NumPad5,
	NumPad6,
	NumPad7,
	NumPad8,
	NumPad9,
	NumPadDivide,
	NumPadMultiply,
	NumPadSubtract,
	NumPadAdd,
	NumPadDecimal, // TODO: NumPadPoint?

	Backquote,
	Minus,
	Equals,
	OpenBracket,
	CloseBracket,
	Backslash,
	Semicolon,
	Quote,
	Comma,
	Period,
	Slash,

	/// Windows sends these messages when the Menu key is pressed and released:
	/// Menu pressed, Menu released, Shift pressed, F10 pressed, F10 released, Shift released
	/// So if any program responds to either Menu or Shift+F10, it will work right.
	Menu, // right of spacebar, between WinKey and Ctrl

	// digits
	D0 = 0x30, D1, D2, D3, D4, D5, D6, D7, D8, D9 = 0x39,
	A = 0x41, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z = 0x5A,
	F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12,

	VolumeUp,
	VolumeDown,
	VolumeMute,

	PlayPause,
	Stop,
	NextTrack,
	PrevTrack,

	Shift   = 0x10000,
	Control = 0x20000,
	Alt     = 0x40000
}

/*string KeyToString(Key key) {
	static string[] table = [
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
	"Escape", "Tab", "Backspace", "Enter", "Space",
	"Left Arrow", "Right Arrow", "Up Arrow", "Down Arrow",
	"Insert", "Delete", "Home", "End", "Page Up", "Page Down",
	"Print Screen", "Pause",
	"Caps Lock", "Num Lock", "Scroll Lock",
	"NumPad0", "NumPad1", "NumPad2", "NumPad3", "NumPad4",
	"NumPad5", "NumPad6", "NumPad7", "NumPad8", "NumPad9",
	"NumPad/", "NumPad*", "NumPad-", "NumPad+", "NumPad.",
	"`", "-", "=", "[", "]", "\\", ";", "'", ",", ".", "/",
	"Shift", "Ctrl", "Alt"
	];
	return table[key];
}
Key toKey(string str) {
	foreach(i, s; table)
		if(s == str)
			return i;
	return
}
unittest {
	assert(keyToString(Key.D0) == "0");
	assert(keyToString(Key.A) == "A");
	assert(keyToString(Key.N) == "N");
	assert(keyToString(Key.F1) == "F1");
	assert(keyToString(Key.Escape) == "Escape");
	assert(keyToString(Key.Left) == "Left");
	assert(keyToString(Key.Up) == "Up");
	assert(keyToString(Key.Insert) == "Insert");
	assert(keyToString(Key.PrintScreen) == "Print Screen");
	assert(keyToString(Key.Pause) == "Pause");
	assert(keyToString(Key.CapsLock) == "CapsLock");
	assert(keyToString(Key.NumPad0) == "NumPad0");
	assert(keyToString(Key.NumPad5) == "NumPad5");
	assert(keyToString(Key.NumPadDivide) == "NumPad/");
	assert(keyToString(Key.Backquote) == "`");
	assert(keyToString(Key.Control) == "Ctrl");
}*/

