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

module dynamin.gui.windows_theme;

import dynamin.core.string;
import dynamin.all_painting;
import dynamin.all_gui;
import tango.io.Stdout;
import Utf = tango.text.convert.Utf;
version(Windows) import dynamin.c.windows;
version(Windows) import dynamin.c.windows_tmschema;
import dynamin.gui_backend;

version(Windows) {
} else {
enum {
	COLOR_SCROLLBAR       = 0,
	COLOR_BACKGROUND      = 1,
	COLOR_ACTIVECAPTION   = 2,
	COLOR_INACTIVECAPTION = 3,
	COLOR_MENU            = 4,
	COLOR_WINDOW          = 5,
	COLOR_WINDOWFRAME     = 6,
	COLOR_MENUTEXT        = 7,
	COLOR_WINDOWTEXT      = 8,
	COLOR_CAPTIONTEXT     = 9,
	COLOR_ACTIVEBORDER    = 10,
	COLOR_INACTIVEBORDER  = 11,
	COLOR_APPWORKSPACE    = 12,
	COLOR_HIGHLIGHT       = 13,
	COLOR_HIGHLIGHTTEXT   = 14,
	COLOR_BTNFACE         = 15,
	COLOR_BTNSHADOW       = 16,
	COLOR_GRAYTEXT        = 17,
	COLOR_BTNTEXT         = 18,
	COLOR_INACTIVECAPTIONTEXT = 19,
	COLOR_BTNHIGHLIGHT    = 20,

	COLOR_3DDKSHADOW      = 21,
	COLOR_3DLIGHT         = 22,
	COLOR_INFOTEXT        = 23,
	COLOR_INFOBK          = 24,

	COLOR_HOTLIGHT        = 26,
	COLOR_GRADIENTACTIVECAPTION = 27,
	COLOR_GRADIENTINACTIVECAPTION = 28,
	COLOR_MENUHILIGHT     = 29,
	COLOR_MENUBAR         = 30,

	COLOR_DESKTOP         = COLOR_BACKGROUND,
	COLOR_3DFACE          = COLOR_BTNFACE,
	COLOR_3DSHADOW        = COLOR_BTNSHADOW,
	COLOR_3DHIGHLIGHT     = COLOR_BTNHIGHLIGHT,
	COLOR_3DHILIGHT       = COLOR_BTNHIGHLIGHT,
	COLOR_BTNHILIGHT      = COLOR_BTNHIGHLIGHT
}
}

/**
 * This file/module, even though it starts with 'windows_', is not part
 * of the windows backend. It is a theme that should run on any system,
 * but can only show visual styles under Windows because the
 * Windows API is needed.
 */

static this() {
	Theme.add(new WindowsTheme());
}

/**
 * This theme should work with any backend, but can only paint the Windows
 * classic look if not on Windows XP, Vista, or newer.
 */
