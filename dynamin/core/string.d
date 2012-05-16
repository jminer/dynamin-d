
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

/**
 * These functions should all return a new string if it is possible for them
 * to ever modify their input. If they will never modify their input, they
 * should always return a slice.
 */
module dynamin.core.string;

public import dynamin.core.array;

import tango.core.Exception;
import tango.text.convert.Utf;
import tango.text.convert.Layout;
import tango.text.Unicode;
import dynamin.core.global;
import dynamin.core.math;

/// Defined as a char[]
alias char[] string;

///
char* toCharPtr(char[] str) {
	return (str~'\0').ptr;
}
///
wchar* toWcharPtr(char[] str) {
	return toString16(str~'\0').ptr;
}

/*
string ToString(ulong num, uint base = 10) {
	if(base > 16)
		throw new Exception("ToString() - radix more than 16");
	char[] digits = "0123456789abcdef";
	string str;
	ulong div = base;
	ulong prevDiv = 1;
	do {
		uint rem = num % div;
		str ~= digits[rem/prevDiv];
		prevDiv = div;
		div *= base;
		num -= rem;
	} while(num > 0);
	str.reverse;
	return str;
}
*/

// TODO: move to encoding.d
/**
  * Returns true if the specified code unit is a high surrogate, in the range of 0xD800 to 0xDBFF.
  * A high surrogate comes before a low surrogate in a surrogate pair.
  */
bool isHighSurrogate(wchar c) {
	return c >= 0xD800 && c <= 0xDBFF;
}
/**
 * Returns true if the specified code unit is a low surrogate, in the range of 0xDC00 to 0xDFFF.
 * A low surrogate comes after a high surrogate in a surrogate pair.
 */
bool isLowSurrogate(wchar c) {
	return c >= 0xDC00 && c <= 0xDFFF;
}

Layout!(char) formatter;
static this() {
	formatter = new Layout!(char);
}
string format(char[] str, ...) {
	return formatter.convert(_arguments, _argptr, str);
}
unittest {
	assert(format("I am {}", 20) == "I am 20");
}

/**
 * Converts all lowercase characters in the specified string to uppercase.
 * Examples:
 * -----
 * "Bounce the ball.".upcase() == "BOUNCE THE BALL."
 * "Mañana".upcase() == "MAÑANA"
 * "æóëø".upcase() == "ÆÓËØ"
 * -----
 */
string upcase(string str) {
	return toUpper(str);
}
unittest {
	assert("Bounce the ball.".upcase() == "BOUNCE THE BALL.");
	assert("Mañana".upcase() == "MAÑANA");
	assert("æóëø".upcase() == "ÆÓËØ");
}
/**
 * Converts all uppercase characters in the specified string to lowercase.
 * Examples:
 * -----
 * "BoUnCe ThE BALL.".downcase() == "bounce the ball."
 * "MAÑANA".downcase() == "mañana"
 * "ÆÓËØ".downcase() == "æóëø"
 * -----
 */
string downcase(string str) {
	return toLower(str);
}
unittest {
	assert("BoUnCe ThE BALL.".downcase() == "bounce the ball.");
	assert("MAÑANA".downcase() == "mañana");
	assert("ÆÓËØ".downcase() == "æóëø");
}

// TODO: make more use of delegates in these?
// TODO; use templates so that these work with wchar and dchar?
bool startsWith(string str, string subStr, int start = 0) {
	if(start+subStr.length > str.length)
		return false;
	return str[start..start+subStr.length] == subStr;
}
bool endsWith(string str, string subStr) {
	return endsWith(str, subStr, str.length);
}
bool endsWith(string str, string subStr, int start) {
	if(start-subStr.length < 0)
		return false;
	return str[str.length-subStr.length..str.length] == subStr;
}
int findLast(string str, string subStr) {
	return findLast(str, subStr, str.length);
}
int findLast(string str, string subStr, int start) {
	for(int i = start-subStr.length; i >= 0; --i)
		if(str[i..i+subStr.length] == subStr)
			return i;
	return -1;
}
int find(string str, string subStr, int start = 0) {
	for(int i = start; i < str.length-subStr.length; ++i)
		if(str[i..i+subStr.length] == subStr)
			return i;
	return -1;
}

