
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.environment;

import dynamin.all_core;
import dynamin.core_backend;

/**
 * Contains static methods to access information about the computer the
 * application is running on.
 */
static class Environment {
static:
private:
	mixin EnvironmentBackend;
public:
	/**
	 * Returns the time in milliseconds since the program was started.
	 * On Windows XP, this time is updated every millisecond.
	 * On Linux, this time is usually updated every millisecond, but
	 * occasionally may take 5 to 10 milliseconds.
	 * This is the author's dream time function because
	 *
	 * $(OL
	 * $(LI It is accurate to 1 millisecond.)
	 * $(LI It works correctly on multiple core computers.)
	 * $(LI It is unaffected by changes to the system time.)
	 * $(LI It never wraps to zero.)
	 * )
	 *
	 * On my 1.3 GHz celeron, this function can be called about 480 times
	 * in one millisecond under Windows and about 380 times in one millisecond
	 * under Linux.
	 *
	 * TODO: make sure it works with multiple cores, although I'm sure it does
	 */
	long runningTime() {
		return backend_runningTime;
	}
	/**
	 * Returns the system time in milliseconds since January 1, 1970 UTC.
	 * On Windows XP, this time is only updated every 15.625 milliseconds.
	 *
	 * On my 1.3 GHz celeron, this function can be called about 12,000 times
	 * in one millisecond under Windows and about 460 times in one millisecond
	 * under Linux.
	 */
	long systemTime() {
		return backend_systemTime;
	}
	/**
	 * Gets the number of logical processors on this computer. A logical
	 * processor can either be a different physical processor or simply
	 * another core in the same processor. Even a single core hyper-threaded
	 * processor is considered to have two logical processors.
	 * Returns: the number of logical processors
	 */
	int processorCount() {
		return backend_processorCount;
	}
	/**
	 * The number returned by this method can be used to measure the
	 * time between two calls. This method uses the highest resolution
	 * timer available.
	 *
	 * On my 1.3 GHz celeron, this function can be called about 500 times
	 * in one millisecond under Windows.
	 *
	 * Returns: the current time in milliseconds
	 *
	 * Note: Under Windows, this is implemented using QueryPerformanceCounter().
	 * QueryPerformanceCounter() gets the time counter from the processor.
	 * On processors with multiple cores (such as an Althon X2 or a Core 2 Duo),
	 * the time counter for each core may be a few milliseconds different.
	 * (Microsoft's documentation says this is due to bugs in the BIOS or HAL.)
	 * Since QueryPerformanceCounter() can get the time from either core,
	 * the time between two calls made within the same millisecond can be off.
	 * For example, on my Althon X2 computer, the difference between cores
	 * is usually 60 ms. If two calls to QueryPerformanceCounter() are made
	 * in the same millisecond, there is a possiblity that the second one
	 * will return a time 60 ms smaller than the first.
	 * Under Linux, this is implemented using gettimeofday(), which has no
	 * problems with multiple cores and is accurate.
	 * One way to fix this inaccuracy is by only allowing the thread to
	 * use one processor. Another problem is that this time will run slightly
	 * faster or slower than the system time.
	 */
	private long processorTime() {
		return backend_processorTime;
	}
}

unittest {
	auto startTime = Environment.runningTime;
	assert(startTime > 0);
	auto time = startTime;
	enum SAMPLE = 50;
	// makes sure that RunningTime does not go backwards
	for(int i = 0; i < SAMPLE;) {
		auto time2 = Environment.runningTime;
		assert(time2 >= time);
		if(time2 > time) {
			time = time2;
			++i;
		}
	}
	//printf("avg accuracy: %.1f ms\n", (time-startTime)/cast(float)SAMPLE);
}