class WindowsTheme : Theme {
version(Windows) {
	static string defaultFont() { // TODO: rename
		NONCLIENTMETRICS ncMetrics;
		ncMetrics.cbSize = NONCLIENTMETRICS.sizeof;
		SystemParametersInfo(SPI_GETNONCLIENTMETRICS,
			NONCLIENTMETRICS.sizeof, &ncMetrics, 0);
		// TODO: need to strip the nulls off the name
		return Utf.toString(ncMetrics.lfMessageFont.lfFaceName);
	}
}
version(Windows) {
	static void printSysColors() {
		int[string] colors = [
		"COLOR_SCROLLBAR"[] : COLOR_SCROLLBAR,
		"COLOR_BACKGROUND" : COLOR_BACKGROUND,
		"COLOR_ACTIVECAPTION" : COLOR_ACTIVECAPTION,
		"COLOR_INACTIVECAPTION" : COLOR_INACTIVECAPTION,
		"COLOR_MENU" : COLOR_MENU,
		"COLOR_WINDOW" : COLOR_WINDOW,
		"COLOR_WINDOWFRAME" : COLOR_WINDOWFRAME,
		"COLOR_MENUTEXT" : COLOR_MENUTEXT,
		"COLOR_WINDOWTEXT" : COLOR_WINDOWTEXT,
		"COLOR_CAPTIONTEXT" : COLOR_CAPTIONTEXT,
		"COLOR_ACTIVEBORDER" : COLOR_ACTIVEBORDER,
		"COLOR_INACTIVEBORDER" : COLOR_INACTIVEBORDER,
		"COLOR_APPWORKSPACE" : COLOR_APPWORKSPACE,
		"COLOR_HIGHLIGHT" : COLOR_HIGHLIGHT,
		"COLOR_HIGHLIGHTTEXT" : COLOR_HIGHLIGHTTEXT,
		"COLOR_BTNFACE" : COLOR_BTNFACE,
		"COLOR_BTNSHADOW" : COLOR_BTNSHADOW,
		"COLOR_GRAYTEXT" : COLOR_GRAYTEXT,
		"COLOR_BTNTEXT" : COLOR_BTNTEXT,
		"COLOR_INACTIVECAPTIONTEXT" : COLOR_INACTIVECAPTIONTEXT,
		"COLOR_BTNHIGHLIGHT" : COLOR_BTNHIGHLIGHT,
		"COLOR_3DDKSHADOW" : COLOR_3DDKSHADOW,
		"COLOR_3DLIGHT" : COLOR_3DLIGHT,
		"COLOR_INFOTEXT" : COLOR_INFOTEXT,
		"COLOR_INFOBK" : COLOR_INFOBK,
		"COLOR_HOTLIGHT" : COLOR_HOTLIGHT,
		"COLOR_GRADIENTACTIVECAPTION" : COLOR_GRADIENTACTIVECAPTION,
		"COLOR_GRADIENTINACTIVECAPTION" : COLOR_GRADIENTINACTIVECAPTION,
		"COLOR_MENUHILIGHT" : COLOR_MENUHILIGHT,
		"COLOR_MENUBAR" : COLOR_MENUBAR,

		"COLOR_DESKTOP" : COLOR_DESKTOP,
		"COLOR_3DFACE" : COLOR_3DFACE,
		"COLOR_3DSHADOW" : COLOR_3DSHADOW,
		"COLOR_3DHIGHLIGHT" : COLOR_3DHIGHLIGHT,
		"COLOR_3DHILIGHT" : COLOR_3DHILIGHT,
		"COLOR_BTNHILIGHT" : COLOR_BTNHILIGHT
		];
		foreach(key, value; colors)
			Stdout.format("{,-27} : {}", key, getColor(value).toUtf8).newline;

	}
}
	static Color getColor(int index) {
version(Windows) {
		uint sysColor = GetSysColor(index);
		return Color(GetRValue(sysColor), GetGValue(sysColor), GetBValue(sysColor));
} else {
		return Color.Black; // TODO: temp to get X backend to compile

		uint sysColor = 0;
		switch(sysColor) {
		default:
			assert(0, "error: default case hit");
		}
}
	}

	//{{{ utility functions
	int findUxState(Button c, int disabled, int normal, int hot, int pressed) {
		if(c.state == ButtonState.Normal)
			return normal;
		else if(c.state == ButtonState.Hot)
			return hot;
		else if(c.state == ButtonState.Pressed)
			return pressed;
	}

	/// draws a classic check, which is 7 wide and 7 high
	void drawCheck(Graphics g, real x, real y) {
		g.source = getColor(COLOR_WINDOWTEXT);
		auto checkYs = [2, 3, 4, 3, 2, 1, 0];
		foreach(i, cy; checkYs) {
			g.moveTo(x + i + 0.5, y + cy);
			g.lineTo(x + i + 0.5, y + cy + 3);
			g.stroke();
		}
	}
	//}}}

	string name() {
		return "Windows";
	}

