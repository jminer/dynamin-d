
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

