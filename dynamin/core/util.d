
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.util;

import dynamin.core.string;
import dynamin.core.exceptions;
import std.exception;

import tango.util.Convert;

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
	enforceEx!ArgumentError(num <= 3999 && num >= 0,
		"Roman numerals must be between 0 and 3999 inclusive.");

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
		enforceEx!ArgumentError(value != -1, "Invalid roman numeral: " ~ c);
		if(value < largestSoFar) {
			num -= value;
		} else {
			num += value;
			largestSoFar = value;
		}
	}
	enforceEx!ArgumentError(num <= 3999 && num >= 0,
		"Roman numerals must be between 0 and 3999 inclusive.");
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

