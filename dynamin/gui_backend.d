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
 * Portions created by the Initial Developer are Copyright (C) 2007-2009
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Jordan Miner <jminer7@gmail.com>
 *
 */

module dynamin.gui_backend;

version(Windows) {
	public import dynamin.gui.windows_clipboard;
	public import dynamin.gui.windows_cursor;
	//public import dynamin.gui.windows_directory_dialog;
	public import dynamin.gui.windows_file_dialog;
	//public import dynamin.gui.windows_screen;
	public import dynamin.gui.windows_window;
} else {
	public import dynamin.gui.x_clipboard;
	public import dynamin.gui.x_cursor;
	//public import dynamin.gui.x_directory_dialog;
	//public import dynamin.gui.x_file_dialog;
	//public import dynamin.gui.x_screen;
	public import dynamin.gui.x_window;
}