	void Window_paint(Window c, Graphics g) {
		g.source = getColor(COLOR_3DFACE);
		g.paint();
	}
	//{{{ Button
	Size Button_bestSize(Button c) {
		// default button size is 17 points tall
		return Size(75, 23);
	}

	void Button_paint(Button c, Graphics g) {
version(Windows) {
		if(Ux.isThemeActive()) {
			auto uxState = findUxState(c, PBS_DISABLED, PBS_NORMAL, PBS_HOT, PBS_PRESSED);
			Ux.drawBackground(g, Rect(0, 0, c.width, c.height), "BUTTON", BP_PUSHBUTTON, uxState);

			g.source = getColor(COLOR_WINDOWTEXT);
			c.paintFore(g);
			return;
		}
}
		g.source = getColor(COLOR_3DFACE);
		g.paint();
		if(c.state == ButtonState.Pressed) {
			draw3dRectangle(g, 0, 0, c.width, c.height,
				getColor(COLOR_3DDKSHADOW), getColor(COLOR_3DHIGHLIGHT));
			draw3dRectangle(g, 1, 1, c.width-2, c.height-2,
				getColor(COLOR_3DSHADOW), getColor(COLOR_3DLIGHT));
		} else {
			draw3dRectangle(g, 0, 0, c.width, c.height,
				getColor(COLOR_3DHIGHLIGHT), getColor(COLOR_3DDKSHADOW));
			draw3dRectangle(g, 1, 1, c.width-2, c.height-2,
				getColor(COLOR_3DLIGHT), getColor(COLOR_3DSHADOW));
		}
		if(c.focused) {
			g.source = getColor(COLOR_WINDOWTEXT);
			g.setDash([1, 1], 0.5);
			g.rectangle(3.5, 3.5, c.width-7, c.height-7);
			g.stroke();
		}
		g.source = getColor(COLOR_WINDOWTEXT);
		c.paintFore(g);
	}
	//}}}

	//{{{ CheckBox
	void CheckBox_paint(CheckBox c, Graphics g) {
version(Windows) {
		if(Ux.isThemeActive()) {
			int uxState;
			if(c.checked) {
				uxState = findUxState(c, CBS_CHECKEDDISABLED, CBS_CHECKEDNORMAL, CBS_CHECKEDHOT, CBS_CHECKEDPRESSED);
			} else {
				uxState = findUxState(c, CBS_UNCHECKEDDISABLED, CBS_UNCHECKEDNORMAL, CBS_UNCHECKEDHOT, CBS_UNCHECKEDPRESSED);
			}
			Ux.drawBackground(g, Rect(0, 0, 13, c.height), "BUTTON", BP_CHECKBOX, uxState);

			g.source = getColor(COLOR_WINDOWTEXT);
			g.translate(15, 0);
			c.paintFore(g);
			return;
		}
}

		if(c.state == ButtonState.Pressed)
			g.source = getColor(COLOR_3DFACE);
		else
			g.source = getColor(COLOR_WINDOW);

		g.rectangle(0, 0, 13, 13);
		g.fill();
		draw3dRectangle(g, 0, 0, 13, 13,
			getColor(COLOR_3DSHADOW), getColor(COLOR_3DHIGHLIGHT));
		draw3dRectangle(g, 1, 1, 11, 11,
			getColor(COLOR_3DDKSHADOW), getColor(COLOR_3DLIGHT));

		if(c.checked)
			drawCheck(g, 3, 3);
		//	drawCheck(g, 0, 0, 13, 13);

		g.source = getColor(COLOR_WINDOWTEXT);
		g.translate(15, 0);
		c.paintFore(g);
	}
	//}}}

