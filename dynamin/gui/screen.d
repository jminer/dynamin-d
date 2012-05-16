
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
import dynamin.gui_backend;
Rect desktopRect() { // TODO: move
	int* data = cast(int*)getXWindowProperty(display,
		XRootWindow(display, XDefaultScreen(display)), XA._NET_WORKAREA);
	scope(exit) XFree(data);
	return Rect(data[0], data[1], data[2], data[3]);
}

}


