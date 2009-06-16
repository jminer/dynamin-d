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

module dynamin.gui.cursor;

import tango.io.Stdout;
import dynamin.gui_backend;

///
class Cursor {
private:
	mixin CursorBackend;
public:
static:
	void setCurrent(Control c, Cursor cur) {
		backend_SetCurrent(c, cur);
	}
	/**
	 * Gets a blank cursor used for an activity, such as typing, with which
	 * the cursor may interfere.
	 */
	Cursor None() {
		return backend_None;
	}
	/**
	 * Gets the cursor used normally.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_arrow_cursor.png)
	 */
	Cursor Arrow() {
		return backend_Arrow;
	}
	/**
	 * Gets the cursor used when the computer is accomplishing some
	 * task that does not prevent the user from continuing work.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_wait_arrow_cursor.png)
	 */
	Cursor WaitArrow() {
		return backend_WaitArrow;
	}
	/**
	 * Gets the cursor used when the computer is accomplishing some
	 * task that prevents the user from continuing work.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_wait_cursor.png)
	 */
	Cursor Wait() {
		return backend_Wait;
	}
	/**
	 * Gets the cursor used when the mouse is over selectable text.
	 * In text that supports dragging, this should not be used when the
	 * mouse is over already selected text, as the text is not then
	 * selectable, but draggable.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_text_cursor.png)
	 */
	Cursor Text() {
		return backend_Text;
	}
	/**
	 * Gets the cursor used when the mouse is over a link.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_hand_cursor.png)
	 */
	Cursor Hand() {
		return backend_Hand;
	}
	/**
	 * Gets the cursor used when moving something.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_move_cursor.png)
	 */
	Cursor Move() {
		return backend_Move;
	}
	/**
	 * Gets the cursor used when resizing the left or right
	 * sides of something.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_resize_horiz_cursor.png)
	 */
	Cursor ResizeHoriz() {
		return backend_ResizeHoriz;
	}
	/**
	 * Gets the cursor used when resizing the top or bottom
	 * sides of something.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_resize_vert_cursor.png)
	 */
	Cursor ResizeVert() {
		return backend_ResizeVert;
	}
	/**
	 * Gets the cursor used when resizing the top-left or bottom-right
	 * corners of something.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_resize_backslash_cursor.png)
	 */
	Cursor ResizeBackslash() {
		return backend_ResizeBackslash;
	}
	/**
	 * Gets the cursor used when resizing the bottom-left or top-right
	 * corners of something.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_resize_slash_cursor.png)
	 */
	Cursor ResizeSlash() {
		return backend_ResizeSlash;
	}
	/**
	 * Gets the cursor used when the mouse is over something that
	 * will accept what has been dragged.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_drag_cursor.png)
	 */
	Cursor Drag() {
		return backend_Drag;
	}
	/**
	 * Gets the cursor used when the mouse is over something that
	 * will not accept what has been dragged.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_invalid_drag_cursor.png)
	 */
	Cursor InvalidDrag() {
		return backend_InvalidDrag;
	}
	/**
	 * Gets the cursor used when the mouse is over a gutter that
	 * will select a line of text when clicked.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_reversed_arrow_cursor.png)
	 */
	Cursor ReversedArrow() {
		return backend_ReversedArrow;
	}
	/**
	 * Gets the cursor that is sometimes used for selecting.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_crosshair_cursor.png)
	 */
	Cursor Crosshair() {
		return backend_Crosshair;
	}
}

