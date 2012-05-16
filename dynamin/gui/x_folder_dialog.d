
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.gui.x_folder_dialog;

public import Utf = tango.text.convert.Utf;
public import dynamin.c.glib;
public import dynamin.c.gtk;

template FolderDialogBackend() {
	DialogResult backend_showDialog() {
		string title = text ? text : "Select Folder";
		auto dialog = gtk_file_chooser_dialog_new(toCharPtr(title), null,
			GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER,
			GTK_STOCK_CANCEL, GTK_RESPONSE_CANCEL,
			GTK_STOCK_OPEN, GTK_RESPONSE_ACCEPT, null);
		if(_folder)
			gtk_file_chooser_set_current_folder(dialog, toCharPtr(_folder));
		scope(exit) {
			gtk_widget_destroy(dialog);
			while(gtk_events_pending())
				gtk_main_iteration();
		}
		if(gtk_dialog_run(dialog) == GTK_RESPONSE_ACCEPT) {
			char* fold = gtk_file_chooser_get_filename(dialog);
			_folder = fold[0..strlen(fold)].dup;
			g_free(fold);
			return DialogResult.OK;
		}
		return DialogResult.Cancel;
	}
}

