
import dynamin.all_core;

import std.stdio;

void main() {
	auto t = Environment.monotonicTime;
	while(true) {
		while(Environment.monotonicTime < t + 5000) {
		}
		t = Environment.monotonicTime;
		writefln("%s", t);
	}
}

