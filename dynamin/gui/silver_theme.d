
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.gui.silver_theme;

import dynamin.core.string;
import dynamin.all_painting;
import dynamin.all_gui;
import dynamin.core.math;
import dynamin.c.cairo;

static this() {
	Theme.add(new SilverTheme());
}

/*
 * Colors used in this theme:
 * - Silver (192, 192, 192)
 * - Light Silver (220, 220, 220)
 * - Dark Silver (170, 170, 170)
 * - (150, 150, 150)
 */
class SilverTheme : Theme {
	string name() {
		return "Silver";
	}

	void Window_paint(Window c, Graphics g) {
		g.source = Color.Silver;
		g.paint();
	}
	Size Button_bestSize(Button c) {
		return Size(70, 25);
	}

	private Color _silver = Color(192, 192, 192);
	private Color _lightSilver = Color(220, 220, 220);
	private Color _darkSilver = Color(170, 170, 170);
	private Color _gray = Color(150, 150, 150);
	private Color _black = Color(0, 0, 0);
	private Color _white = Color(255, 255, 255);
	//{{{ common
	void drawButtonBack(Graphics g, double x, double y, double width, double height, ButtonState state) {
		with(g) {
			if(state == ButtonState.Normal)
				source = _silver;
			else if(state == ButtonState.Hot) {
				auto grad = cairo_pattern_create_radial(width/2, height, 0,
					width/2, height, height);
				cairo_pattern_add_color_stop_rgb(grad, 0, 0.863, 0.863, 0.863);
				cairo_pattern_add_color_stop_rgb(grad, 1, 0.753, 0.753, 0.753);
				cairo_set_source(handle, grad);
			} else if(state == ButtonState.Pressed)
				source = _darkSilver;
			roundedRectangle(x+0.5, y+0.5, width-1, height-1, 2);
			fill();

			if(state == ButtonState.Normal)
				source = _lightSilver;
			else if(state == ButtonState.Hot)
				source = _white;
			else if(state == ButtonState.Pressed)
				source = _gray;
			roundedRectangle(x+0.5, y+0.5, width-1, height-1, 2);
			stroke();
		}
	}
	//}}}

	void Button_paint(Button c, Graphics g) {
		with(g) {
			drawButtonBack(g, 0, 0, c.width, c.height, c.state);
			source = _black;
			c.paintFore(g);
		}
	}

	void CheckBox_paint(CheckBox c, Graphics g) {
		with(g) {
			Point box = Point(2, cast(int)(c.height/2-6));
			fontSize = 13;
			drawText(c.text, box.x+18, 2);

			source = c.state == ButtonState.Pressed ? Color.Black : Color.White;
			rectangle(box.x, box.y, 13, 13);
			fill();
			source = Color.Black;
			rectangle(box.x+0.5, box.y+0.5, 12, 12);
			stroke();
			if(c.state == ButtonState.Hot) {
				rectangle(box.x+1.5, box.y+1.5, 10, 10);
				stroke();
			}

			source = c.state == ButtonState.Pressed ? Color.White : Color.Black;
			if(c.checked) {
				moveTo(box.x+2.5, box.y+7.5);
				relLineTo(2, 3);
				relLineTo(6, -8);
				stroke();
			}
		}
	}
	void RadioButton_paint(CheckBox c, Graphics g) {
		with(g) {
			int radius = 6;
			Point circle = Point(2, cast(int)(c.height/2-radius));
			fontSize = 13;
			drawText(c.text, circle.x+18, 2);

			source = c.state == ButtonState.Pressed ? Color.Black : Color.White;
			ellipse(circle.x+radius, circle.y+radius, radius);
			fill();
			source = Color.Black;
			if(c.state == ButtonState.Hot) {
				lineWidth = 2;
				ellipse(circle.x+radius, circle.y+radius, radius-1);
			} else {
				ellipse(circle.x+radius, circle.y+radius, radius-0.5);
			}
			stroke();
			lineWidth = 1;

			source = c.state == ButtonState.Pressed ? Color.White : Color.Black;
			if(c.checked) {
				ellipse(circle.x+radius, circle.y+radius, radius-4);
				fill();
			}
		}
	}

	void ScrollBarTrack_paint(ScrollBarTrack c, Graphics g) {
		if(c.state == ButtonState.Pressed)
			g.paint();
		else if(isOdd(cast(int)round(c.x)) || isOdd(cast(int)round(c.y)))
			drawCheckerboard(g, 0, 0, c.width, c.height,
				Color.White, Color.Black);
		else
			drawCheckerboard(g, 0, 0, c.width, c.height,
				Color.Black, Color.White);
	}

	void ScrollBarThumb_paint(ScrollBarThumb c, Graphics g) {
		with(g) {
			source = Color.White;
			paint();
			source = Color.Black;
			rectangle(0.5, 0.5, c.width-1, c.height-1);
			stroke();
		}
	}

	double ScrollBar_size() {
		// TODO: all themes should get this from SystemGui.ScrollBarSize
		return 18;
	}

	void ArrowButton_paint(ArrowButton c, Graphics g) {
		Button_paint(c, g);
	}

	BorderSize Scrollable_borderSize(Scrollable c) {
		return BorderSize(1, 1, 1, 1);
	}

	void Scrollable_paint(Scrollable c, Graphics g) {
		g.source = Color.White;
		g.paint();
		g.source = Color.Black;
		g.rectangle(0.5, 0.5, c.width-0.5, c.height-0.5);
		g.stroke();
	}

	BorderSize Notebook_borderSize(Notebook c) {
		return BorderSize(1, 1, 1, 1);
	}
	void Tab_paint(TabPage page, Notebook c, Graphics g){
		g.translate(page.tabLocation);
		g.drawText(page.text, 5, (page.tabSize.height-g.getTextExtents(page.text).height)/2);
		g.translate(-page.tabLocation);
	}
	void Notebook_paint(Notebook c, Graphics g){}

}

