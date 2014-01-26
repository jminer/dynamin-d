
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.global;

import dynamin.core.string;
import std.math : abs;
import std.traits;
import tango.io.model.IFile;
import tango.core.Exception;

public import tango.util.Convert;

static if((void*).sizeof == 4) {
	/**
	 * Defined as an int on 32-bit platforms and as a long on 64-bit platforms.
	 */
	alias int word;
	/**
	 * Defined as a uint on 32-bit platforms and
	 * as a ulong on 64-bit platforms.
	 */
	alias uint uword;
} else static if((void*).sizeof == 8) {
	/**
	 * Defined as an int on 32-bit platforms and as a long on 64-bit platforms.
	 */
	alias long word;
	/**
	 * Defined as a uint on 32-bit platforms and
	 * as a ulong on 64-bit platforms.
	 */
	alias ulong uword;
}

version(Windows) {
	// The C `long` type is 32-bit in both 32 and 64-bit Windows.
	alias int c_long;
	alias uint c_ulong;
} else {
	// These sizes are right for most systems.
	// http://en.wikipedia.org/wiki/64-bit_computing#64-bit_data_models
	// http://stackoverflow.com/questions/384502/what-is-the-bit-size-of-long-on-64-bit-windows
	version(D_LP64) {
		alias long c_long;
		alias ulong c_ulong;
	} else {
		alias int c_long;
		alias uint c_ulong;
	}
}

/**
 * The string used to separate lines.
 * This is "\r\n" under Windows and "\n" under Linux.
 */
enum string LineSeparator = FileConst.NewlineString;
/**
 * The string used to separate directories in a path.
 * This is "\\" under Windows and "/" under Linux.
 */
enum string DirSeparator = FileConst.PathSeparatorString;
///
enum char DirSeparatorChar = FileConst.PathSeparatorChar;
/**
 * The string used to separate paths.
 * This is ";" under Windows and ":" under Linux
 */
enum string PathSeparator = FileConst.SystemPathString;
///
enum char PathSeparatorChar = FileConst.SystemPathChar;

/**
 * Tests whether num1 and num2 are equal. They are considered equal
 * if the difference between them is less than epsilon.
 * Examples:
 * -----
 * floatsEqual(3.14, 3.2, 0.1) == true
 * floatsEqual(3.14, 3.3, 0.1) == false
 * floatsEqual(3.14, 3.151, 0.01) == false
 * -----
 */
bool floatsEqual(double num1, double num2, double epsilon) {
	return abs(num1 - num2) <= epsilon;
}
unittest {
	assert(floatsEqual(3.14, 3.2, 0.1) == true);
	assert(floatsEqual(3.14, 3.3, 0.1) == false);
	assert(floatsEqual(3.14, 3.151, 0.01) == false);
}

/**
 * Copies length elements starting at srcStart in srcData to destStart
 * in destData. Data is copied as if srcData and destData are two separate
 * arrays, even if they are the same.
 */
void arrayCopy(T)(T[] srcData, word srcStart, T[] destData, word destStart, word length) {
	if((srcData is destData && srcStart == destStart) || length == 0)
		return;
	if(srcStart > destStart) {
		//copy forward
		for(word i = 0; i < length; ++i)
		  destData[destStart + i] = srcData[srcStart + i];
	} else {
		//copy reverse
		for(word i = length-1; i >= 0; --i)
			destData[destStart + i] = srcData[srcStart + i];
	}
}
unittest {
	char[] c = "Computer".dup;
	arrayCopy!(char)(c, 3, c, 2, 4);
	assert(c == "Coputeer");
	c = "Computer".dup;
	arrayCopy!(char)(c, 2, c, 3, 4);
	assert(c == "Commputr");
	c = "hi".dup;
	arrayCopy!(char)(c, 1, c, 0, 1);
	assert(c == "ii");
}


extern(C) {
	void* memmove(void* dest, const void* src, uword n);
	void* memset(void* s, int c, uword n);
}

/**
 * Sets every byte of the specified memory block to value.
 */
void memoryFill(void* mem, uword count, ubyte value) {
	memset(mem, value, count);
}
unittest {
	char[] buff = "jEdit".dup;
	memoryFill(buff.ptr+1, 3, 0x23);
	assert(buff == "j\x23\x23\x23t");
}

/**
 * Sets every byte of the specified memory block to zero.
 */
void memoryZero(void* mem, uword count) {
	memoryFill(mem, count, 0);
}
unittest {
	char[] buff = "jEdit".dup;
	memoryZero(buff.ptr+1, 3);
	assert(buff == "j\0\0\0t");
}

/**
 * Copies the specified number of bytes from srcMem to destMem. The source
 * and destination may overlap.
 * Note that the source and destination parameters are opposite in
 * order from the C function memcpy().
 */
void memoryCopy(void* srcMem, void* destMem, uword count) {
	memmove(destMem, srcMem, count);
}
unittest {
	char[] buff = "Hello".dup;
	memoryCopy(buff.ptr, buff.ptr+3, 2);
	assert(buff == "HelHe");
	buff = "Longer text here".dup;
	memoryCopy(buff.ptr+7, buff.ptr+12, 4);
	assert(buff == "Longer text text");
}

/// Returns the smallest of the specified values.
T min(T)(T a, T b) {
	return a < b ? a : b;
}
/// ditto
CommonType!T min(T...)(T params) {
	CommonType!T result = params[0];
	foreach(i, p; params) {
		if(params[i] < result)
			result = params[i];
	}
	return result;
}

