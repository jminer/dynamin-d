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

