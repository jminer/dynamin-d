
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.unix_environment;

public import tango.stdc.posix.sys.time;
public import tango.io.Stdout;
public import core.atomic;
public import dynamin.core.global;
version(OSX) {
	public import dynamin.c.mach_time;
}

// TODO: v1.0 make a binding to these
extern(C) {
	version(OSX) {
		enum _SC_NPROCESSORS_ONLN = 58;

	}

	c_long sysconf(int name);
}

template EnvironmentBackend() {
	long backend_timevalToMs(timeval* tv) {
		return tv.tv_sec*1000L+tv.tv_usec/1000;
	}

	static shared long firstMonotonicTime = 0;
	version(OSX) {
		static mach_timebase_info_data_t timebaseInfo;
	}

	long backend_monotonicTime() {
		version(linux) {
			timespec ts;
			clock_gettime(CLOCK_MONOTONIC, &ts);
			long time = ts.tv_sec * 1000 + tv_nsec / 1000 / 1000;
		}
		version(OSX) {
			long time = cast(long)mach_absolute_time();
			if(timebaseInfo.denom == 0)
				mach_timebase_info(&timebaseInfo);
			time = time * timebaseInfo.numer / timebaseInfo.denom;
			time /= 1000000;
		}

		cas(&firstMonotonicTime, 0L, time);
		time = time - firstMonotonicTime;
		return time;
	}
	long backend_systemTime() {
		timeval tv;
		if(gettimeofday(&tv, null))
			Stdout("gettimeofday() failed!").newline;
		return backend_timevalToMs(&tv);
	}
	int backend_processorCount() {
		return cast(int)sysconf(_SC_NPROCESSORS_ONLN);
	}
	long backend_processorTime() {
		return 0;
	}
}

