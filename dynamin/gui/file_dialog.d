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

module dynamin.gui.file_dialog;

import dynamin.c.windows;
import dynamin.all_core;
import dynamin.gui.window;
import tango.io.Stdout;
import Utf = tango.text.convert.Utf;

// not used by programs
struct FileDialogFilter {
	string name;
	string[] extensions;
	// ignored for now
	bool delegate(string fileName) shouldShow;
}

/**
 * As this is an abstract class, use OpenFileDialog or SaveFileDialog instead.
 *
 * TODO: figure out a way to allow the user to type in a custom filter?
 * TODO: on Linux, use a GTK dialog if available, otherwise use a custom one.
 *
 * The appearance of a file dialog with Windows Classic:
 *
 * $(IMAGE ../web/example_file_dialog.png)
 */
abstract class FileDialog {
protected:
	bool _multipleSelection;
	string _initialFileName;
	string _text;
	string _directory;
	string[] _files;
	FileDialogFilter[] _filters;
	int _selectedFilter;
public:
	/**
	 * Adds a filter that only shows files with the specified extensions.
	 * Note that the "All Files (*.*)" filter is added automatically when the
	 * dialog is shown if not added previously because I don't like when
	 * programs don't let me have control over what extension to use and
	 * don't let me be able to see all the files.
	 * Examples:
	 * -----
	 * dialog.addFilter("All Files (*.*)");
	 * dialog.addFilter("Cascading Style Sheets (*.css)", "css");
	 * dialog.addFilter("Web Pages (*.html, *.htm)", "html", "htm");
	 * -----
	 */
	void addFilter(string name, string[] exts...) {
		FileDialogFilter filter;
		filter.name = name;
		filter.extensions = exts;

		_filters.length = _filters.length + 1;
		_filters[_filters.length-1] = filter;
	}
	/**
	 * Adds a filter that only shows files with which the specified delegate
	 * returns true for.
	 * BUG: not implemented
	 */
	void addFilter(string name, string ext, bool delegate(string fileName) shouldShow) {
		// TODO:
		throw new Exception("addFilter(string, string, delegate) not implemented");
		FileDialogFilter filter;
		filter.name = name;
		filter.extensions = [ext];
		filter.shouldShow = shouldShow;

		_filters.length = _filters.length + 1;
		_filters[_filters.length-1] = filter;
	}
	/// Gets or sets the selected filter. An index of 0 is the first one added.
	int selectedFilter() { return _selectedFilter; }
	/// ditto
	void selectedFilter(int index) { _selectedFilter = index; }
	/**
	 * Gets or sets whether more than one file can be selected.
	 * The default is true for an OpenFileDialog and false for SaveFileDialog.
	 */
	bool multipleSelection() { return _multipleSelection; }
	/// ditto
	void multipleSelection(bool b) { _multipleSelection = b;	}
	/// Gets or sets the text that is displayed in the dialog's title bar.
	string text() { return _text; }
	/// ditto
	void text(string str) { _text = str; }
	/**
	 * Sets the text in the file name text box to the specified string.
	 * Example:
	 * -----
	 * dialog.initialFileName = "Untitled";
	 * -----
	 */
	void initialFileName(string str) {
		// TODO: make sure str is not a path?
		_initialFileName = str;
	}
	/**
	 * Sets the directory that the FileDialog shows. If this is null,
	 * the default directory is used when the dialog is first shown.
	 * After the dialog has been shown, this is set to the directory
	 * the user was last looking at.
	 */
	void directory(string str) {
		_directory = str;
	}
	/// TODO: Should this be SelectedDirectory ?
	string directory() {
		return _directory;
	}
	/**
	 * Gets the files selected by the user.
	 * If the user did not type a file name extension, the correct one
	 * will be added according to the selected filter.
	 */
	string[] files() { return _files; }
	/// Gets the first of the files selected by the user.
	string file() { return _files[0]; }
	protected int getXFileName(OPENFILENAME* ofn);
	// TODO: parameters
	// TODO: should ShowDialog take any parameters?
	//       what should happen if no owner is set?
	//       Windows Forms sets the owner to the currently active window in the application
	//       do the same? or have no owner (really annoying, as window can get below)?
	DialogResult showDialog() {
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

		if(!getXFileName(&ofn)) {
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

///
class OpenFileDialog : FileDialog {
	this() {
		_multipleSelection = true;
		// different settings
	}
	protected int getXFileName(OPENFILENAME* ofn) {
		return GetOpenFileName(ofn);
	}
}

///
class SaveFileDialog : FileDialog {
	this() {
		_multipleSelection = false;
		// different settings
	}
	protected int getXFileName(OPENFILENAME* ofn) {
		return GetSaveFileName(ofn);
	}
}
