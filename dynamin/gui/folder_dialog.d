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

module dynamin.gui.folder_dialog;

import dynamin.all_core;
import dynamin.gui_backend;

/**
 *
 *
 * The appearance of a directory dialog with Windows Classic:
 *
 * $(IMAGE ../web/example_directory_dialog.png)
 */
class FolderDialog {
private:
	mixin FolderDialogBackend;
	string _text;
	string _directory;
public:
	/// Gets or sets the text that is displayed in the dialog's title bar.
	string text() { return _text; }
	/// ditto
	void text(string str) { _text = str; }

	/// Gets or sets the selected directory.
	string directory() {
		return _directory;
	}
	/// ditto
	void directory(string str) {
		_directory = str;
	}

	DialogResult showDialog() {
		return backend_showDialog();
	}
}
