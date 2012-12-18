
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.console;

import dynamin.core.string;
import dynamin.core_backend;
import tango.io.Stdout;
import tango.io.Console;

///
enum ConsoleColor {
// Black, Silver, Maroon, DarkBlue, Green,      Purple, DarkYellow, Teal,
// Gray,  White,  Red,    Blue,     LightGreen, Pink,   Yellow,     Cyan
	Black,      ///
	Silver,     ///
	Maroon,     ///
	DarkBlue,   ///
	Green,      ///
	Purple,     ///
	DarkYellow, ///
	Teal,       ///
	Gray,       ///
	White,      ///
	Red,        ///
    Blue,       ///
	LightGreen, ///
	Pink,       ///
	Yellow,     ///
	Cyan        ///
}

/**
 * This class allows programs to read from and write to the console.
 *
 * Programs can also take advantage of some more advanced console features,
 * such as reading input without echoing it to the screen, clearing the screen,
 * setting text foreground and background color, and setting text style.
 * However, the more advanced features will not be available if the program
 * is not actually writing to a console window, such as if its output has be
 * redirected to a file or if another program is receiving its output.
 * The only functions that will work corectly when output or input have been
 * redirected are the following:
 * $(UL
	 $(LI write())
	 $(LI writeLine())
	 $(LI readLine())
 * )
 * On Windows, when writing to a console window, all functionality is
 * available except Bold, Italic, Underline, Strikethrough. Windows does
 * not support these.
 *
 * On other systems, colors and styles are supported by writing
 * out control codes.
 */
class Console {
static:
private:
	mixin ConsoleBackend;
public:
//required features:
//- Easily reading a line at once...input is returned when user presses ENTER
//- Easily reading a key press from the user...input is returned as soon as it is available
//- Allow for typing a password and replacing the characters entered with *
//   considering this would actually be fairly hard, I may not implement it...
//   Instead could do as linux and not show anything...
//wished features:
//- Getting the screen size
//- Turning off echoing the key press that the user types when returning
//  input without ENTER
//- Writing a string, such as "23%", and then changing it to like "24%".
//  Console.writeBuffer(40) writes 40 spaces and returns a ConsoleBuffer object
	/**
	 * Sets whether or not writing to the standard output will be
	 * buffered. By default, this is false, meaning that no buffering will
	 * ever be done. Setting this to true will buffer output when the standard
	 * output is going to a file or stream, such as a text editor, but will
	 * not buffer output to a console window.
	 * TODO: not implemented on Windows
	 */
	void buffered(bool b) {
		backend_buffered(b);
	}
	/**
	 * Writes the specified text string to the console.
	 */
	void write(cstring s, ...) {
		Stdout.layout.convert(&Stdout.emit, _arguments, _argptr, s);
	}
	/**
	 * Writes the specified text string to the console, followed by a newline.
	 */
	void writeLine() { Stdout.newline; }
	/// ditto
	void writeLine(cstring s, ...) {
		Stdout.layout.convert(&Stdout.emit, _arguments, _argptr, s);
		Stdout.newline;
	}
	/**
	 * Reads a line of text from the console. The returned returned string
	 * will end in a newline, unless it was read from the last line in a text
	 * file.
	 */
	mstring readLineRaw() { return Cin.copyln(true); }
	/**
	 * Reads a line of text from the console. The returned string does not
	 * contain a newline.
	 */
	mstring readLine() { return Cin.copyln(false); }
	/// ditto
	mstring readLine(cstring prompt, ...) {
		Stdout.layout.convert(&Stdout.emit, _arguments, _argptr, prompt);
		return readLine();
	}
	/**
	 * reads a character, echoing it to the screen
	 * TODO: not implemented
	 */
	mstring read() { return backend_read(); }
	/// ditto
	mstring read(cstring prompt) {
		write(prompt);
		return backend_read();
	}
	/**
	 * reads a line without showing that line
	 * TODO: not implemented
	 */
	mstring readLineHidden() { return backend_readLineHidden(); }
	/// ditto
	mstring readLineHidden(cstring prompt) {
		write(prompt);
		return backend_readLineHidden();
	}
	/**
	 * reads a character without showing it
	 * TODO: not implemented
	 */
	mstring readHidden() { return backend_readHidden(); }
	/// ditto
	mstring readHidden(cstring prompt) {
		write(prompt);
		return backend_readHidden();
	}
	/**
	 * Clears the text that has been written to the console.
	 */
	void clear() {
		backend_clear();
	}
	/**
	 * Sets the foreground color of text written to the console.
	 */
	void foreColor(ConsoleColor color) {
		backend_foreColor = color;
	}
	/**
	 * Sets the background color of text written to the console.
	 */
	void backColor(ConsoleColor color) {
		backend_backColor = color;
	}
	/**
	 * Resets the foreground and background colors of text written to the
	 * console to the defaults.
	 */
	void resetColors() {
		backend_resetColors();
	}
	/**
	 * Sets whether text written to the console is bold.
	 * Has no effect on Windows.
	 */
	void bold(bool b) {
		backend_bold = b;
	}
	/**
	 * Sets whether text written to the console is italic.
	 * Has no effect on Windows.
	 */
	void italic(bool b) {
		backend_italic = b;
	}
	/**
	 * Sets whether text written to the console is underlined.
	 * Has no effect on Windows.
	 */
	void underline(bool b) {
		backend_underline = b;
	}
	/**
	 * Sets whether text written to the console is strikethrough.
	 * Has no effect on Windows.
	 */
	void strikethrough(bool b) {
		backend_strikethrough = b;
	}
}
/*  "\x1b[9;31mThis is red and strikethrough\x1b[0m"
*/

///
alias Console.readLine readLine;
///
alias Console.writeLine writeLine;

/* unittest {
	Console.foreColor = ConsoleColor.Black;
	writeLine("Black");
	Console.foreColor = ConsoleColor.Gray;
	writeLine("Gray");
	Console.foreColor = ConsoleColor.Silver;
	writeLine("Silver");
	Console.foreColor = ConsoleColor.Red;
	writeLine("Red");
	Console.foreColor = ConsoleColor.Blue;
	writeLine("Blue");
	Console.foreColor = ConsoleColor.LightGreen;
	writeLine("LightGreen");
	Console.foreColor = ConsoleColor.Green;
	writeLine("Green");
	Console.foreColor = ConsoleColor.Teal;
	writeLine("Teal");
	Console.foreColor = ConsoleColor.Yellow;
	writeLine("Yellow");
	Console.foreColor = ConsoleColor.Purple;
	writeLine("Purple");
	Console.foreColor = ConsoleColor.Pink;
	writeLine("Pink");
	Console.foreColor = ConsoleColor.DarkYellow;
	writeLine("DarkYellow");
	Console.foreColor = ConsoleColor.Maroon;
	writeLine("Maroon");
	Console.foreColor = ConsoleColor.DarkBlue;
	writeLine("DarkBlue");
	Console.foreColor = ConsoleColor.Cyan;
	writeLine("Cyan");
	Console.foreColor = ConsoleColor.White;
	writeLine("White");
} */

