
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.gui_backend;

version(Windows) {
	public import dynamin.gui.windows_clipboard;
	public import dynamin.gui.windows_cursor;
	public import dynamin.gui.windows_file_dialog;
	public import dynamin.gui.windows_folder_dialog;
	//public import dynamin.gui.windows_screen;
	public import dynamin.gui.windows_window;
} else {
	public import dynamin.gui.x_clipboard;
	public import dynamin.gui.x_cursor;
	public import dynamin.gui.x_file_dialog;
	public import dynamin.gui.x_folder_dialog;
	//public import dynamin.gui.x_screen;
	public import dynamin.gui.x_window;
}