	//{{{ RadioButton
	void RadioButton_paint(CheckBox c, Graphics g) {
version(Windows) {
		if(Ux.isThemeActive()) {
			int uxState;
			if(c.checked) {
				uxState = findUxState(c, RBS_CHECKEDDISABLED, RBS_CHECKEDNORMAL, RBS_CHECKEDHOT, RBS_CHECKEDPRESSED);
			} else {
				uxState = findUxState(c, RBS_UNCHECKEDDISABLED, RBS_UNCHECKEDNORMAL, RBS_UNCHECKEDHOT, RBS_UNCHECKEDPRESSED);
			}
			Ux.drawBackground(g, Rect(0, 0, 13, c.height), "BUTTON", BP_RADIOBUTTON, uxState);

			g.source = getColor(COLOR_WINDOWTEXT);
			g.translate(15, 0);
			c.paintFore(g);
			return;
		}
}

		if(c.state == ButtonState.Pressed)
			g.source = getColor(COLOR_3DFACE);
		else
			g.source = getColor(COLOR_WINDOW);

		g.rectangle(2, 2, 8, 8);
		g.fill();
		const double[][] outerLines = [
		[1.5, 8,   1.5, 10],  [0.5, 4,   0.5, 8],
		[1.5, 2,   1.5, 4],   [2.0, 1.5,   4, 1.5],
		[4.0, 0.5,   8, 0.5], [8.0, 1.5,   10, 1.5]];
		const double[][] innerLines = [
		[2.5, 8,   2.5, 9],  [1.5, 4,   1.5, 8],
		[2.5, 2,   2.5, 4],   [3.0, 2.5,   4, 2.5],
		[4.0, 1.5,   8, 1.5], [8.0, 2.5,   10, 2.5]];
		g.source = getColor(COLOR_3DSHADOW);
		foreach(line; outerLines) {
			g.moveTo(line[0], line[1]);
			g.lineTo(line[2], line[3]);
			g.stroke();
		}
		g.source = getColor(COLOR_3DDKSHADOW);
		foreach(line; innerLines) {
			g.moveTo(line[0], line[1]);
			g.lineTo(line[2], line[3]);
			g.stroke();
		}
		g.source = getColor(COLOR_3DHIGHLIGHT);
		foreach(line; outerLines) {
			g.moveTo(12-line[0], 12-line[1]);
			g.lineTo(12-line[2], 12-line[3]);
			g.stroke();
		}
		g.source = getColor(COLOR_3DLIGHT);
		foreach(line; innerLines) {
			g.moveTo(12-line[0], 12-line[1]);
			g.lineTo(12-line[2], 12-line[3]);
			g.stroke();
		}

		if(c.checked) {
			g.source = getColor(COLOR_WINDOWTEXT);
			g.translate(4, 4);
			g.rectangle(1, 0, 2, 1);
			g.rectangle(0, 1, 4, 2);
			g.rectangle(1, 3, 2, 1);
			g.fill();
			g.translate(-4, -4);
		}

		g.source = getColor(COLOR_WINDOWTEXT);
		g.translate(15, 0);
		c.paintFore(g);
	}
	//}}}

	//{{{ ScrollBar
	void ScrollBarTrack_paint(ScrollBarTrack c, Graphics g) {
version(Windows) {
		if(Ux.isThemeActive()) {
			auto uxState = findUxState(c, SCRBS_DISABLED, SCRBS_NORMAL, SCRBS_HOT, SCRBS_PRESSED);
			if(cast(VScrollBar)c.parent) {
				Ux.drawBackground(g, Rect(0, 0, c.width, c.height), "SCROLLBAR", SBP_UPPERTRACKVERT, uxState);
			} else {
				Ux.drawBackground(g, Rect(0, 0, c.width, c.height), "SCROLLBAR", SBP_UPPERTRACKHORZ, uxState);
			}
			return;
		}
}

	Color c1 = getColor(COLOR_3DHIGHLIGHT), c2 = getColor(COLOR_SCROLLBAR);
	if(c.state == ButtonState.Pressed) {
		c1.invert();
		c2.invert();
	}
	int x = cast(int)round(c.x), y = cast(int)round(c.y);
	drawCheckerboard(g, -(x & 1), -(y & 1), c.width + 1, c.height + 1,
		c1, c2);
	}

