
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core_backend;

version(Windows) {
	public import dynamin.core.windows_console;
	public import dynamin.core.windows_environment;
} else {
	public import dynamin.core.unix_console;
	public import dynamin.core.unix_environment;
}