string remove(string str, int start, int count = 1) {
	return str[0..start] ~ str[start+count..str.length];
}
// TODO: ?
// split(string str, int delegate(string s) func)
//string[] split(string str, string subStr) {
//	return split(str, (string s) { return s.startsWith(subStr) ? subStr.length, : -1; };
//}
// TODO: return slices to string
//split1("50=20=10", "=") -> ["50", "20=10"]
string[] split1(string str, string subStr) {
	if(subStr.length == 0)
		return [str];
	int index = find(str, subStr);
	if(index == -1)
		return [str];
	string[] strs = new string[2];
	strs[0] = str[0..index].dup;
	strs[1] = str[index+subStr.length..str.length].dup;
	return strs;
}
// TODO: return slices to string
//split("50=20=10", "=") -> ["50", "20", "10"]
string[] split(string str, string subStr) {
	if(subStr.length == 0)
		return [str];
	string[] strs;
	int index, searchFrom;
	int i = 0;
	while(searchFrom < str.length) {
		index = find(str, subStr, searchFrom);
		if(index == -1) index = str.length;
		strs.length = strs.length+1;
		strs[i] = str[searchFrom..index].dup;
		++i;
		searchFrom = index+subStr.length;
	}
	return strs;
}
///
enum Newline {
	///
	Cr = 0,
	///
	Lf = 1,
	///
	Crlf = 2,
	///
	Macintosh = 0,
	///
	Linux = 1,
	///
	Windows = 2
}
/**
 * Changes every occurrence of a newline in the specified string to the specified newline.
 * Examples:
 * -----
 * "\r\n\n\r".convertNewlines(Newline.Lf) == "\n\n\n"
 * "\r\n\n\r".convertNewlines(Newline.Windows) == "\r\n\r\n\r\n"
 * "\n\r\n".convertNewlines(Newline.Macintosh) == "\r\r"
 * -----
 */
string convertNewlines(string str, Newline nl) {
	string lineSep;
	switch(nl) {
	case Newline.Cr:   lineSep = "\r";   break;
	case Newline.Lf:   lineSep = "\n";   break;
	case Newline.Crlf: lineSep = "\r\n"; break;
	}
	return str.replace([cast(string)"\r\n", "\r", "\n"], lineSep);
}
unittest {
	assert("\r\n\n\r".convertNewlines(Newline.Lf) == "\n\n\n");
	assert("\r\n\n\r".convertNewlines(Newline.Windows) == "\r\n\r\n\r\n");
	assert("\n\r\n".convertNewlines(Newline.Macintosh) == "\r\r");
}

/**
 * Joins all the strings in the specified array together into one string, putting
 * the specified separator between them.
 * Examples:
 * -----
 * join(["10", "15", "17"], " - ") == "10 - 15 - 17"
 * join(["789", "672", "484"], ",") == "789,672,484"
 * join(["aol.com", "join", "intro.html"], "/") == "aol.com/join/intro.html"
 * -----
 */
string join(string[] strs, string sep) {
	if(strs.length == 0)
		return "";
	int len;
	foreach(string s; strs)
		len += s.length;
	len += sep.length*(strs.length-1);

	string newStr = new char[len];
	newStr[0..strs[0].length] = strs[0];
	int start = strs[0].length;
	for(int i = 1; i < strs.length; ++i) {
		auto str = strs[i];
		newStr[start..start+sep.length] = sep;
		start += sep.length;
		newStr[start..start+str.length] = str;
		start += str.length;
	}
	return newStr;
}
unittest {
	// TODO: remove cast(string) when D has bugs fixed
	assert(join(["10", "15", "17"], " - ") == "10 - 15 - 17");
	assert(join(["789", "672", "484"], ",") == "789,672,484");
	assert(join([cast(string)"aol.com", "join", "intro.html"], "/") == "aol.com/join/intro.html");
}

