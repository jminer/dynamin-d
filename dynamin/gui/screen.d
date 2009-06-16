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

module dynamin.gui.screen;

import dynamin.painting.coordinates;

// TODO: Screen.size and Screen.DesktopRect  ?
//ScreenList[] Screens() { }
//Screen PrimaryScreen() { return MonitorFromPoint(0, 0); }
//GetMonitorInfo(HMONITOR, MONITORINFO*)
//EnumDisplayMonitors(HDC, RECT*, MONITORENUMPROC, LPARAM);
/*
class Screen {
static {
	Screen[] getAll()
	Screen primary()
}
	Size size()
	Rect desktopRect()
}
*/

/*
On Windows, Screen mainly wraps an HMONITOR.
On X, Screen mainly wraps a Screen*
*/
version(Windows) {

import dynamin.c.windows;
/// Returns: the area on the primary monitor that is not covered by the taskbar
Rect desktopRect() { // TODO: move
	RECT rect;
	SystemParametersInfo(SPI_GETWORKAREA, 0, &rect, 0);
	return Rect(rect.left, rect.top, rect.right-rect.left, rect.bottom-rect.top);
}
/// Returns: the screen resolution of the primary monitor
Size screenSize() { // TODO: move
	return Size(GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN));
}

} else {
import dynamin.gui.backend;
Rect desktopRect() { // TODO: move
	int* data = cast(int*)getXWindowProperty(display,
		XRootWindow(display, XDefaultScreen(display)), XA._NET_WORKAREA);
	scope(exit) XFree(data);
	return Rect(data[0], data[1], data[2], data[3]);
}

}


