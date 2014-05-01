
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.painting.color;

import dynamin.core.string;

/**
 * If a color has an alpha of 255, it is fully opaque.
 *
 * The pre-defined colors are from http://clrs.cc/
 */
align(1)
struct Color { // TODO: make a class and make a Pixel32 struct
	// TODO: actually...color should stay a struct, but use 32-bit floats
	// TODO: should use 32-bit floats
version(BigEndian) {
	ubyte A;
	ubyte R;
	ubyte G;
	ubyte B;
} else {
	ubyte B;
	ubyte G;
	ubyte R;
	ubyte A;
}
	/+
	this(ubyte r, ubyte g, ubyte b, ubyte a = 255) {
		this.r = r/255.0;
		this.g = g/255.0;
		this.b = b/255.0;
		this.a = a/255.0;
	}
	this(double r, double g, double b, double a = 1.0) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}
	private double getMin() {
	}
	private double getMax() {
		double max = r;
		if(g > max)
			max = g;
		if(b > max)
			max = b;
		return max;
	}
	/**
	 * From 0 to 360 degrees.
	 */
	double gethue() {
		double min = min();
		double max = max();
		double delta = max - min;
		if(max == 0)  // r = g = b = 0 = black
			return 0;

		double hue;
		if(r == max)
			hue = (g - b) / delta;     // between yellow and magenta
		else if(g == max)
			hue = 2 + (b - r) / delta; // between cyan and yellow
		else
			hue = 4 + (r - g) / delta; // between magenta and cyan

		hue *= 60;
		if(hue < 0)
			hue += 360;

	}
	double getSaturation() {
	}
	double getValue() {
		return getMax();
	}
	+/
	/**
	 * Changes this color to its inverse.
	 * The inverse of black is white. The inverse of blue is yellow.
	 */
	void invert() {
		R = 255 - R;
		G = 255 - G;
		B = 255 - B;
	}
	string toUtf8() {
		return format("Color [R={,3}, G={,3}, B={,3}]", R, G, B).idup;
	}
static:
	Color opCall(ubyte a, ubyte r, ubyte g, ubyte b) {
		Color c;
		c.A = a;
		c.R = r;
		c.G = g;
		c.B = b;
		return c;
	}
	Color opCall(ubyte r, ubyte g, ubyte b) {
		return Color(255, r, g, b);
	}
	Color opCall(uint argb) {
		return Color(argb >> 24, argb & 0xFFFFFF >> 16, argb & 0xFFFF >> 8, argb & 0xFF);
	}

	/**
	* <code style="background-color: rgb(0, 31, 63);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color Navy() {    return Color(  0,  31,  63); }

	/**
	* <code style="background-color: rgb(0, 116, 217);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color Blue() {    return Color(  0, 116, 217); }

	/**
	* <code style="background-color: rgb(127, 219, 255);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color Aqua() {    return Color(127, 219, 255); }

	/**
	* <code style="background-color: rgb(57, 204, 204);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color Teal() {    return Color( 57, 204, 204); }

	/**
	* <code style="background-color: rgb(61, 153, 112);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color Olive() {   return Color( 61, 153, 112); }

	/**
	* <code style="background-color: rgb(46, 204, 64);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color Green() {   return Color( 46, 204,  64); }

	/**
	* <code style="background-color: rgb(1, 255, 112);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color Lime() {    return Color(  1, 255, 112); }

	/**
	* <code style="background-color: rgb(255, 220, 0);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color Yellow() {  return Color(255, 220,   0); }

	/**
	* <code style="background-color: rgb(255, 133, 27);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color Orange() {  return Color(255, 133,  27); }

	/**
	* <code style="background-color: rgb(255, 65, 54);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color Red() {     return Color(255,  65,  54); }

	/**
	* <code style="background-color: rgb(133, 20, 75);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color Maroon() {  return Color(133,  20,  75); }

	/**
	* <code style="background-color: rgb(240, 18, 190);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color Fuchsia() { return Color(240,  18, 190); }

	/**
	* <code style="background-color: rgb(177, 13, 201);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color Purple() {  return Color(177,  13, 201); }

	/**
	* <code style="background-color: rgb(255, 255, 255);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color White() {   return Color(255, 255, 255); }

	/**
	* <code style="background-color: rgb(221, 221, 221);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color Silver() {  return Color(221, 221, 221); }

	/**
	* <code style="background-color: rgb(170, 170, 170);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color Gray() {    return Color(170, 170, 170); }

	/**
	* <code style="background-color: rgb(17, 17, 17);">
	* &nbsp;&nbsp;&nbsp;</code>
	*/
	Color Black() {   return Color( 17,  17,  17); }

}