/**
 * Multiplies the given string the specified number of times.
 * Returns: a string that is the result of adding the specified string onto
 *          an empty string the specified number of times
 * Examples:
 * -----
 * "Hi...".times(3) == "Hi...Hi...Hi..."
 * "0".times(20) == "00000000000000000000"
 * "Hi".times(0) == ""
 * -----
 */
string times(string str, int n) {
	string newStr = new char[n * str.length];
	for(int i = 0; i < newStr.length; i += str.length)
		newStr[i..i+str.length] = str;
	return newStr;
}
unittest {
	assert("0".times(4) == "0000");
	assert("Hello! ".times(2) == "Hello! Hello! ");
	assert("".times(50) == "");
	assert("Hi".times(0) == "");
}

// TODO: flesh out and make public
struct sbuilder {
	int Count;
	string Data;
	void Add(char c) {
		if(Count + 1 > Data.length)
			Data.length = (Data.length + 1) * 2;
		Data[Count] = c;
		++Count;
	}
	void Add(string str) {
		if(Count + str.length > Data.length)
			Data.length = max((Data.length + 1) * 2, Count + str.length);
		Data[Count..Count+str.length] = str;
		Count += str.length;
	}
	string ToString() {
		return Data[0..Count].dup;
	}
}
/**
 * Replaces any occurrence of a specified search string in the specified string
 * with corresponding replacement string. The length of the searchStrs array
 * must equal the length of the replacements array.
 * Examples:
 * -----
 * "Mississippi".replace(["is", "i"], ["..", "*"]) == "M..s..s*pp*"
 * "Mississippi".replace("ss", "...") == "Mi...i...ippi"
 * "Hello".replace("ll", "y") == "Heyo"
 * "Hi".replace([], []) == "Hi"
 * -----
 * Note: If multiple search strings have the same prefix, the longer search
 *       strings must be given first. Otherwise, any occurrence will match a
 *       shorter one and will not have a chance to match any longer one.
 * Examples:
 * -----
 * "Speaker".replace(["ea", "e"], ":") == "Sp:k:r"
 * "Speaker".replace(["e", "ea"], ":") == "Sp:ak:r"
 * -----
 * Bug: If a search string has a length of zero, this method will go into an infinite loop.
 */
string replace(string str, string[] searchStrs, string[] replacements) {
	if(replacements.length == 1 && searchStrs.length > 1) {
		string tmp = replacements[0];
		replacements = new string[searchStrs.length];
			foreach(i, dummy; searchStrs)
				replacements[i] = tmp;
	}
	if(searchStrs.length != replacements.length)
		throw new IllegalArgumentException(
			"Replace(): searchStrs and replacements must be same length");
	sbuilder builder;
	loop:
	for(int i = 0; i < str.length; ) {
		foreach(j, subStr; searchStrs) {
			if(i+subStr.length <= str.length && str[i..i+subStr.length] == subStr) {
				// skip the part of string that matched
				i += subStr.length;
				builder.Add(replacements[j]);
				continue loop;
			}
		}
		builder.Add(str[i]);
		++i;
	}
	return builder.ToString();
}
/// ditto
string replace(string str, string[] searchStrs, string replacement) {
	return str.replace(searchStrs, [replacement]);
}
/// ditto
string replace(string str, string searchStr, string replacement) {
	return str.replace([searchStr], [replacement]);
}
unittest {
	assert("Mississippi".replace([cast(string)"is", "i"], [cast(string)"..", "*"]) == "M..s..s*pp*");
	assert("Mississippi".replace("ss", "...") == "Mi...i...ippi");
	assert("Hello".replace("ll", "y") == "Heyo");
	//assert("Hi".Replace(cast(string[])[], cast(string[])[]) == "Hi");
	assert("Speaker".replace([cast(string)"ea", "e"], ":") == "Sp:k:r");
	assert("Speaker".replace([cast(string)"e", "ea"], ":") == "Sp:ak:r");
}

