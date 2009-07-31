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

import dynamin.all_core;
import dynamin.gui_backend;

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
private:
	mixin FileDialogBackend;
protected:
	bool _multipleSelection;
	string _initialFileName;
	string _text;
	string _folder;
	string[] _files;
	FileDialogFilter[] _filters;
	int _selectedFilter;

	uint fileDialogType;
	enum {
		Open, Save
	}
	invariant() {
		assert(fileDialogType == Open || fileDialogType == Save);
	}
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
	void multipleSelection(bool b) { _multipleSelection = b; }

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
	 * Sets the folder that the FileDialog shows. If this is null,
	 * the default folder is used when the dialog is first shown.
	 * After the dialog has been shown, this is set to the folder
	 * the user was last looking at.
	 */
	void folder(string str) {
		_folder = str;
	}
	/// TODO: Should this be selectedFolder ?
	string folder() {
		return _folder;
	}

	/**
	 * Gets the files selected by the user.
	 * If the user did not type a file name extension, the correct one
	 * will be added according to the selected filter.
	 */
	string[] files() { return _files; }
	/// Gets the first of the files selected by the user.
	string file() { return _files[0]; }

	// TODO: parameters
	// TODO: should showDialog take any parameters?
	//       what should happen if no owner is set?
	//       WinForms sets the owner to the currently active window in the app
	//       do the same? or have no owner (annoying, as window can get below)?
	DialogResult showDialog() {
		return backend_showDialog();
	}
	private void ensureAllFilesFilter() {
		foreach(filter; _filters)
			if(filter.extensions.length == 0)
				return;
		addFilter("All Files (*.*)");
	}
	private void maybeAddExt(ref string file) {
		auto selFilter = _filters[selectedFilter];

		// return if the "All Files (*.*)" filter is selected
		if(selFilter.extensions.length == 0)
			return;

		// return if the file already has an extension from the selected filter
		foreach(ext; selFilter.extensions)
			if(file.downcase().endsWith(ext.downcase()))
				return;

		file ~= "." ~ selFilter.extensions[0].downcase();
	}
}

///
class OpenFileDialog : FileDialog {
	this() {
		_multipleSelection = true;
		// different settings
		fileDialogType = Open;
	}
}

///
class SaveFileDialog : FileDialog {
	this() {
		_multipleSelection = false;
		// different settings
		fileDialogType = Save;
	}
}
