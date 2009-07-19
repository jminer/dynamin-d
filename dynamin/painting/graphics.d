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

module dynamin.painting.graphics;

import dynamin.c.cairo;
import dynamin.core.string;
import dynamin.core.math;
import dynamin.core.file;
import dynamin.painting.coordinates;
import dynamin.painting.color;
import tango.io.Stdout;

///
class Font {
private:
	string _family;
	int _style = 0;
	int _size;
public:
	this(string family_ = "", int size = 10, bool b = false, bool i = false, bool u = false) {
		this.family = family_;
		this.size = size;
		bold = b;
		italic = i;
		underline = u;
	}
	/**
	 * Gets or sets the family name of this font. Common font family names on
	 * Windows are "Arial", "Times New Roman", and "Tahoma".
	 */
	string family() { return _family; }
	/// ditto
	void family(string str) { _family = str; }
	///
	int style() { return _style; }
	/// ditto
	void style(int s) { _style = s; }
	/// Gets or sets whether this font is bold.
	bool bold() { return cast(bool)(_style & 1); }
	/// ditto
	void bold(bool b) { b ? (_style |= 1) : (_style &= ~1); }
	/// Gets or sets whether this font is italic.
	bool italic() { return cast(bool)(_style & 2); }
	/// ditto
	void italic(bool b) { b ? (_style |= 2) : (_style &= ~2); }
	/// Gets or sets whether this font is underline.
	bool underline() { return cast(bool)(_style & 4); }
	/// ditto
	void underline(bool b) { b ? (_style |= 4) : (_style &= ~4); }
	/// Gets or sets whether this font is strikethrough.
	bool strikethrough() { return cast(bool)(_style & 8); }
	/// ditto
	void strikethrough(bool b) { b ? (_style |= 8) : (_style &= ~8); }
	/**
	 * Gets or sets the size of this font in user space units, not in points.
	 * This size is the ascent plus the descent, not including the leading.
	 */
	int size() { return _size; }
	/// ditto
	void size(int s) { _size = s; }
}

///
struct FontExtents {
	///
	real ascent;
	///
	real descent;
	///
	real leading() { return height - ascent - descent; }
	///
	real height;
	///
	real maxAdvance;
}

//import lodepng = dynamin.lodepng.decode;
/// An RGBA 32-bit-per-pixel image.
class Image {
	Color* _data;
	uint _width, _height;
	Color* data() { return _data; }
	uint width() { return _width; }
	uint height() { return _height; }
	protected this() {
	}
	Color* opIndex(int x, int y) {
		return _data + x+y*_width;
	}
	static Image load(string file) {
		static if(false) {
		auto img = new Image;
		lodepng.PngInfo info;
		img._data = cast(Color*)lodepng.decode32(readFileBytes(file), info);
		img._width = info.image.width;
		img._height = info.image.height;

		ubyte r;
		for(uint i = 0; i < img.width * img.height; ++i) {
			// lodepng returns data as ABGR instead of the ARGB that cairo,
			// Windows, and I think X use.
			r = img.data[i].R;
			img.data[i].R = img.data[i].B;
			img.data[i].B = r;
			// cairo, Windows, and I think X use pre-multiplied alpha
			img.data[i].R = img.data[i].R * img.data[i].A / 255;
			img.data[i].G = img.data[i].G * img.data[i].A / 255;
			img.data[i].B = img.data[i].B * img.data[i].A / 255;
		}

		return img;
		} else { return null; }
	}
}

///
enum GraphicsOperator {
	Clear,  ///

	Source, ///
	Over,   ///
	In,     ///
	Out,    ///
	Atop,   ///

	Dest,     ///
	DestOver, ///
	DestIn,   ///
	DestOut,  ///
	DestAtop, ///

	Xor,     ///
	Add,     ///
	Saturate ///
}

///
enum GraphicsFillRule {
	         ///
	Winding,
	EvenOdd  ///
}
/**
 * Example:
 * -----
 * graphics.source = Color.Gold;
 * graphics.rectangle(40, 10, 100, 120);
 * graphics.fill();
 * graphics.source = Color.Black;
 *
 * graphics.lineWidth = 20;
 *
 * // GraphicsLineCap.Butt is default
 * graphics.moveTo(40, 30);
 * graphics.lineTo(140, 30);
 * graphics.stroke();
 *
 * graphics.lineCap = GraphicsLineCap.Round;
 * graphics.moveTo(40, 70);
 * graphics.lineTo(140, 70);
 * graphics.stroke();
 *
 * graphics.lineCap = GraphicsLineCap.Square;
 * graphics.moveTo(40, 110);
 * graphics.lineTo(140, 110);
 * graphics.stroke();
 * -----
 * $(IMAGE ../web/example_line_cap.png)
 */
