
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

/**
 * Utilities for testing.
 */
module dynamin.core.test;

import core.exception;
import dynamin.core.global;

/**
 * Throws an AssertError iff expr does not throw an exception of type T. As with the
 * built-in assert(), the expression is not evaluated when assertions are disabled.
 */
void assertThrows(T, U)(lazy U expr) {
	version(assert) {
		try {
			expr();
		} catch(T ex) {
			return;
		}
		throw new AssertError(T.stringof ~ " was not thrown.");
	}
}
/// ditto
void assertThrows(T, U)(lazy U expr, lazy string message) {
	version(assert) {
		try {
			expr();
		} catch(T ex) {
			return;
		}
		throw new AssertError(message());
	}
}

void assertEqual(T, U)(lazy T expr1, lazy U expr2) {
	version(assert) {
		if(expr1() != expr2())
			throw new AssertError(	"Values " ~ to!string(expr1) ~
				" and " ~ to!string(expr2) ~ " are not equal.");
	}
}

