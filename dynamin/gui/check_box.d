
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
	/// Override this method in a subclass to handle the checkedChanged event.
	protected void whenCheckedChanged(EventArgs e) { }
	/// This event occurs after .
	Event!(whenCheckedChanged) checkedChanged;
	this() {
		checkedChanged.setUp(&whenCheckedChanged);
		_focusable = true;
	}
	this(string text) {
		this();
		this.text = text;
	}
	/// Gets or sets whether this check box is checked.
	bool checked() {
		return _checkState == CheckState.Checked;
	}
	/// ditto
	void checked(bool b) {
		auto old = _checkState;
		_checkState = b ? CheckState.Checked : CheckState.Unchecked;
		if(_checkState == old)
			return;
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

