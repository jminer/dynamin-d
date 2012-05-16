
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.gui.action;

import dynamin.all_core;
import dynamin.all_gui;
import tango.util.collection.HashMap;

/**
 * TODO: change to struct with D 2.0 and use ref return on ActionMap.addAction
 *       might not be possible...probably have to keep class
 */
class Action {
	/// The non-visible name of the action
	string name; // no setter for this ...set with constructor
	/// The text displayed on the menu item, tool bar button, etc.
	string text;
	///
	string shortcut; // TODO: how to store string and key/modifiers?
	/**
	 * The icon displayed on the menu item, tool bar button, etc.
	 * Icons for disabled and hot controls are created automatically
	 * using the current theme.
	 */
	string icon; // TODO: allow setting hot and disabled icons to override
	///
	void delegate() invoke;
	/**
	 * If toggle is true, then this action can be selected and deselected.
	 */
	bool toggle = false;
	/**
	 * Has no effect unless toggle is set to true.
	 * If the group is the default, the action can be selected/deselected
	 * regardless of other actions. If the group is set to another value, then
	 * selecting this action will deselect other actions with the same group.
	 */
	// TODO: the deselecting of other actions w/same group should look through
	//       the ActionMap...will need ref
	int group = -1; // TODO: a string is a lot easier to avoid conflicts
	///
	bool selected = false;
	///
	bool enabled;
	// TODO: need to make getters and setters...have to fire event when changed
}

/**
 * Example:
 * -----
 * with(actionMap.addAction("data-viewer")) {
 *     text = "Data Viewer";
 *     shortcut = "Ctrl+D";
 *     icon = "data-viewer.png";
 *     toggle = true;
 *     group = 2;
 *     invoke = {
 *         new DataViewerDialog().show();
 *     };
 * }
 * -----
 */
class ActionMap : HashMap!(string, Action) {
	Action addAction(string name) {
		assert(!name.contains(' '), "action name cannot contain space");
		Action a = new Action(name);
		add(name, a);
	}
}

unittest {
	//
}