/**
 * Changes every occurrence of a specified character in chars to the
 * corresponding character in escChars.
 * Examples:
 * -----
 * "Line1\r\nLine2\\".escape() == "Line1\\r\\nLine2\\\\"
 * "Line1\tLine2".escape() == "Line1\\tLine2"
 * "Part1|Part2\r\n".escape("|\r\n", "|rn") == "Part1\\|Part2\\r\\n"
 * -----
 */
string escape(string str, char[] chars, char[] escChars) {
	if(chars.length != escChars.length)
		throw new IllegalArgumentException("Escape(): chars and escChars must be same length");
	sbuilder builder;
	loop:
	foreach(i, c; str) {
		foreach(j, c2; chars) {
			if(c == '\\') {   // always escape backslash
				builder.Add('\\');
				builder.Add('\\');
				continue loop;
			}
			if(c == c2) {
				builder.Add('\\');
				builder.Add(escChars[j]);
				continue loop;
			}
		}
		builder.Add(c);
	}
	return builder.ToString();
}
/// ditto
string escape(string str) {
	return str.escape("\t\r\n", "trn");
}
unittest {
	assert("Line1\r\nLine2\\".escape() == "Line1\\r\\nLine2\\\\");
	assert("Line1\tLine2".escape() == "Line1\\tLine2");
	assert("Part1|Part2\r\n".escape("|\r\n", "|rn") == "Part1\\|Part2\\r\\n");
}
/**
 * Changes every occurrence of a specified character in escChars to the
 * corresponding character in chars.
 * Examples:
 * -----
 * "Line1\\r\\nLine2".unescape() == "Line1\r\nLine2"
 * "Line1\\tLine2".unescape() == "Line1\tLine2"
 * "Part1\\|Part2\\r\\n".unescape("|rn", "|\r\n") == "Part1|Part2\r\n"
 * // error:
 * "test\\".unescape()
 * -----
 */
string unescape(string str, char[] escChars, char[] chars) {
	if(escChars.length != chars.length)
		throw new IllegalArgumentException("Unescape(): escChars and chars must be same length");
	sbuilder builder;
	loop:
	foreach(i, c; str) {
		if(c == '\\') {
			if(i == str.length-1)
				throw new IllegalArgumentException("Unescape(): partial escape sequence at end of string");
			if(str[i+1] == '\\') {
				builder.Add('\\');
				++i;
				continue loop;
			}
			foreach(j, c2; escChars) {
				if(str[i+1] == c2) {
					builder.Add(chars[j]);
					++i;
					continue loop;
				}
			}
			throw new IllegalArgumentException("Unescape(): invalid escape sequence");
		}
		builder.Add(str[i]);
	}
	return builder.ToString();
}
/// ditto
string unescape(string str) {
	return str.unescape("trn", "\t\r\n");
}
unittest {
	assert("Line1\\r\\nLine2\\\\".unescape() == "Line1\r\nLine2\\");
	assert("Line1\\tLine2".unescape() == "Line1\tLine2");
	assert("Part1\\|Part2\\r\\n".unescape("|rn", "|\r\n") == "Part1|Part2\r\n");
}
unittest {
	string str = r"C:\\n";
	assert(str.escape().unescape() == str);
}
/**
 * Removes all whitespace characters from the specified string.
 * Examples:
 * -----
 * "4a d2  7c 3f".removeWhitespace() == "4ad27c3f"
 * " Hello \r\n".removeWhitespace() == "Hello"
 * "How are you?".removeWhitespace() == "Howareyou?"
 * "\t \n\r\f\v".removeWhitespace() == ""
 * -----
 */
string removeWhitespace(string str) {
	sbuilder builder;
	foreach(c; str)
		if(!" \t\n\r\v\f".contains(c))
			builder.Add(c);
	return builder.ToString();
}
unittest {
	assert("4a d2  7c 3f".removeWhitespace() == "4ad27c3f");
	assert(" Hello \r\n".removeWhitespace() == "Hello");
	assert("How are you?".removeWhitespace() == "Howareyou?");
	assert("\t \n\r\f\v".removeWhitespace() == "");
}
/**
 * Removes all the whitespace characters from the start and from the end
 * of the specified string. Returns a slice.
 * Examples:
 * -----
 * " Hello \r\n".trim() == "Hello"
 * "How are you?".trim() == "How are you?"
 * "\n la di da ".trim() == "la di da"
 * " \n".trim() == ""
 * "".trim() == ""
 * -----
 */
