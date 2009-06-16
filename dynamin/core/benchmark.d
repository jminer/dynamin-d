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

module dynamin.core.benchmark;

import dynamin.all_core;
import dynamin.core.string;
import tango.io.Stdout;

/**
 * Returns: The average number of milliseconds one call of the specified
 *          delegate took.
 */
real benchmark(int repetitions, void delegate() dg) { // use static opCall()?
	long time = Environment.runningTime;
	for(int i = 0; i < repetitions; ++i)
		dg();
	return (Environment.runningTime-time)/cast(real)repetitions;
}
real benchmark(void delegate() dg) {
	return benchmark(1, dg);
}
/**
 * name can be null
 */
real benchmarkAndWrite(string name, int repetitions, void delegate() dg) {
	real time = benchmark(repetitions, dg);
	Stdout.format("{} took {:.2}ms.", name, time).newline; // TODO: verify :.2
	return time;
}
real benchmarkAndWrite(string name, void delegate() dg) {
	return benchmarkAndWrite(name, 1, dg);
}

/**
 * As the constructor calls the Start() method, the only time one would need
 * to is when reusing a Benchmark object.
 */
class Benchmark {
	long _startTime;
	this() {
		start();
	}
	void start() {
		_startTime = Environment.runningTime;
	}
	long time() {
		return _startTime-Environment.runningTime;
	}
	void writeTime(string opName) {
		if(opName is null)
			opName = "Benchmark";
		Stdout.format("{} took {}ms.", opName, time).newline;
	}

	/**
	 * calls the specified delegate the specified number of times and
	 * returns the average time one call took
	 */
	static long measure(int times, void delegate() d) {
		long time = Environment.runningTime;
		for(int i = 0; i < times; ++i)
			d();
		return (Environment.runningTime-time)/times;
	}
}
