
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
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
double benchmark(int repetitions, void delegate() dg) { // use static opCall()?
	long time = Environment.monotonicTime;
	for(int i = 0; i < repetitions; ++i)
		dg();
	return (Environment.monotonicTime-time)/cast(double)repetitions;
}
double benchmark(void delegate() dg) {
	return benchmark(1, dg);
}
/**
 * name can be null
 */
double benchmarkAndWrite(cstring name, int repetitions, void delegate() dg) {
	double time = benchmark(repetitions, dg);
	Stdout.format("{} took {:.2}ms.", name, time).newline; // TODO: verify :.2
	return time;
}
double benchmarkAndWrite(cstring name, void delegate() dg) {
	return benchmarkAndWrite(name, 1, dg);
}

/**
 * As the constructor calls the start() method, the only time one would need
 * to is when reusing a Benchmark object.
 */
class Benchmark {
	long _startTime;
	this() {
		start();
	}
	void start() {
		_startTime = Environment.monotonicTime;
	}
	long time() {
		return _startTime-Environment.monotonicTime;
	}
	void writeTime(cstring opName) {
		if(opName is null)
			opName = "Benchmark";
		Stdout.format("{} took {}ms.", opName, time).newline;
	}

	/**
	 * calls the specified delegate the specified number of times and
	 * returns the average time one call took
	 */
	static double measure(int repetitions, void delegate() d) {
		long time = Environment.monotonicTime;
		for(int i = 0; i < repetitions; ++i)
			d();
		return (Environment.monotonicTime - time) / cast(double)repetitions;
	}

	/**
	* Calls the specified delegate until the specified time has elapsed and
	* returns the average time in milliseconds that one call took.
	*
	* The time will be checked every `2^checkN` iterations (to reduce the overhead
	* of checking the time). For example, a value of 4 for `checkN` will cause the
	* time to be checked every 16 iterations, and the number of iterations
	* performed would be a multiple of 16.
	*/
	static double measureFor(int time, int checkN, void delegate() d) {
		checkN = 1 << checkN;
		long iterations;
		auto startTime = Environment.monotonicTime;
		for(iterations = 0; ; ++iterations) {
			if((iterations & checkN) && (Environment.monotonicTime - startTime) > time)
				break;
			d();
		}
		return (Environment.monotonicTime - startTime)/cast(double)iterations;
	}
}
