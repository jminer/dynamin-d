
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

// TODO: v1.0 make a binding to these
extern(C) {
	int get_nprocs_conf();
	int get_nprocs();
	int getitimer(int which, itimerval* value);
	int setitimer(int which, itimerval* value,
		itimerval* ovalue);
}

enum {
	ITIMER_REAL    = 0,
	ITIMER_VIRTUAL = 1,
	ITIMER_PROF    = 2
}

struct itimerval {
	timeval it_interval;
	timeval it_value;
}

template EnvironmentBackend() {
	long backend_timevalToMs(timeval* tv) {
		return tv.tv_sec*1000L+tv.tv_usec/1000;
	}
	const long timerSec = 31_536_000*5; // 31,536,000 seconds in 365 days
	static this() {
		itimerval itv;
		itv.it_value.tv_sec = timerSec;
		if(setitimer(ITIMER_REAL, &itv, null))
			Stdout("setitimer() failed").newline;
	}
	long backend_runningTime() {
		itimerval itv;
		getitimer(ITIMER_REAL, &itv);
		return timerSec*1000-backend_timevalToMs(&itv.it_value);
	}
	long backend_systemTime() {
		timeval tv;
		if(gettimeofday(&tv, null))
			Stdout("gettimeofday() failed!").newline;
		return backend_timevalToMs(&tv);
	}
	int backend_processorCount() {
		return get_nprocs();
	}
	long backend_processorTime() {
		return 0;
	}
}

