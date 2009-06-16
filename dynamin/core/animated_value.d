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
 * Portions created by the Initial Developer are Copyright (C) 2008
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Jordan Miner <jminer7@gmail.com>
 *
 */

module dynamin.core.animated_value;

/// AnimatedValue!(int)
alias AnimatedValue!(int) AnimatedInt;
/// AnimatedValue!(float)
alias AnimatedValue!(float) AnimatedFloat;
/// AnimatedValue!(double)
alias AnimatedValue!(double) AnimatedDouble;
/// AnimatedValue!(real)
alias AnimatedValue!(real) AnimatedReal;

// TODO: change to a struct?
/**
 * Holds a value that changes over time. The value can be changed by calling
 * animate(), then calling advance() with an amount of time.
 * Example:
 * -----
 * AnimatedInt x = new AnimatedInt;
 * x.set(100);   /+ start the animation at 100 +/
 * x.animate(900, 1000);   /+ animate to 900, over a period of 1000 ms +/
 * x.advance(250);   /+ advance 250 ms, one-fourth of the way to 1000 +/
 * x.get(); /+ returns 300, one-fourth of the way between 100 and 900 +/
 * x.advance(2000); /+ advance past the end of the animation +/
 * x.get(); /+ returns 900 +/
 * -----
 */
class AnimatedValue(T) {
	T _value = 0;
	T _startValue, _endValue;
	int _elapsed, _duration;
	bool _animating;
	T get() {
		return _value;
	}
	T end() {
		return _endValue;
	}
	AnimatedValue set(T newVal) {
		_value = newVal;
		_endValue = _value;
		_animating = false;
		return this;
	}
	void animate(T endVal, int dur) {
		_animating = true;
		_elapsed = 0;
		_duration = dur;
		_startValue = _value;
		_endValue = endVal;
	}
	bool animating() { return _animating; }
	void advance(int time) {
		_elapsed += time;
		if(!_animating)
			return;
		if(_elapsed > _duration)
			set(_endValue);
		else
			_value = _startValue+(_endValue-_startValue)*_elapsed/_duration;
	}
	int elapsed() {
		return _elapsed;
	}
	int duration() {
		return _duration;
	}
}
