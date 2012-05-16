
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.gui.windows_file_dialog;

public import dynamin.c.windows;
public import Utf = tango.text.convert.Utf;

template FileDialogBackend() {
	DialogResult backend_showDialog() {
		OPENFILENAME ofn;
		ofn.lStructSize = OPENFILENAME.sizeof;
		//ofn.hwndOwner = ;

		ensureAllFilesFilter();
		string filterStr;
		foreach(filter; _filters) {
			if(filter.shouldShow)
				continue;
			string[] exts = filter.extensions.dup;
			if(exts.length == 0)
				exts = [cast(string)"*.*"];
			else
				for(int i = 0; i < exts.length; ++i)
					exts[i] = "*." ~ exts[i];
			filterStr ~= filter.name ~ "\0" ~ exts.join(";") ~ "\0";
		}
		filterStr ~= "\0";
		ofn.lpstrFilter = filterStr.toWcharPtr();
		ofn.nFilterIndex = _selectedFilter + 1;
		wchar[] filesBufferW = Utf.toString16(_initialFileName~"\0");
		// TODO: should use a static buffer of 4096, passing to toString16
		// avoid concat too
		filesBufferW.length = 4096;
		scope(exit) delete filesBufferW;
		ofn.lpstrFile = filesBufferW.ptr;
		ofn.nMaxFile = filesBufferW.length;
		ofn.lpstrInitialDir = _folder.toWcharPtr();
		ofn.lpstrTitle = _text.toWcharPtr();
		ofn.Flags = OFN_EXPLORER;
		//if(canChooseLinks)
		//	ofn.Flags |= OFN_NODEREFERENCELINKS;
		ofn.Flags |= OFN_FILEMUSTEXIST;
		ofn.Flags |= OFN_HIDEREADONLY;
		ofn.Flags |= OFN_OVERWRITEPROMPT;
		if(_multipleSelection && fileDialogType == Open)
			ofn.Flags |= OFN_ALLOWMULTISELECT;

		auto GetFileName = fileDialogType == Open ?
		                   &GetOpenFileName : &GetSaveFileName ;
		if(!GetFileName(&ofn)) {
			if(CommDlgExtendedError() == FNERR_BUFFERTOOSMALL)
				MessageBoxW(null, "Too many files picked.", "Error", 0);
			return DialogResult.Cancel;
		}

		_selectedFilter = ofn.nFilterIndex - 1;
		// must zero FFFF chars here because the
		// parsing here assumes the unused part of the string is zeroed
		foreach(i, c; filesBufferW)
			if(c == 0xFFFF)
				filesBufferW[i] = 0;
		int index; // index of null char right after the last non-null char
		for(index = filesBufferW.length; index > 0; --index)
			if(filesBufferW[index-1] != 0)
				break;
		auto filesBuffer = Utf.toString(filesBufferW[0..index]);
		scope(exit) delete filesBuffer;
		if(filesBuffer.contains('\0')) { // multiple files
			auto arr = filesBuffer.split("\0");
			_folder = arr[0];
			// make sure folder ends with a backslash
			// "C:\" does but "C:\Program Files" does not
			if(!_folder.endsWith("\\"))
				_folder ~= "\\";
			_files = new string[arr.length-1];
			for(int i = 1; i < arr.length; ++i) {
				if(arr[i].contains('\\')) // a dereferenced link--absolute
					_files[i-1] = arr[i];
				else
					_files[i-1] = _folder ~ arr[i];
				maybeAddExt(_files[i-1]);
			}
		} else { //single file
			assert(filesBuffer.contains('\\'));
			_folder = filesBuffer[0..filesBuffer.findLast("\\")].dup;
			_files = [filesBuffer.dup];
			maybeAddExt(_files[0]);
		}

		return DialogResult.OK;
	}
}

