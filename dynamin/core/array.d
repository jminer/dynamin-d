
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.array;

import dynamin.core.string;
import dynamin.core.test;

/**
 * Returns true if the specified item is in the specified array and false otherwise.
 *
 * ## Examples
 *
 *     assert("Hello".contains('e'));
 *     assert(!"Hello".contains('a'));
 *     assert(!"".contains('e'));
 *     assert([2, 3, 7].contains(3));
 *     assert(![2, 3, 7].contains(0));
 */
bool contains(T, U)(T[] arr, U item) {
	foreach(U item2; arr) {
		if(item == item2)
			return true;
	}
	return false;
}

unittest {
	assert("Hello".contains('e'));
	assert(!"Hello".contains('a'));
	assert(!"".contains('e'));
	assert([2, 3, 7].contains(3));
	assert(![2, 3, 7].contains(0));
}

/**
 * Reverses the items in place in the specified array.
 *
 * ## Examples
 *
 *     mstring str = "ABCD".dup;
 *     str.reverse();
 *     assertEqual(str, "DCBA");
 *
 */
void reverse(T)(T[] arr) {
	T tmp;
	for(int i = 0; i < arr.length / 2; ++i) {
		tmp = arr[i];
		arr[i] = arr[$ - 1 - i];
		arr[$ - 1 - i] = tmp;
	}
}

unittest {
	mstring str;
	str = "ABCD".dup;
	str.reverse();
	assertEqual(str, "DCBA");
	str = "ABCDE".dup;
	str.reverse();
	assertEqual(str, "EDCBA");
	str = "".dup;
	str.reverse();
	assertEqual(str, "");
}