enum GraphicsLineCap {
	/**
	 * Uses no ending. The line ends exactly at the end point.
	 */
	Butt,
	/**
	 * Uses a rounded ending with the center of the circle at the end point.
	 * Therefore, the cap extends past the end point for half the line width.
	 */
	Round,
	/**
	 * Uses a square ending with the center of the square at the end point.
	 * Therefore, the cap extends past the end point for half the line width.
	 */
	Square
}

// cairo_copy_clip_rectangles  --> Rectangle[] ClipRectangles()
// cairo_get_dash  --> Dashes()
// cairo_get_color_stop_rgba  --> ColorStops()
/**
 * A Graphics object uses its source to draw on its target. Its target is set
 * when it is created, but its source can be changed whenever desired. For
 * example, for a painting event, the target of a Graphics is the control
 * being painted. In other cases it could be an image. Its source is usually a
 * color, but could be a gradient, an image, or some other pattern.
 *
 * If the documentation here is not sufficient, cairo might have
 * better documentation at $(LINK http://www.cairographics.org/manual/).
 */
class Graphics {
private:
	cairo_t* cr;
public:
	this(cairo_t* cr) {
		this.cr = cr;
		cairo_reference(cr);
		checkStatus();
	}
	~this() {
		cairo_destroy(cr);
	}
	/**
	 * Returns: a pointer to the cairo context (cairo_t*) that backs this object
	 */
	cairo_t* handle() { return cr; }
	void checkStatus() {
		cairo_status_t status = cairo_status(cr);
		if(status == CAIRO_STATUS_SUCCESS)
			return;

		Stdout("Cairo error: ")(cairo_status_to_string(status)).newline;
		assert(0);
	}
	///
	void moveTo(real x, real y) {
		cairo_move_to(cr, x, y);
	}
	/// ditto
	void moveTo(Point pt) {
		moveTo(pt.x, pt.y);
	}
	///
	void lineTo(real x, real y) {
		cairo_line_to(cr, x, y);
	}
	/// ditto
	void lineTo(Point pt) {
		lineTo(pt.x, pt.y);
	}
	///
	void curveTo(Point pt1, Point pt2, Point pt3) {
		curveTo(pt1.x, pt1.y, pt2.x, pt2.y, pt3.x, pt3.y);
	}
	/// ditto
	void curveTo(real x1, real y1, real x2, real y2, real x3, real y3) {
		cairo_curve_to(cr, x1, y1, x2, y2, x3, y3);
	}
	///
	void relMoveTo(real x, real y) {
		cairo_rel_move_to(cr, x, y);
	}
	/// ditto
	void relMoveTo(Point pt) {
		relMoveTo(pt.x, pt.y);
	}
	///
	void relLineTo(real x, real y) {
		cairo_rel_line_to(cr, x, y);
	}
	/// ditto
	void relLineTo(Point pt) {
		relLineTo(pt.x, pt.y);
	}
	///
	void relCurveTo(Point pt1, Point pt2, Point pt3) {
		relCurveTo(pt1.x, pt1.y, pt2.x, pt2.y, pt3.x, pt3.y);
	}
	/// ditto
	void relCurveTo(real x1, real y1, real x2, real y2, real x3, real y3) {
		cairo_rel_curve_to(cr, x1, y1, x2, y2, x3, y3);
	}
	/**
	 * Adds an arc to the current path. A line is added connecting the
	 * current point to the beginning of the arc.
	 * Example:
	 * -----
	 * graphics.moveTo(5, 5);
	 * graphics.arc(50.5, 80.5, 40, 40, -0.2, PI/2);
	 * graphics.stroke();
	 * -----
	 * $(IMAGE ../web/example_arc.png)
	 */
	void arc(Point ptc, real radius, real angle1, real angle2) {
		arc(ptc.x, ptc.y, radius, angle1, angle2);
	}
	/// ditto
	void arc(real xc, real yc, real radius, real angle1, real angle2) {
		cairo_arc(cr, xc, yc, radius, angle1, angle2);
	}
	/// ditto
	void arc(real xc, real yc, real xradius, real yradius, real angle1, real angle2) {
		cairo_save(cr);
		cairo_translate(cr, xc, yc);
		cairo_scale(cr, xradius, yradius);
		cairo_arc(cr, 0, 0, 1, angle1, angle2);
		cairo_restore(cr);
	}
	/**
	 * Adds an ellipse as a closed sub-path--a line will not connect it
	 * to the current point.
	 * Example:
	 * -----
	 * graphics.ellipse(70.5, 50.5, 60, 25);
	 * graphics.stroke();
	 * -----
	 * $(IMAGE ../web/example_ellipse.png)
	 */
	void ellipse(real xc, real yc, real radius) {
		cairo_new_sub_path(cr);
		cairo_arc(cr, xc, yc, radius, 0, Pi * 2);
		cairo_close_path(cr);
	}
	/// ditto
	void ellipse(real xc, real yc, real xradius, real yradius) {
		cairo_new_sub_path(cr);
		arc(xc, yc, xradius, yradius, 0, Pi * 2);
		cairo_close_path(cr);
	}
	/**
	 * Adds a rectangle as a sub-path--a line will not connect it
	 * to the current point.
	 * Example:
	 * -----
	 * graphics.rectangle(5.5, 5.5, 70, 20);
	 * graphics.stroke();
	 * -----
	 * $(IMAGE ../web/example_rectangle.png)
	 */
	void rectangle(Rect rect) {
		rectangle(rect.x, rect.y, rect.width, rect.height);
	}
	/// ditto
	void rectangle(real x, real y, real width, real height) {
		cairo_rectangle(cr, x, y, width, height);
	}
	/**
	 * Adds a rectangle with rounded corners as a sub-path--a line will
	 * not connect it to the current point.
	 */
	void roundedRectangle(Rect rect, real radius) {
		roundedRectangle(rect.x, rect.y, rect.width, rect.height, radius);
	}
	/// ditto
	void roundedRectangle(real x, real y, real width, real height, real radius) {
		alias radius r;
		cairo_new_sub_path(cr);
		arc(x+r,       y+r,        r, Pi,     3*Pi/2);
		arc(x+width-r, y+r,        r, 3*Pi/2, 0);
		arc(x+width-r, y+height-r, r, 0,      Pi/2);
		arc(x+r,       y+height-r, r, Pi/2,   Pi);
		closePath();
	}
	///
	void closePath() {
		cairo_close_path(cr);
	}
	/**
	 * Draws the outline of the current path.
	 * Example:
	 * -----
	 * graphics.moveTo(12.5, 14.5);
	 * graphics.lineTo(123.5, 22.5);
	 * graphics.lineTo(139.5, 108.5);
	 * graphics.lineTo(49.5, 86.5);
	 * graphics.closePath();
	 * graphics.stroke();
	 * -----
	 * $(IMAGE ../web/example_stroke.png)
	 */
	void stroke() {
		cairo_stroke(cr);
	}
	/**
	 * Draws the inside of the current path.
	 * Example:
	 * -----
	 * graphics.MoveTo(12.5, 14.5);
	 * graphics.LineTo(123.5, 22.5);
	 * graphics.LineTo(139.5, 108.5);
	 * graphics.LineTo(49.5, 86.5);
	 * graphics.ClosePath();
	 * graphics.Fill();
	 * -----
	 * $(IMAGE ../web/example_fill.png)
	 */
	void fill() {
		cairo_fill(cr);
	}
	/**
	 * Paints the current source everywhere within the current clip region.
	 * Examples:
	 * -----
	 * graphics.source = Color(255, 128, 0);
	 * graphics.paint();
	 * -----
	 * $(IMAGE ../web/example_paint.png)
	 */
	void paint() {
		cairo_paint(cr);
	}
	/**
	 * Gets or sets the line _width used for stroking.
	 * Example:
	 * -----
	 * graphics.ellipse(40.5, 30.5, 30, 20);
	 * graphics.lineWidth = 1;
	 * graphics.stroke();
	 * graphics.ellipse(40.5, 80.5, 30, 20);
	 * graphics.lineWidth = 5;
	 * graphics.stroke();
	 * -----
	 * $(IMAGE ../web/example_line_width.png)
	 */
	real lineWidth() {
		return cairo_get_line_width(cr);
	}
	/// ditto
	void lineWidth(real width) {
		cairo_set_line_width(cr, width);
	}
	/**
	 * Gets or sets the line cap used for stroking.
	 *
	 * The line cap is only examined when the stroke is performed, not before.
	 * Therefore, drawing two lines, each with a different line cap, would
	 * require calling stroke twice.
	 */
	GraphicsLineCap lineCap() {
		return cast(GraphicsLineCap)cairo_get_line_cap(cr);
	}
	/// ditto
	void lineCap(GraphicsLineCap cap) {
		cairo_set_line_cap(cr, cap);
	}
	/**
	 * Sets the font size to the specified size in user space units, not
	 * in points.
	 */
	void fontSize(real size) {
		assert(size != 0);
		cairo_set_font_size(cr, size);
	}
	/**
	 * Set the font used to draw text.
	 */
	void font(Font f) {
		assert(f.size != 0);
		cairo_set_font_size(cr, f.size);
		cairo_select_font_face(cr, toCharPtr(f.family), f.italic, f.bold);
	}
	// TODO: if text is all ascii, do fast path with no uniscribe
	void drawText(string text, real x, real y) {
		auto extents = getFontExtents;
		cairo_font_extents_t fextents;
		cairo_font_extents(cr, &fextents);
		cairo_move_to(cr, x, y + fextents.ascent);
		cairo_show_text(cr, toCharPtr(text)); // 99% of time spent in show_text
		checkStatus();
	}
	///
	Size getTextExtents(string text) {
		cairo_text_extents_t textents;
		cairo_text_extents(cr, toCharPtr(text), &textents);
		cairo_font_extents_t fextents;
		cairo_font_extents(cr, &fextents);
		return Size(textents.x_advance, fextents.height);
	}
	///
	FontExtents getFontExtents() {  // TODO: make property?
		cairo_font_extents_t fextents;
		cairo_font_extents(cr, &fextents);
		FontExtents extents;
		extents.ascent = fextents.ascent;
		extents.descent = fextents.descent;
		extents.height = fextents.height;
		extents.maxAdvance = fextents.max_x_advance;
		return extents;
	}
	///
	Rect getClipExtents() {  // TODO: make property?
		double x, y, width, height;
		cairo_clip_extents(cr, &x, &y, &width, &height);
		return Rect(x, y, width, height);
	}
	///
	void save() {
		cairo_save(cr);
	}
	///
	void restore() {
		cairo_restore(cr);
		checkStatus();
	}
	///
	void clip() {
		cairo_clip(cr);
	}
	///
	void translate(Point pt) {
		translate(pt.x, pt.y);
	}
	/// ditto
	void translate(real x, real y) {
		cairo_translate(cr, x, y);
	}
	///
	void scale(real x, real y) {
		cairo_scale(cr, x, y);
	}
	///
	void rotate(real angle) {
		cairo_rotate(cr, angle);
	}
	///
	GraphicsOperator operator() {
		return cast(GraphicsOperator)cairo_get_operator(cr);
	}
	///
	void operator(GraphicsOperator op) {
		cairo_set_operator(cr, cast(cairo_operator_t)op);
	}
	/**
	 * Sets the dash pattern to be used when lines are drawn.
	 */
	void setDash(real[] dashes, real offset) {
		auto cdashes = new double[dashes.length];
		foreach(int i, real r; dashes)
			cdashes[i] = r;
		cairo_set_dash(cr, cdashes.ptr, cdashes.length, offset);
	}
	/**
	 * Gets or sets the fill rule the current fill rule.
	 * The default is GraphicsFillRule.Winding.
	 */
	GraphicsFillRule fillRule() {
		return cast(GraphicsFillRule)cairo_get_fill_rule(cr);
	}
	/// ditto
	void fillRule(GraphicsFillRule rule) {
		cairo_set_fill_rule(cr, cast(cairo_fill_rule_t)rule);
	}
	/**
	 * The temporary surface created will be the same size as the current clip. To speed up using this function, call Clip() to the area you will be drawing in.
	 */
	void pushGroup() {
		cairo_push_group(cr);
	}
	//popGroup() { // TODO: returning a pattern
	//	cairo_pop_group(cr);
	//}
	/**
	 * Terminates the redirection begun by a call to PushGroup() or
	 * PushGroupWithContent() and installs the resulting pattern as the
	 * source pattern.
	 */
	void popGroupToSource() {
		cairo_pop_group_to_source(cr);
		checkStatus();
	}
	// TODO: figure out the best way to set the source and get the source
	void source(Color c) {
		cairo_set_source_rgba(cr, c.R/255.0, c.G/255.0, c.B/255.0, c.A/255.0);
	}
	//void source(Pattern s) {}
	//void setSource(Surface s, real x = 0, real y = 0) {}
	// TODO: remove this function and have users do:
	// g.setSource(img, x, y);
	// g.paint();
	// ???
	// paintSource(Image, real, real) ?
	/// Draws the specified image unscaled.
	void drawImage(Image image, real x, real y) {
		auto surface= cairo_image_surface_create_for_data(cast(char*)image.data,
			CAIRO_FORMAT_ARGB32, image.width, image.height, image.width*4);
		save();
		cairo_set_source_surface(cr, surface, x, y);
		cairo_paint(cr);
		restore();
		cairo_surface_destroy(surface);
	}
	// Draws the specified image scaled to the specified width and height.
	//void drawImage(Image image, real x, real y, real width, real height);
}
