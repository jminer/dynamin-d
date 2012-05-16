
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.gui.label;

import dynamin.core.string;
import dynamin.all_painting;
import dynamin.all_gui;

///
class Label : Control {
protected:
	override Size bestSize() {
		Size s;
		withGraphics((Graphics g) { s = g.getTextExtents(text); });
		return s;
	}
	override void whenPainting(PaintingEventArgs e) {
		with(e.graphics) {
			drawText(text, 0, (height-getTextExtents(text).height)/2);
		}
	}
public:
	this() {
	}
	this(string text) {
		this();
		this.text = text;
	}
	override int baseline() { return 10; }
}

