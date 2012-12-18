
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.gui.windows_folder_dialog;

public import Utf = tango.text.convert.Utf;

template FolderDialogBackend() {
	extern(Windows) static int setSelectedFolder(HWND hwnd,
			UINT uMsg, LPARAM lParam, LPARAM lpData) {
		if(uMsg == BFFM_INITIALIZED)
			SendMessage(hwnd, BFFM_SETSELECTION, true, lpData);
		return 0;
	}

	DialogResult backend_showDialog() {
		BROWSEINFO bi;
		//bi.hwndOwner = ;
		bi.lpszTitle = "Choose a folder:";
		bi.ulFlags |= BIF_RETURNONLYFSDIRS;
		bi.ulFlags |= BIF_USENEWUI;
		if(_folder) {
			bi.lpfn = &setSelectedFolder;
			bi.lParam = cast(LPARAM)toWcharPtr(_folder);
		}

		ITEMIDLIST* pidl = SHBrowseForFolder(&bi);
		if(!pidl)
			return DialogResult.Cancel;
		wchar[MAX_PATH+1] dirBuffer; // MAX_PATH is 260
		if(!SHGetPathFromIDList(pidl, dirBuffer.ptr)) {
			Stdout("GetPathFromIDList() failed").newline;
			return DialogResult.Cancel;
		}
		CoTaskMemFree(pidl);
		int index = MAX_PATH;
		foreach(i, c; dirBuffer)
			if(c == 0) { // find first null
				index = i;
				if(dirBuffer[i-1] != '\\') {
					dirBuffer[i] = '\\';
					index++;
				}
				break;
			}
		_folder = cast(immutable)Utf.toString(dirBuffer[0..index]);
		return DialogResult.OK;
	}
}

