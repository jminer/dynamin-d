
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.windows_environment;

import dynamin.c.windows;
public import core.atomic;
public import core.sync.mutex;

template EnvironmentBackend() {
	long pStart;    // processor time in milliseconds
	long tStart;    // computer uptime in milliseconds
	long startDiff; // pStart-tStart

	static shared long firstMonotonicTime = 0;

	static __gshared Mutex monotonicMutex;
	static __gshared uint lastMonotonicTime32 = 0;
	static __gshared long monotonicTimeSum = 0;

	static this() {
		// TODO: should not do this to all programs by default
		// need an API that programs can use to request more accurate times
		// Still need to re-increase the resolution when coming out of sleep, if
		// the program has requested more accuracy.
		backend_increaseTimerRes();
		QueryPerformanceFrequency(&freq);
		freq /= 1000;
		pStart = processorTime;
		tStart = timeGetTime();
		startDiff = pStart-tStart;
	}
	public void backend_increaseTimerRes() {
		static int period = -1;
		if(period >= 0)
			timeEndPeriod(period);
		TIMECAPS tc;
		timeGetDevCaps(&tc, TIMECAPS.sizeof);
		period = tc.wPeriodMin > 0 ? tc.wPeriodMin : 1;
		timeBeginPeriod(period);

		monotonicMutex = new Mutex;
	}
	long backend_monotonicTime() {
		// see http://www.tech-archive.net/Archive/Development/microsoft.public.win32.programmer.kernel/2009-02/msg00147.html
		// for testing this with App Verifier
		uint time32 = timeGetTime();
		long time;
		synchronized(monotonicMutex) {
			// Won't detect a rollover if called more than 49.7 days apart,
			// but I think that's fine.
			if(time32 < lastMonotonicTime32) { // rolled over
				monotonicTimeSum += uint.max;
			}
			lastMonotonicTime32 = time32;
			time = time32 + monotonicTimeSum;
		}

		cas(&firstMonotonicTime, 0L, time);
		time = time - firstMonotonicTime;
		return time;
	}
	long backend_systemTime() {
		long t;
		// gets time as 100 ns since Jan 1, 1601
		GetSystemTimeAsFileTime(cast(FILETIME*)&t);
		// This code gets the difference between 1601 and 1970
		//SYSTEMTIME st;
		//st.wYear = 1970;
		//st.wMonth = 1;
		//st.wDay = 1;
		//long diff;
		//SystemTimeToFileTime(&st, cast(FILETIME*)&diff);
		t -= 116444736000000000; // change to Jan 1, 1970
		t /= 10000; // change to milliseconds
		return t;
	}
	int backend_processorCount() {
		SYSTEM_INFO si;
		GetSystemInfo(&si);
		return si.dwNumberOfProcessors;
	}
	ulong freq = 0;
	long backend_processorTime() {
		ulong count;
		QueryPerformanceCounter(&count);
		return count/freq;
	}
}

