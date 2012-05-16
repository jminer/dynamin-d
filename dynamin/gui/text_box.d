
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
		selectionChanged.setUp(&whenSelectionChanged);

		super();
		_focusable = true;
		content.cursor = Cursor.Text;

		// TODO: change if Multiline is added
		visibleScrollBars = VisibleScrollBars.None;
		elasticX = true;
		elasticY = false;
	}
}

