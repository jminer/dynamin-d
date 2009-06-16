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

module dynamin.gui.x_clipboard;

public import dynamin.core.string;
public import dynamin.core.environment;
public import dynamin.gui.x_window;

// TODO: get notified of selection changes by using the XFixes extension
// TODO: use the ClipboardManager to ensure that the clipboard data stays after
//       the program is closed

/* Fairly obvious, but:
	selecting but with no explicit copy should only set PRIMARY,
	never CLIPBOARD

	middle mouse button should paste PRIMARY, never CLIPBOARD

	explicit cut/copy commands (i.e. menu items, toolbar buttons)
	should always set CLIPBOARD to the currently-selected data (i.e. conceptually copy PRIMARY to CLIPBOARD)

	explicit paste commands should paste CLIPBOARD, not PRIMARY

	possibly contradicting the ICCCM, clients don't need to support
	SECONDARY, though if anyone can figure out what it's good for they should feel free to use it for that
*/
extern(C) XBool isRequestOrNotify(XDisplay* d, XEvent* e, XPointer arg) {
	// either
	// - SelectionRequest & the msgWin is the owner
	// - SelectionNotify & another program is owner is giving data
	return (e.type == SelectionRequest || e.type == SelectionNotify) &&
		e.xany.window == msgWin;

}

string backend_getSelText(XAtom sel, ref ClipboardData data) {
	XConvertSelection(display, sel, XA.UTF8_STRING, XA.DYNAMIN_SELECTION, msgWin, CurrentTime);
	XSync(display, false);
	auto start = Environment.runningTime;
	XEvent ev;
	while(true) {
		// don't wait more than a second
		if(Environment.runningTime - start > 1000)
			return null;
		if(!XCheckIfEvent(display, &ev, &isRequestOrNotify, null))
			continue;
		if(ev.type == SelectionRequest)
				return data.data[0..data.length];
		// must be SelectionNotify past here

		auto selEv = &ev.xselection;
		if(selEv.property == None)
			return null;

		int count;
		char* propData = cast(char*)getXWindowProperty(display, msgWin,
			selEv.property, &count);
		scope(exit) XFree(propData);
		XDeleteProperty(display, msgWin, selEv.property);

		string str = new char[count];
		str[] = propData[0..count];
		return str;
	}
}
struct ClipboardData {
	XAtom target;
	char* data;
	uint length; // number of bytes in data
}
// always called from the event thread...don't have to avoid static data
void backend_setSelText(XAtom sel, string text, ref ClipboardData data) {
	XSetSelectionOwner(display, sel, msgWin, CurrentTime);
	data.target = XA.UTF8_STRING;
	data.data = text.ptr;
	data.length = text.length;

	XConvertSelection(display, XA.CLIPBOARD_MANAGER, XA.SAVE_TARGETS, None, msgWin, CurrentTime);
}

template ClipboardBackend() {
	ClipboardData data; // make array when supporting multiple types (PNG & BMP)
	void backend_setText(string text) {
		backend_setSelText(XA.CLIPBOARD, text, data);
	}
	string backend_getText() {
		return backend_getSelText(XA.CLIPBOARD, data);
	}
	bool backend_containsText() {
		return backend_getText() != null;
	}
}

template SelectionBackend() {
	ClipboardData data; // make array when supporting multiple types (PNG & BMP)
	void backend_setText(string text) {
		backend_setSelText(XA.PRIMARY, text, data);
	}
	string backend_getText() {
		return backend_getSelText(XA.PRIMARY, data);
	}
	bool backend_containsText() {
		return backend_getText() != null;
	}
}

