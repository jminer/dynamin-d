
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.windows_console;

public import dynamin.c.windows;
public import dynamin.core.string;

public import tango.io.Stdout;
public import tango.stdc.stdlib;

template ConsoleBackend() {
	uint inputCP;
	uint outputCP;
	static this() {
		// calling GetConsoleOutputCP() takes twice as long as
		// the entire backend_Write() function...it is slow!
		//inputCP = GetConsoleCP();
		//outputCP = GetConsoleOutputCP();
	}
	bool buffered = false;
	void backend_buffered(bool b) {
		buffered = b;
	}
	void backend_write(string s) {
		// the reasons for this function being slower than writef():
		//  - partly the conversion overhead (UTF-8 -> UTF16 -> CP)
		//  - partly because it is not buffered
/+
		// make sure printf/writef output appears in right order
		fflush(stdout);

		auto wbuffer = ToUtf16(s);
		scope(exit) delete wbuffer;
		auto needed = WideCharToMultiByte(outputCP, 0, wbuffer.ptr, wbuffer.length, null, 0, null, null);
		// faster than: auto buffer = new char[needed];
		auto buffer = (cast(char*)alloca(needed))[0..needed];
		scope(exit) delete buffer;
		WideCharToMultiByte(outputCP, 0, wbuffer.ptr, wbuffer.length, buffer.ptr, buffer.length, null, null);

		auto stdOut = GetStdHandle(-11);
		DWORD numWritten;
		if(!WriteFile(stdOut, buffer.ptr, buffer.length, &numWritten, null))
			printf("WriteFile() failed, error %d\n", GetLastError());+/

	}
	string backend_readLineRaw() {/+
		auto stdIn = GetStdHandle(-10);
		// TODO: does not work if input is from a file!
		// if reading from a file, a line can be very long...
		// and you do not want to read farther than that.
		char[4096] buffer = void;
		DWORD numRead;
		if(!ReadFile(stdIn, buffer.ptr, buffer.length, &numRead, null))
			printf("ReadFile() failed, error %d\n", GetLastError());

		auto needed = MultiByteToWideChar(inputCP, 0, buffer.ptr, numRead, null, 0);
		//faster than:  auto wbuffer = new wchar[needed];
		auto wbuffer = (cast(wchar*)alloca(needed*2))[0..needed];
		scope(exit) delete wbuffer;
		auto numUsed = MultiByteToWideChar(inputCP, 0, buffer.ptr, numRead, wbuffer.ptr, wbuffer.length);
		return ToUtf8(wbuffer[0..numUsed]);+/
		return null;
	}
	string backend_read() {
		return null;
	}
	string backend_readLineHidden() {
		return null;
	}
	string backend_readHidden() {
		return null;
	}
	void backend_clear() {
		system("cls");
	}
	uint backend_getColorFlags(ConsoleColor c, bool fore) {
		uint i = fore ? FOREGROUND_INTENSITY : BACKGROUND_INTENSITY;
		uint r = fore ? FOREGROUND_RED : BACKGROUND_RED;
		uint g = fore ? FOREGROUND_GREEN : BACKGROUND_GREEN;
		uint b = fore ? FOREGROUND_BLUE : BACKGROUND_BLUE;
		switch(c) {
		case c.Black:      return 0;
		case c.Silver:     return r | g | b;
		case c.Maroon:     return r;
		case c.DarkBlue:   return b;
		case c.Green:      return g;
		case c.Purple:     return r | b;
		case c.DarkYellow: return r | g;
		case c.Teal:       return g | b;
		case c.Gray:       return i;
		case c.White:      return r | g | b | i;
		case c.Red:        return r | i;
		case c.Blue:       return b | i;
		case c.LightGreen: return g | i;
		case c.Pink:       return r | b | i;
		case c.Yellow:     return r | g | i;
		case c.Cyan:       return g | b | i;
		default: assert(0);
		}
	}
	void backend_foreColor(ConsoleColor color) {
		CONSOLE_SCREEN_BUFFER_INFO bufferInfo;
		if(!GetConsoleScreenBufferInfo(GetStdHandle(-11), &bufferInfo))
			return;
		bufferInfo.wAttributes &= ~0b1111; // clear the 4 foreground bits
		SetConsoleTextAttribute(GetStdHandle(-11),
			bufferInfo.wAttributes | backend_getColorFlags(color, true));
	}
	void backend_backColor(ConsoleColor color) {
		CONSOLE_SCREEN_BUFFER_INFO bufferInfo;
		if(!GetConsoleScreenBufferInfo(GetStdHandle(-11), &bufferInfo))
			return;
		bufferInfo.wAttributes &= ~0b11110000; // clear the 4 background bits
		SetConsoleTextAttribute(GetStdHandle(-11),
			bufferInfo.wAttributes | backend_getColorFlags(color, false));
	}
	void backend_resetColors() {
	}
	void backend_bold(bool b) { }
	void backend_italic(bool b) { }
	void backend_underline(bool b) { }
	void backend_strikethrough(bool b) { }
}

