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

/// Represents the ways items can be changed in a list.
enum ListChangeType {
	/// An item was added to the list.
	Added,
	/// An item was removed from the list.
	Removed,
	/// An item was replaced with another item.
	Replaced
}

/**
 * A list of items backed by an array. If changeNotification is true, then a delegate is passed
 * into the constructor as a callback. The delegate will be called when any item is added to or
 * removed from the list. Also, when changeNotfication is true, some methods are not
 * available. These are marked in their documentation.
 */
class List(T, bool changeNotification = false) {
protected:
	T[] _data;
	uint _count;
	static if(changeNotification)
		void delegate(ListChangeType, T, T, uint) whenChanged;
	const int DefaultCapacity = 16;
public:
	/**
	 * Creates a list with the specified capacity.
	 *
	 * Only available if changeNotification is false.
	 */
	this() {
		static if(changeNotification)
			throw new Exception("not available");
		this(DefaultCapacity);
	}
	/// ditto
	this(uint capacity) {
		static if(changeNotification)
			throw new Exception("not available");
		_data = new T[capacity];
	}

	/**
	 * Creates a list with the specified capacity and with a delegate that will be called
	 * when an item is added to or removed from the list. The type specifies whether an
	 * item was added, removed, or replaced. oldItem contains the item that was removed,
	 * and newItem contains the item that was added. So if type is ListChangeType.Added,
	 * oldItem will be T.init (which is null for reference types). If type is
	 * ListChangeType.Removed, newItem will be T.init. The index of the item after being
	 * added or before being removed is also passed to the delegate.
	 *
	 * Only available if changeNotification is true.
	 */
	this(void delegate(ListChangeType type, T oldItem, T newItem, uint index) whenChanged) {
		static if(changeNotification) {
			this(DefaultCapacity, whenChanged);
		} else {
			throw new Exception("not available");
		}
	}
	/// ditto
	this(uint capacity,
		 void delegate(ListChangeType type, T oldItem, T newItem, uint index) whenChanged) {
		static if(changeNotification) {
			_data = new T[capacity];
			this.whenChanged = whenChanged;
		} else {
			throw new Exception("not available");
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
	void opIndexAssign(T item, uint index) {
		T oldItem = _data[0.._count][index];
		_data[0.._count][index] = item;
		static if(changeNotification)
			whenChanged(ListChangeType.Replaced, oldItem, item, index);
	}
	void push(T item) {
		add(item);
	}
	T pop() {
		if(_count < 1)
			throw new Exception("List.pop() - List is empty");
		T item = _data[_count-1];
		// must null out to allow to be collected
		_data[_count-1] = T.init;
		--_count;
		static if(changeNotification)
			whenChanged(ListChangeType.Removed, item, T.init, _count);
		return item;
	}
	void add(T item) {
		insert(item, _count);
	}
	void remove(T item) {
		uint i = find(item);
		if(i == -1)
			return;
		removeAt(i);
	}
	void removeAt(uint index) {
		T item = _data[index];

		for(uint i = index + 1; i < _count; ++i)
			_data[i-1] = _data[i];
		// must null out to allow to be collected
		_data[_count-1] = T.init;
		--_count;

		static if(changeNotification)
			whenChanged(ListChangeType.Removed, item, T.init, index);
	}
	void insert(T item, uint index) {
		maybeEnlarge(_count+1);
		arrayCopy!(T)(_data, index, _data, index+1, _count - index);
		_data[index] = item;
		++_count;
		static if(changeNotification)
			whenChanged(ListChangeType.Added, T.init, item, index);
	}
	void clear() {
		for(; _count > 0; --_count) {
			static if(changeNotification)
				whenChanged(ListChangeType.Removed, _data[_count-1], T.init, _count-1);
			// must null out to allow to be collected
			data[_count-1] = T.init;
		}
	}
	uint find(T item) {
		foreach(i, item2; _data)
			if(item == item2) // if(item2 == item) would crash on a null item
				return i;
		return -1;
	}
	//trimCapacity()
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
	list.removeAt(0);
	assert(list.data == "elo!, Mat");
	list.removeAt(8);
	assert(list.data == "elo!, Ma");
	list.removeAt(1);
	assert(list.data == "eo!, Ma");
	list.clear();
	assert(list.data == "");

	int a = 0, r = 0, r2 = 0;
	void changed(ListChangeType t, string o, string n, uint) {
		if(t == ListChangeType.Added) {
			a++;
			assert(o == "" && n != "");
		}
		if(t == ListChangeType.Removed) {
			r++;
			assert(n == "" && o != "");
		}
		if(t == ListChangeType.Replaced) {
			r2++;
		}
	};
	auto list2 = new List!(string, true)(&changed);
	assert(a == 0 && r == 0 && r2 == 0);
	list2.add("hello");
	assert(a == 1 && r == 0 && r2 == 0);
	assert(list2.pop() == "hello");
	assert(a == 1 && r == 1 && r2 == 0);

	list2.add("Hi");
	list2.add("Jacob");
	assert(a == 3 && r == 1 && r2 == 0);
	list2[1] = "Matt";
	assert(a == 3 && r == 1 && r2 == 1);
	list2.insert("John", 1);
	list2.insert("Pete", 3);
	assert(list2.data == ["Hi", "John", "Matt", "Pete"]);
	assert(a == 5 && r == 1 && r2 == 1);
	list2.removeAt(0);
	assert(list2.data == ["John", "Matt", "Pete"]);
	assert(a == 5 && r == 2 && r2 == 1);
	list2.clear();
	assert(a == 5 && r == 5 && r2 == 1);
}

