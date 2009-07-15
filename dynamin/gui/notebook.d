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

module dynamin.gui.notebook;

import dynamin.core.event;
import dynamin.core.list;
import dynamin.all_gui;
import dynamin.all_painting;
import dynamin.core.string;
import tango.core.Exception;

///
class TabPage {
protected:
	string _text;
	Control _content;
	Point _tabLocation;
	Size _tabSize;
public:
	/**
	 * Gets or sets the text displayed on the tab of this tab page.
	 */
	string text() { return _text; }
	/// ditto
	void text(string str) { _text = str; }
	/**
	 * Gets or sets the control that is shown in this tab page.
	 */
	Control content() { return _content; }
	/// ditto
	void content(Control c) { _content = c; }
	Point tabLocation() { return _tabLocation; }
	void tabLocation(Point pt) { _tabLocation = pt; }
	Size tabSize() { return _tabSize; }
	void tabSize(Size sz) { _tabSize = sz; }
}

/**
 * A notebook is a control that has tabs and changes what it displays
 * depending upon which tab is selected.
 *
 * The appearance of a notebook with Windows Classic:
 *
 * $(IMAGE ../web/example_notebook.png)
 */
class Notebook : Container {
protected:
	List!(TabPage) _tabPages;
	int _selectedIndex = -1;
	bool _multipleLines = true;
	Control _content;
	package int _tabAreaSize;
	override void whenMouseDown(MouseEventArgs e) {
		if(e.button != MouseButton.Left)
			return;
		foreach(i, page; _tabPages) {
			if((page.tabLocation+page.tabSize).contains(e.location))
				selectedIndex = i;
		}
	}
	override void whenPainting(PaintingEventArgs e) {
		Theme.current.Notebook_paint(this, e.graphics);
		foreach(page; _tabPages) {
			if(page is selectedTabPage)
				continue;

			Theme.current.Tab_paint(page, this, e.graphics);
		}
		Theme.current.Tab_paint(selectedTabPage, this, e.graphics);
	}
	void whenTabPagesChanged() {
		if(_tabPages.count == 0)
			selectedIndex = -1;
		else if(selectedIndex == -1)
			selectedIndex = 0;
		layout();
	}
public:
	/// Override this method in a subclass to handle the SelectionChanged event.
	protected void whenSelectionChanged(EventArgs e) {
		if(_content !is null)
			_children.remove(_content);
		_content = null;
		if(_selectedIndex >= 0) {
			_content = selectedTabPage.content;
			add(_content);
		}
		layout();
	}
	/// This event occurs after a different tab is selected.
	Event!() selectionChanged;

	this() {
		selectionChanged = new Event!()(&whenSelectionChanged);

		_tabPages = new List!(TabPage)(&whenTabPagesChanged);
		_focusable = true;
	}
	override void layout() {
		_tabAreaSize = 20;
		int x = 2;
		foreach(page; _tabPages) {
			page.tabLocation = Point(x, 2);
			page.tabSize = Size(70, 18);
			x += 70;
		}
		if(_content) {
			auto border = Theme.current.Notebook_borderSize(this);
			_content.location = [border.left, _tabAreaSize+border.top];
			_content.size = [width-border.left-border.right, height-border.top-border.bottom-_tabAreaSize];
		}
	}
	/**
	  * Gets the tab pages displayed in this notebook.
	  * Examples:
	  * -----
	  * TabPage advancedPage = new TabPage;
	  * advancedPage.text = "Advanced";
	  * advancedPage.content = advancedPanel; // a previously created Panel
	  * tabbedView.TabPages.Add(advancedPage);
	  * -----
	  */
	List!(TabPage) tabPages() { return _tabPages; }
	/**
	 * Gets or sets the selected tab using its index. An index of -1 means
	 * there is no selected tab.
	 */
	int selectedIndex() { return _selectedIndex; }
	/// ditto
	void selectedIndex(int index) {
		if(index < -1)
			throw new IllegalArgumentException("index cannot be less than -1");
		_selectedIndex = index;
		selectionChanged(new EventArgs);
	}

	/**
	  * Gets or sets the selected tab using its tab page.
	  * A value of null means there is no selected tab.
	  * A specified tab page must be in the TabPages list.
	  */
	TabPage selectedTabPage() {
		if(_selectedIndex == -1)
			return null;
		else
			return _tabPages[_selectedIndex];
	}
	/// ditto
	void selectedTabPage(TabPage p) {
		if(p is null) {
			selectedIndex = -1;
			return;
		}
		foreach(i, page; _tabPages) {
			if(p is page) {
				selectedIndex = i;
				break;
			}
		}
		// if here, do nothing
	}

	bool multipleLines() { return _multipleLines; }
	void multipleLines(bool b) {
		if(b == false)
			throw new Exception("sorry, MultipleLines = false not implemented");
		_multipleLines = b;
	}
}

