
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.math;

public import tango.math.Math;

///
alias PI Pi; // about 3

///
bool isOdd(T)(T x) { return cast(bool)(x & 1); }

