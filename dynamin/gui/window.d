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

module dynamin.gui.window;

import dynamin.c.cairo;
import dynamin.all_core;
import dynamin.all_painting;
import dynamin.all_gui;
import dynamin.gui.control;
import dynamin.gui.cursor;
import dynamin.gui_backend;
import dynamin.gui.container;
import dynamin.gui.events;
import tango.io.Stdout;
import tango.core.Exception;
import tango.core.Thread;

///
static class Application {
static:
	mixin ApplicationBackend;
	package Thread eventThread;
	/// Starts event processing. Must be called from main().
	void run(Window w = null) {
		Window.hasProcessedEvents = true;

		auto thread = Thread.getThis();
		assert(eventThread is null || eventThread is thread,
			"Application.run called from two different threads");
		eventThread = thread;

		backend_run(w);
	}
	/**
	 * Calls the specified delegate on the event thread and returns without
	 * waiting for the delegate to finish. Since the delegate is not called
	 * immediately, it must not live on the stack. Instead, it could be a
	 * method of a class. In D2, delegates generally are on the heap.
	 */
	void invoke(void delegate() dg) {
		backend_invoke(dg);
	}
	/**
	 * Calls the specified delegate on the event thread and blocks until
	 * the delegate finishes.
	 */
	void invokeNow(void delegate() dg) {
		backend_invokeNow(dg);
	}
}

///
enum DialogResult {
	///
	OK,
	///
	Yes,
	///
	No,
	///
	Cancel,
	///
	Custom
}

///
enum Position {
	/// Specifies being at the top-left corner.
	TopLeft,
	/// Specifies being centered between the top-left corner and the top-right corner.
	Top,
	/// Specifies being at the top-right corner.
	TopRight,
	/// Specifies being centered between the top-left corner and the bottom-left corner.
	Left,
	/// Specifies being centered between all corners.
	Center,
	/// Specifies being centered between the top-right corner and the bottom-right corner.
	Right,
	/// Specifies being at the bottom-left corner.
	BottomLeft,
	/// Specifies being centered between the bottom-left corner and the bottom-right corner.
	Bottom,
	/// Specifies being at the bottom-right corner.
	BottomRight
}

/**
 * The different types of borders that a window may have.
 * These do not affect whether the window is resizable--
 * use Window.Resizable for that.
 */
enum WindowBorderStyle {
	/** Specifies that the window has no border around the content area. */
	None,
	/**
	 * Specifies that the window has a normal border with a title bar, icon,
	 * and minimize button.
	 */
	Normal,
	/** Specifies that the window has a normal border without a minimize button. */
	Dialog,
	/** Specifies that the window has the border of a floating tool box. */
	Tool
}

alias List!(Control) ControlList;
//Frames and Dialogs are identical except that Dialogs do not have minimize and
//maximize buttons, are not shown on the taskbar, and can be modal.
/**
 * A window is a top level control that has no parent. Its location is relative
 * to the top-left corner of the screen.
 * A window can have no border, the border of a normal window, or the border
 * of a tool window.
 *
 * The appearance of a window with Windows Classic:
 *
 * $(IMAGE ../web/example_window.png)
 */
class Window : Container {
	private static hasProcessedEvents = false;
	~this() { // this should be a static ~this, but I get a circular dep error
		if(!hasProcessedEvents) {
			Stdout("Warning: a window was created, but Application.run");
			Stdout(" was not called to process events").newline;
		}
	}
protected:
	mixin WindowBackend;
	BorderSize _borderSize;
	Window _owner;
	WindowBorderStyle _borderStyle;
	bool _resizable = true;
	Container _content;
	Control _focusedControl;
	package Control focusedControl() { return _focusedControl; }
	package void focusedControl(Control c) {
		_focusedControl = c;
	}
	override void dispatchPainting(PaintingEventArgs e) {
		Theme.current.Window_paint(this, e.graphics);
		super.dispatchPainting(e);
	}
public:
	this() {
		_children = new ControlList();
		content = new Panel;

		_visible = false;
		_minSize = Size(0, 0);
		_maxSize = Size(0, 0);
		_borderStyle = WindowBorderStyle.Normal;
		recreateHandle();
	}
	this(string text) {
		this();
		this.text = text;
	}

	void content(Container panel) {
		if(panel is null)
			throw new IllegalArgumentException("content must not be null");
		// TODO: remove handlers
		super.remove(panel);
		super.add(_content = panel);
		_content.resized += &whenContentResized;
		_content.minSizeChanged += &whenContentMinSizeChanged;
		_content.maxSizeChanged += &whenContentMaxSizeChanged;

		auto best = _content.bestSize;
		_content.minSize = best;
		_content.maxSize = Size(_content.elasticX ? 0 : best.width,
		                        _content.elasticY ? 0 : best.height);
		resizable = _content.maxSize != best; // avoid calling elasticX/Y again
		_content.size = best;

	}
	bool ignoreResize;
	void whenContentResized(EventArgs e) {
		if(ignoreResize)
			return;
		ignoreResize = true;
		size = _content.size + _borderSize;
		ignoreResize = false;
	}
	void whenContentMinSizeChanged(EventArgs e) {
		if(!handleCreated)
			return;
		backend_contentMinSizeChanged;
	}
	void whenContentMaxSizeChanged(EventArgs e) {
		if(!handleCreated)
			return;
		backend_contentMaxSizeChanged;
	}
	override void whenResized(EventArgs e) {
		if(ignoreResize)
			return;
		_content._location = Point(_borderSize.left, _borderSize.top);
		ignoreResize = true;
		_content.size = _size-_borderSize;
		ignoreResize = false;
	}
	Container content() {
		return _content;
	}

