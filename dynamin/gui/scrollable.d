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
 * Portions created by the Initial Developer are Copyright (C) 2007-2009
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Jordan Miner <jminer7@gmail.com>
 *
 */

module dynamin.gui.scrollable;

import dynamin.all_core;
import dynamin.all_painting;
import dynamin.all_gui;
import tango.io.Stdout;

///
enum VisibleScrollBars {
	/**
	  * Shows a vertical scroll bar when it is needed. A horizontal scroll bar
	  * is never shown. A text box with line wrap turned on could use this
	  * option.
	  */
	Vertical,
	/**
	  * Shows a horizontal scroll bar when it is needed. A vertical scroll bar
	  * is never shown. The list view in Windows Explorer could use this option.
	  */
	Horizontal,
	/**
	 * Shows either scroll bar when it is needed.
	 * A control, such as the detail view in Windows Explorer, that changes its
	 * width when not being scrolled should use this option.
	 */
	Each,
	/**
	  * Shows both scroll bars when both are needed.
	  * A control, such as a text box, that changes its width based upon
	  * where it is scrolled to should use this option.
	  */
	Both,
	/**
	  * Does not show any scroll bars, even if they are needed.
	  * A single-line text box uses this option.
	  */
	None
}

class ScrollableClipper : Control {
protected:
	override void whenPainting(PaintingEventArgs e) {
		auto par = cast(Scrollable)_parent;
		e.graphics.fillRule = GraphicsFillRule.EvenOdd;
		e.graphics.rectangle(Rect(0, 0, width, height));
		e.graphics.rectangle(par.contentVisibleRect);
		e.graphics.clip();
		e.graphics.source = par.foreColor;
		Theme.current.Scrollable_paint(par, e.graphics);
	}
public:
	override bool contains(Point pt) {
		auto par = cast(Scrollable)_parent;
		if(par is null)
			return false;
		return !par.contentVisibleRect.contains(pt);
	}
}

class ScrollableContent : Panel {
private:
	Scrollable sc;
	package this(Scrollable s) {
		sc = s;
	}
protected:
	public override Size bestSize() {
		return sc.contentBestSize;
	}
	override void whenMoved(EventArgs e) {
		sc.whenContentMoved(e);
	}
	override void whenResized(EventArgs e) {
		sc.whenContentResized(e);
	}
	override void whenMouseEntered(EventArgs e) {
		sc.whenContentMouseEntered(e);
	}
	override void whenMouseLeft(EventArgs e) {
		sc.whenContentMouseLeft(e);
	}
	override void whenMouseDown(MouseEventArgs e) {
		sc.whenContentMouseDown(e);
	}
	override void whenMouseUp(MouseEventArgs e) {
		sc.whenContentMouseUp(e);
	}
	override void whenMouseMoved(MouseEventArgs e) {
		sc.whenContentMouseMoved(e);
	}
	override void whenMouseDragged(MouseEventArgs e) {
		sc.whenContentMouseDragged(e);
	}
	override void whenPainting(PaintingEventArgs e) {
		sc.whenContentPainting(e);
	}
}

/**
 * Here is a skeleton implementation of a scrollable control:
 * -----
 * class YourControl : Scrollable {
 *   protected override void whenContentPainting(PaintingEventArgs e) {
 * 	   with(e.graphics) {
 * 	     drawText("Hello World", 5, 5);
 * 	   }
 *   }
 * }
 * -----
 */
abstract class Scrollable : Container {
private:
	Panel _content;
protected:
	VisibleScrollBars _scrollBars;
	ScrollBar _hScrollBar, _vScrollBar;
	ScrollableClipper _clipper;

	real _sbSize;
	real _leftControlsWidth, _topControlsHeight;
	// the area the content could be shown if no scroll bars
	Rect _availableRect;
	// the area the content is actually visible, after scroll bars are
	// taken into account
	Rect _visibleRect;
	bool _hVisible, _vVisible;
	override void whenMouseTurned(MouseTurnedEventArgs e) {
		_vScrollBar.value = _vScrollBar.value + cast(int)(10*e.scrollAmount);
	}

	Size contentBestSize() { return Size(0, 0); } ///
	void whenContentMoved(EventArgs e) { } ///
	void whenContentResized(EventArgs e) { } ///
	void whenContentMouseEntered(EventArgs e) { } ///
	void whenContentMouseLeft(EventArgs e) { } ///
	void whenContentMouseDown(MouseEventArgs e) { } ///
	void whenContentMouseUp(MouseEventArgs e) { } ///
	void whenContentMouseMoved(MouseEventArgs e) { } ///
	void whenContentMouseDragged(MouseEventArgs e) { } ///
	void whenContentPainting(PaintingEventArgs e) { } ///

