
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.gui.cursor;

import tango.io.Stdout;
import dynamin.gui_backend;

///
final class Cursor {
private:
	mixin CursorBackend;
static:
	Cursor _none = null;
	Cursor _arrow = null;
	Cursor _waitArrow = null;
	Cursor _wait = null;
	Cursor _text = null;
	Cursor _hand = null;
	Cursor _move = null;
	Cursor _resizeHoriz = null;
	Cursor _resizeVert = null;
	Cursor _resizeBackslash = null;
	Cursor _resizeSlash = null;
	Cursor _drag = null;
	Cursor _invalidDrag = null;
	Cursor _reversedArrow = null;
	Cursor _crosshair = null;
	// handles caching for backends
	Cursor maybeLoad(Cursor function() loadCursor, ref Cursor cache) {
		if(cache is null)
			cache = loadCursor();
		return cache;
	}
public:
	/**
	 * Gets a blank cursor used for an activity, such as typing, with which
	 * the cursor may interfere.
	 */
	Cursor None() {
		return maybeLoad(&backend_None, _none);
	}
	/**
	 * Gets the cursor used normally.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_arrow_cursor.png)
	 */
	Cursor Arrow() {
		return maybeLoad(&backend_Arrow, _arrow);
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
		return maybeLoad(&backend_WaitArrow, _waitArrow);
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
		return maybeLoad(&backend_Wait, _wait);
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
		return maybeLoad(&backend_Text, _text);
	}
	/**
	 * Gets the cursor used when the mouse is over a link.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_hand_cursor.png)
	 */
	Cursor Hand() {
		return maybeLoad(&backend_Hand, _hand);
	}
	/**
	 * Gets the cursor used when moving something.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_move_cursor.png)
	 */
	Cursor Move() {
		return maybeLoad(&backend_Move, _move);
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
		return maybeLoad(&backend_ResizeHoriz, _resizeHoriz);
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
		return maybeLoad(&backend_ResizeVert, _resizeVert);
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
		return maybeLoad(&backend_ResizeBackslash, _resizeBackslash);
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
		return maybeLoad(&backend_ResizeSlash, _resizeSlash);
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
		return maybeLoad(&backend_Drag, _drag);
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
		return maybeLoad(&backend_InvalidDrag, _invalidDrag);
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
		return maybeLoad(&backend_ReversedArrow, _reversedArrow);
	}
	/**
	 * Gets the cursor that is sometimes used for selecting.
	 *
	 * The appearance with Windows XP:
	 *
	 * $(IMAGE ../web/example_crosshair_cursor.png)
	 */
	Cursor Crosshair() {
		return maybeLoad(&backend_Crosshair, _crosshair);
	}
}

