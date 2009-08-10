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

module dynamin.gui.control;

import dynamin.all_core;
import dynamin.all_painting;
import dynamin.gui.container;
import dynamin.gui.events;
import dynamin.gui.window;
import dynamin.gui.cursor;
import tango.io.Stdout;

//{{{ hotControl
Control hotControl;
// the hot control is the one the mouse is over
package void setHotControl(Control c) {
	if(c !is hotControl) {
		if(hotControl)
			hotControl.mouseLeft(new EventArgs);
		hotControl = c;
		if(c)
			c.mouseEntered(new EventArgs);
	}
}
package Control getHotControl() { return hotControl; }
//}}}

//{{{ captorControl
Control captorControl;
package void setCaptorControl(Control c) {
	captorControl = c;
}
package Control getCaptorControl() { return captorControl; }
//}}}

//{{{ focusedControl
Control focusedControl;
package void setFocusedControl(Control c) {
	if(focusedControl is c)
		return;
	scope e = new EventArgs;
	if(focusedControl)
		focusedControl.focusLost(e);
	focusedControl = c;
	if(focusedControl)
		focusedControl.focusGained(e);
}
package Control getFocusedControl() { return focusedControl; }
//}}}

/**
 * The painting event is an exception to the rule that added handlers are called
 * before whenPainting. The painting event is far more useful since
 * added handles are called after the control's whenPainting has finished.
 * Otherwise, anything handlers painted would likely be painted over when the
 * control painted.
 */
class Control {
protected:
	bool _focusable;
	bool _focused;
	int _tabIndex;
	package Point _location;
	package Size _size;
	string _text;
	Color _backColor;
	Color _foreColor;
	Font _font;
	Cursor _cursor;
	Container _parent;
	bool _elasticX, _elasticY;
public:
	protected void dispatchMouseEntered(EventArgs e) {
		setCurrentCursor(_cursor);
		mouseEntered.callHandlers(e);
		mouseEntered.callMainHandler(e);
	}
	protected void dispatchMouseDown(MouseEventArgs e) {
		setCaptorControl(this);
		mouseDown.callHandlers(e);
		mouseDown.callMainHandler(e);
	}
	protected void dispatchMouseUp(MouseEventArgs e) {
		setCaptorControl(null);
		mouseUp.callHandlers(e);
		mouseUp.callMainHandler(e);
	}
	protected void dispatchMouseMoved(MouseEventArgs e) {
		setHotControl(this);
		mouseMoved.callHandlers(e);
		mouseMoved.callMainHandler(e);
	}
	protected void dispatchMouseDragged(MouseEventArgs e) {
		setHotControl(this);
		mouseDragged.callHandlers(e);
		mouseDragged.callMainHandler(e);
	}
	protected void dispatchMouseTurned(MouseTurnedEventArgs e) {
		mouseTurned.callHandlers(e);
		mouseTurned.callMainHandler(e);
		if(!e.stopped && _parent)
			_parent.mouseTurned(e);
	}
	protected void dispatchKeyDown(KeyEventArgs e) {
		keyDown.callHandlers(e);
		keyDown.callMainHandler(e);
		if(!e.stopped && _parent)
			_parent.keyDown(e);
	}
	protected void dispatchKeyUp(KeyEventArgs e) {
		keyUp.callHandlers(e);
		keyUp.callMainHandler(e);
		if(!e.stopped && _parent)
			_parent.keyUp(e);
	}
	protected void dispatchKeyTyped(KeyTypedEventArgs e) {
		keyTyped.callHandlers(e);
		keyTyped.callMainHandler(e);
		if(!e.stopped && _parent)
			_parent.keyTyped(e);
	}
	protected void dispatchPainting(PaintingEventArgs e) {
		e.graphics.save();
		painting.callMainHandler(e);
		e.graphics.restore();
		e.graphics.save();
		// TODO: every call to a handler should be wrapped in a save/restore
		painting.callHandlers(e);
		e.graphics.restore();
	}

	/// Override this method in a subclass to handle the moved event.
	protected void whenMoved(EventArgs e) { }
	/// This event occurs after the control has been moved.
	Event!(whenMoved) moved;