/// Returns the largest of the specified values.
T max(T)(T a, T b) {
	return a > b ? a : b;
}
/// ditto
CommonType!T max(T...)(T params) {
	CommonType!T result = params[0];
	foreach(i, p; params) {
		if(params[i] > result)
			result = params[i];
	}
	return result;
}

unittest {
	assert(min(5.5, 8) == 5.5);
	assert(min(8, 5.5) == 5.5);

	assert(max(8.5, 5) == 8.5);
	assert(max(5, 8.5) == 8.5);

	assert(min(6, 4.5, 8.5) == 4.5);

	assert(max(6, 4.5, 8.5) == 8.5);
}

/**
 * Converts a number into its roman numeral form. The number must
 * be between 0 and 3,999, inclusive.
 * Examples:
 * -----
 * toRomanNumerals(2) == "II"
 * toRomanNumerals(58) == "LVIII"
 * toRomanNumerals(194) == "CXCIV"
 * -----
 */
mstring toRomanNumerals(int num) {
	if(num > 3999 || num < 0)
		throw new IllegalArgumentException("toRomanNumerals():" ~
			"highest convertable roman numeral is 3999");
	static combos = [[0][0..0], [0], [0,0], [0,0,0], [0,1],
	[1], [1,0], [1,0,0], [1,0,0,0], [0,2]];
	static letters = "IVXLCDM";
	mstring str;
	int letterOffset = 0;
	while(num > 0) {
		foreach_reverse(int c; combos[num % 10])
			str = letters[c+letterOffset] ~ str;
		num /= 10;
		letterOffset += 2;
	}
	return str;
}
unittest {
	assert(toRomanNumerals(2) == "II");
	assert(toRomanNumerals(58) == "LVIII");
	assert(toRomanNumerals(194) == "CXCIV");

	assert(toRomanNumerals(0) == "");
	assert(toRomanNumerals(1) == "I");
	assert(toRomanNumerals(10) == "X");
	assert(toRomanNumerals(500) == "D");
	assert(toRomanNumerals(18) == "XVIII");
	assert(toRomanNumerals(3949) == "MMMCMXLIX");
}

private int numeralToValue(char c) {
	switch(c) {
	case 'I': case 'i': return 1;
	case 'V': case 'v': return 5;
	case 'X': case 'x': return 10;
	case 'L': case 'l': return 50;
	case 'C': case 'c': return 100;
	case 'D': case 'd': return 500;
	case 'M': case 'm': return 1000;
	default: return -1;
	}
}
/**
 * Parses the specified string of roman numerals and returns the value.
 * The value must be less than or equal to 3,999. The string may be uppercase,
 * lowercase, or a mixture of both cases.
 * Examples:
 * -----
 * parseRomanNumerals("II") == 2
 * parseRomanNumerals("LVIII") == 58
 * parseRomanNumerals("CXCIV") == 194
 * parseRomanNumerals("xxxxviiii") == 49
 * -----
 */
int parseRomanNumerals(cstring str) {
	int num = 0;
	int largestSoFar = 1;
	foreach_reverse(c; str) {
		int value = numeralToValue(c);
		if(value == -1)
			throw new IllegalArgumentException("Invalid roman numeral: " ~ c);
		if(value < largestSoFar) {
			num -= value;
		} else {
			num += value;
			largestSoFar = value;
		}
	}
	if(num > 3999 || num < 0)
		throw new IllegalArgumentException("parseRomanNumerals():" ~
			"highest convertable roman numeral is 3999");
	return num;
}
unittest {
	assert(parseRomanNumerals("II") == 2);
	assert(parseRomanNumerals("LVIII") == 58);
	assert(parseRomanNumerals("CXCIV") == 194);
	assert(parseRomanNumerals("xxxxviiii") == 49);

	assert(parseRomanNumerals("") == 0);
	assert(parseRomanNumerals("I") == 1);
	assert(parseRomanNumerals("X") == 10);
	assert(parseRomanNumerals("D") == 500);
	assert(parseRomanNumerals("XVIII") == 18);
	assert(parseRomanNumerals("MMMCMXLIX") == 3949);
}
unittest {
	for(int i = 0; i < 4000; ++i)
		assert(toRomanNumerals(i).parseRomanNumerals() == i);
}

/**
 * Converts a number of bytes into a human friendly string. The units
 * supported are bytes, KB, MB, GB, TB, PB, EB, ZB, and YB.
 * Examples:
 * -----
 * byteCountToString(202) == "202 bytes"
 * byteCountToString(1021) == "1021 bytes"
 * byteCountToString(106_496) == "104 KB"
 * byteCountToString(620_705_792) == "591 MB"
 * -----
 */
mstring byteCountToString(ulong num) {
	enum factor = 1024;
	//kilo, mega, giga, tera, peta, exa, zetta, yotta
	string[] units = [
	" bytes", " KB", " MB", " GB", " TB", " PB", " EB", " ZB", " YB"];
	uint unitIndex = 0;
	ulong div = factor;
	uint rem;
	while(num > factor-1 && unitIndex < units.length-1) {
		rem = num % factor;
		num /= factor;
		++unitIndex;
	}
	//rem/1024 equals the fraction of unit
	mstring str = to!(mstring)(num);
	if(str.length < 3) {
		str ~= "." ~ to!(mstring)(rem*10/factor);
	}
	str ~= units[unitIndex];
	return str;
}
unittest {
	assert(byteCountToString(202) == "202 bytes");
	assert(byteCountToString(1021) == "1021 bytes");
	assert(byteCountToString(106_496) == "104 KB");
	assert(byteCountToString(620_705_792) == "591 MB");
}

