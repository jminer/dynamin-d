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
 * Portions created by the Initial Developer are Copyright (C) 2006-2012
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Jordan Miner <jminer7@gmail.com>
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

