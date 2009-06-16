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

module dynamin.gui.check_box;

import dynamin.all_core;
import dynamin.all_gui;
import dynamin.all_painting;
import tango.io.Stdout;

enum CheckState {
	///
	Unchecked,
	///
	Checked,
	///
	Both
}

/**
 * A control that can be checked or unchecked independent of other controls.
 *
 * The appearance of a check box with Windows Classic:
 *
 * $(IMAGE ../web/example_check_box.png)
 */
class CheckBox : Button {
protected:
	CheckState _checkState = CheckState.Unchecked;
	override void whenClicked(EventArgs e) {
		checked = !checked;
		focus();
	}
	override void whenPainting(PaintingEventArgs e) {
		Theme.current.CheckBox_paint(this, e.graphics);
	}

public:
	/// This event occurs after .
	Event!() checkedChanged;
	/// Override this method in a subclass to handle the SelectedChanged event.
	protected void whenCheckedChanged(EventArgs e) { }
	this() {
		checkedChanged = new Event!()(&whenCheckedChanged);
		_focusable = true;
	}
	this(string text) {
		this();
		this.text = text;
	}
	bool checked() {
		return _checkState == CheckState.Checked;
	}
	void checked(bool b) {
		_checkState = b ? CheckState.Checked : CheckState.Unchecked;
		repaint();
		checkedChanged(new EventArgs);
	}
	override Size bestSize() {
		return Size(70, 15);
	}
	override void paintFore(Graphics g) {
		g.drawText(text, 0, (height-g.getTextExtents(text).height)/2);
	}
}

