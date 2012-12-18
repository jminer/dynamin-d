
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.gui.windows_clipboard;

import dynamin.c.windows;
import Utf = tango.text.convert.Utf;

template ClipboardBackend() {
	void backend_setText(cstring text) {
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
	mstring backend_getText() {
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
	void backend_setText(cstring text) {
	}
	mstring backend_getText() {
		return null;
	}
	bool backend_containsText() {
		return false;
	}
}

