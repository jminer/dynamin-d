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

module dynamin.gui.theme;

import dynamin.core.string;
import dynamin.all_painting;
import dynamin.all_gui;
import dynamin.c.cairo;
import tango.stdc.stdlib;

/**
 * Draws a rectangle with 1 pixel wide lines inside the specified bounds. The
 * left and top are drawn with the first color, and the right and
 * bottom are drawn with the second color.
 */
void draw3dRectangle(Graphics g, real x, real y, real width, real height,
	Color c1, Color c2) {
	g.lineWidth = 1;

	g.source = c1;
	g.moveTo(x+0.5, y+height-1);
	g.lineTo(x+0.5, y+0.5);
	g.lineTo(x+width-1, y+0.5);
	g.stroke();

	g.source = c2;
	g.moveTo(x+width-0.5, y);
	g.lineTo(x+width-0.5, y+height-0.5);
	g.lineTo(x, y+height-0.5);
	g.stroke();
}

void drawCheckerboard(Graphics g, real x, real y, real width, real height,
	Color c1, Color c2, int squareSize = 1) {
	drawCheckerboard(g, Rect(x, y, width, height), c1, c2, squareSize);
}
void drawCheckerboard(Graphics g, Rect rect,
	Color c1, Color c2, int squareSize = 1) {
	int width = cast(int)rect.width;
	int height = cast(int)rect.height;
	auto format = c1.A == 255 && c2.A == 255 ?
		CAIRO_FORMAT_RGB24 : CAIRO_FORMAT_ARGB32;
	int* data = cast(int*)malloc(width*height*4);
	scope(exit) free(data);
	c1.R = c1.R*c1.A/255;
	c1.G = c1.G*c1.A/255;
	c1.B = c1.B*c1.A/255;
	c2.R = c2.R*c2.A/255;
	c2.G = c2.G*c2.A/255;
	c2.B = c2.B*c2.A/255;
	int pixel1 = *cast(int*)&c1;
	int pixel2 = *cast(int*)&c2;

	bool oddRow;
	int squareSize2 = squareSize * 2;
	for(int i = 0; i < height; ++i) {
		oddRow = i % squareSize2 < squareSize;
		for(int j = 0; j < width; ++j) {
			if(oddRow ^ j % squareSize2 < squareSize)
				data[j+i*width] = pixel1;
			else
				data[j+i*width] = pixel2;
		}
	}

	auto surface = cairo_image_surface_create_for_data(cast(char*)data, format, width, height, width*4);
	g.save();
	cairo_set_source_surface(g.handle, surface, rect.x, rect.y);
	g.rectangle(rect);
	g.fill();
	g.restore();
	cairo_surface_destroy(surface);
}

abstract class Theme {
static {
	int _curIndex = 0;
	Theme[] _themes;
	Theme[] getAll() { return _themes.dup; }
	void add(Theme theme) { // TODO: rename to register()?
		_themes.length = _themes.length+1;
		_themes[$-1] = theme;
	}
	Theme current() { return _themes[_curIndex]; }
	void current(Theme theme) {
		foreach(i, t; _themes) {
			if(t is theme) {
				_curIndex = i;
				// TODO: relayout all windows
			}
		}
	}
	//Theme system() { return ; }
}
	string name();

	//all theme methods follow

	// TODO: need to have bestSize, BorderSize, foreColor, backColor,
	//       Font, and Paint for all controls
	// TODO: have default imps for foreColor, backColor, and Font:
	//       { return Control_ForeColor; }
	//       { return Control_Font; }
	void Window_paint(Window c, Graphics g);
	Size Button_bestSize(Button c);
	void Button_paint(Button c, Graphics g);
	void CheckBox_paint(CheckBox c, Graphics g);
	void RadioButton_paint(CheckBox c, Graphics g);
	void ScrollBarTrack_paint(ScrollBarTrack c, Graphics g);
	void ScrollBarThumb_paint(ScrollBarThumb c, Graphics g);
	real ScrollBar_size();
	void ArrowButton_paint(ArrowButton c, Graphics g);
	BorderSize Scrollable_borderSize(Scrollable c);
	void Scrollable_paint(Scrollable c, Graphics g);
	BorderSize Notebook_borderSize(Notebook c);
	void Tab_paint(TabPage page, Notebook c, Graphics g);
	void Notebook_paint(Notebook c, Graphics g);
}


