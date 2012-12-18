
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.gui.x_file_dialog;

public import Utf = tango.text.convert.Utf;
public import dynamin.c.glib;
public import dynamin.c.gtk;

template FileDialogBackend() {
	DialogResult backend_showDialog() {
		// gdk_x11_get_server_time             (GdkWindow *window)
		// could be used in clipboard

		mstring title = text ? text : (fileDialogType == Open ? "Open" : "Save");
		auto dialog = gtk_file_chooser_dialog_new(toCharPtr(title), null,
			fileDialogType == Open ?
			GTK_FILE_CHOOSER_ACTION_OPEN : GTK_FILE_CHOOSER_ACTION_SAVE,
			GTK_STOCK_CANCEL, GTK_RESPONSE_CANCEL,
			fileDialogType == Open ? GTK_STOCK_OPEN : GTK_STOCK_SAVE, GTK_RESPONSE_ACCEPT, null);

		ensureAllFilesFilter();
		foreach(i, filter; _filters) {
			if(filter.shouldShow) // TODO:
				continue;
			auto gfilter = gtk_file_filter_new();
			gtk_file_filter_set_name(gfilter, toCharPtr(filter.name));

			if(filter.extensions.length == 0)
				gtk_file_filter_add_pattern(gfilter, "*");
			else foreach(ext; filter.extensions)
				gtk_file_filter_add_pattern(gfilter, toCharPtr("*."~ext));

			gtk_file_chooser_add_filter(dialog, gfilter);
			if(selectedFilter == i)
				gtk_file_chooser_set_filter(dialog, gfilter);
		}

		if(fileDialogType == Open)
			gtk_file_chooser_set_select_multiple(dialog, multipleSelection);
		gtk_file_chooser_set_do_overwrite_confirmation(dialog, true);
		if(_folder)
			gtk_file_chooser_set_current_folder(dialog, toCharPtr(_folder));
		if(_initialFileName)
			gtk_file_chooser_set_current_name(dialog, toCharPtr(_initialFileName));

		scope(exit) {
			gtk_widget_destroy(dialog);
			while(gtk_events_pending())
				gtk_main_iteration();
		}
		if(gtk_dialog_run(dialog) == GTK_RESPONSE_ACCEPT) {
			auto gfilters = gtk_file_chooser_list_filters(dialog);
			_selectedFilter = g_slist_index(gfilters,
				gtk_file_chooser_get_filter(dialog));
			g_slist_free(gfilters);

			auto list = gtk_file_chooser_get_filenames(dialog);
			_files = new mstring[g_slist_length(list)];
			for(int i = 0; i < _files.length; ++i) {
				auto d = cast(char*)list.data;
				_files[i] = d[0..strlen(d)].dup;
				maybeAddExt(_files[i]);
				g_free(list.data);
				list = g_slist_next(list);
			}
			g_slist_free(list);

			char* fold = gtk_file_chooser_get_current_folder(dialog);
			_folder = fold[0..strlen(fold)].dup;
			g_free(fold);

			return DialogResult.OK;
		}
		return DialogResult.Cancel;
	}
}