string trim(string str) {
	int start = -1, end = str.length;
	while( --end >= 0 && " \t\n\r\v\f".contains(str[end]) ) { }
	end++;
	if(end == 0) // means all whitespace
		return "";
	while(" \t\n\r\v\f".contains(str[++start])) { }
	return str[start..end];
}
unittest {
	assert(" Hello \r\n".trim() == "Hello");
	assert("How are you?".trim() == "How are you?");
	assert("\n la di da ".trim() == "la di da");
	assert(" \n".trim() == "");
	assert("".trim() == "");
}
/**
 * Removes all the whitespace characters from the start
 * of the specified string. Returns a slice.
 * Examples:
 * -----
 * " Hello \r\n".trimLeft() == "Hello \r\n"
 * "How are you?".trimLeft() == "How are you?"
 * "\n la di da ".trimLeft() == "la di da "
 * " \n".trimLeft() == ""
 * "".trimLeft() == ""
 * -----
 */
string trimLeft(string str) {
	int start = -1;
	while(++start < str.length && " \t\n\r\v\f".contains(str[start])) { }
	return str[start..$];
}
unittest {
	assert(" Hello \r\n".trimLeft() == "Hello \r\n");
	assert("How are you?".trimLeft() == "How are you?");
	assert("\n la di da ".trimLeft() == "la di da ");
	assert(" \n".trimLeft() == "");
	assert("".trimLeft() == "");
}
/**
 * Removes all the whitespace characters from the start
 * of the specified string. Returns a slice.
 * Examples:
 * -----
 * " Hello \r\n".trimRight() == " Hello"
 * "How are you?".trimRight() == "How are you?"
 * "\n la di da ".trimRight() == "\n la di da"
 * " \n".trimRight() == ""
 * "".trimRight() == ""
 * -----
 */
string trimRight(string str) {
	int end = str.length;
	while( --end >= 0 && " \t\n\r\v\f".contains(str[end]) ) { }
	end++;
	return str[0..end];
}
unittest {
	assert(" Hello \r\n".trimRight() == " Hello");
	assert("How are you?".trimRight() == "How are you?");
	assert("\n la di da ".trimRight() == "\n la di da");
	assert(" \n".trimRight() == "");
	assert("".trimRight() == "");
}


unittest {
	assert(".NET Framework".startsWith(".N"));
	assert(".NET Framework".startsWith("Frame", 5));
	assert(!".NET Framework".startsWith(".NEW"));
	assert(".NET Framework".find("NET") == 1);
	assert(".NET Framework".find("NET", 2) == -1);
	assert(".NET Framework".find("") == 0);
	assert("Mississippi".findLast("ss") == 5);
	assert("Mississippi".findLast("ss", 4) == 2);
	assert("Jordan=20".split("=") == [cast(string)"Jordan", "20"]);
	assert("Jordan".split("") == [cast(string)"Jordan"]);
	assert("Jordan".split1("=") == [cast(string)"Jordan"]);
}

/*class Encoding {
private:
	//TODO: remove dependency on std.utf
	static Encoding[] encodings = [
		//new Encoding("windows-1252".Str(), "Western European (Windows)".Str(), encodeTableWindows1252)
	];
	String name;
	String desc;
public:
	//property
	static Encoding[] Encodings() {
		return encodings;
	}
	static Encoding GetEncoding(String name) {
	}
	static byte[] Convert(Encoding src, Encoding dst, byte[] bytes) {}

	this(String name, String description, wchar[] table) {
		this.name = name;
	}
	// example: utf-8
	String Name() {
		return name;
	}
	// example: Unicode (UTF-8)
	String Description() {
		return desc;
	}
	int GetEncodedCount() {}
	byte[] Encode(String str) {
	}
	//Returns the number of characters
	int GetDecodedLength() {
	}
	String Decode(byte[] bytes) {
	}
}*/
//class Utf8Encoding : Encoding {
//public:
//}