	/// Override this method in a subclass to handle the resized event.
	protected void whenResized(EventArgs e) { }
	/// This event occurs after the control has been resized.
	Event!(whenResized) resized;

	/// Override this method in a subclass to handle the mouseEntered event.
	protected void whenMouseEntered(EventArgs e) { }
	/// This event occurs after the mouse has entered the control.
	Event!(whenMouseEntered) mouseEntered;

	/// Override this method in a subclass to handle the mouseLeft event.
	protected void whenMouseLeft(EventArgs e) { }
	/// This event occurs after the mouse has left the control.
	Event!(whenMouseLeft) mouseLeft;

	/// Override this method in a subclass to handle the mouseDown event.
	protected void whenMouseDown(MouseEventArgs e) { }
	/// This event occurs after a mouse button is pressed.
	Event!(whenMouseDown) mouseDown;

	/// Override this method in a subclass to handle the mouseUp event.
	protected void whenMouseUp(MouseEventArgs e) { }
	/// This event occurs after a mouse button is released.
	Event!(whenMouseUp) mouseUp;

	/// Override this method in a subclass to handle the mouseMoved event.
	protected void whenMouseMoved(MouseEventArgs e) { }
	/// This event occurs after the mouse has been moved.
	Event!(whenMouseMoved) mouseMoved;

	/// Override this method in a subclass to handle the mouseMoved event.
	protected void whenMouseDragged(MouseEventArgs e) { }
	/// This event occurs after the mouse has been moved.
	Event!(whenMouseDragged) mouseDragged;

	/// Override this method in a subclass to handle the mouseTurned event.
	/// If this event is not stopped, it will be sent to the control's parent.
	protected void whenMouseTurned(MouseTurnedEventArgs e) { }
	/// This event occurs after the mouse wheel has been turned.
	Event!(whenMouseTurned) mouseTurned;

	/// Override this method in a subclass to handle the keyDown event.
	/// If this event is not stopped, it will be sent to the control's parent.
	protected void whenKeyDown(KeyEventArgs e) { }
	/// This event occurs after a key is pressed.
	Event!(whenKeyDown) keyDown;

	/// Override this method in a subclass to handle the keyTyped event.
	/// If this event is not stopped, it will be sent to the control's parent.
	protected void whenKeyTyped(KeyTypedEventArgs e) { }
	/// This event occurs after a character key is pressed.
	Event!(whenKeyTyped) keyTyped;

	/// Override this method in a subclass to handle the keyUp event.
	/// If this event is not stopped, it will be sent to the control's parent.
	protected void whenKeyUp(KeyEventArgs e) { }
	/// This event occurs after a key is released.
	Event!(whenKeyUp) keyUp;

	/// Override this method in a subclass to handle the painting event.
	protected void whenPainting(PaintingEventArgs e) {
		e.graphics.source = backColor;
		e.graphics.paint();
	}
	/// This event occurs when the control needs to be painted.
	Event!(whenPainting) painting;

	/// Override this method in a subclass to handle the focusGained event.
	protected void whenFocusGained(EventArgs e) {
		repaint();
	}
	/// This event occurs after this control is focused.
	Event!(whenFocusGained) focusGained;

	/// Override this method in a subclass to handle the focusLost event.
	protected void whenFocusLost(EventArgs e) {
		repaint();
	}
	/// This event occurs after this control loses focus.
	Event!(whenFocusLost) focusLost;

