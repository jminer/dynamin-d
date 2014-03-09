
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
import dynamin.core.benchmark;
import dynamin.core.array;
import dynamin.core.meta;

//version = DebugQueue;

class Queue(T) {
private:
	T[] _data;
	word _start;
	word _end;

	// Ideally, types that don't contain a reference type, like bool, char, int,
	// float, and structs without reference types would not be cleared, but every
	// other type would. Clearing chars is handy for testing the clearing code...
	enum _needsCleared = !Meta.isTypeIntegral!T && !Meta.isTypeFloatingPoint!T;
public:
	@property
	word capacity() {
		return _data.length;
	}

	void ensureCapacity(word minCapacity) {
		if(_data.length >= minCapacity)
			return;

		auto oldLength = _data.length;

		_data.reserve(max(minCapacity, (_data.length + 2) * 2));
		_data.length = _data.capacity;

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
			Stdout.format("slideItems()  start: {}, end: {}, amount: {}", start, end, amount).newline;
			Stdout.format("slideItems()  newStart: {}, newEnd: {}", newStart, newEnd).newline;
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

	private static void clearItems(T[] data, word start, word end) {
		if(!_needsCleared)
			return;

		version(DebugQueue) {
			Stdout.format("clearItems()  start: {}, end: {}", start, end).newline;
		}
		if(end < start) {
			data.fill(T.init, start, data.length - start);
			data.fill(T.init, 0, end);
		} else {
			data.fill(T.init, start, end - start);
		}
	}

	@property
	word count() {
		return _end < _start ? _data.length - (_start - _end) : _end - _start;
	}

	void splice(word index, word count, const(T)[] items) {
		enforceEx!ArgumentError(index >= 0, "index >= 0 failed");
		enforceEx!ArgumentError(count >= 0, "count >= 0 failed");
		enforceEx!ArgumentError(index + count <= this.count,
								"index + count <= this.count failed");

		word countDelta = items.length - count;
		ensureCapacity(this.count + countDelta);
		word end = index + count;
		version(DebugQueue) {
			Stdout.format("splice()  index: {}, end: {}, items.length: {}", index, end, items.length).newline;
		}

		auto wrappedStart = wrapStartIndex(_start + index, _data.length);
		auto wrappedEnd = wrapEndIndex(_start + end, _data.length);
		version(DebugQueue) {
			Stdout.format("splice()  wrappedStart: {}, wrappedEnd: {}", wrappedStart, wrappedEnd).newline;
		}
		if(index < (this.count - end)) {
			// make room by moving left side
			slideItems(_data, _start, wrappedStart, -countDelta);
			auto newStart = wrapStartIndex(_start - countDelta, _data.length);
			if(countDelta < 0)
				clearItems(_data, _start, newStart);
			_start = newStart;
			wrappedStart = wrapStartIndex(wrappedStart - countDelta, _data.length);
		} else {
			// make room by moving right side
			slideItems(_data, wrappedEnd, _end, countDelta);
			auto newEnd = wrapEndIndex(_end + countDelta, _data.length);
			if(countDelta < 0)
				clearItems(_data, newEnd, _end);
			_end = newEnd;
			wrappedEnd = wrapEndIndex(wrappedEnd + countDelta, _data.length);
		}

		version(DebugQueue) {
			Stdout.format("splice()  new wrappedStart: {}, wrappedEnd: {}", wrappedStart, wrappedEnd).newline;
		}
		if(wrappedEnd < wrappedStart) { // if items will be split
			auto firstPart = _data.length - wrappedStart;
			arrayCopy(items, 0, _data, wrappedStart, firstPart);
			arrayCopy(items, firstPart, _data, 0, items.length - firstPart);
		} else {
			arrayCopy(items, 0, _data, wrappedStart, items.length);
		}
	}

	void insert(T item, word index) {
		splice(index, 0, (&item)[0..1]);
	}

	void add(T item) {
		// could use splice(count, 0, (&item)[0..1]), but this is 1.9x the speed
		ensureCapacity(this.count + 1);
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
		auto item = _data[oldEnd - 1];
		if(_needsCleared)
			_data[oldEnd - 1] = T.init;
		return item;
	}

	void enqueue(T item) {
		add(item);
	}

	T dequeue() {
		enforceEx!StateError(_start != _end, "There are no items to return.");

		auto oldStart = _start;
		_start = wrapStartIndex(_start + 1, _data.length);
		auto item = _data[oldStart];
		if(_needsCleared)
			_data[oldStart] = T.init;
		return item;
	}

	void remove(word index, word count = 1) {
		splice(index, count, (cast(T*)null)[0..0]);
	}

	ref T opIndex(word index) {
		return _data[wrapStartIndex(_start + index, _data.length)];
	}

	void opIndexAssign(T item, word index) {
		_data[wrapStartIndex(_start + index, _data.length)] = item;
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

unittest {
	Queue!char queue;

	queue = new Queue!char;
	queue.splice(0, 0, "Test");
	assert(queue.count == 4);
	assert(queue._start == 0 && queue._end == 4);
	assert(queue.dequeue == 'T');
	assert(queue._start == 1 && queue._end == 4);

	auto reset1 = {
		queue._data = "89    01234567".dup;
		queue._start = 6;
		queue._end = 2;
	};

	// test that left side is copied
	reset1();
	queue.splice(2, 1, "AB");
	assert(queue._data == "89   01AB34567");
	assert(queue._start == 5);
	assert(queue._end == 2);

	// test that right side is copied
	reset1();
	queue.splice(6, 1, "AB");
	assert(queue._data == "789   012345AB");
	assert(queue._start == 6);
	assert(queue._end == 3);

	// test that items will be copied split
	reset1();
	queue.splice(7, 1, "ABCDE");
	assert(queue._data == "BCDE890123456A");
	assert(queue._start == 6);
	assert(queue._end == 6);

	// test moving left side right
	reset1();
	queue.splice(1, 4, "AB");
	assert(queue._data == "89    \xff\xff0AB567");
	assert(queue._start == 8);
	assert(queue._end == 2);

	// test moving right side left
	reset1();
	queue.splice(5, 4, "AB");
	assert(queue._data == "\xff\xff    01234AB9");
	assert(queue._start == 6);
	assert(queue._end == 14);

	reset1();
	queue.remove(2);
	assert(queue._data == "89    \xff0134567");

	/*
	double speed;
	queue = new Queue!char;
	speed = Benchmark.measureFor(2000, 4, {
		queue.splice(queue.count, 0, "H");
	});
	Stdout.format("splice time: {0:8.7}ms, queue.count: {1}", speed, queue.count).newline;

	queue = new Queue!char;
	speed = Benchmark.measureFor(2000, 4, {
		queue.add('H');
	});
	Stdout.format("add time: {0:8.7}ms, queue.count: {1}", speed, queue.count).newline;
	*/
}