	void ScrollBarThumb_paint(ScrollBarThumb c, Graphics g) {
version(Windows) {
		if(Ux.isThemeActive()) {
			auto uxState = findUxState(c, SCRBS_DISABLED, SCRBS_NORMAL, SCRBS_HOT, SCRBS_PRESSED);
			if(cast(VScrollBar)c.parent) {
				Ux.drawBackground(g, Rect(0, 0, c.width, c.height), "SCROLLBAR", SBP_THUMBBTNVERT, uxState);
				if(c.height > 16)
					Ux.drawBackground(g, Rect(0, 0, c.width, c.height), "SCROLLBAR", SBP_GRIPPERVERT, 0);
			} else {
				Ux.drawBackground(g, Rect(0, 0, c.width, c.height), "SCROLLBAR", SBP_THUMBBTNHORZ, uxState);
				if(c.width > 16)
					Ux.drawBackground(g, Rect(0, 0, c.width, c.height), "SCROLLBAR", SBP_GRIPPERHORZ, 0);
			}
			return;
		}
}

		g.source = getColor(COLOR_3DFACE);
		g.paint();
		draw3dRectangle(g, 0, 0, c.width, c.height,
			getColor(COLOR_3DLIGHT), getColor(COLOR_3DDKSHADOW));
		draw3dRectangle(g, 1, 1, c.width-2, c.height-2,
			getColor(COLOR_3DHIGHLIGHT), getColor(COLOR_3DSHADOW));
	}

	real ScrollBar_size() {
		// TODO: all themes should get this from SystemGui.ScrollBarSize
	version(Windows)
		return GetSystemMetrics(SM_CXVSCROLL);
	else
		return 18;
	}

	void ArrowButton_paint(ArrowButton c, Graphics g) {
version(Windows) {
		if(Ux.isThemeActive()) {
			int uxState;
			if(c.direction == ArrowDirection.Left)
				uxState = findUxState(c, ABS_LEFTDISABLED, ABS_LEFTNORMAL, ABS_LEFTHOT, ABS_LEFTPRESSED);
			else if(c.direction == ArrowDirection.Right)
				uxState = findUxState(c, ABS_RIGHTDISABLED, ABS_RIGHTNORMAL, ABS_RIGHTHOT, ABS_RIGHTPRESSED);
			else if(c.direction == ArrowDirection.Up)
				uxState = findUxState(c, ABS_UPDISABLED, ABS_UPNORMAL, ABS_UPHOT, ABS_UPPRESSED);
			else
				uxState = findUxState(c, ABS_DOWNDISABLED, ABS_DOWNNORMAL, ABS_DOWNHOT, ABS_DOWNPRESSED);
			Ux.drawBackground(g, Rect(0, 0, c.width, c.height), "SCROLLBAR", SBP_ARROWBTN, uxState);
			return;
		}
}

		g.source = getColor(COLOR_3DFACE);
		g.paint();
		if(c.state == ButtonState.Pressed) {
			g.source = getColor(COLOR_3DDKSHADOW);
			g.rectangle(0.5, 0.5, c.width-1, c.height-1);
			g.stroke();
		} else {
			draw3dRectangle(g, 0, 0, c.width, c.height,
				getColor(COLOR_3DLIGHT), getColor(COLOR_3DDKSHADOW));
			draw3dRectangle(g, 1, 1, c.width-2, c.height-2,
				getColor(COLOR_3DHIGHLIGHT), getColor(COLOR_3DSHADOW));
		}
	}
	//}}}

	//{{{ Scrollable
	BorderSize Scrollable_borderSize(Scrollable c) {
		return BorderSize(2, 2, 2, 2);
	}

