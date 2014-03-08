
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.format;

import dynamin.core.global;
import dynamin.core.meta;
import dynamin.core.string;
import dynamin.core.test;

private:

cstring parseFormatParam(cstring specifier, ref int paramIndex) {
	// specifier is something like "1:x" or ":d"
	int i;
	for(i = 0; i < specifier.length && specifier[i] != ':'; ++i) {
	}
	if(i > 0) {
		try {
			paramIndex = to!int(specifier[0..i]);
		} catch(Exception ex) {
			throw new Exception("Invalid parameter index.");
		}
	}
	return i >= specifier.length ? "" : specifier[i+1..$];
}

/**
 * Parses `formatStr`, passing each part to `write` or `writeParam` as it is encountered.
 * For example:
 *
 *     parseFormatString("I am {0:x} years old!", writeParam, write);
 *     // will result in:
 *     write("I am ");
 *     writeParam(0, "x");
 *     write(" years old!");
 *
 */
public void parseFormatString(	cstring formatStr,
	void delegate(int param, cstring format) writeParam,
	void delegate(scope cstring str) write) {

	int paramIndex = 0;     // param to write next, if not specified
	cstring paramFormat;

	uword start = 0;

	for(int i = 0; i < formatStr.length; ++i) {
		if(formatStr[i] == '{') {
			write(formatStr[start..i]);
			start = i + 1;

			if(i + 1 >= formatStr.length)
				throw new Exception("Unterminated format specifier.");
			++i;

			if(formatStr[i] == '{') {            // escaped open brace
				// start already is the index of the second open brace
			} else {                             // format specifier
				while(formatStr[i] != '}') {
					if(formatStr[i] == '{')
						throw new Exception("Open brace in format specifier.");
					if(++i >= formatStr.length)
						throw new Exception("Unterminated format specifier.");
				}
				paramFormat = parseFormatParam(formatStr[start..i], paramIndex);
				start = i + 1;
				writeParam(paramIndex, paramFormat);
				++paramIndex;
			}
		} else if(formatStr[i] == '}') {
			write(formatStr[start..i]);
			start = i + 1;

			if(i + 1 >= formatStr.length || formatStr[i + 1] != '}')
				throw new Exception("Unescaped close brace.");
			++i;                                 // escaped close brace
		}
	}
	if(start < formatStr.length)
		write(formatStr[start..$]);
}

unittest {
	struct Call {
		int index;
		string str;
	}
	Call[] calls;
	int callIndex;
	void paramCallback(int param, cstring format) {
		assertEqual(param, calls[callIndex].index); // crash if out of bounds
		assertEqual(format, calls[callIndex].str);
		++callIndex;
	};
	void strCallback(scope cstring str) {
		assertEqual(str, calls[callIndex].str); // crash if out of bounds
		++callIndex;
	};

	calls = [
		Call(-1, "one"),
		Call(0, ""),
		Call(-1, "two"),
		Call(1, ""),
		Call(-1, "three")
	];
	callIndex = 0;
	parseFormatString("one{0}two{1}three", &paramCallback, &strCallback);
	assertEqual(callIndex, calls.length);

	calls = [
		Call(-1, "one"),
		Call(0, "abc12"),
		Call(-1, "two"),
		Call(1, "yyyy-mm-dd"),
		Call(-1, "three")
	];
	callIndex = 0;
	parseFormatString("one{0:abc12}two{1:yyyy-mm-dd}three", &paramCallback, &strCallback);
	assertEqual(callIndex, calls.length);

	calls = [
		Call(-1, "one"),
		Call(0, "~!@#$%^&*()_+-=[]\\:\"<>?;',./"),
		Call(-1, "two"),
	];
	callIndex = 0;
	parseFormatString("one{0:~!@#$%^&*()_+-=[]\\:\"<>?;',./}two", &paramCallback, &strCallback);
	assertEqual(callIndex, calls.length);

	calls = [
		Call(-1, "one"),
		Call(0, ""),
		Call(-1, "two"),
		Call(1, ""),
		Call(-1, "three"),
		Call(2, ""),
	];
	callIndex = 0;
	parseFormatString("one{}two{}three{}", &paramCallback, &strCallback);
	assertEqual(callIndex, calls.length);

	calls = [
		Call(-1, "one"),
		Call(4, ""),
		Call(-1, "two"),
		Call(5, ""),
		Call(-1, "three"),
		Call(2, ""),
		Call(-1, "four"),
		Call(3, "x"),
	];
	callIndex = 0;
	parseFormatString("one{4}two{}three{2}four{:x}", &paramCallback, &strCallback);
	assertEqual(callIndex, calls.length);

	string testStr;
	parseFormatString(	"on{{e}}{2}}}two{{{}}}",
		delegate (i, f) { testStr ~= "P"; },
		delegate (scope str) { testStr ~= str; });
	assertEqual(testStr, "on{e}P}two{P}");

	assertThrows!Exception(parseFormatString(	"test{",
		delegate (i, f) { },
		delegate (scope str) { }));
	assertThrows!Exception(parseFormatString(	"test{0",
		delegate (i, f) { },
		delegate (scope str) { }));
	assertThrows!Exception(parseFormatString(	"test{0{}",
		delegate (i, f) { },
		delegate (scope str) { }));
	assertThrows!Exception(parseFormatString(	"test}ing",
		delegate (i, f) { },
		delegate (scope str) { }));
	assertThrows!Exception(parseFormatString(	"test{0x12}ing",
		delegate (i, f) { },
		delegate (scope str) { }));
}

// 32-bit integers in base 10 require 10 characters (11 if negative)
// 64-bit integers in base 10 require 20 characters
// worst case: a 64-bit integer in base 2: 65 characters
public string toString(T)(T num, int base = 10, bool uppercase = true, mstring buffer = null)
if(Meta.isTypeIntegral!(T)) {
	string digits;

	static if(Meta.areTypesEqual!(T, long)) {
		if(num == long.min)
			return "-9223372036854775808";
	} else static if(Meta.areTypesEqual!(T, int)) {
		if(num == int.min)
			return toString!long(num, base, uppercase, buffer);
	} else static if(Meta.areTypesEqual!(T, short)) {
		if(num == short.min)
			return toString!int(num, base, uppercase, buffer);
	} else static if(Meta.areTypesEqual!(T, byte)) {
		if(num == byte.min)
			return toString!short(num, base, uppercase, buffer);
	}

	if(uppercase)
		digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	else
		digits = "0123456789abcdefghijklmnopqrstuvwxyz";

	int requiredLength;
	if(base >= 10)
		requiredLength = T.sizeof <= 4 ? 11 : 20;
	else
		requiredLength = 65;

	if(!buffer || buffer.length < requiredLength)
		buffer = new char[requiredLength];

	bool negative = num < 0;
	if(negative)
		num = -num;
	auto i = buffer.length;
	while(num != 0) {
		buffer[--i] = digits[cast(word)(num % base)];
		num /= base;
	}
	if(negative)
		buffer[--i] = '-';
	return cast(immutable)buffer[i..$];
}

unittest {
	char[20] buff;
	assertEqual(toString(15), "15");
	assertEqual(toString(-15), "-15");
	assertEqual(toString(-2_147_483_648), "-2147483648");
	assertEqual(toString(684, 16), "2AC");
	assertEqual(toString(684, 16, false), "2ac");
	assertEqual(toString(684, 2), "1010101100");
	auto str = toString(150, 10, true, buff);
	assertEqual(str, "150");
	assert(str.ptr == buff[$-3..$].ptr);
}

