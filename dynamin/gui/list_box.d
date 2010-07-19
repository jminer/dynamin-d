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

module dynamin.gui.list_box;

import dynamin.all_painting;
import dynamin.all_core;
import dynamin.all_gui;

/**
 * A control that shows a list of items that can be selected.
 *
 * The appearance of a list box with Windows Classic:
 *
 * $(IMAGE ../web/example_list_box.png)
 */
class ListBox : Scrollable {
protected:
	List!(string, true) _items;
	int _selectedIndex = -1;

	override void whenKeyDown(KeyEventArgs e) {
			if(e.key == Key.Down) {
				if(selectedIndex + 1 < _items.count)
					selectedIndex = selectedIndex + 1;
			} else if(e.key == Key.Up) {
				if(selectedIndex - 1 >= 0)
					selectedIndex = selectedIndex - 1;
			}
		}
	override Size bestSize() {
		return Size(0, 13*_items.count);
	}
	override void whenContentPainting(PaintingEventArgs e) {
		with(e.graphics) {
			source = backColor;
			paint();
			auto clip = getClipExtents();
			int start = cast(int)clip.y/13, end = cast(int)clip.bottom/13+1;
			for(int i = start; i < _items.count && i < end; ++i) {
				source = Color.Black;
				if(i == _selectedIndex) {
					// TODO: hack
					//Source = WindowsTheme.getColor(dynamin.c.windows.COLOR_HIGHLIGHT);
					rectangle(0, i*13, width, 13);
					fill();
					//Source = WindowsTheme.getColor(dynamin.c.windows.COLOR_HIGHLIGHTTEXT);
				}
				drawText(_items[i], 3, i*13);
			}
		}
	}
	override void whenContentMouseDown(MouseEventArgs e) {
		focus();
		selectedIndex = cast(int)e.y/13;
	}
public:

	/// Override this method in a subclass to handle the selectionChanged event.
	protected void whenSelectionChanged(EventArgs e) { }
	/// This event occurs after the selection has changed.
	Event!(whenSelectionChanged) selectionChanged;

	void whenListItemsChanged(ListChangeType, string, string, uint) {
		super.layout();
		repaint();
	}

	///
	this() {
		selectionChanged.setUp(&whenSelectionChanged);
		_items = new List!(string, true)(&whenListItemsChanged);

		super();
		_focusable = true;
		// TODO: hack
		backColor = WindowsTheme.getColor(5);
	}
	///
	List!(string, true) items() {
		return _items;
	}
	///
	int selectedIndex() { return _selectedIndex; }
	/// ditto
	void selectedIndex(int i) {
		if(i == _selectedIndex)
			return;
		_selectedIndex = i;
		repaint();
		selectionChanged(new EventArgs);
	}
}

