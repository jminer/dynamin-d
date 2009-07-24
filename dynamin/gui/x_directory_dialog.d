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
 * Portions created by the Initial Developer are Copyright (C) 2009
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Jordan Miner <jminer7@gmail.com>
 *
 */

module dynamin.gui.x_directory_dialog;

public import Utf = tango.text.convert.Utf;
public import dynamin.c.glib;
public import dynamin.c.gtk;

template DirectoryDialogBackend() {
	DialogResult backend_showDialog() {
		string title = text ? text : "Select Folder";
		auto dialog = gtk_file_chooser_dialog_new(toCharPtr(title), null,
			GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER,
			GTK_STOCK_CANCEL, GTK_RESPONSE_CANCEL,
			GTK_STOCK_OPEN, GTK_RESPONSE_ACCEPT, null);
		if(_directory)
			gtk_file_chooser_set_current_folder(dialog, toCharPtr(_directory));
		scope(exit) {
			gtk_widget_destroy(dialog);
			while(gtk_events_pending())
				gtk_main_iteration();
		}
		if(gtk_dialog_run(dialog) == GTK_RESPONSE_ACCEPT) {
			char* folder = gtk_file_chooser_get_filename(dialog);
			_directory = folder[0..strlen(folder)].dup;
			g_free(folder);
			return DialogResult.OK;
		}
		return DialogResult.Cancel;
	}
}

