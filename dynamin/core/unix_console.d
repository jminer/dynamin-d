
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.unix_console;

public import tango.stdc.stdlib;
//public import tango.stdc.string;
public import dynamin.core.string;

/*
Can get width of console with $COLUMNS
Can get height of console with $LINES
*/
// The control codes are defined in ECMA-48.
template ConsoleBackend() {
	static colorsUsed = false;
	static ~this() {
		if(colorsUsed)
			backend_resetColors();
	}
	bool buffered = false;
	void backend_buffered(bool b) {
		buffered = b;
	}
	void backend_write(string s) {
		/*fwrite(s.ptr, 1, s.length, stdout);
		if(!buffered)
			fflush(stdout);*/
	}
	string backend_readLineRaw() {
		/*uint size;
		char* line;
		auto numRead = getline(&line, &size, stdin);
		scope(exit) free(line);
		string str = new char[numRead];
		str[] = line[0..numRead];
		return str;*/
		return null;
	}
	string backend_read() {
		return null;
	}
	// TODO: use this
	//termios ts;
	//tcgetattr(filedes, &ts);
	//ts.c_lflag |= ICANON; // turns on waiting for a whole lines
	//ts.c_lflag |= ECHO;   // turns on echoing
	//tcsetattr(filedes, TCSAFLUSH, &ts);
	string backend_readLineHidden() {
		system("stty -echo");
		auto line = readLine();
		system("stty echo");
		return line;
	}
	string backend_readHidden() {
		return null;
	}
	void backend_clear() {
		system("clear");
	}
	string backend_getColorStr(ConsoleColor c, bool fore) {
		switch(c) {
		case c.Black:      return fore ? "\x1b[30m" : "\x1b[40m";
		case c.Silver:     return fore ? "\x1b[37m" : "\x1b[47m";
		case c.Maroon:     return fore ? "\x1b[31m" : "\x1b[41m";
		case c.DarkBlue:   return fore ? "\x1b[34m" : "\x1b[44m";
		case c.Green:      return fore ? "\x1b[32m" : "\x1b[42m";
		case c.Purple:     return fore ? "\x1b[35m" : "\x1b[45m";
		case c.DarkYellow: return fore ? "\x1b[33m" : "\x1b[43m";
		case c.Teal:       return fore ? "\x1b[36m" : "\x1b[46m";
		case c.Gray:       return fore ? "\x1b[90m" : "\x1b[100m";
		case c.White:      return fore ? "\x1b[97m" : "\x1b[107m";
		case c.Red:        return fore ? "\x1b[91m" : "\x1b[101m";
		case c.Blue:       return fore ? "\x1b[94m" : "\x1b[104m";
		case c.LightGreen: return fore ? "\x1b[92m" : "\x1b[102m";
		case c.Pink:       return fore ? "\x1b[95m" : "\x1b[105m";
		case c.Yellow:     return fore ? "\x1b[93m" : "\x1b[103m";
		case c.Cyan:       return fore ? "\x1b[96m" : "\x1b[106m";
		default: assert(0);
		}
	}
	void backend_foreColor(ConsoleColor color) {
		colorsUsed = true;
		backend_write(backend_getColorStr(color, true));
	}
	void backend_backColor(ConsoleColor color) {
		colorsUsed = true;
		backend_write(backend_getColorStr(color, false));
	}
	void backend_resetColors() {
		backend_write("\x1b[39;49m");
	}
	void backend_bold(bool b) {
		backend_write(b ? "\x1b[1m" : "\x1b[22m");
	}
	void backend_italic(bool b) {
		backend_write(b ? "\x1b[3m" : "\x1b[23m");
	}
	void backend_underline(bool b) {
		backend_write(b ? "\x1b[4m" : "\x1b[24m");
	}
	void backend_strikethrough(bool b) {
		backend_write(b ? "\x1b[9m" : "\x1b[29m");
	}
}

