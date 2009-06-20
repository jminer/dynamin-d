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

module dynamin.gui.windows_file_dialog;

public import dynamin.c.windows;
public import Utf = tango.text.convert.Utf;

template FileDialogBackend() {
	DialogResult backend_showDialog() {
		OPENFILENAME ofn;
		ofn.lStructSize = OPENFILENAME.sizeof;
		//ofn.hwndOwner = ;

		bool allFilesFilter = false;
		foreach(filter; _filters)
			if(filter.extensions.length == 0)
				allFilesFilter = true;
		if(!allFilesFilter) addFilter("All Files (*.*)");

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
		ofn.lpstrInitialDir = _directory.toWcharPtr();
		ofn.lpstrTitle = _text.toWcharPtr();
		ofn.Flags = OFN_EXPLORER;
		//if(canChooseLinks)
		//	ofn.Flags |= OFN_NODEREFERENCELINKS;
		ofn.Flags |= OFN_FILEMUSTEXIST;
		ofn.Flags |= OFN_HIDEREADONLY;
		ofn.Flags |= OFN_OVERWRITEPROMPT;
		if(_multipleSelection)
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
			_directory = arr[0];
			// make sure directory ends with a backslash
			// "C:\" does but "C:\Program Files" does not
			if(!_directory.endsWith("\\"))
				_directory ~= "\\";
			_files = new string[arr.length-1];
			for(int i = 1; i < arr.length; ++i) {
				if(arr[i].contains('\\')) // a dereferenced link--absolute
					_files[i-1] = arr[i];
				else
					_files[i-1] = _directory ~ arr[i];
			}
		} else { //single file
			assert(filesBuffer.contains('\\'));
			_directory = filesBuffer[0..filesBuffer.findLast("\\")].dup;
			_files = [filesBuffer.dup];
		}

		// if "All Files (*.*)" filter is not selected
		if(_filters[selectedFilter].extensions.length > 0) {
			// go over every chosen file and add the selected filter's
			// extension if the file doesn't already have one from the selected filter
			for(int i = 0; i < _files.length; ++i) {
				bool validExt = false;
				foreach(ext; _filters[selectedFilter].extensions)
					if(_files[i].downcase().endsWith(ext.downcase()))
						validExt = true;
				if(!validExt)
					_files[i] ~= "." ~ _filters[selectedFilter].extensions[0].downcase();
			}
		}

		return DialogResult.OK;
	}
}

