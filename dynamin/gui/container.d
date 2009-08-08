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

module dynamin.gui.container;

import dynamin.all_core;
import dynamin.all_painting;
import dynamin.all_gui;
import dynamin.gui.control;
import dynamin.gui.events;
import tango.io.Stdout;

alias List!(Control, true) ControlList;

///
class Container : Control {
protected:
	ControlList _children;
	Size _minSize;
	Size _maxSize;

	override void whenResized(EventArgs e) {
		layout();
	}
	// If the specified array is large enough to hold the results, no heap
	// allocation will be done.
	Control[] getFocusableDescendants(Control[] des = null) {
		uint cur = 0;

		void addDescendants(Container c) {
			if(c._focusable) { // TODO: && c.enabled) {
				if(cur == des.length)
					des.length = des.length + 20;
				des[cur++] = c;
			}
			foreach(ch; c._children) {
				if(cast(Container)ch)
					addDescendants(cast(Container)ch);
				else if(ch.focusable) { // TODO: && ch.enabled) {
					if(cur == des.length)
						des.length = des.length + 20;
					des[cur++] = ch;
				}
			}
		}
		addDescendants(this);
		return des[0..cur];
	}
	unittest {
		class MyControl : Control {
			this() {
				_focusable = true;
			}
		}
		auto container1 = new Container();
		auto container2 = new Container();
		auto container3 = new Container();
		auto container4 = new Container();
		container2._focusable = true;
		container4._focusable = true;
		auto ctrl1 = new MyControl();
		auto ctrl2 = new MyControl();
		auto ctrl3 = new MyControl();

		container1.add(container2);
		container1.add(container3);
		container3.add(container4);
		container2.add(ctrl1);
		container4.add(ctrl2);
		container4.add(ctrl3);
		assert(container1.getFocusableDescendants() ==
			[cast(Control)container2, ctrl1, container4, ctrl2, ctrl3]);
		Control[5] buf;
		assert(container1.getFocusableDescendants(buf).ptr == buf.ptr);
	}

	// not an event
	void whenChildAdded(Control child, int) {
		if(child.parent)
			child.parent.remove(child);
		child.parent = this;
		repaint();

		void callAdded(Control ctrl) {
			scope e = new HierarchyEventArgs(ctrl);
			descendantAdded(e);

			if(auto cntr = cast(Container)ctrl) {
				foreach(c; cntr._children)
					callAdded(c);
			}
		}
		callAdded(child);
	}

	// not an event
	void whenChildRemoved(Control child, int) {
		child.parent = null;
		repaint();

		scope e = new HierarchyEventArgs(child);
		descendantRemoved(e);
	}

	void dispatchDescendantAdded(HierarchyEventArgs e) {
		descendantAdded.callHandlers(e);
		descendantAdded.callMainHandler(e);
		e.levels = e.levels + 1;
		if(_parent)
			_parent.descendantAdded(e);
	}
	void dispatchDescendantRemoved(HierarchyEventArgs e) {
		descendantRemoved.callHandlers(e);
		descendantRemoved.callMainHandler(e);
		e.levels = e.levels + 1;
		if(_parent)
			_parent.descendantRemoved(e);
	}
public:
	/// Override this method in a subclass to handle the minSizeChanged event.
	protected void whenMinSizeChanged(EventArgs e) { }
	/// This event occurs after the control's minimum size has been changed.
	Event!(whenMinSizeChanged) minSizeChanged;

	/// Override this method in a subclass to handle the maxSizeChanged event.
	protected void whenMaxSizeChanged(EventArgs e) { }
	/// This event occurs after the control's maximum size has been changed.
	Event!(whenMaxSizeChanged) maxSizeChanged;

	/// Override this method in a subclass to handle the descendantAdded event.
	protected void whenDescendantAdded(HierarchyEventArgs e) { }
	/// This event occurs after a control is added as a descendant of this container.
	Event!(whenDescendantAdded) descendantAdded;

	/// Override this method in a subclass to handle the descendantRemoved event.
	protected void whenDescendantRemoved(HierarchyEventArgs e) { }
	/// This event occurs after a descendant of this container has been removed.
	Event!(whenDescendantRemoved) descendantRemoved;

	this() {
		minSizeChanged.mainHandler = &whenMinSizeChanged;
		maxSizeChanged.mainHandler = &whenMaxSizeChanged;
		descendantAdded.mainHandler = &whenDescendantAdded;
		descendantAdded.dispatcher = &dispatchDescendantAdded;
		descendantRemoved.mainHandler = &whenDescendantRemoved;
		descendantRemoved.dispatcher = &dispatchDescendantRemoved;

		_children = new ControlList(&whenChildAdded, &whenChildRemoved);

		elasticX = true;
		elasticY = true;
	}
	override void dispatchPainting(PaintingEventArgs e) {
		super.dispatchPainting(e);
		foreach(c; _children) {
			e.graphics.save();
			e.graphics.translate(c.x, c.y);
			c.setupGraphics(e.graphics);
			c.painting(e);
			e.graphics.restore();
		}
	}
	// TODO: make these use common code...get rid of copy and paste
	override void dispatchMouseDown(MouseEventArgs e) {
		auto c = getChildAtPoint(e.location);
		if(c && getCaptorControl() !is this) {
			e.location = e.location - c.location;
			c.mouseDown(e);
			e.location = e.location + c.location;
		} else {
			super.dispatchMouseDown(e);
		}
	}
	override void dispatchMouseUp(MouseEventArgs e) {
		auto c = getChildAtPoint(e.location);
		if(c && getCaptorControl() !is this) {
			e.location = e.location - c.location;
			c.mouseUp(e);
			e.location = e.location + c.location;
		} else {
			super.dispatchMouseUp(e);
		}
	}
	override void dispatchMouseMoved(MouseEventArgs e) {
		auto c = getChildAtPoint(e.location);
		if(c && getCaptorControl() !is this) {
			e.location = e.location - c.location;
			c.mouseMoved(e);
			e.location = e.location + c.location;
		} else {
			super.dispatchMouseMoved(e);
		}
	}
	override void dispatchMouseDragged(MouseEventArgs e) {
		auto c = getChildAtPoint(e.location);
		if(c && getCaptorControl() !is this) {
			e.location = e.location - c.location;
			c.mouseDragged(e);
			e.location = e.location + c.location;
		} else {
			super.dispatchMouseDragged(e);
		}
	}

