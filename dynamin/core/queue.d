
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.queue;

import dynamin.core.global;
import dynamin.core.exceptions;
import core.memory;
import std.exception;
import tango.io.Stdout;

//version = DebugQueue;

class Queue(T) {
private:
	T[] _data;
	word _start;
	word _end;

public:
	@property
	word capacity() {
		return _data.length;
	}

	void ensureCapacity(word minCapacity) {
		if(_data.length >= minCapacity)
			return;

		auto oldLength = _data.length;

		word prefCapacity = max(minCapacity, (_data.length + 2) * 2);
		word newSize = GC.extend(_data.ptr,
			(minCapacity - _data.length) * T.sizeof,
			(prefCapacity - _data.length) * T.sizeof);
		if(newSize != 0) // extend succeeded
			_data = _data.ptr[0..newSize / T.sizeof];
		else
			_data.length = prefCapacity;

		if(_end < _start) {
			auto part1Length = oldLength - _start;
			auto lengthDelta = _data.length - oldLength;
			// copy whichever part is smaller
			if(part1Length < _end) {
				arrayCopy(_data, _start, _data, _start + lengthDelta, part1Length);
				_start += lengthDelta;
			} else {
				slideItems(_data, 0, _end, -lengthDelta);
				_end = wrapEndIndex(_end - lengthDelta, _data.length);
			}
		}
	}

	private static word wrapStartIndex(word index, word length) {
		return index < 0 ? index + length :
			index >= length ? index - length : index;
	}

	private static word wrapEndIndex(word index, word length) {
		return index <= 0 ? index + length :
			index > length ? index - length : index;
	}

	private static void slideItems(T[] data, word start, word end, word amount) {
		if(amount == 0)
			return;
		// any move can be done in <= 3 arrayCopy()s
		auto newStart = wrapStartIndex(start + amount, data.length);
		auto newEnd = wrapEndIndex(end + amount, data.length);
		version(DebugQueue) {
			Stdout.format("start: {}, end: {}, amount: {}", start, end, amount).newline;
			Stdout.format("newStart: {}, newEnd: {}", newStart, newEnd).newline;
		}
		static if(false) {
			if(amount < 0) {
				for(word i = start, j = newStart; i != end; ++i, ++j) {
					if(i == data.length)
						i = 0;
					if(j == data.length)
						j = 0;
					data[j] = data[i];
				}
			} else if(amount > 0) {
				for(word i = end - 1, j = newEnd - 1; i != start - 1; --i, --j) {
					if(i < 0)
						i = data.length - 1;
					if(j < 0)
						j = data.length - 1;
					data[j] = data[i];
				}
			}
			return;
		}
		// This could be done shorter (above), but not without an if() in the copy loop.
		if(end < start) {
			if(newEnd < newStart) {
				if(newStart < start) {
					auto part1Length = data.length - start;
					auto part2Length = start - newStart;
					auto part3Length = newEnd;
					arrayCopy(data, start,       data, newStart,               part1Length);
					arrayCopy(data, 0,           data, newStart + part1Length, part2Length);
					arrayCopy(data, part2Length, data, 0,                      part3Length);
				} else {
					auto part1Length = data.length - newStart;
					auto part2Length = newStart - start;
					auto part3Length = end;
					arrayCopy(data, 0,                   data, part2Length, part3Length);
					arrayCopy(data, start + part1Length, data, 0,           part2Length);
					arrayCopy(data, start,               data, newStart,    part1Length);
				}
			} else {
				auto part1Length = data.length - start;
				auto part2Length = end;
				if(amount < 0) {
					arrayCopy(data, start, data, newStart,               part1Length);
					arrayCopy(data, 0,     data, newStart + part1Length, part2Length);
				} else {
					arrayCopy(data, 0,     data, newStart + part1Length, part2Length);
					arrayCopy(data, start, data, newStart,               part1Length);
				}
			}
		} else {
			if(newEnd < newStart) {
				auto part1Length = data.length - newStart;
				auto part2Length = newEnd;
				if(amount < 0) {
					arrayCopy(data, start,               data, newStart, part1Length);
					arrayCopy(data, start + part1Length, data, 0,        part2Length);
				} else {
					arrayCopy(data, start + part1Length, data, 0,        part2Length);
					arrayCopy(data, start,               data, newStart, part1Length);
				}
			} else {
				arrayCopy(data, start, data, newStart, end - start);
			}
		}

	}

	@property
	word count() {
		return _end < _start ? _data.length - (_start - _end) : _end - _start;
	}

	void add(T item) {
		ensureCapacity(_data.length + 1);
		_data[_end] = item;
		_end = wrapEndIndex(_end + 1, _data.length);
	}

	void push(T item) {
		add(item);
	}

	T pop() {
		enforceEx!StateError(_start != _end, "There are no items to pop.");

		auto oldEnd = _end;
		_end = wrapEndIndex(_end - 1, _data.length);
		return _data[oldEnd - 1];
	}

	void enqueue(T item) {
		add(item);
	}

	T dequeue() {
		enforceEx!StateError(_start != _end, "There are no items to return.");

		auto oldStart = _start;
		_start = wrapStartIndex(_start + 1, _data.length);
		return _data[oldStart];

		// TODO: need to zero references in unused part of _data
		// could be a struct holding references/pointers...
	}

	void remove(word index, word count = 1) {
		if(count == 0)
			return;
		enforceEx!ArgumentError(index >= 0, "index >= 0 failed");
		enforceEx!ArgumentError(index <= this.count, "index <= this.count failed");
		enforceEx!ArgumentError(count >= 0, "count >= 0 failed");
		enforceEx!ArgumentError(index + count <= this.count,
			"index + count <= this.count failed");

		auto start = wrapStartIndex(_start + index + count, _data.length);
		slideItems(_data, start, _end, -count);
		_end = wrapEndIndex(_end - count, _data.length);

		// TODO: need to zero references in unused part of _data
		// could be a struct holding references/pointers...

	}
}

unittest {
	char[] arr;

	// no split
	arr = "0123456789".dup;
	Queue!char.slideItems(arr, 3, 7, 2);
	assert(arr == "0123434569", "failed: " ~ arr);

	// no split
	arr = "0123456789".dup;
	Queue!char.slideItems(arr, 3, 7, -3);
	assert(arr == "3456456789", "failed: " ~ arr);

	// split after but not before, shifted left
	arr = "0123456789".dup;
	Queue!char.slideItems(arr, 1, 5, -3);
	assert(arr == "3423456712", "failed: " ~ arr);

	// split after but not before, shifted right
	arr = "0123456789".dup;
	Queue!char.slideItems(arr, 5, 9, 3);
	assert(arr == "7823456756", "failed: " ~ arr);

	// split before but not after, shifted left
	arr = "0123456789".dup;
	Queue!char.slideItems(arr, 8, 3, -4);
	assert(arr == "0123890129", "failed: " ~ arr);

	// split before but not after, shifted right
	arr = "0123456789".dup;
	Queue!char.slideItems(arr, 8, 3, 4);
	assert(arr == "0189012789", "failed: " ~ arr);

	// split before and after, shifted left
	arr = "0123456789".dup;
	Queue!char.slideItems(arr, 8, 3, -1);
	assert(arr == "1223456890", "failed: " ~ arr);

	// split before and after, shifted right
	arr = "0123456789".dup;
	Queue!char.slideItems(arr, 8, 3, 1);
	assert(arr == "9012456788", "failed: " ~ arr);

}