	this() {
		_elasticX = true;
		_elasticY = true;

		_scrollBars = VisibleScrollBars.Each;
		//content = c;
		_content = new ScrollableContent(this);
		_content.location = [borderSize.left, borderSize.top];
		add(_content);

		_clipper = new ScrollableClipper;
		add(_clipper);

		_vScrollBar = new VScrollBar;
		_vScrollBar.valueChanged += &whenValueChanged;
		_hScrollBar = new HScrollBar;
		_hScrollBar.valueChanged += &whenValueChanged;
		layout();
	}
	void whenValueChanged(EventArgs e) {
		_content.location = [_visibleRect.x-_hScrollBar.value, _visibleRect.y-_vScrollBar.value];
	}
public:
	override void layout() {
		_sbSize = Theme.current.ScrollBar_size;
		_leftControlsWidth = 0;
		//foreach(c; leftControls)
		//	total += c.bestSize.width;
		_topControlsHeight = 0;
		//foreach(c; topControls)
		//	total += c.bestSize.height;
		_availableRect = Rect(0, 0, width, height) - borderSize -
			BorderSize(_leftControlsWidth, _topControlsHeight, 0, 0);
		_hVisible = HScrollBarVisible;
		_vVisible = VScrollBarVisible;
		_visibleRect = _availableRect;
		if(_hVisible)
			_visibleRect.height = _visibleRect.height - _sbSize;
		if(_vVisible)
			_visibleRect.width = _visibleRect.width - _sbSize;

		remove(_hScrollBar);
		remove(_vScrollBar);
		if(_hVisible)
			add(_hScrollBar);
		if(_vVisible)
			add(_vScrollBar);

		_content.size = _content.bestSize;
		if(_content.width < _visibleRect.width)
			_content.size = Size(_visibleRect.width, _content.height);
		if(_content.height < _visibleRect.height)
			_content.size = Size(_content.width, _visibleRect.height);
		_clipper.size = size;

		_vScrollBar.maxValue = cast(int)(_content.height-_visibleRect.height);
		_vScrollBar.visibleValue = _visibleRect.height/_content.height;
		_hScrollBar.maxValue = cast(int)(_content.width-_visibleRect.width);
		_hScrollBar.visibleValue = _visibleRect.width/_content.width;

		_vScrollBar.location = [_visibleRect.right, _visibleRect.y];
		_vScrollBar.size = [_sbSize, _visibleRect.height];
		_hScrollBar.location = [_visibleRect.x, _visibleRect.bottom];
		_hScrollBar.size = [_visibleRect.width, _sbSize];

		whenValueChanged(null);
	}
	/**
	 * Gets or sets which scroll bars are shown. The default is Each.
	 */
	VisibleScrollBars visibleScrollBars() { return _scrollBars; }
	/// ditto
	void visibleScrollBars(VisibleScrollBars bars) { // TODO: rename? SBPolicy?
		_scrollBars = bars;
	}
	/**
	 * Gets whether the horizontal scroll bar is currently shown.
	 */
	bool HScrollBarVisible() {
		switch(_scrollBars) {
		case VisibleScrollBars.None:
		case VisibleScrollBars.Vertical:
			return false;
		case VisibleScrollBars.Horizontal:
			return _content.bestSize.width > _availableRect.width;
		case VisibleScrollBars.Each:
			// if vertical scroll bar shown
			if(_content.bestSize.height > _availableRect.height)
				return _content.bestSize.width > _availableRect.width-_sbSize;
			else
				return _content.bestSize.width > _availableRect.width;
		case VisibleScrollBars.Both:
			return _content.bestSize.width > _availableRect.width ||
				_content.bestSize.height > _availableRect.height;
		}
	}
	/**
	 * Gets whether the vertical scroll bar is currently shown.
	 */
	bool VScrollBarVisible() {
		switch(_scrollBars) {
		case VisibleScrollBars.None:
		case VisibleScrollBars.Horizontal:
			return false;
		case VisibleScrollBars.Vertical:
			return _content.bestSize.height > _availableRect.height;
		case VisibleScrollBars.Each:
			// if horizontal scroll bar shown
			if(_content.bestSize.width > _availableRect.width)
				return _content.bestSize.height > _availableRect.height-_sbSize;
			else
				return _content.bestSize.height > _availableRect.height;
		case VisibleScrollBars.Both:
			return _content.bestSize.height > _availableRect.height ||
				_content.bestSize.width > _availableRect.width;
		}
	}
	/**
	 * Gets the combined width of all the controls docked on the left side of
	 * this scrollable.
	 */
	real leftControlsWidth() {
		return _leftControlsWidth;
	}
	/**
	 * Gets the combined height of all the controls docked on the top side of
	 * this scrollable.
	 */
	real topControlsHeight() {
		return _topControlsHeight;
	}

	/// Returns the area inside the border, scroll bars, and any controls on the side.
	Rect contentVisibleRect() {
		return _visibleRect;
	}
	Panel content() { return _content; }
	BorderSize borderSize() {
		return Theme.current.Scrollable_borderSize(this);
	}
}

