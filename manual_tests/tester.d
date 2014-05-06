
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

import tango.io.Stdout;
import tango.util.Convert;
import dynamin.c.windows;
import dynamin.c.cairo;
import dynamin.all;
import tango.math.Math;
import dynamin.gui_backend;
import dynamin.c.windows_tmschema;

void drawProgressCircle(double progress, Graphics g,
	double x, double y, double width, double height) {
	with(g) {
		cairo_t* cr = g.handle;
		double xc = x+width/2;
		double yc = y+height/2;
		save();
		rectangle(x, y, width, height);
		clip();
		cairo_push_group(cr);
		operator = GraphicsOperator.Saturate;
		// completed part
		auto grad = cairo_pattern_create_linear(x+width, y, x, y+height);
		cairo_pattern_add_color_stop_rgba(grad, 0, 1, .75, 0, 1);
		cairo_pattern_add_color_stop_rgba(grad, 1, .7, .35, 0, 1);
		cairo_set_source(cr, grad);
		cairo_pattern_destroy(grad);
		moveTo(xc, yc);
		arc(xc, yc, width/2, height/2, -Pi/2, Pi*2*progress-Pi/2);
		fill();

		// uncompleted part
		grad = cairo_pattern_create_linear(x+width, y, x, y+height);
		cairo_pattern_add_color_stop_rgba(grad, 0, .7, .7, .7, 1);
		cairo_pattern_add_color_stop_rgba(grad, 1, .3, .3, .3, 1);
		cairo_set_source(cr, grad);
		cairo_pattern_destroy(grad);
		moveTo(xc, yc);
		if(floatsEqual(progress, 0, 0.00001))
			ellipse(xc, yc, width/2, height/2);
		else
			arc(xc, yc, width/2, height/2, Pi*2*progress-Pi/2, -Pi/2);
		fill();

		cairo_pop_group_to_source(cr);
		cairo_paint(cr);
		restore();
	}
}

