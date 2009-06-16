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
 * Portions created by the Initial Developer are Copyright (C) 2006-2009
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Jordan Miner <jminer7@gmail.com>
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

