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

module dynamin.painting.coordinates;

import dynamin.core.string;
import dynamin.core.math;

///
struct Point {
private:
	float _x = 0, _y = 0;
public:
	///
	static Point opCall() {
		Point pt;
		return pt;
	}
	///
	static Point opCall(float x, float y) {
		Point pt;
		pt.x = x;
		pt.y = y;
		return pt;
	}
	///
	float x() { return _x; }
	///
	void x(float f) { _x = f; }
	///
	float y() { return _y; }
	///
	void y(float f) { _y = f; }
	///
	Point opNeg() {
		Point pt2;
		pt2.x = -x;
		pt2.y = -y;
		return pt2;
	}
	///
	Point opAdd(Point pt) {
		Point pt2;
		pt2.x = x + pt.x;
		pt2.y = y + pt.y;
		return pt2;
	}
	///
	Point opSub(Point pt) {
		Point pt2;
		pt2.x = x - pt.x;
		pt2.y = y - pt.y;
		return pt2;
	}
	///
	Rect opAdd(Size size) {
		Rect rect;
		rect.x = x;
		rect.y = y;
		rect.width  = size.width;
		rect.height = size.height;
		return rect;
	}
	string toString() {
		return format("Point [x={}, y={}]", x, y);
	}
}

///
struct Size {
private:
	float _width = 0, _height = 0;
public:
	///
	static Size opCall() {
		Size size;
		return size;
	}
	///
	static Size opCall(float width, float height) {
		Size size;
		size._width  = width;  // TODO: underscores for CTFE--remove with D2
		size._height = height;
		return size;
	}
	///
	float width() { return _width; }
	///
	void width(float f) { _width = f; }
	///
	float height() { return _height; }
	///
	void height(float f) { _height = f; }
	///
	Size opAdd(Size size) {
		Size size2;
		size2.width  = width  + size.width;
		size2.height = height + size.height;
		return size2;
	}
	///
	Size opSub(Size size) {
		Size size2;
		size2.width  = width  - size.width;
		size2.height = height - size.height;
		return size2;
	}
	///
	Size opAdd(BorderSize border) {
		Size size2;
		size2.width  = width  + border.left + border.right;
		size2.height = height + border.top  + border.bottom;
		return size2;
	}
	///
	Size opSub(BorderSize border) {
		Size size2;
		size2.width  = width  - border.left - border.right;
		size2.height = height - border.top  - border.bottom;
		return size2;
	}
	string toString() {
		return format("Size [width={}, height={}]", width, height);
	}
}

///
struct Rect {
private:
	float _x = 0, _y = 0, _width = 0, _height = 0;
public:
	static Rect opCall() {
		Rect rect;
		return rect;
	}
	static Rect opCall(float x, float y, float width, float height) {
		Rect rect;
		rect.x = x;
		rect.y = y;
		rect.width  = width;
		rect.height = height;
		return rect;
	}
	///
	float x() { return _x; }
	///
	void x(float f) { _x = f; }
	///
	float y() { return _y; }
	///
	void y(float f) { _y = f; }
	///
	float width() { return _width; }
	///
	void width(float f) { _width = f; }
	///
	float height() { return _height; }
	///
	void height(float f) { _height = f; }
	///
	float right() { return x + width; }
	///
	float bottom() { return y + height; }
	///
	Rect opAdd(Rect rect) {
		Rect rect2;
		rect2.x = x + rect.x;
		rect2.y = y + rect.y;
		rect2.width  = width  + rect.width;
		rect2.height = height + rect.height;
		return rect2;
	}
	///
	Rect opSub(Rect rect) {
		Rect rect2;
		rect2.x = x - rect.x;
		rect2.y = y - rect.y;
		rect2.width  = width  - rect.width;
		rect2.height = height - rect.height;
		return rect2;
	}
	///
	Rect opAdd(Point pt) {
		Rect rect2;
		rect2.x = x + pt.x;
		rect2.y = y + pt.y;
		rect2.width  = width;
		rect2.height = height;
		return rect2;
	}
	///
	Rect opSub(Point pt) {
		Rect rect2;
		rect2.x = x - pt.x;
		rect2.y = y - pt.y;
		rect2.width  = width;
		rect2.height = height;
		return rect2;
	}
	///
	Rect opAdd(Size size) {
		Rect rect2;
		rect2.x = x;
		rect2.y = y;
		rect2.width  = width  + size.width;
		rect2.height = height + size.height;
		return rect2;
	}
	///
	Rect opSub(Size size) {
		Rect rect2;
		rect2.x = x;
		rect2.y = y;
		rect2.width  = width  - size.width;
		rect2.height = height - size.height;
		return rect2;
	}
	///
	Rect opAdd(BorderSize border) {
		Rect rect2;
		rect2.x = x - border.left;
		rect2.y = y - border.top;
		rect2.width  = width  + border.left + border.right;
		rect2.height = height + border.top  + border.bottom;
		return rect2;
	}
	///
	Rect opSub(BorderSize border) {
		Rect rect2;
		rect2.x = x + border.left;
		rect2.y = y + border.top;
		rect2.width  = width  - border.left - border.right;
		rect2.height = height - border.top  - border.bottom;
		return rect2;
	}
	bool contains(Point pt) {
		return pt.x >= x && pt.y >= y && pt.x < right && pt.y < bottom;
	}
	Rect getUnion(Rect rect) {
		auto x2 = min(x, rect.x);
		auto y2 = min(y, rect.y);
		Rect rect2;
		rect2.width  = max(x + width,  rect.x + rect.width ) - x2;
		rect2.height = max(y + height, rect.y + rect.height) - y2;
		rect2.x = x2;
		rect2.y = y2;
		return rect2;
	}
	string toString() {
		return format("Rect [x={}, y={}, width={}, height={}]",
			x, y, width, height);
	}
}
unittest {
	assert(Rect(20, 2, 70, 5).getUnion(Rect(22, 3, 70, 4)) == Rect(20, 2, 72, 5));
}

///
struct BorderSize {
private:
	float _left = 0, _top = 0, _right = 0, _bottom = 0;
public:
	static BorderSize opCall() {
		BorderSize border;
		return border;
	}
	static BorderSize opCall(float left, float top, float right, float bottom) {
		BorderSize border;
		border.left = left;
		border.top = top;
		border.right = right;
		border.bottom = bottom;
		return border;
	}
	///
	float left() { return _left; }
	///
	void left(float f) { _left = f; }
	///
	float top() { return _top; }
	///
	void top(float f) { _top = f; }
	///
	float right() { return _right; }
	///
	void right(float f) { _right = f; }
	///
	float bottom() { return _bottom; }
	///
	void bottom(float f) { _bottom = f; }
	///
	BorderSize opAdd(BorderSize border) {
		BorderSize border2;
		border2.left = left + border.left;
		border2.right = right + border.right;
		border2.top = top + border.top;
		border2.bottom = bottom + border.bottom;
		return border2;
	}
	///
	BorderSize opSub(BorderSize border) {
		BorderSize border2;
		border2.left = left - border.left;
		border2.right = right - border.right;
		border2.top = top - border.top;
		border2.bottom = bottom - border.bottom;
		return border2;
	}
	string toString() {
		return format("BorderSize [left={}, top={}, right={}, bottom={}]",
			left, top, right, bottom);
	}
}

unittest {
	Point pt = Point(7, 9);
	assert(pt.x == 7);
	assert(pt.y == 9);
	Rect rect = pt + Size(15, 13);
	assert(rect == Rect(7, 9, 15, 13));
	assert(Size(15, 10) + BorderSize(3, 5, 1, 7) == Size(19, 22));
}

