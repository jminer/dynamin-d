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
 * Portions created by the Initial Developer are Copyright (C) 2007-2009
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Jordan Miner <jminer7@gmail.com>
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

