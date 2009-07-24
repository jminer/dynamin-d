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

module dynamin.gui.windows_directory_dialog;

public import Utf = tango.text.convert.Utf;

template DirectoryDialogBackend() {
	DialogResult backend_showDialog() {
		BROWSEINFO bi;
		//bi.hwndOwner = ;
		bi.lpszTitle = "Choose a folder:";
		bi.ulFlags |= BIF_RETURNONLYFSDIRS;
		bi.ulFlags |= BIF_USENEWUI;

		// TODO: I can't get this #!@#! COM stuff working...
		//IShellFolder* shf;
		//SHGetDesktopFolder(&shf);
		//ITEMIDLIST* pidlInit;
		//shf.ParseDisplayName(null, null, toWcharPointer(directory), null, &pidlInit, null);
		//shf.Release();
		//bi.pidlRoot = pidlInit;

		ITEMIDLIST* pidl = SHBrowseForFolder(&bi);
		//CoTaskMemFree(pidlInit);
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
		_directory = Utf.toString(dirBuffer[0..index]);
		return DialogResult.OK;
	}
}