	this() {
		moved.mainHandler = &whenMoved;
		resized.mainHandler = &whenResized;
		mouseEntered.mainHandler = &whenMouseEntered;
		mouseEntered.dispatcher = &dispatchMouseEntered;
		mouseLeft.mainHandler = &whenMouseLeft;
		mouseDown.mainHandler = &whenMouseDown;
		mouseDown.dispatcher = &dispatchMouseDown;
		mouseUp.mainHandler = &whenMouseUp;
		mouseUp.dispatcher = &dispatchMouseUp;
		mouseMoved.mainHandler = &whenMouseMoved;
		mouseMoved.dispatcher = &dispatchMouseMoved;
		mouseDragged.mainHandler = &whenMouseDragged;
		mouseDragged.dispatcher = &dispatchMouseDragged;
		mouseTurned.mainHandler = &whenMouseTurned;
		mouseTurned.dispatcher = &dispatchMouseTurned;
		keyDown.mainHandler = &whenKeyDown;
		keyDown.dispatcher = &dispatchKeyDown;
		keyTyped.mainHandler = &whenKeyTyped;
		keyTyped.dispatcher = &dispatchKeyTyped;
		keyUp.mainHandler = &whenKeyUp;
		keyUp.dispatcher = &dispatchKeyUp;
		painting.mainHandler = &whenPainting;
		painting.dispatcher = &dispatchPainting;
		focusGained.mainHandler = &whenFocusGained;
		focusLost.mainHandler = &whenFocusLost;

		_location = Point(0, 0);
		_size = Size(100, 100);
		_text = "";
		_focusable = false;
		_focused = false;
		_tabIndex = 0;
		_cursor = Cursor.Arrow;
		_elasticX = false;
		_elasticY = false;

		// TODO: remove these when themes mature
		_foreColor = Color.Black;
		_font = new Font("Tahoma", 11);
	}

	protected Graphics quickCreateGraphics() {
		if(_parent is null)
			return null;
		auto g = _parent.quickCreateGraphics();
		if(g)
			g.translate(location);
		return g;
	}

	/**
	 * Sets the specified Graphics' font and source to this control's font
	 * and foreground color. Also, clips to this control's rectangle.
	 */
	void setupGraphics(Graphics g) {
		g.rectangle(0, 0, width, height);
		g.clip();
		g.font = font;
		g.source = foreColor;
	}

	/**
	 * Creates a Graphics, calls the specified delegate with it, and deletes
	 * it to release resources.
	 */
	void withGraphics(void delegate(Graphics g) dg) {
		auto g = quickCreateGraphics();
		if(!g)
			return;
		setupGraphics(g);
		dg(g);
		delete g;
	}

	/**
	 * Returns whether or not this control can receive focus.
	 */
	bool focusable() {
		return _focusable;
	}
	void focusable(bool f) {
		_focusable = f;
		// TODO:
	}

	/**
	 * Returns whether this control currently has focus. A control with focus
	 * receives keyboard events.
	 */
	bool focused() {
		return getFocusedControl() is this;
	}

	/**
	 * Returns true if this control should visually show when it has focus
	 * and returns false if not. Focus is usually hidden until the
	 * user uses the keyboard to navigate.
	 *
	 * A text box is one control that shows when it is
	 * focused (by its caret), regardless of this value. (Because showing
	 * focus isn't the sole purpose of a caret.)
	 */
	bool showFocus() {
		auto top = getTopLevel();
		return top && (cast(Window)top).showFocus;
	}

	/**
	 * Gets or sets this control's tab index. The tab index of controls
	 * decides in what order they are focused when the tab key is pressed.
	 * If multiple controls in a window have the same tab index, focus is
	 * changed based on the order they were added to the window.
	 * The default is 0.
	 */
	int tabIndex() {
		return _tabIndex;
	}
	/// ditto
	void tabIndex(int i) {
		_tabIndex = i;
	}

	/**
	 *
	 */
	void focus() {
		if(!_focusable)
			return;

		auto top = getTopLevel();
		if(!top)
			return;
		if(auto win = cast(Window)top)
			win.focusedControl = this;
	}

	/**
	 * Returns whether this control is on the screen. A control is
	 * on screen if one of its ancestors is a top level window. Whether or
	 * not the control is visible has no bearing on this value. If a control
	 * has no parent, then it is clearly not on the screen.
	 */
	bool onScreen() {
		return _parent && _parent.onScreen;
	}

	/**
	 * Gets the location of this control in screen coordinates. An exception is
	 * thrown if this control is not on the screen.
	 */
	Point screenLocation() {
		if(!_parent)
			throw new Exception("control is not on screen");
		return _parent.screenLocation + location;
	}

