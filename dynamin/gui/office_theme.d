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