//characters that cannot be mapped to unicode are 0xFFFD in the tables
wchar[] encodeTableWindows1252 = [
	0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0007, 0x0008,
	0x0009, 0x000A, 0x000B, 0x000C, 0x000D, 0x000E, 0x000F, 0x0010, 0x0011,
	0x0012, 0x0013, 0x0014, 0x0015, 0x0016, 0x0017, 0x0018, 0x0019, 0x001A,
	0x001B, 0x001C, 0x001D, 0x001E, 0x001F, 0x0020, 0x0021, 0x0022, 0x0023,
	0x0024, 0x0025, 0x0026, 0x0027, 0x0028, 0x0029, 0x002A, 0x002B, 0x002C,
	0x002D, 0x002E, 0x002F, 0x0030, 0x0031, 0x0032, 0x0033, 0x0034, 0x0035,
	0x0036, 0x0037, 0x0038, 0x0039, 0x003A, 0x003B, 0x003C, 0x003D, 0x003E,
	0x003F, 0x0040, 0x0041, 0x0042, 0x0043, 0x0044, 0x0045, 0x0046, 0x0047,
	0x0048, 0x0049, 0x004A, 0x004B, 0x004C, 0x004D, 0x004E, 0x004F, 0x0050,
	0x0051, 0x0052, 0x0053, 0x0054, 0x0055, 0x0056, 0x0057, 0x0058, 0x0059,
	0x005A, 0x005B, 0x005C, 0x005D, 0x005E, 0x005F, 0x0060, 0x0061, 0x0062,
	0x0063, 0x0064, 0x0065, 0x0066, 0x0067, 0x0068, 0x0069, 0x006A, 0x006B,
	0x006C, 0x006D, 0x006E, 0x006F, 0x0070, 0x0071, 0x0072, 0x0073, 0x0074,
	0x0075, 0x0076, 0x0077, 0x0078, 0x0079, 0x007A, 0x007B, 0x007C, 0x007D,
	0x007E, 0x007F, 0x20AC, 0xFFFD, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020,
	0x2021, 0x02C6, 0x2030, 0x0160, 0x2039, 0x0152, 0xFFFD, 0x017D, 0xFFFD,
	0xFFFD, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014, 0x02DC,
	0x2122, 0x0161, 0x203A, 0x0153, 0xFFFD, 0x017E, 0x0178, 0x00A0, 0x00A1,
	0x00A2, 0x00A3, 0x00A4, 0x00A5, 0x00A6, 0x00A7, 0x00A8, 0x00A9, 0x00AA,
	0x00AB, 0x00AC, 0x00AD, 0x00AE, 0x00AF, 0x00B0, 0x00B1, 0x00B2, 0x00B3,
	0x00B4, 0x00B5, 0x00B6, 0x00B7, 0x00B8, 0x00B9, 0x00BA, 0x00BB, 0x00BC,
	0x00BD, 0x00BE, 0x00BF, 0x00C0, 0x00C1, 0x00C2, 0x00C3, 0x00C4, 0x00C5,
	0x00C6, 0x00C7, 0x00C8, 0x00C9, 0x00CA, 0x00CB, 0x00CC, 0x00CD, 0x00CE,
	0x00CF, 0x00D0, 0x00D1, 0x00D2, 0x00D3, 0x00D4, 0x00D5, 0x00D6, 0x00D7,
	0x00D8, 0x00D9, 0x00DA, 0x00DB, 0x00DC, 0x00DD, 0x00DE, 0x00DF, 0x00E0,
	0x00E1, 0x00E2, 0x00E3, 0x00E4, 0x00E5, 0x00E6, 0x00E7, 0x00E8, 0x00E9,
	0x00EA, 0x00EB, 0x00EC, 0x00ED, 0x00EE, 0x00EF, 0x00F0, 0x00F1, 0x00F2,
	0x00F3, 0x00F4, 0x00F5, 0x00F6, 0x00F7, 0x00F8, 0x00F9, 0x00FA, 0x00FB,
	0x00FC, 0x00FD, 0x00FE, 0x00FF
];