	/**
	 * Converts the specified point in content coordinates into screen
	 * coordinates. An exception is thrown if this control is not on the screen.
	 */
	Point contentToScreen(Point pt) { // TODO: content?? even on Window??
		if(!_parent)
			throw new Exception("control is not on screen");
		return _parent.contentToScreen(pt + location);
	}

	/**
	 * Converts the specified point in screen coordinates into content
	 * coordinates. An exception is thrown if this control is not on the screen.
	 */
	Point screenToContent(Point pt) {
		if(!_parent)
			throw new Exception("control is not on screen");
		return _parent.screenToContent(pt) - location; // TODO: borders
	}

	/**
	 * Converts the specified point in this control's content coordinates
	 * into the specified control's content coordinates. An exception is
	 * thrown if this control is not on the screen.
	 */
	Point contentToContent(Point pt, Control c) {
		return c.screenToContent(contentToScreen(pt));
	}

	/**
	 * Returns whether the specified point is inside this control.
	 */
	bool contains(Point pt) {
		return pt.x >= 0 && pt.y >= 0 && pt.x < width && pt.y < height;
	}
	/// ditto
	bool contains(real x, real y) {
		return contains(Point(x, y));
	}

	/**
	 * Returns true if this control is a top-level control and false otherwise.
	 * Top-level controls do not have parents. Non-top-level controls can only
	 * be shown on the screen by adding them as children to a top-level control.
	 * Currently, the only top-level control is Window.
	 */
	bool topLevel() { return false; }
	// TODO: return NativeControl/Window?
	/**
	 * Loops over this control's ancestors, and if a top-level control is found,
	 * it is returned. If this control does not have a top-level ancestor,
	 * null is returned.
	 */
	Control getTopLevel() {
		Control c = this;
		while(c.parent)
			c = c.parent;
		return c.topLevel ? c : null;
	}

	/**
	 * Gets this control's parent.
	 */
	Container parent() { return _parent; }
	package void parent(Container c) {
		_parent = c;
		//parentChanged(new EventArgs); // TODO: add event
	}

	/**
	 * Calls the specified delegate with each of this control's ancestors,
	 * starting with its parent and moving up. Returns the first ancestor
	 * that the delgate returns true for. If none are found, returns null.
	 */
	Container findAncestor(bool delegate(Container) dg) {
		Container anc = parent;
		while(anc) {
			if(dg(anc))
				return anc;
			anc = anc.parent;
		}
		return null;
	}

	/**
	 * Gets or sets the location of this control in its parent's content
	 * coordinates.
	 * Examples:
	 * -----
	 * control.location = [5, 35];
	 * control.location = Point(50, 50);
	 * -----
	 */
	Point location() { return _location; }
	/// ditto
	void location(Point pt) {
		if((cast(Window)_parent) !is null)
			throw new Exception("cannot set location of a window's content");
		pt.x = round(pt.x);
		pt.y = round(pt.y);
		repaint();
		_location = pt;
		repaint();
		moved(new EventArgs);
	}
	/// ditto
	void location(real[] pt) {
		assert(pt.length == 2, "pt must be just an x and y");
		location = Point(pt[0], pt[1]);
	}

	/**
	 * Gets or sets the size of this control.
	 * Examples:
	 * -----
	 * control.size = [75, 23];
	 * control.size = Size(80, 20);
	 * -----
	 */
	Size size() { return _size; }
	/// ditto
	void size(Size newSize) {
		if(newSize.width < 0)
			newSize.width = 0;
		if(newSize.height < 0)
			newSize.height = 0;
		newSize.width = round(newSize.width);
		newSize.height = round(newSize.height);
		repaint();
		_size = newSize;
		repaint();
		resized(new EventArgs);
	}
	/// ditto
	void size(real[] newSize) {
		assert(newSize.length == 2, "size must be just a width and height");
		size = Size(newSize[0], newSize[1]);
	}

