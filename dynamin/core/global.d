
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.global;

import std.math : abs;
import std.traits;
import tango.io.model.IFile;

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

