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

module dynamin.core.global;

import dynamin.core.string;
import tango.math.Math;
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

/**
 * The string used to separate lines.
 * This is "\r\n" under Windows and "\n" under Linux.
 */
const string LineSeparator = FileConst.NewlineString;
/**
 * The string used to separate directories in a path.
 * This is "\\" under Windows and "/" under Linux.
 */
const string DirSeparator = FileConst.PathSeparatorString;
///
const char DirSeparatorChar = FileConst.PathSeparatorChar;
/**
 * The string used to separate paths.
 * This is ";" under Windows and ":" under Linux
 */
const string PathSeparator = FileConst.SystemPathString;
///
const char PathSeparatorChar = FileConst.SystemPathChar;

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
bool floatsEqual(real num1, real num2, real epsilon) {
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
void arrayCopy(T)(T[] srcData, uint srcStart, T[] destData, uint destStart, uint length) {
	if((srcData is destData && srcStart == destStart) || length == 0)
		return;
	if(srcStart > destStart) {
		//copy forward
		for(int i = 0; i < length; ++i)
		  destData[destStart + i] = srcData[srcStart + i];
	} else {
		//copy reverse
		for(int i = length-1; i >= 0; --i)
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

/**
 * Sets every byte of the specified memory block to value.
 */
void memoryFill(void* mem, uword count, ubyte value) {
	ubyte* memB = cast(ubyte*)mem;
	while(count != 0) {
		*memB++ = value;
		--count;
	}
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
 * and destination should not overlap, or the results will be undefined.
 * Note that the source and destination parameters are opposite in
 * order from the C function memcpy(). If count is a multiple of the
 * native pointer size, the copy will be done in blocks of that size.
 */
void memoryCopy(void* srcMem, void* destMem, uword count) {
	// copy in blocks of the pointer size, if possible
	if(count % word.sizeof == 0) {
		count /= word.sizeof;
		uword* src = cast(uword*)srcMem;
		uword* dest = cast(uword*)destMem;
		while(count != 0) {
			*dest++ = *src++;
			--count;
		}
	} else {
		ubyte* src = cast(ubyte*)srcMem;
		ubyte* dest = cast(ubyte*)destMem;
		while(count != 0) {
			*dest++ = *src++;
			--count;
		}
	}
}
unittest {
	char[] buff = "Hello".dup;
	memoryCopy(buff.ptr, buff.ptr+3, 2);
	assert(buff == "HelHe");
	buff = "Longer text here".dup;
	memoryCopy(buff.ptr+7, buff.ptr+12, 4);
	assert(buff == "Longer text text");
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
string toRomanNumerals(int num) {
	if(num > 3999 || num < 0)
		throw new IllegalArgumentException("ToRomanNumerals():" ~
			"highest convertable roman numeral is 3999");
	static combos = [[0][0..0], [0], [0,0], [0,0,0], [0,1],
	[1], [1,0], [1,0,0], [1,0,0,0], [0,2]];
	static letters = "IVXLCDM";
	string str = "";
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

int numeralToValue(char c) {
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
int parseRomanNumerals(string str) {
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
		throw new IllegalArgumentException("ParseRomanNumerals():" ~
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
string byteCountToString(ulong num) {
	const factor = 1024;
	//kilo, mega, giga, tera, peta, exa, zetta, yotta
	char[][] units = [
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
	string str = to!(string)(num);
	if(str.length < 3) {
		str ~= "." ~ to!(string)(rem*10/factor);
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