	/**
	 * Gets the child control at the specified point. If there are
	 * multiple child controls at the point, the topmost control is returned.
	 * If there is no child control at the point, null is returned. The returned
	 * control, if any, is a direct child of this container.
	 */
	Control getChildAtPoint(real[] pt) {
		assert(pt.length == 2, "pt must be just an x and y");
		return getChildAtPoint(Point(pt[0], pt[1]));
	}
	/// ditto
	Control getChildAtPoint(real x, real y) {
		return getChildAtPoint(Point(x, y));
	}
	/// ditto
	Control getChildAtPoint(Point pt) {
		for(int i = _children.count-1; i >= 0; --i) {
			pt = pt - _children[i].location;
			scope(exit) pt = pt + _children[i].location;
			if(_children[i].contains(pt))
				return _children[i];
		}
		return null;
	}

	/**
	 * Never returns null. If there is no descendant at the specified point,
	 * this container will be returned.
	 */
	Control getDescendantAtPoint(real[] pt) {
		assert(pt.length == 2, "pt must be just an x and y");
		return getDescendantAtPoint(Point(pt[0], pt[1]));
	}
	/// ditto
	Control getDescendantAtPoint(real x, real y) {
		return getDescendantAtPoint(Point(x, y));
	}
	/// ditto
	Control getDescendantAtPoint(Point pt) {
		Container des = this;
		while(true) {
			auto child = des.getChildAtPoint(pt);
			if(!child)
				return des;
			auto isContainer = cast(Container)child;
			if(isContainer) {
				des = isContainer;
				pt = pt - des.location;
				// loop around with this container
			} else {
				return child;
			}
		}
	}

	/**
	 * Gets or sets the minimum size of this window. A minimum width or
	 * height of 0 means that there is no minimum width or height.
	 * The default is Size(0, 0).
	 */
	Size minSize() { return _minSize; }
	/// ditto
	void minSize(Size size) {
		_minSize = size;
		minSizeChanged(new EventArgs);
	}
	/// ditto
	void minSize(real[] size) {
		assert(size.length == 2, "size must be just a width and height");
		minSize = Size(size[0], size[1]);
	}
	///
	real minWidth() { return _minSize.width; }
	///
	real minHeight() { return _minSize.height; }

	/**
	 * Gets or sets the maximum size of this window. A maximum width or
	 * height of 0 means that there is no maximum width or height.
	 * The default is Size(0, 0).
	 */
	Size maxSize() { return _maxSize; }
	/// ditto
	void maxSize(Size size) {
		_maxSize = size;
		minSizeChanged(new EventArgs);
	}
	/// ditto
	void maxSize(real[] size) {
		assert(size.length == 2, "size must be just a width and height");
		maxSize = Size(size[0], size[1]);
	}
	///
	real maxWidth() { return _maxSize.width; }
	///
	real maxHeight() { return _maxSize.height; }

	/**
	 * Causes this container to position its child controls. Called on every
	 * resize. Usually, this function will get each child's best size, and
	 * then set each child's location and height. The definition in Container
	 * is empty, as it is intended for subclasses to override.
	 */
	void layout() {
	}

	protected void add(Control child) {
		_children.add(child);
	}

	protected void remove(Control child) {
		_children.remove(child);
	}

	int opApply(int delegate(inout Control item) dg) {
		for(uint i = 0; i < _children.count; ++i) {
			auto tmp = _children[i];
			if(int result = dg(tmp))
				return result;
		}
		return 0;
	}
	int opApply(int delegate(inout uint index, inout Control item) dg) {
		for(uint i = 0; i < _children.count; ++i) {
			auto tmp = _children[i];
			if(int result = dg(i, tmp))
				return result;
		}
		return 0;
	}
}
unittest {
	auto i = 0;
	auto container = new Panel;
	container.descendantAdded += (HierarchyEventArgs e) { i++; };
	auto sub = new Panel;
	sub.add(new Control);
	container.add(sub);
	assert(i == 2);
}

// TODO: calling panel.children.add(button) will cause a crash
// because the button's parent is not set to the panel
// need to add a change handler on children?
class Panel : Container {
	ControlList children() { return _children; }
	void add(Control child) { super.add(child); };
	void remove(Control child) { super.remove(child); };
	int opApply(int delegate(inout Control item) dg) {
		return super.opApply(dg);
	}
	int opApply(int delegate(inout uint index, inout Control item) dg) {
		return super.opApply(dg);
	}
//	override protected void whenPainting() {
//	}
}

