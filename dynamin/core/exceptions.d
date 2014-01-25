
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.exceptions;

import dynamin.core.global;
import core.exception : AssertError, RangeError;


class ArgumentError : Error {
	this(string msg, string file = __FILE__, word line = __LINE__, Throwable next = null) {
		super(msg, file, line, next);
	}
}

class StateError : Error {
	this(string msg, string file = __FILE__, word line = __LINE__, Throwable next = null) {
		super(msg, file, line, next);
	}
	this(string file = __FILE__, word line = __LINE__, Throwable next = null) {
		super("The operation was not allowed by the current state of the object.",
			file, line, next);
	}
}

class UnimplementedError : Error {
	this(string file = __FILE__, word line = __LINE__, Throwable next = null) {
		super("The operation is not implemented.", file, line, next);
	}
}

class UnsupportedError : Error {
	this(string msg, string file = __FILE__, word line = __LINE__, Throwable next = null) {
		super(msg, file, line, next);
	}
}


class FormatException : Exception {
	this(string msg, string file = __FILE__, word line = __LINE__, Throwable next = null) {
		super(msg, file, line, next);
	}
}

class IOException : Exception {
	this(string msg, string file = __FILE__, word line = __LINE__, Throwable next = null) {
		super(msg, file, line, next);
	}
}

/*
Dart                              C#                         Java
FormatException
IOException                       IOException                IOException
IntegerDivisionByZeroException    DivideByZeroException      ArithmeticException
ParseException                                               ParseException
SerializationException            SerializationException
ArgumentError                     ArgumentException          IllegalArgumentException
AssertionError                                               AssertionError
CastError                         InvalidCastException
OutOfMemoryError                  OutOfMemoryException       OutOfMemoryError
RuntimeError                                                 RuntimeException
StateError                        InvalidOperationException
UnimplementedError                NotImplementedException
UnsupportedError                  NotSupportedException      UnsupportedOperationException
NoSuchMethodError
NullError                         NullReferenceException     NullPointerException
RangeError                        IndexOutOfRangeException   IndexOutOfBoundsException
                                                             TimeoutException
                                                             NoSuchElementException

Not all of these are exact equivalents. For example, failing to parse a string into an integer
results in a NumberFormatException (inherited from IllegalArgumentException) in Java and a FormatException in C#. .NET's DivideByZeroException inherits from ArithmeticException.

StateError and InvalidOperationException are exactly the same between Dart and .NET.

Exception
	RangeException
	ArgumentException
		RangeException
	FormatException
		InvalidXmlException
		InvalidJsonException
		InvalidCsvException
	IOException
	AccessDeniedException
	UnimplementedException
	UnsupportedException
	StateException
	TimeoutException
	SecurityException
*/

