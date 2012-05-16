
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

template EnvironmentBackend() {
	long pStart;    // processor time in milliseconds
	long tStart;    // computer uptime in milliseconds
	long startDiff; // pStart-tStart
	static this() {
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
	}
	long backend_runningTime() {
		// NOTE: might be a faster way to do this...ProcessorTime is slow
		// Use ProcessorTime to fix when timeGetTime() rolls over
		const strayMs = 18_000_000; // 5 hours
		long pNow = processorTime;
		long tNow = timeGetTime();
		// pNow-startDiff would equal tNow except that:
		// - tNow has possibly rolled over
		// - pNow has strayed because it runs at a slightly different speed
		while(pNow-startDiff > tNow+strayMs)
			tNow += 0xFFFF_FFFF;   // tNow has rolled over, so fix it
		return tNow-tStart;
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