//iso8859-1 does not need a conversion table, as its values are all the same as Unicode's

wchar[] encodeTableIso8859_2 = [
	0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0007, 0x0008,
	0x0009, 0x000A, 0x000B, 0x000C, 0x000D, 0x000E, 0x000F, 0x0010, 0x0011,
	0x0012, 0x0013, 0x0014, 0x0015, 0x0016, 0x0017, 0x0018, 0x0019, 0x001A,
	0x001B, 0x001C, 0x001D, 0x001E, 0x001F, 0x0020, 0x0021, 0x0022, 0x0023,
	0x0024, 0x0025, 0x0026, 0x0027, 0x0028, 0x0029, 0x002A, 0x002B, 0x002C,
	0x002D, 0x002E, 0x002F, 0x0030, 0x0031, 0x0032, 0x0033, 0x0034, 0x0035,
	0x0036, 0x0037, 0x0038, 0x0039, 0x003A, 0x003B, 0x003C, 0x003D, 0x003E,
	0x003F, 0x0040, 0x0041, 0x0042, 0x0043, 0x0044, 0x0045, 0x0046, 0x0047,
	0x0048, 0x0049, 0x004A, 0x004B, 0x004C, 0x004D, 0x004E, 0x004F, 0x0050,
	0x0051, 0x0052, 0x0053, 0x0054, 0x0055, 0x0056, 0x0057, 0x0058, 0x0059,
	0x005A, 0x005B, 0x005C, 0x005D, 0x005E, 0x005F, 0x0060, 0x0061, 0x0062,
	0x0063, 0x0064, 0x0065, 0x0066, 0x0067, 0x0068, 0x0069, 0x006A, 0x006B,
	0x006C, 0x006D, 0x006E, 0x006F, 0x0070, 0x0071, 0x0072, 0x0073, 0x0074,
	0x0075, 0x0076, 0x0077, 0x0078, 0x0079, 0x007A, 0x007B, 0x007C, 0x007D,
	0x007E, 0x007F, 0x0080, 0x0081, 0x0082, 0x0083, 0x0084, 0x0085, 0x0086,
	0x0087, 0x0088, 0x0089, 0x008A, 0x008B, 0x008C, 0x008D, 0x008E, 0x008F,
	0x0090, 0x0091, 0x0092, 0x0093, 0x0094, 0x0095, 0x0096, 0x0097, 0x0098,
	0x0099, 0x009A, 0x009B, 0x009C, 0x009D, 0x009E, 0x009F, 0x00A0, 0x0104,
	0x02D8, 0x0141, 0x00A4, 0x013D, 0x015A, 0x00A7, 0x00A8, 0x0160, 0x015E,
	0x0164, 0x0179, 0x00AD, 0x017D, 0x017B, 0x00B0, 0x0105, 0x02DB, 0x0142,
	0x00B4, 0x013E, 0x015B, 0x02C7, 0x00B8, 0x0161, 0x015F, 0x0165, 0x017A,
	0x02DD, 0x017E, 0x017C, 0x0154, 0x00C1, 0x00C2, 0x0102, 0x00C4, 0x0139,
	0x0106, 0x00C7, 0x010C, 0x00C9, 0x0118, 0x00CB, 0x011A, 0x00CD, 0x00CE,
	0x010E, 0x0110, 0x0143, 0x0147, 0x00D3, 0x00D4, 0x0150, 0x00D6, 0x00D7,
	0x0158, 0x016E, 0x00DA, 0x0170, 0x00DC, 0x00DD, 0x0162, 0x00DF, 0x0155,
	0x00E1, 0x00E2, 0x0103, 0x00E4, 0x013A, 0x0107, 0x00E7, 0x010D, 0x00E9,
	0x0119, 0x00EB, 0x011B, 0x00ED, 0x00EE, 0x010F, 0x0111, 0x0144, 0x0148,
	0x00F3, 0x00F4, 0x0151, 0x00F6, 0x00F7, 0x0159, 0x016F, 0x00FA, 0x0171,
	0x00FC, 0x00FD, 0x0163, 0x02D9
];

