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

module dynamin.gui.windows_clipboard;

import dynamin.c.windows;
import Utf = tango.text.convert.Utf;

template ClipboardBackend() {
	void backend_setText(string text) {
		if(!OpenClipboard(msgWnd))
			return;
		EmptyClipboard();
		auto wtext = Utf.toString16(text);
		HGLOBAL hmem = GlobalAlloc(GMEM_MOVEABLE, (wtext.length+1)*wchar.sizeof);
		wchar* data = cast(wchar*)GlobalLock(hmem);
		data[0..wtext.length] = wtext;
		data[wtext.length] = 0;
		GlobalUnlock(hmem);
		SetClipboardData(CF_UNICODETEXT, data);
		CloseClipboard();
	}
	string backend_getText() {
		if(!OpenClipboard(msgWnd))
			return null;
		wchar* data = cast(wchar*)GetClipboardData(CF_UNICODETEXT);
		CloseClipboard();
		if(data is null)
			return null;
		int i = 0;
		while(data[i] != '\0')
			++i;
		if(i == 0)
			return null;
		return Utf.toString(data[0..i]);
	}
	bool backend_containsText() {
		return IsClipboardFormatAvailable(CF_UNICODETEXT) ? true : false;
	}
}

// Windows only has one clipboard
template SelectionBackend() {
	void backend_setText(string text) {
	}
	string backend_getText() {
		return null;
	}
	bool backend_containsText() {
		return false;
	}
}

