
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.gui.clipboard;

import dynamin.core.string;
import dynamin.gui.window;
import dynamin.gui_backend;
import tango.io.Stdout;

/*
 * Goals of this class:
 * - Allow copying and pasting of plain text, 32 bpp images, file lists,
 *   formatted text, and user defined data
 * - As this does not depend on the audio classes, copying audio data should
 *   be handled in the audio code.
 */
///
static class Clipboard {
static:
private:
	mixin ClipboardBackend;
public:
	/**
	 * This event occurs after the data on clipboard has been changed.
	 * Note: This event will not always be fired when the data on the clipboard
	 * changes, as some backends have no way of being notified of such an event.
	 */
	//Event!() DataChanged;
	static this() {
		//DataChanged = new Event!()(null);
	}

	/**
	 * Sets the data on the clipboard to the specified _text.
	 */
	void setText(string text) {
		backend_setText(text);
	}
	alias setText copyText;
	/**
	 * Gets text from the clipboard. If the clipboard does not have any text
	 * or has an empty string, null is returned.
	 */
	string getText() {
		return backend_getText();
	}
	alias getText pasteText;
	// TODO: don't need this?
	bool containsText() {
		return backend_containsText();
	}

}

/**
 * On the X window system, this holds the current selection. Whenever the
 * selection is changed in a program, X's selection should be updated using
 * this class.
 * On Windows, this class does not do anything.
 *
 * See the Clipboard documentation for a description of the functionality
 * of this class.
 */
static class Selection {
static:
private:
	mixin SelectionBackend;
public:
	///
	void setText(string text) {
		backend_setText(text);
	}
	///
	string getText() {
		return backend_getText();
	}
	///
	bool containsText() {
		return backend_containsText();
	}
}

