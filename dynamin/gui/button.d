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
 * Portions created by the Initial Developer are Copyright (C) 2006-2009
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Jordan Miner <jminer7@gmail.com>
 *
 */

module dynamin.gui.button;

import dynamin.all_core;
import dynamin.all_gui;
import dynamin.all_painting;
import tango.io.Stdout;
import dynamin.c.cairo; // TODO: remove

// TODO: maybe change to ControlState and add Disabled ?
enum ButtonState {
	Normal, Hot, Pressed
}
// TODO: move to another file
enum TextImageRelation {
	Overlay, TextBeforeImage, ImageBeforeText, TextAboveImage, ImageAboveText
}

/**
 * A button is a control that can be clicked to perform an action.
 *
 * The appearance of a button with Windows Classic:
 *
 * $(IMAGE ../web/example_button.png)
 */
class Button : Control {
protected:
	ButtonState _state;
	override void whenMouseDragged(MouseEventArgs e) {
		if(contains(e.x, e.y))
			state = ButtonState.Pressed;
		else
			state = ButtonState.Normal;
	}
	override void whenMouseEntered(EventArgs e) {
		state = ButtonState.Hot;
	}
	override void whenMouseLeft(EventArgs e) {
		state = ButtonState.Normal;
	}
	override void whenMouseDown(MouseEventArgs e) {
		if(e.button == MouseButton.Left) {
			state = ButtonState.Pressed;
			focus();
		}
	}
	override void whenMouseUp(MouseEventArgs e) {
		if(state != ButtonState.Pressed) return;
		state = ButtonState.Hot;
		clicked(new EventArgs);
	}
	override void whenKeyDown(KeyEventArgs e) {
		if(e.key == Key.Space)
			state = ButtonState.Pressed;
	}
	override void whenKeyUp(KeyEventArgs e) {
		if(e.key == Key.Space) {
			if(state != ButtonState.Pressed) return;
			state = ButtonState.Normal;
			clicked(new EventArgs);
		}
	}
	override void whenPainting(PaintingEventArgs e) {
		Theme.current.Button_paint(this, e.graphics);
		return;
		// TODO: move to a theme or delete
		with(e.graphics) {
			if(_state == ButtonState.Hot)
				source = Color(200, 0, 0);
			else if(_state == ButtonState.Pressed)
				source = Color(110, 0, 0);
			else
				source = Color(220, 80, 80);
			moveTo(3, 0);
			lineTo(width-3, 0);
			lineTo(width, 3);
			lineTo(width, height-3);
			lineTo(width-3, height);
			lineTo(3, height);
			lineTo(0, height-3);
			lineTo(0, 3);
			closePath();
			fill();
			auto grad = cairo_pattern_create_linear(0, 0, 0, height/2+3);
			cairo_pattern_add_color_stop_rgba(grad, 0, 1, 1, 1, .4);
			cairo_pattern_add_color_stop_rgba(grad, 1, 1, 1, 1, .05);
			cairo_set_source(handle, grad);
			cairo_pattern_destroy(grad);
			moveTo(3, 0);
			lineTo(width-3, 0);
			lineTo(width, 3);
			lineTo(width, cast(int)height/2-3);
			lineTo(width-3, cast(int)height/2);
			lineTo(3, cast(int)height/2);
			lineTo(0, cast(int)height/2+3);
			lineTo(0, 3);
			closePath();
			fill();

			source = _state == ButtonState.Pressed ? Color.White : Color.Black;
			fontSize = 13;
			drawText(text, 5, height/2);
		}
		return;

	}
	public void paintFore(Graphics g) {
		auto extents = g.getTextExtents(text);
		g.drawText(text, (width-extents.width)/2, (height-extents.height)/2);
	}

public:
	/// Override this method in a subclass to handle the clicked event.
	protected void whenClicked(EventArgs e) { }
	/// This event occurs after the button has been clicked.
	Event!(whenClicked) clicked;

	this() {
		clicked.mainHandler = &whenClicked;
		_focusable = true;
	}
	this(string text) {
		this();
		this.text = text;
	}
	override Size bestSize() { return Theme.current.Button_bestSize(this); }
	ButtonState state() { return _state; }
	void state(ButtonState s) { _state = s; repaint(); }
}
