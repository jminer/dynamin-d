
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
 * The pre-defined colors are those recognized by the SVG standard
 * found at $(LINK http://www.w3.org/TR/SVG/types.html#ColorKeywords).
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
		return format("Color [R={,3}, G={,3}, B={,3}]", R, G, B);
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
	 * <code style="background-color: rgb(240, 248, 255);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color AliceBlue() {       return Color(240, 248, 255); }
	/**
	 * <code style="background-color: rgb(250, 235, 215);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color AntiqueWhite() {    return Color(250, 235, 215); }
	/**
	 * <code style="background-color: rgb(  0, 255, 255);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Aqua() {            return Color(  0, 255, 255); }
	/**
	 * <code style="background-color: rgb(127, 255, 212);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Aquamarine() {      return Color(127, 255, 212); }
	/**
	 * <code style="background-color: rgb(240, 255, 255);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Azure() {           return Color(240, 255, 255); }
	/**
	 * <code style="background-color: rgb(245, 245, 220);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Beige() {           return Color(245, 245, 220); }
	/**
	 * <code style="background-color: rgb(255, 228, 196);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Bisque() {          return Color(255, 228, 196); }
	/**
	 * <code style="background-color: rgb(  0,   0,   0);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Black() {           return Color(  0,   0,   0); }
	/**
	 * <code style="background-color: rgb(255, 235, 205);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color BlanchedAlmond() {  return Color(255, 235, 205); }
	/**
	 * <code style="background-color: rgb(  0,   0, 255);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Blue() {            return Color(  0,   0, 255); }
	/**
	 * <code style="background-color: rgb(138,  43, 226);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color BlueViolet() {      return Color(138,  43, 226); }
	/**
	 * <code style="background-color: rgb(165,  42,  42);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Brown() {           return Color(165,  42,  42); }
	/**
	 * <code style="background-color: rgb(222, 184, 135);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color BurlyWood() {       return Color(222, 184, 135); }
	/**
	 * <code style="background-color: rgb( 95, 158, 160);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color CadetBlue() {       return Color( 95, 158, 160); }
	/**
	 * <code style="background-color: rgb(127, 255,   0);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Chartreuse() {      return Color(127, 255,   0); }
	/**
	 * <code style="background-color: rgb(210, 105,  30);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Chocolate() {       return Color(210, 105,  30); }
	/**
	 * <code style="background-color: rgb(255, 127,  80);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Coral() {           return Color(255, 127,  80); }
	/**
	 * <code style="background-color: rgb(100, 149, 237);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color CornflowerBlue() {  return Color(100, 149, 237); }
	/**
	 * <code style="background-color: rgb(255, 248, 220);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Cornsilk() {        return Color(255, 248, 220); }
	/**
	 * <code style="background-color: rgb(220,  20,  60);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Crimson() {         return Color(220,  20,  60); }
	/**
	 * <code style="background-color: rgb(  0, 255, 255);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Cyan() {            return Color(  0, 255, 255); }
	/**
	 * <code style="background-color: rgb(  0,   0, 139);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkBlue() {        return Color(  0,   0, 139); }
	/**
	 * <code style="background-color: rgb(  0, 139, 139);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkCyan() {        return Color(  0, 139, 139); }
	/**
	 * <code style="background-color: rgb(184, 134,  11);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkGoldenrod() {   return Color(184, 134,  11); }
	/**
	 * <code style="background-color: rgb(169, 169, 169);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkGray() {        return Color(169, 169, 169); }
	/**
	 * <code style="background-color: rgb(  0, 100,   0);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkGreen() {       return Color(  0, 100,   0); }
	/**
	 * <code style="background-color: rgb(189, 183, 107);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkKhaki() {       return Color(189, 183, 107); }
	/**
	 * <code style="background-color: rgb(139,   0, 139);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkMagenta() {     return Color(139,   0, 139); }
	/**
	 * <code style="background-color: rgb( 85, 107,  47);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkOliveGreen() {  return Color( 85, 107,  47); }
	/**
	 * <code style="background-color: rgb(255, 140,   0);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkOrange() {      return Color(255, 140,   0); }
	/**
	 * <code style="background-color: rgb(153,  50, 204);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkOrchid() {      return Color(153,  50, 204); }
	/**
	 * <code style="background-color: rgb(139,   0,   0);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkRed() {         return Color(139,   0,   0); }
	/**
	 * <code style="background-color: rgb(233, 150, 122);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkSalmon() {      return Color(233, 150, 122); }
	/**
	 * <code style="background-color: rgb(143, 188, 143);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkSeaGreen() {    return Color(143, 188, 143); }
	/**
	 * <code style="background-color: rgb( 72,  61, 139);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkSlateBlue() {   return Color( 72,  61, 139); }
	/**
	 * <code style="background-color: rgb( 47,  79,  79);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkSlateGray() {   return Color( 47,  79,  79); }
	/**
	 * <code style="background-color: rgb(  0, 206, 209);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkTurquoise() {   return Color(  0, 206, 209); }
	/**
	 * <code style="background-color: rgb(148,   0, 211);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DarkViolet() {      return Color(148,   0, 211); }
	/**
	 * <code style="background-color: rgb(255,  20, 147);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DeepPink() {        return Color(255,  20, 147); }
	/**
	 * <code style="background-color: rgb(  0, 191, 255);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DeepSkyBlue() {     return Color(  0, 191, 255); }
	/**
	 * <code style="background-color: rgb(105, 105, 105);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DimGray() {         return Color(105, 105, 105); }
	/**
	 * <code style="background-color: rgb( 30, 144, 255);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color DodgerBlue() {      return Color( 30, 144, 255); }
	/**
	 * <code style="background-color: rgb(178,  34,  34);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Firebrick() {       return Color(178,  34,  34); }
	/**
	 * <code style="background-color: rgb(255, 250, 240);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color FloralWhite() {     return Color(255, 250, 240); }
	/**
	 * <code style="background-color: rgb( 34, 139,  34);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color ForestGreen() {     return Color( 34, 139,  34); }
	/**
	 * <code style="background-color: rgb(255,   0, 255);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Fuchsia() {         return Color(255,   0, 255); }
	/**
	 * <code style="background-color: rgb(220, 220, 220);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Gainsboro() {       return Color(220, 220, 220); }
	/**
	 * <code style="background-color: rgb(248, 248, 255);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color GhostWhite() {      return Color(248, 248, 255); }
	/**
	 * <code style="background-color: rgb(255, 215,   0);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Gold() {            return Color(255, 215,   0); }
	/**
	 * <code style="background-color: rgb(218, 165,  32);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Goldenrod() {       return Color(218, 165,  32); }
	/**
	 * <code style="background-color: rgb(128, 128, 128);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Gray() {            return Color(128, 128, 128); }
	/**
	 * <code style="background-color: rgb(  0, 128,   0);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Green() {           return Color(  0, 128,   0); }
	/**
	 * <code style="background-color: rgb(173, 255,  47);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color GreenYellow() {     return Color(173, 255,  47); }
	/**
	 * <code style="background-color: rgb(240, 255, 240);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Honeydew() {        return Color(240, 255, 240); }
	/**
	 * <code style="background-color: rgb(255, 105, 180);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color HotPink() {         return Color(255, 105, 180); }
	/**
	 * <code style="background-color: rgb(205,  92,  92);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color IndianRed() {       return Color(205,  92,  92); }
	/**
	 * <code style="background-color: rgb( 75,   0, 130);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Indigo() {          return Color( 75,   0, 130); }
	/**
	 * <code style="background-color: rgb(255, 255, 240);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Ivory() {           return Color(255, 255, 240); }
	/**
	 * <code style="background-color: rgb(240, 230, 140);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Khaki() {           return Color(240, 230, 140); }
	/**
	 * <code style="background-color: rgb(230, 230, 250);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Lavender() {        return Color(230, 230, 250); }
	/**
	 * <code style="background-color: rgb(255, 240, 245);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LavenderBlush() {   return Color(255, 240, 245); }
	/**
	 * <code style="background-color: rgb(124, 252,   0);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LawnGreen() {       return Color(124, 252,   0); }
	/**
	 * <code style="background-color: rgb(255, 250, 205);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LemonChiffon() {    return Color(255, 250, 205); }
	/**
	 * <code style="background-color: rgb(173, 216, 230);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LightBlue() {       return Color(173, 216, 230); }
	/**
	 * <code style="background-color: rgb(240, 128, 128);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LightCoral() {      return Color(240, 128, 128); }
	/**
	 * <code style="background-color: rgb(224, 255, 255);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LightCyan() {       return Color(224, 255, 255); }
	/**
	 * <code style="background-color: rgb(250, 250, 210);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LightGoldenrodYellow() { return Color(250, 250, 210); }
	/**
	 * <code style="background-color: rgb(211, 211, 211);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LightGray() {       return Color(211, 211, 211); }
	/**
	 * <code style="background-color: rgb(144, 238, 144);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LightGreen() {      return Color(144, 238, 144); }
	/**
	 * <code style="background-color: rgb(255, 182, 193);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LightPink() {       return Color(255, 182, 193); }
	/**
	 * <code style="background-color: rgb(255, 160, 122);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LightSalmon() {     return Color(255, 160, 122); }
	/**
	 * <code style="background-color: rgb( 32, 178, 170);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LightSeaGreen() {   return Color( 32, 178, 170); }
	/**
	 * <code style="background-color: rgb(135, 206, 250);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LightSkyBlue() {    return Color(135, 206, 250); }
	/**
	 * <code style="background-color: rgb(119, 136, 153);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LightSlateGray() {  return Color(119, 136, 153); }
	/**
	 * <code style="background-color: rgb(176, 196, 222);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LightSteelBlue() {  return Color(176, 196, 222); }
	/**
	 * <code style="background-color: rgb(255, 255, 224);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LightYellow() {     return Color(255, 255, 224); }
	/**
	 * <code style="background-color: rgb(  0, 255,   0);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Lime() {            return Color(  0, 255,   0); }
	/**
	 * <code style="background-color: rgb( 50, 205,  50);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color LimeGreen() {       return Color( 50, 205,  50); }
	/**
	 * <code style="background-color: rgb(250, 240, 230);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Linen() {           return Color(250, 240, 230); }
	/**
	 * <code style="background-color: rgb(255,   0, 255);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Magenta() {         return Color(255,   0, 255); }
	/**
	 * <code style="background-color: rgb(128,   0,   0);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Maroon() {          return Color(128,   0,   0); }
	/**
	 * <code style="background-color: rgb(102, 205, 170);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color MediumAquamarine() { return Color(102, 205, 170); }
	/**
	 * <code style="background-color: rgb(  0,   0, 205);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color MediumBlue() {      return Color(  0,   0, 205); }
	/**
	 * <code style="background-color: rgb(186,  85, 211);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color MediumOrchid() {    return Color(186,  85, 211); }
	/**
	 * <code style="background-color: rgb(147, 112, 219);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color MediumPurple() {    return Color(147, 112, 219); }
	/**
	 * <code style="background-color: rgb( 60, 179, 113);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color MediumSeaGreen() {  return Color( 60, 179, 113); }
	/**
	 * <code style="background-color: rgb(123, 104, 238);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color MediumSlateBlue() { return Color(123, 104, 238); }
	/**
	 * <code style="background-color: rgb(  0, 250, 154);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color MediumSpringGreen() { return Color(  0, 250, 154); }
	/**
	 * <code style="background-color: rgb( 72, 209, 204);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color MediumTurquoise() { return Color( 72, 209, 204); }
	/**
	 * <code style="background-color: rgb(199,  21, 133);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color MediumVioletRed() { return Color(199,  21, 133); }
	/**
	 * <code style="background-color: rgb( 25,  25, 112);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color MidnightBlue() {    return Color( 25,  25, 112); }
	/**
	 * <code style="background-color: rgb(245, 255, 250);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color MintCream() {       return Color(245, 255, 250); }
	/**
	 * <code style="background-color: rgb(255, 228, 225);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color MistyRose() {       return Color(255, 228, 225); }
	/**
	 * <code style="background-color: rgb(255, 228, 181);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Moccasin() {        return Color(255, 228, 181); }
	/**
	 * <code style="background-color: rgb(255, 222, 173);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color NavajoWhite() {     return Color(255, 222, 173); }
	/**
	 * <code style="background-color: rgb(  0,   0, 128);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Navy() {            return Color(  0,   0, 128); }
	/**
	 * <code style="background-color: rgb(253, 245, 230);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color OldLace() {         return Color(253, 245, 230); }
	/**
	 * <code style="background-color: rgb(128, 128,   0);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Olive() {           return Color(128, 128,   0); }
	/**
	 * <code style="background-color: rgb(107, 142,  35);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color OliveDrab() {       return Color(107, 142,  35); }
	/**
	 * <code style="background-color: rgb(255, 165,   0);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Orange() {          return Color(255, 165,   0); }
	/**
	 * <code style="background-color: rgb(255,  69,   0);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color OrangeRed() {       return Color(255,  69,   0); }
	/**
	 * <code style="background-color: rgb(218, 112, 214);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Orchid() {          return Color(218, 112, 214); }
	/**
	 * <code style="background-color: rgb(238, 232, 170);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color PaleGoldenrod() {   return Color(238, 232, 170); }
	/**
	 * <code style="background-color: rgb(152, 251, 152);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color PaleGreen() {       return Color(152, 251, 152); }
	/**
	 * <code style="background-color: rgb(175, 238, 238);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color PaleTurquoise() {   return Color(175, 238, 238); }
	/**
	 * <code style="background-color: rgb(219, 112, 147);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color PaleVioletRed() {   return Color(219, 112, 147); }
	/**
	 * <code style="background-color: rgb(255, 239, 213);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color PapayaWhip() {      return Color(255, 239, 213); }
	/**
	 * <code style="background-color: rgb(255, 218, 185);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color PeachPuff() {       return Color(255, 218, 185); }
	/**
	 * <code style="background-color: rgb(205, 133,  63);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Peru() {            return Color(205, 133,  63); }
	/**
	 * <code style="background-color: rgb(255, 192, 203);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Pink() {            return Color(255, 192, 203); }
	/**
	 * <code style="background-color: rgb(221, 160, 221);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Plum() {            return Color(221, 160, 221); }
	/**
	 * <code style="background-color: rgb(176, 224, 230);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color PowderBlue() {      return Color(176, 224, 230); }
	/**
	 * <code style="background-color: rgb(128,   0, 128);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Purple() {          return Color(128,   0, 128); }
	/**
	 * <code style="background-color: rgb(255,   0,   0);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Red() {             return Color(255,   0,   0); }
	/**
	 * <code style="background-color: rgb(188, 143, 143);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color RosyBrown() {       return Color(188, 143, 143); }
	/**
	 * <code style="background-color: rgb( 65, 105, 225);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color RoyalBlue() {       return Color( 65, 105, 225); }
	/**
	 * <code style="background-color: rgb(139,  69,  19);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color SaddleBrown() {     return Color(139,  69,  19); }
	/**
	 * <code style="background-color: rgb(250, 128, 114);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Salmon() {          return Color(250, 128, 114); }
	/**
	 * <code style="background-color: rgb(244, 164,  96);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color SandyBrown() {      return Color(244, 164,  96); }
	/**
	 * <code style="background-color: rgb( 46, 139,  87);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color SeaGreen() {        return Color( 46, 139,  87); }
	/**
	 * <code style="background-color: rgb(255, 245, 238);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Seashell() {        return Color(255, 245, 238); }
	/**
	 * <code style="background-color: rgb(160,  82,  45);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Sienna() {          return Color(160,  82,  45); }
	/**
	 * <code style="background-color: rgb(192, 192, 192);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Silver() {          return Color(192, 192, 192); }
	/**
	 * <code style="background-color: rgb(135, 206, 235);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color SkyBlue() {         return Color(135, 206, 235); }
	/**
	 * <code style="background-color: rgb(106,  90, 205);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color SlateBlue() {       return Color(106,  90, 205); }
	/**
	 * <code style="background-color: rgb(112, 128, 144);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color SlateGray() {       return Color(112, 128, 144); }
	/**
	 * <code style="background-color: rgb(255, 250, 250);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Snow() {            return Color(255, 250, 250); }
	/**
	 * <code style="background-color: rgb(  0, 255, 127);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color SpringGreen() {     return Color(  0, 255, 127); }
	/**
	 * <code style="background-color: rgb( 70, 130, 180);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color SteelBlue() {       return Color( 70, 130, 180); }
	/**
	 * <code style="background-color: rgb(210, 180, 140);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Tan() {             return Color(210, 180, 140); }
	/**
	 * <code style="background-color: rgb(  0, 128, 128);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Teal() {            return Color(  0, 128, 128); }
	/**
	 * <code style="background-color: rgb(216, 191, 216);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Thistle() {         return Color(216, 191, 216); }
	/**
	 * <code style="background-color: rgb(255,  99,  71);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Tomato() {          return Color(255,  99,  71); }
	/**
	 * <code style="background-color: rgb( 64, 224, 208);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Turquoise() {       return Color( 64, 224, 208); }
	/**
	 * <code style="background-color: rgb(238, 130, 238);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Violet() {          return Color(238, 130, 238); }
	/**
	 * <code style="background-color: rgb(245, 222, 179);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Wheat() {           return Color(245, 222, 179); }
	/**
	 * <code style="background-color: rgb(255, 255, 255);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color White() {           return Color(255, 255, 255); }
	/**
	 * <code style="background-color: rgb(245, 245, 245);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color WhiteSmoke() {      return Color(245, 245, 245); }
	/**
	 * <code style="background-color: rgb(255, 255,   0);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color Yellow() {          return Color(255, 255,   0); }
	/**
	 * <code style="background-color: rgb(154, 205,  50);">
	 * &nbsp;&nbsp;&nbsp;</code>
	 */
	Color YellowGreen() {     return Color(154, 205,  50); }
}