	void Scrollable_paint(Scrollable c, Graphics g) {
version(Windows) {
		if(Ux.isThemeActive()) {
			Ux.drawBackground(g, Rect(0, 0, c.width, c.height), "EDIT", EP_EDITTEXT, ETS_NORMAL);
			// TODO: get this working
			//g.Source = c.backColor;
			g.source = getColor(COLOR_WINDOW);
			g.rectangle(1.5, 1.5, c.width-3, c.height-3);
			g.stroke();
			return;
		}
}
		draw3dRectangle(g, 0, 0, c.width, c.height,
			getColor(COLOR_3DSHADOW), getColor(COLOR_3DHIGHLIGHT));
		draw3dRectangle(g, 1, 1, c.width-2, c.height-2,
			getColor(COLOR_3DDKSHADOW), getColor(COLOR_3DLIGHT));
	}
	//}}}

	//{{{ Notebook
	BorderSize Notebook_borderSize(Notebook c) {
version(Windows) {
		if(Ux.isThemeActive())
			return BorderSize(2, 2, 4, 4);
}
		return BorderSize(2, 2, 2, 2);
	}
	void Tab_paint(TabPage page, Notebook c, Graphics g) {
version(Windows) {
		if(Ux.isThemeActive()) {
			g.translate(page.tabLocation);
			//auto uxState = findUxState(c, PBS_DISABLED, PBS_NORMAL, PBS_HOT, PBS_PRESSED);
			auto uxState = TIS_NORMAL;
			BorderSize selectedDelta;
			if(page is c.selectedTabPage) {
				uxState = TIS_SELECTED;
				selectedDelta = BorderSize(2, 2, 2, 2);
			}
			Ux.drawBackground(g, Point() + page.tabSize + selectedDelta, "TAB", TABP_TABITEM, uxState);
			g.drawText(page.text, 5, (page.tabSize.height-g.getTextExtents(page.text).height)/2);
			g.translate(-page.tabLocation);
			return;
		}
}
		g.translate(page.tabLocation);
		g.source = getColor(COLOR_3DHIGHLIGHT);
		g.moveTo(0.5, 2);
		g.lineTo(0.5, page.tabSize.height);
		g.moveTo(1, 1.5);
		g.lineTo(2, 1.5);
		g.moveTo(2, 0.5);
		g.lineTo(page.tabSize.width-2, 0.5);
		g.stroke();
		g.source = Color(128, 128, 128);
		g.moveTo(page.tabSize.width-1.5, 2);
		g.lineTo(page.tabSize.width-1.5, page.tabSize.height);
		g.stroke();
		g.source = Color(64, 64, 64);
		g.moveTo(page.tabSize.width-2, 1.5);
		g.lineTo(page.tabSize.width-1, 1.5);
		g.moveTo(page.tabSize.width-0.5, 2);
		g.lineTo(page.tabSize.width-0.5, page.tabSize.height);
		g.stroke();
		g.source = getColor(COLOR_WINDOWTEXT);
		g.drawText(page.text, 5, (page.tabSize.height-g.getTextExtents(page.text).height)/2);
		g.translate(-page.tabLocation);
	}
	void Notebook_paint(Notebook c, Graphics g) {
version(Windows) {
		if(Ux.isThemeActive()) {
			//auto uxState = findUxState(c, PBS_DISABLED, PBS_NORMAL, PBS_HOT, PBS_PRESSED);
			Ux.drawBackground(g, Rect(0, c._tabAreaSize, c.width, c.height-c._tabAreaSize), "TAB", TABP_PANE, 0);
			g.save();
			g.rectangle(4, 4, c.width-8, c.height-8);
			g.clip();
			for(float i = 4; i < c.width-8+10; i += 10)
				Ux.drawBackground(g, Rect(i, c._tabAreaSize+4, 10, c.height*1.7-8-(c._tabAreaSize+4)), "TAB", TABP_BODY, 0);
			g.restore();

			return;
		}
}
		draw3dRectangle(g, 0, c._tabAreaSize, c.width, c.height,
			getColor(COLOR_3DHIGHLIGHT), Color(64, 64, 64));
		draw3dRectangle(g, 1, c._tabAreaSize+1, c.width-2, c.height-2,
			Color(212, 208, 200), Color(128, 128, 128));

	}
	//}}}

}

