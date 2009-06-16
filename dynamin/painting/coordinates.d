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
		pt._x = x;
		pt._y = y;
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
		pt2._x = -_x;
		pt2._y = -_y;
		return pt2;
	}
	///
	Point opAdd(Point pt) {
		Point pt2;
		pt2._x = _x + pt._x;
		pt2._y = _y + pt._y;
		return pt2;
	}
	///
	Point opSub(Point pt) {
		Point pt2;
		pt2._x = _x - pt._x;
		pt2._y = _y - pt._y;
		return pt2;
	}
	///
	Rect opAdd(Size size) {
		Rect rect;
		rect._x = _x;
		rect._y = _y;
		rect._width = size._width;
		rect._height = size._height;
		return rect;
	}
	string toString() {
		return format("Point [x={}, y={}]", _x, _y);
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
		size._width = width;
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
		size2._width = _width + size._width;
		size2._height = _height + size._height;
		return size2;
	}
	///
	Size opSub(Size size) {
		Size size2;
		size2._width = _width - size._width;
		size2._height = _height - size._height;
		return size2;
	}
	///
	Size opAdd(BorderSize border) {
		Size size2;
		size2._width = _width + border._left + border._right;
		size2._height = _height + border._top + border._bottom;
		return size2;
	}
	///
	Size opSub(BorderSize border) {
		Size size2;
		size2._width = _width - border._left - border._right;
		size2._height = _height - border._top - border._bottom;
		return size2;
	}
	string toString() {
		return format("Size [width={}, height={}]", _width, _height);
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
		rect._x = x;
		rect._y = y;
		rect._width = width;
		rect._height = height;
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
	float right() { return _x+_width; }
	///
	float bottom() { return _y+_height; }
	///
	Rect opAdd(Rect rect) {
		Rect rect2;
		rect2._x = _x + rect._x;
		rect2._y = _y + rect._y;
		rect2._width = _width + rect._width;
		rect2._height = _height + rect._height;
		return rect2;
	}
	///
	Rect opSub(Rect rect) {
		Rect rect2;
		rect2._x = _x - rect._x;
		rect2._y = _y - rect._y;
		rect2._width = _width - rect._width;
		rect2._height = _height - rect._height;
		return rect2;
	}
	///
	Rect opAdd(Point pt) {
		Rect rect2;
		rect2._x = _x + pt._x;
		rect2._y = _y + pt._y;
		rect2._width = _width;
		rect2._height = _height;
		return rect2;
	}
	///
	Rect opSub(Point pt) {
		Rect rect2;
		rect2._x = _x - pt._x;
		rect2._y = _y - pt._y;
		rect2._width = _width;
		rect2._height = _height;
		return rect2;
	}
	///
	Rect opAdd(Size size) {
		Rect rect2;
		rect2._x = _x;
		rect2._y = _y;
		rect2._width = _width + size._width;
		rect2._height = _height + size._height;
		return rect2;
	}
	///
	Rect opSub(Size size) {
		Rect rect2;
		rect2._x = _x;
		rect2._y = _y;
		rect2._width = _width - size._width;
		rect2._height = _height - size._height;
		return rect2;
	}
	///
	Rect opAdd(BorderSize border) {
		Rect rect2;
		rect2._x = _x - border._left;
		rect2._y = _y - border._top;
		rect2._width = _width + border._left + border._right;
		rect2._height = _height + border._top + border._bottom;
		return rect2;
	}
	///
	Rect opSub(BorderSize border) {
		Rect rect2;
		rect2._x = _x + border._left;
		rect2._y = _y + border._top;
		rect2._width = _width - border._left - border._right;
		rect2._height = _height - border._top - border._bottom;
		return rect2;
	}
	bool contains(Point pt) {
		return pt.x >= x && pt.y >= y && pt.x < right && pt.y < bottom;
	}
	Rect getUnion(Rect rect) {
		auto x2 = min(_x, rect._x);
		auto y2 = min(_y, rect._y);
		Rect rect2;
		rect2._width = max(_x+_width, rect._x+rect._width)-x2;
		rect2._height = max(_y+_height, rect._y+rect._height)-y2;
		rect2._x = x2;
		rect2._y = y2;
		return rect2;
	}
	string toString() {
		return format("Rect [x={}, y={}, width={}, height={}]",
			_x, _y, _width, _height);
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
	static BorderSize opCall(float _left, float _top, float _right, float _bottom) {
		BorderSize border;
		border._left = _left;
		border._top = _top;
		border._right = _right;
		border._bottom = _bottom;
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
		border2._left = _left + border._left;
		border2._right = _right + border._right;
		border2._top = _top + border._top;
		border2._bottom = _bottom + border._bottom;
		return border2;
	}
	///
	BorderSize opSub(BorderSize border) {
		BorderSize border2;
		border2._left = _left - border._left;
		border2._right = _right - border._right;
		border2._top = _top - border._top;
		border2._bottom = _bottom - border._bottom;
		return border2;
	}
	string toString() {
		return format("BorderSize [_left={}, _top={}, _right={}, _bottom={}]",
			_left, _top, _right, _bottom);
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