	/**
	 * Gets the size at which this control looks the best. It is intended that
	 * the control not be made smaller than this size, and only be made larger
	 * if it is elastic, or if it needs to be aligned with other controls.
	 *
	 * This property should be overridden in subclasses to return a best size.
	 */
	Size bestSize() { return Size(100, 100); }

	/**
	 * Gets the distance from the top of this control to the baseline of
	 * the first line of this control's text. If this control does not have
	 * text, 0 may be returned.
	 */
	int baseline() { return 0; }

	/// Same as location.x
	real x() { return location.x; }
	/// Same as location.y
	real y() { return location.y; }
	/// Same as size.width
	real width() { return size.width; }
	/// Same as size.height
	real height() { return size.height; }

	/**
	 * Gets or sets whether this control is elastic horizontally or vertically.
	 * If a control is elastic, then it is intended to be made larger than its
	 * best size.
	 */
	bool elasticX() { return _elasticX; }
	/// ditto
	void elasticX(bool b) { _elasticX = b; }
	/// ditto
	bool elasticY() { return _elasticY; }
	/// ditto
	void elasticY(bool b) { _elasticY = b; }

	/**
	 * Gets or sets the text that this control shows.
	 */
	string text() { return _text.dup; }
	/// ditto
	void text(string str) {
		_text = str.dup;
		repaint();
		//TextChanged(EventArgs e) // TODO: add event
	}

	/**
	 * Gets or sets the background color of this control.
	 */
	Color backColor() { return _backColor; }
	/// ditto
	void backColor(Color c) {
		_backColor = c;
		repaint();
	}

	/**
	 * Gets or sets the foreground color of this control.
	 */
	Color foreColor() { return _foreColor; }
	/// ditto
	void foreColor(Color c) {
		_foreColor = c;
		repaint();
	}

	/**
	 * Gets or sets the font of this control uses to display text. A value of
	 * null means that the font is unset. When the font is null, the
	 * current theme's font is used. The default is null.
	 */
	Font font() {
		// TODO: if font is null (unset), return from theme
		//if(font is null)
		//	return Theme.Current.Control_Font(this);
		//else
		return _font;
	}
	/// ditto
	void font(Font f) {
		_font = f;
		repaint();
	}

	void setCurrentCursor(Cursor cur) {
		if(parent)
			parent.setCurrentCursor(cur);
	}
	/**
	 * Gets or sets the mouse cursor that will be shown when the mouse
	 * is over this control.
	 */
	Cursor cursor() {
		return _cursor;
	}
	/// ditto
	void cursor(Cursor cur) {
		if(_cursor is cur)
			return;
		_cursor = cur;
		if(getHotControl() is this)
			setCurrentCursor(_cursor);
	}

	/**
	 * Causes the part of the control inside the specified
	 * rectangle to be repainted. The rectangle is in content coordinates.
	 *
	 * The control will not be repainted before this method returns; rather,
	 * the area is just marked as needing to be repainted. The next time there
	 * are no other system events to be processed, a painting event will
	 * be called.
	 */
	void repaint(Rect rect) {
		// TODO: make sure that parts clipped off by the parent are
		//       not invalidated
		if(_parent)
			_parent.repaint(rect + location);
	}
	/// ditto
	void repaint(real x, real y, real width, real height) {
		repaint(Rect(x, y, width, height));
	}
	/**
	 * Causes the entire control to be repainted.
	 */
	void repaint() {
		repaint(Rect(0, 0, width, height));
	}
}

/**
 * Sets the tabIndex of each control to be subsequent numbers. The first control
 * will have an index of startIndex.
 */
void setTabOrder(Control[] controls...) {
	setTabOrder(0, controls);
}
/// ditto
void setTabOrder(int startIndex, Control[] controls...) {
	foreach(c; controls)
		c.tabIndex = startIndex++;
}

unittest {
	auto c1 = new Control;
	auto c2 = new Control;
	auto c3 = new Control;

	// test setTabOrder()
	setTabOrder(c1, c2, c3);
	assert(c1.tabIndex == 0);
	assert(c2.tabIndex == 1);
	assert(c3.tabIndex == 2);

	c1.withGraphics((Graphics g) { g.source = Color.Blue; });
}