wchar[] encodeTableIso8859_3 = [
	0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0007, 0x0008,
	0x0009, 0x000A, 0x000B, 0x000C, 0x000D, 0x000E, 0x000F, 0x0010, 0x0011,
	0x0012, 0x0013, 0x0014, 0x0015, 0x0016, 0x0017, 0x0018, 0x0019, 0x001A,
	0x001B, 0x001C, 0x001D, 0x001E, 0x001F, 0x0020, 0x0021, 0x0022, 0x0023,
	0x0024, 0x0025, 0x0026, 0x0027, 0x0028, 0x0029, 0x002A, 0x002B, 0x002C,
	0x002D, 0x002E, 0x002F, 0x0030, 0x0031, 0x0032, 0x0033, 0x0034, 0x0035,
	0x0036, 0x0037, 0x0038, 0x0039, 0x003A, 0x003B, 0x003C, 0x003D, 0x003E,
	0x003F, 0x0040, 0x0041, 0x0042, 0x0043, 0x0044, 0x0045, 0x0046, 0x0047,
	0x0048, 0x0049, 0x004A, 0x004B, 0x004C, 0x004D, 0x004E, 0x004F, 0x0050,
	0x0051, 0x0052, 0x0053, 0x0054, 0x0055, 0x0056, 0x0057, 0x0058, 0x0059,
	0x005A, 0x005B, 0x005C, 0x005D, 0x005E, 0x005F, 0x0060, 0x0061, 0x0062,
	0x0063, 0x0064, 0x0065, 0x0066, 0x0067, 0x0068, 0x0069, 0x006A, 0x006B,
	0x006C, 0x006D, 0x006E, 0x006F, 0x0070, 0x0071, 0x0072, 0x0073, 0x0074,
	0x0075, 0x0076, 0x0077, 0x0078, 0x0079, 0x007A, 0x007B, 0x007C, 0x007D,
	0x007E, 0x007F, 0x0080, 0x0081, 0x0082, 0x0083, 0x0084, 0x0085, 0x0086,
	0x0087, 0x0088, 0x0089, 0x008A, 0x008B, 0x008C, 0x008D, 0x008E, 0x008F,
	0x0090, 0x0091, 0x0092, 0x0093, 0x0094, 0x0095, 0x0096, 0x0097, 0x0098,
	0x0099, 0x009A, 0x009B, 0x009C, 0x009D, 0x009E, 0x009F, 0x00A0, 0x0126,
	0x02D8, 0x00A3, 0x00A4, 0x0124, 0x00A7, 0x00A8, 0x0130, 0x015E, 0x011E,
	0x0134, 0x00AD, 0x017B, 0x00B0, 0x0127, 0x00B2, 0x00B3, 0x00B4, 0x00B5,
	0x0125, 0x00B7, 0x00B8, 0x0131, 0x015F, 0x011F, 0x0135, 0x00BD, 0x017C,
	0x00C0, 0x00C1, 0x00C2, 0x00C4, 0x010A, 0x0108, 0x00C7, 0x00C8, 0x00C9,
	0x00CA, 0x00CB, 0x00CC, 0x00CD, 0x00CE, 0x00CF, 0x00D1, 0x00D2, 0x00D3,
	0x00D4, 0x0120, 0x00D6, 0x00D7, 0x011C, 0x00D9, 0x00DA, 0x00DB, 0x00DC,
	0x016C, 0x015C, 0x00DF, 0x00E0, 0x00E1, 0x00E2, 0x00E4, 0x010B, 0x0109,
	0x00E7, 0x00E8, 0x00E9, 0x00EA, 0x00EB, 0x00EC, 0x00ED, 0x00EE, 0x00EF,
	0x00F1, 0x00F2, 0x00F3, 0x00F4, 0x0121, 0x00F6, 0x00F7, 0x011D, 0x00F9,
	0x00FA, 0x00FB, 0x00FC, 0x016D, 0x015D, 0x02D9
];
