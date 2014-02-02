
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.meta;

///
template Tuple(T...) {
	alias T Tuple;
}

///
struct Meta {
	/**
	 * Returns true if `T` is the same type as `U`.
	 */
	template areTypesEqual(T, U) {
		enum areTypesEqual = is(T == U);
	}

	/**
	 * Returns true if `T` is the same type as or is implicitly convertible to `U`.
	 */
	template isTypeConvertible(T, U) {
		enum isTypeConvertible = is(T : U);
	}


	/**
	 * Returns true if `T` is `byte`, `short`, `int`, `long`, `ubyte`, `ushort`,
	 * `uint`, or `ulong`, .
	 */
	template isTypeIntegral(T) {
		enum isTypeIntegral = isTypeUnsigned!(T) ||
			areTypesEqual!(T, byte) || areTypesEqual!(T, short) ||
			areTypesEqual!(T, int)  || areTypesEqual!(T, long);
	}

	/**
	 * Returns true if `T` is `ubyte`, `ushort`, `uint`, or `ulong`.
	 */
	template isTypeUnsigned(T) {
		enum isTypeUnsigned =
			areTypesEqual!(T, ubyte) || areTypesEqual!(T, ushort) ||
			areTypesEqual!(T, uint)  || areTypesEqual!(T, ulong);
	}

	/**
	 * Returns true if `T` is `float`, `double`, or `real`.
	 */
	template isTypeFloatingPoint(T) {
		enum isTypeFloatingPoint =
			areTypesEqual!(T, float) ||
			areTypesEqual!(T, double) ||
			areTypesEqual!(T, real);
	}
}