//import dynamin.gui.windows_theme;
int main(char[][] args) {
	Theme.current = Theme.getAll[2];

	/*for(int i = 0; i < 100; i++)
		writeLine("This is a test of console speed!");
	auto t1 = Environment.runningTime;
	for(int i = 0; i < 20000; i++)
		writeLine("This is a test of console speed!");
	auto t2 = Environment.runningTime;*/

	/*Window win = new Window();
	win.content.backColor = Color.White;
	win.content.painting += (PaintingEventArgs e) {
	};
	win.location = Point(90, 40);
	win.size = Size(200, 200);
	win.text = "Title";
	win.visible = true;
	Application.run(win);
	return 0;*/
	version(Windows) WindowsTheme.printSysColors();

	//prototype code of an AnchorLayout:
	static if(0) {
		Window window;
		Button okButton, cancelButton, applyButton;
		// all the controls have already been added to _window_
		auto buttons = [okButton, cancelButton, applyButton];

		window.Anchor(Hook.Right,  buttons,      Hook.Right, window);
		window.Anchor(Hook.Top,    okButton,     Hook.Top,   window);
		window.Anchor(Hook.Bottom, okButton,     Hook.Top,   cancelButton);
		window.Anchor(Hook.Bottom, cancelButton, Hook.Top,   applyButton);
	}

	static if(0) {
		// TODO: figure out the best way to error check
		// 1) XML must be well-formed (handled entirely by parser)
		// 2) <note> node should only contain one <color>, one <date>, etc
		reader = new XmlReader();
		foreach(n; reader.RootNode) {
			if(n.Name == "note") {
				foreach(n2; n) {
					if(n2.Name == "date") {
					} else if(n2.Name == "color") {
					} else if(n2.Name == "text") {
						WriteLine(n2.text);
					}
				}
			} else if(n.Name == "event") {
			}
		}
	}

	Window w = new Window;
	//w.Resizable = false;
	float x, y;
	bool drawEllipse = true;
	w.content.mouseDragged += (MouseEventArgs e) {
		x = e.x;
		y = e.y;
		w.content.repaint();
	};
	//Stdout("font: "~WindowsTheme.DefaultFont).newline;
	foreach(t; Theme.getAll())
		Stdout(t.name).newline;
	//auto logo = Image.load(`./web/logo.png`);
	w.content.painting += (PaintingEventArgs e) {
		drawCheckerboard(e.graphics, 250, 50, 20, 60, Color.White, Color.Black);
		draw3dRectangle(e.graphics, 100, 200, 75, 23, Color.Orange, Color.Green);
		//if(Ux.isThemeActive)
			//Ux.drawBackground(e.graphics, Rect(x-20, y+60, 75, 23), "BUTTON", BP_PUSHBUTTON, PBS_NORMAL);
		with(e.graphics) {
			source = Color.Green;
			lineWidth = 15;
			moveTo(0, 5);
			lineTo(w.width, 5);
			stroke();
			fontSize = 60;
			drawText("Translucent gradients!", 10, 70);
			lineWidth = 1;
			if(drawEllipse) {
				ellipse(x, y, 100, 50);
				fill();
			} else {
				int sides = 10;
				int radius = 70;
				auto pts = new Point[sides];
				for(int i = 0; i < sides; ++i) {
					double arcDist = 3.14159*2*i/sides;
					pts[i] = Point(x+radius*sin(arcDist), y-radius*cos(arcDist));
				}
				moveTo(pts[0]);
				// to draw a regular polygon
				//foreach(pt; pts)
				//	LineTo(pt);
				// to draw a star
				int opp;
				foreach(i, pt; pts) {
					opp = i + sides/2 + 1;
					if(opp >= pts.length)
						opp -= sides;
					lineTo(pt);
					lineTo(pts[opp]);
				}
				// end star drawing
				closePath();
				fill();
			}

			static progress = 0.;
			progress += .01;
			if(progress > 1)
				progress = 0;
			drawProgressCircle(progress, e.graphics, x-100, y-100, 50, 50);

			//drawImage(logo, 100, 10);
		}
	};
	w.content.mouseDown += (MouseEventArgs e) {
		static long startTime;
		Stdout.format("elapsed: {}", Environment.runningTime-startTime).newline;
		startTime = Environment.runningTime;

		drawEllipse = !drawEllipse;
		w.content.repaint();
		if(e.button == MouseButton.Right) {
			if(w.borderStyle == 3)
				w.borderStyle = WindowBorderStyle.None;
			else
				w.borderStyle = cast(WindowBorderStyle)(w.borderStyle+1);
		}
	};
	w.content.mouseTurned += (MouseTurnedEventArgs e) {
		Stdout.format("MouseTurned, {}", e.scrollAmount).newline;
		//Stdout.format("runningTime: {:.1} min", Environment.runningTime/1000.0/60).newline;

		/*auto first = Environment.runningTime;
		int m = 0;
		while(Environment.runningTime < first+1000)
			m++;
		Stdout.format("called [] times", m).newline;*/

	};
	w.content.mouseMoved += (MouseEventArgs e) {
		//if(w.getChildAtPoint(e.location) !is null)
		//	Stdout("Over button").newline;
	};
	auto b = new Button();
	with(b) {
		text = "Push Me!";
		location = Point(50, 80);
		size = Size(100, 23);
		b.clicked += { w.location = [50, 70]; w.size = [501, 301]; writeLine("You pushed me!"); };
		mouseUp += (MouseEventArgs e) { writeLine("e.X="~to!(string)(e.x)~", e.Y="~to!(string)(e.y)); };
	}
	w.content.add(b);
	b = new Button();
	with(b) {
		text = "Open File...";
		location = [50, 120];
		size = [100, 23];
		cursor = Cursor.Wait;
		b.clicked += {
			auto dialog = new OpenFileDialog;
			dialog.addFilter("Portable Network Graphics (*.png)", "png");
			dialog.multipleSelection = true;
			if(dialog.showDialog() == DialogResult.OK) {
				foreach(f; dialog.files)
					Stdout(f).newline;
			}
		};
	}
	w.content.add(b);
	b = new Button();
	with(b) {
		text = "Open Folder...";
		location = Point(50, 160);
		size = Size(100, 23);
		clicked += {
			auto dialog = new FolderDialog;
			dialog.folder = "c:\\";
			if(dialog.showDialog() == DialogResult.OK)
				Stdout(dialog.folder).newline;
		};
	}
	w.content.add(b);
	b = new Button();
	with(b) {
		text = "Paste";
		location = [170, 120];
		size = [100, 23];
		b.clicked += {
			if(Clipboard.containsText)
				Stdout(Clipboard.getText()).newline;
		};
	}
	w.content.add(b);

	b = new Button();
	with(b) {
		text = "Copy";
		location = [170, 90];
		size = [100, 23];
		b.clicked += {
			Clipboard.setText("Howdy, I come from the clipboard!");
		};
	}
	w.content.add(b);

	auto cb = new CheckBox();
	with(cb) {
		text = "Resizable";
		location = [280, 120];
		size = [100, 23];
		checkedChanged += {
			w.resizable = cb.checked;
		};
	}
	w.content.add(cb);

	b = new Button();
	with(b) {
		text = "Recreate Handle";
		location = [170, 160];
		size = [100, 23];
		b.clicked += {
			w.recreateHandle;
		};
	}
	w.content.add(b);

	b.mouseEntered += {
		Stdout.format("here").newline;

		ICONINFO iconInfo;
		GetIconInfo(IDC_HAND, &iconInfo);
		HICON icon = CreateIconIndirect(&iconInfo);
		Stdout(iconInfo).newline;
		SetCursor(icon);
	};


	//auto panel = new Panel;
	//panel.location = [200, 200];
	//panel.size = [80, 40];
	//panel.Painting += (PaintingEventArgs args) {
	//	args.Graphics.Rectangle(1, 1, 75, 35);
	//	args.Graphics.Stroke();
	//};
	//	b.location = [5, 5];
	//	b.size = [100, 23];
	//panel.add(b);
	//w.content.add(panel);

	auto tb = new TextBox;
	tb.text = "Hello";
	tb.location = [300, 150];
	tb.size = tb.bestSize;
	w.content.add(tb);

	auto rb1 = new RadioButton;
	rb1.text = "Option 1";
	rb1.location = [400, 120];
	rb1.size = rb1.bestSize;
	w.content.add(rb1);

	auto rb2 = new RadioButton;
	rb2.text = "Option 2!";
	rb2.location = [400, 140];
	rb2.size = rb1.bestSize;
	w.content.add(rb2);

	auto rb3 = new RadioButton;
	rb3.text = "Option 3";
	rb3.location = [400, 160];
	rb3.size = rb1.bestSize;
	w.content.add(rb3);

	static if(true) {
		auto scrollBar = new VScrollBar;
		w.content.resized += {
			scrollBar.location = [w.content.width-19, 0];
			scrollBar.size = [19.0, w.content.height];
		};
	} else {
		auto scrollBar = new HScrollBar;
		w.content.Resized += {
			scrollBar.location = [0.0, w.content.Height-19];
			scrollBar.size = [w.content.Width, 19.0];
		};
	}
	scrollBar.maxValue = 10;
	w.content.add(scrollBar);
	scrollBar.valueChanged += {
		Stdout.format("value is now {}", scrollBar.value).newline;
	};

	Notebook notebook;
	with(notebook = new Notebook) {
		location = [20, 200];
		size = [390, 360];

		TabPage page;
		page = new TabPage;
		page.text = "Tab 1";
		page.content = new Button;
		tabPages.add(page);

		page = new TabPage;
		page.text = "Tab2";
		page.content = new TextBox;
		tabPages.add(page);
	}
	w.content.add(notebook);

	auto input = new Label("Input:");
	auto inputBox = new TextBox;

	auto type = new Label("Input type:");
	auto textType = new RadioButton("Text");
	auto dataType = new RadioButton("Data");

	auto direction = new Label("Direction:");
	auto backward = new RadioButton("Backward");
	auto forward = new RadioButton("Forward");

	auto relative = new CheckBox("Relative");

	auto find = new Button("Find");
	auto close = new Button("Close");

	auto range = new CheckBox("Use range");
	auto start = new Label("Start offset:");
	auto startBox = new TextBox;
	auto end = new Label("End:");
	auto endBox = new TextBox;
	//forward.elasticY = true;
	Window layoutWin = new Window("Find");
	layoutWin.content = mixin(createLayout(`
		H( V( H(input inputBox)
		      H( V(type textType dataType) * V(direction backward forward) * )
		      relative range T[2](start startBox H(*end) endBox) )
			V(find close) ) `));
	//layoutWin.content = mixin(createLayout(r"H(*T[1]( * start find close ))"));
	layoutWin.content.defaultButton = find;
	layoutWin.visible = true;

	//Stdout(w.borderSize.toString).newline;
	//w.borderStyle = WindowBorderStyle.Normal;
	//w.location = [50, 70];
	w.content.backColor = Color(212, 208, 200);
	//w.content.backColor = Color.White;
	w.text = "Dynamin - Encyclopædia";
	w.content.size = Size(640, 480);
	w.position = Position.Right;
	//w.SnapRect = DesktopRect;
	//w.Resizable = false;
	//w.content.MinSize = Size(50, 50);
	//w.content.MaxSize = Size(800, 600);
	w.visible = true;
	/*int width = 640;
	int height = 480;
	SIZE size;
	size.cx = width;
	size.cy = height;
	POINT pt;
	pt.x = 0;
	pt.y = 0;
	BLENDFUNCTION bf;
	bf.BlendOp = AC_SRC_OVER;
	bf.SourceConstantAlpha = 255;
	bf.AlphaFormat = AC_SRC_ALPHA;
	HDC hdc = CreateCompatibleDC(null);
	BITMAPINFO bi;
	bi.bmiHeader.biSize = bi.bmiHeader.sizeof;
	bi.bmiHeader.biWidth = width;
	bi.bmiHeader.biHeight = -height;
	bi.bmiHeader.biPlanes = 1;
	bi.bmiHeader.biBitCount = 32;
	bi.bmiHeader.biCompression = BI_RGB;
	uint* data;
	HBITMAP hbmp = CreateDIBSection(GetDC(null), &bi, DIB_RGB_COLORS, cast(void**)&data, null, 0);
	HBITMAP hbmpDefault = SelectObject(hdc, hbmp);
	//start paint
	cairo_surface_t* surface = cairo_image_surface_create_for_data(
		cast(char*)data, CAIRO_FORMAT_ARGB32, width, height, width*4);
	cairo_t* cr = cairo_create(surface);
	cairo_surface_destroy(surface);
	//draw gradient
	cairo_pattern_t* grad = cairo_pattern_create_linear(0, 0, 0, height);
	cairo_pattern_add_color_stop_rgb(grad, 0.1,      1, 0, 0);
	cairo_pattern_add_color_stop_rgb(grad, 0.1+0.18, 1, 1, 0);
	cairo_pattern_add_color_stop_rgb(grad, 0.1+0.36, 0, 1, 0);
	cairo_pattern_add_color_stop_rgb(grad, 0.1+0.54, 0, 1, 1);
	cairo_pattern_add_color_stop_rgb(grad, 0.1+0.72, 0, 0, 1);
	cairo_pattern_add_color_stop_rgb(grad, 1.0,      1, 0, 1);
	cairo_set_source(cr, grad);
	cairo_pattern_destroy(grad);
	cairo_paint(cr);
	cairo_set_operator(cr, CAIRO_OPERATOR_XOR);
	grad = cairo_pattern_create_linear(0, 0, width, 0);
	cairo_pattern_add_color_stop_rgba(grad, 0, 0, 0, 0, 0);
	cairo_pattern_add_color_stop_rgba(grad, 1, 0, 0, 0, 1);
	cairo_set_source(cr, grad);
	cairo_pattern_destroy(grad);
	cairo_paint(cr);
	cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
	cairo_set_source_rgb(cr, .5, .7, 1);
	w.painting(new PaintingEventArgs(new Graphics(cr)));
	cairo_destroy(cr);
	//end paint
	SetWindowRgn(w.handle, null, true);
	if( UpdateLayeredWindow(w.handle, null, null, &size, hdc, &pt, 0, &bf, ULW_ALPHA)==0 ) {
		Stdout.format("UpdateLayeredWindow() failed, error: {}", GetLastError()).newline;
	}
	SelectObject(hdc, hbmpDefault);
	DeleteDC(hdc);
	DeleteObject(hbmp);*/

	Application.run(w);
	return 0;
}
