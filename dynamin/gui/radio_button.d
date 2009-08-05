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

module dynamin.gui.radio_button;

import dynamin.all_core;
import dynamin.all_gui;
import dynamin.all_painting;
import tango.io.Stdout;

/**
 * A control that can be checked only if other radio buttons are unchecked.
 *
 * The appearance of a radio button with Windows Classic:
 *
 * $(IMAGE ../web/example_radio_button.png)
 */
class RadioButton : CheckBox {
protected:
	int _group = 1;
	RadioButton[] collectGroup(ref int checkedIndex) {
		Window topLevel = cast(Window)getTopLevel();
		if(!topLevel)
			return null;
		RadioButton[] radios;
		void collectFromContainer(Container container) {
			foreach(control; container) {
				if(auto r = cast(RadioButton)control) {
					if(r.group != group)
						continue;
					radios.length = radios.length + 1;
					radios[$-1] = r;
					if(r.checked)
						checkedIndex = radios.length-1;
				} else if(auto c = cast(Container)control)
					collectFromContainer(c);
			}
		}
		checkedIndex = -1;
		collectFromContainer(topLevel.content);
		return radios;
	}
	override void whenKeyDown(KeyEventArgs e) {
		// TODO: when GetTopLevel() is changed to return NativeControl,
		// update this
		int index;
		if(e.key == Key.Down || e.key == Key.Right) {
			RadioButton[] radios = collectGroup(index);
			if(radios is null)
				return;
			if(++index >= radios.length)
				index = 0;
			radios[index].clicked(new EventArgs);
			e.stopped = true;
		} else if(e.key == Key.Up || e.key == Key.Left) {
			RadioButton[] radios = collectGroup(index);
			if(radios is null)
				return;
			if(--index < 0)
				index = radios.length-1;
			radios[index].clicked(new EventArgs);
			e.stopped = true;
		}
	}
	override void whenPainting(PaintingEventArgs e) {
		Theme.current.RadioButton_paint(this, e.graphics);
	}
	override void whenClicked(EventArgs e) {
		int index;
		RadioButton[] radios = collectGroup(index);
		foreach(r; radios)
			r.checked = false;
		checked = true;
		focus();

	}
public:
	this() {
	}
	this(string text) {
		this();
		this.text = text;
	}
	override Size bestSize() {
		return Size(70, 15);
	}
	/**
	 * Gets or sets what group this radio button is a part of. The default is 1.
	 */
	int group() { return _group; }
	/// ditto
	void group(int i) { _group = i; }
}
