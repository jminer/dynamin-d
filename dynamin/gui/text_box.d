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

module dynamin.gui.text_box;

import dynamin.all_painting;
import dynamin.all_core;
import dynamin.all_gui;

/**
 * A control that allows text to be entered and edited.
 *
 * The appearance of a text box with Windows Classic:
 *
 * $(IMAGE ../web/example_text_box.png)
 */
class TextBox : Scrollable {
protected:
	string _text;
	int _caret = 0;
	override Size contentBestSize() {
		return Size(0, 0);
	}
	override void whenContentPainting(PaintingEventArgs e) {
		with(e.graphics) {
			source = Color.White;
			paint();
			source = Color.Black;
			drawText(_text, 1, 1);
			if(focused) {
				Size ex = getTextExtents(_text[0.._caret]);
				moveTo(1+ex.width+0.5, 1);
				lineTo(1+ex.width+0.5, 14);
				stroke();
			}
		}
	}
	override void whenContentMouseDown(MouseEventArgs e) {
		focus();
		repaint();
	}
	override void whenKeyDown(KeyEventArgs e) {
		switch(e.key) {
		case Key.Backspace:
			if(_caret > 0)
				_text = _text[0.._caret-1] ~ _text[_caret..$];
			if(_caret > 0)
				_caret--;
			break;
		case Key.Delete:
			if(_text.length > _caret)
				_text = _text[0.._caret] ~ _text[_caret+1..$];
			break;
		case Key.Right:
			if(_caret < _text.length)
				_caret++;
			break;
		case Key.Left:
			if(_caret > 0)
				_caret--;
			break;
		case Key.Home:
			_caret = 0;
			break;
		case Key.End:
			_caret = _text.length;
			break;
		default:
			return;
		}
		repaint();
	}
	override void whenKeyTyped(KeyTypedEventArgs e) {
		_text = format("{}{}{}", _text[0.._caret], e.character, _text[_caret..$]);
		_caret++;
		repaint();
	}
	override void whenMouseDown(MouseEventArgs e) {
		focus();
	}
public:
	override Size bestSize() {
		// TODO: columns and rows
		return Size(100, 20);
	}
	override int baseline() { return 14; }

	/// Override this method in a subclass to handle the selectionChanged event.
	protected void whenSelectionChanged(EventArgs e) { }
	/// This event occurs after the selection has changed.
	Event!(whenSelectionChanged) selectionChanged;

	this() {
		selectionChanged.mainHandler = &whenSelectionChanged;

		super();
		_focusable = true;
		content.cursor = Cursor.Text;

		// TODO: change if Multiline is added
		visibleScrollBars = VisibleScrollBars.None;
		elasticX = true;
		elasticY = false;
	}
}

