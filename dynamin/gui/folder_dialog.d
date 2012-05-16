
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.gui.folder_dialog;

import dynamin.all_core;
import dynamin.gui_backend;

/**
 *
 *
 * The appearance of a folder dialog with Windows Classic:
 *
 * $(IMAGE ../web/example_folder_dialog.png)
 */
class FolderDialog {
private:
	mixin FolderDialogBackend;
	string _text;
	string _folder;
public:
	/// Gets or sets the text that is displayed in the dialog's title bar.
	string text() { return _text; }
	/// ditto
	void text(string str) { _text = str; }

	/// Gets or sets the selected folder.
	string folder() {
		return _folder;
	}
	/// ditto
	void folder(string str) {
		_folder = str;
	}

	DialogResult showDialog() {
		return backend_showDialog();
	}
}