	/**
	 * If the handle has not yet been created, calling this will cause it to be.
	 * Under the Windows backend, returns a HWND.
	 * Under the X backend, returns a Window.
	 * Returns: the backend specific native handle.
	 */
	typeof(_handle) handle() {
		if(!handleCreated)
			recreateHandle();
		assert(Thread.getThis() is Application.eventThread ||
				Application.eventThread is null,
			"Controls must be accessed and changed only on the event thread. Use invokeNow() from other threads.");
		return _handle;
	}

	bool handleCreated() { return backend_handleCreated; }

	void recreateHandle() {
		backend_recreateHandle();
	}

	override protected Graphics quickCreateGraphics() {
		if(!handleCreated)
			return null;
		return backend_quickCreateGraphics();
	}
	override bool onScreen() {
		return true;
	}
	override Point screenLocation() {
		return location;
	}
	override Point contentToScreen(Point pt) {
		return pt + location;
	}
	override Point screenToContent(Point pt) {
		return pt - location;
	}
	override bool topLevel() { return true; }
	override Container parent() { return null; }
	// TODO: because you should always be able to click a window from
	//       the taskbar, then show it on taskbar if window has an owner,
	//       but don't if it does not
	void owner(Window w) {
		_owner = w;
		if(!handleCreated)
			return;
		recreateHandle();
	}
	Window owner() { return _owner; }
	alias Control.visible visible;
	void visible(bool b) {
		_visible = b;
		backend_visible = b;
	}

	/**
	 * Gets or sets what border this window will have around its contents.
	 * The default is WindowBorderStyle.Normal.
	 */
	WindowBorderStyle borderStyle() { return _borderStyle; }
	/// ditto
	void borderStyle(WindowBorderStyle border) {
		if(border > WindowBorderStyle.Tool)
			throw new IllegalArgumentException("Window.borderStyle(): invalid border style");
		_borderStyle = border;
		backend_borderStyle = border;
	}

	override void setCurrentCursor(Cursor cur) {
		if(!handleCreated)
			return;
		backend_setCurrentCursor(cur);
	}

	alias Control.repaint repaint;
	void repaint(Rect rect) {
		if(!handleCreated)
			return;
		backend_repaint(rect);
	}

	/**
	 * An array of rectangles in screen coordinates that the window will be
	 * snapped to.
	 */
	Rect[] snapRects = null;
	/**
	 * Convenience method that sets SnapRects to an array
	 * with just the specified Rect.
	 */
	void snapRect(Rect rect) {
		snapRects = [rect];
	}

	/**
	 * The SnapDistance specifies how close a window has to be to a
	 * snap rectangle for the window to snap to it. The default is 10 pixels.
	 */
	uint snapDistance = 10;

	/**
	 * Gets or sets whether this window can be resized by the user.
	 * The default is true.
	 */
	bool resizable() { return _resizable; }
	/// ditto
	void resizable(bool b) { // TODO: set based upon whether content is elastic?
		_resizable = b;
		if(!handleCreated)
			return;
		backend_resizable = b;
	}

	// TODO: 1.0  MinSize -> contentMinSize  MaxSize -> contentMaxSize
	alias Control.location location;
	void location(Point pt) {
		super.location(pt);
		if(!handleCreated)
			return;
		backend_location = pt;
	}
	alias Control.size size;
	void size(Size size) {
		super.size(size);
		_content.size = size - _borderSize;
		if(!handleCreated)
			return;
		backend_size = size;
	}
	/**
	 * Gets the size of the border/frame around this window.
	 */
	BorderSize borderSize() {
		return _borderSize;
	}
	alias Control.text text;
	void text(string str) {
		super.text(str);
		if(!handleCreated)
			return;
		backend_text = str;
	}

	/**
	 * Moves this window to the specified position relative to
	 * the specified control. If no control is specified, the
	 * window is positioned relative to the screen.
	 */
	void position(Position pos, Control c = null) {
		Rect rect;
		if(c && c.onScreen) {
			rect = c.screenLocation + c.size;
		} else {
			rect = desktopRect;
		}
		Point newLoc = Point();
		switch(pos) {
		case Position.TopLeft:
		case Position.Left:
		case Position.BottomLeft:
			newLoc.x = rect.x;
			break;
		case Position.Top:
		case Position.Center:
		case Position.Bottom:
			newLoc.x = rect.x + (rect.width - width)/2;
			break;
		case Position.TopRight:
		case Position.Right:
		case Position.BottomRight:
			newLoc.x = rect.x + rect.width - width;
			break;
		}
		switch(pos) {
		case Position.TopLeft:
		case Position.Top:
		case Position.TopRight:
			newLoc.y = rect.y;
			break;
		case Position.Left:
		case Position.Center:
		case Position.Right:
			newLoc.y = rect.y + (rect.height - height)/2;
			break;
		case Position.BottomLeft:
		case Position.Bottom:
		case Position.BottomRight:
			newLoc.y = rect.y + rect.height - height;
			break;
		}
		location = newLoc;
	}
}

