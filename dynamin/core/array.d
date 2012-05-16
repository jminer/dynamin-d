
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.array;

/**
 * Tests whether or not the specified item is in the specified array.
 * Returns: true if the specified item is in the array and false otherwise
 * Examples:
 * -----
 * "Hello".contains('e') == true
 * "Hello".contains('a') == false
 * "".contains('e') == false
 * assert([2, 3, 7].contains(3) == true);
 * assert([2, 3, 7].contains(0) == false);
 * -----
 */
bool contains(T, U)(T[] arr, U item) {
	foreach(U item2; arr) {
		if(item == item2)
			return true;
	}
	return false;
}

unittest {
	assert("Hello".contains('e') == true);
	assert("Hello".contains('a') == false);
	assert("".contains('e') == false);
	assert([2, 3, 7].contains(3) == true);
	assert([2, 3, 7].contains(0) == false);
}

