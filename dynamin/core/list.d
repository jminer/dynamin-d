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
 * Portions created by the Initial Developer are Copyright (C) 2006-2009
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Jordan Miner <jminer7@gmail.com>
 *
 */

module dynamin.core.list;

import dynamin.core.global;
import dynamin.core.string;
import dynamin.core.math;
import tango.io.Stdout;

// TODO: QuickSearch()
// TODO: BinarySearch()
//       MUST use (high + low) >>> 1 to find the average
// TODO: Search()
// TODO: QuickSort()
// TODO: HeapSort()
// TODO: Sort() - calls HeapSort() so stable sort is default
class List(T, bool hasDelegates = false) {
protected:
	T[] _data;
	uint _count;
	static if(hasDelegates) {
		void delegate(T, int) whenAdded;
		void delegate(T, int) whenRemoved;
	}
	const int DefaultCapacity = 16;
public:
	static if(hasDelegates) {
		/// whenAdded or whenRemoved is called right after an item is added
		/// or removed
		this(void delegate(T, int) whenAdded,
		     void delegate(T, int) whenRemoved) {
			this(DefaultCapacity, whenAdded, whenRemoved);
		}
		this(uint capacity,
		     void delegate(T, int) whenAdded,
		     void delegate(T, int) whenRemoved) {
			_data = new T[capacity];
			this.whenAdded = whenAdded;
			this.whenRemoved = whenRemoved;
		}
	} else {
		this() {
			this(DefaultCapacity);
		}
		this(uint capacity) {
			_data = new T[capacity];
		}
	}
	static List!(T) fromArray(T[] arr...) {
		auto list = new List!(T)();
		list._data = arr.dup;
		list._count = arr.length;
		return list;
	}
	uint count() {
		return _count;
	}
	uint capacity() {
		return _data.length;
	}
	T[] toArray() {
		return _data[0.._count].dup;
	}
	T[] data() {
		return _data[0.._count];
	}
	/*string toString() {
		string str = "[";
		if(Count > 0)
			str ~= ToString(this[0]);
		foreach(item; this) {
			str ~= ", ";
			str ~= ToString(item);
		}
		str ~= "]";
		return str;
	}*/
	protected void maybeEnlarge(uint neededCap) {
		if(neededCap <= capacity)
			return;
		_data.length = max(neededCap, (capacity+1)*2);
	}
	T opIndex(uint index) {
		return _data[0.._count][index];
	}
	void push(T item) {
		add(item);
	}
	T pop() {
		if(_count < 1)
			throw new Exception("List.pop() - List is empty");
		T item = _data[_count-1];
		// must null out to allow to be collected
		static if(is(T == class) || is(T == interface))
			_data[_count-1] = cast(T)null;
		--_count;
		static if(hasDelegates)
			whenRemoved(item, _count);
		return item;
	}
	void add(T item) {
		insert(item, _count);
	}
	void remove(T item) {
		uint i = find(item);
		if(i == -1)
			return;

		for(++i; i < _count; ++i)
			_data[i-1] = _data[i];
		// must null out to allow to be collected
		static if(is(T == class) || is(T == interface))
			_data[_count-1] = cast(T)null;
		--_count;

		static if(hasDelegates)
			whenRemoved(item, i);
	}
	void insert(T item, uint index) {
		maybeEnlarge(_count+1);
		arrayCopy!(T)(_data, index, _data, index+1, _count - index);
		_data[index] = item;
		++_count;
		static if(hasDelegates)
			whenAdded(item, index);
	}
	void clear() {
		for(; _count > 0; --_count) {
			static if(hasDelegates)
				whenRemoved(_data[_count-1], _count-1);
			// must null out to allow to be collected
			static if(is(T == class) || is(T == interface))
				data[_count-1] = cast(T)null;
		}
	}
	uint find(T item) {
		foreach(i, item2; _data)
			if(item == item2) // if(item2 == item) would crash on a null item
				return i;
		return -1;
	}
	//trimCapacity()
	//opIndex
	//opIndexAssign
	//opConcat
	//opEquals
	//opSlice
	//opSliceAssign
	int opApply(int delegate(inout T item) dg) {
		for(uint i = 0; i < _count; ++i) {
			if(int result = dg(_data[i]))
				return result;
		}
		return 0;
	}
	//so you can do:
	//foreach(i, item; list)
	int opApply(int delegate(inout uint index, inout T item) dg) {
		for(uint i = 0; i < _count; ++i) {
			if(int result = dg(i, _data[i]))
				return result;
		}
		return 0;
	}

}
unittest {
	auto list = List!(char).fromArray("Hello, Mat");
	list.add('t');
	assert(list.data == "Hello, Matt");
	assert(list.pop() == 't');
	assert(list.data == "Hello, Mat");
	list.insert('!', 5);
	assert(list.data == "Hello!, Mat");
	list.remove('l');
	assert(list.data == "Helo!, Mat");
	list.clear();
	assert(list.data == "");

	int a = 0, r = 0;
	void added(string, int) { a++; };
	void removed(string, int) { r++; };
	auto list2 = new List!(string, true)(&added, &removed);
	assert(a == 0 && r == 0);
	list2.add("hello");
	assert(a == 1 && r == 0);
	assert(list2.pop() == "hello");
	assert(a == 1 && r == 1);

	list2.add("Hi");
	list2.add("Jacob!");
	assert(a == 3 && r == 1);
	list2.clear();
	assert(a == 3 && r == 3);
}

