
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.gui.office_theme;

static this() {
	addTheme(new OfficeTheme());
}

enum OfficeStyle {
	//Office2000 = 1
	OfficeXP = 2, Office2003
}
// this theme paints its tool bars and menus as Office XP or Office 2003
// It paints other controls exactly as the WindowsTheme does, as it is derived
// from it.
class OfficeTheme : WindowsTheme {
	OfficeStyle _style = OfficeStyle.Office2003;
	void officeStyle(OfficeStyle s) { _style = s; }
	OfficeStyle officeStyle() { return _style; }
}

