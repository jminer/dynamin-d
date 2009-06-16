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

module dynamin.gui.layout;

import dynamin.all_gui;
import dynamin.gui.control;
import dynamin.all_painting;
import dynamin.core.string;
import tango.io.Stdout;
import dynamin.core.benchmark;

// this is a temporary file to hold layout code until I figure out what
// files to put it in

/*
Opera's find dialog:

auto whatLabel = win.content.add(new Label("Find What"));
...

V(	whatLabel
	H( findBox findButton )
	H( V(wholeWordCheck caseCheck) ~ V(upRadio downRadio) ~)
	H( ~ closeButton )
)
*/

enum LayoutType {
	None, Table, Control, Filler, Spacer
}
enum Elasticity {
	No, Semi, Yes
}
struct LayoutGroup {
	LayoutType type;
	LayoutGroup* parent;
	LayoutGroup[] children; // used if type == LayoutType.Horiz or Vert or Table
	Control control;        // used if type == LayoutType.Control
	int numColumns;         // used if type == LayoutType.Table
	int numRows() { return children.length / numColumns; }

	bool cacheActive;
	private Elasticity _elasticXCache, _elasticYCache;
	private Size _bestSizeCache;
	private int _baselineCache;

	// spacing variables
	int spacing = 8;
	static LayoutGroup opCall(LayoutType type, LayoutGroup* parent) {
		LayoutGroup layout;
		layout.type = type;
		layout.parent = parent;
		layout.children.length = 3;
		layout.children.length = 0;
		return layout;
	}

	void setCache() {
		for(int i = 0; i < children.length; ++i) // can't use foreach--copies
			children[i].setCache();
		_elasticXCache = _elasticX;
		_elasticYCache = _elasticY;
		_bestSizeCache = _bestSize;
		_baselineCache = _baseline;
		cacheActive = true;
	}
	void clearCache() {
		cacheActive = false;
		for(int i = 0; i < children.length; ++i) // can't use foreach--copies
			children[i].clearCache();
	}
	Elasticity elasticX() { return cacheActive ? _elasticXCache : _elasticX; }
	Elasticity elasticY() { return cacheActive ? _elasticYCache : _elasticY; }
	Size bestSize() { return cacheActive ? _bestSizeCache : _bestSize; }
	int  baseline() { return cacheActive ? _baselineCache : _baseline; }

	//{{{ _elasticX()
	private Elasticity _elasticX() {
		switch(type) {
		case LayoutType.Control:
			return control.elasticX ? Elasticity.Yes : Elasticity.No;
		case LayoutType.Table:
			auto e = Elasticity.No;
			foreach(layout; children) {
				if(layout.elasticX > e)
					e = layout.elasticX;
				if(e == Elasticity.Yes)
					return e;
			}
			return e;
		case LayoutType.Filler:
			return Elasticity.Semi;
		case LayoutType.Spacer:
			return Elasticity.No;
		}
	}
	//}}}
	//{{{ _elasticY()
	private Elasticity _elasticY() {
		switch(type) {
		case LayoutType.Control:
			return control.elasticY ? Elasticity.Yes : Elasticity.No;
		case LayoutType.Table:
			auto e = Elasticity.No;
			foreach(layout; children) {
				if(layout.elasticY > e)
					e = layout.elasticY;
				if(e == Elasticity.Yes)
					return e;
			}
			return e;
		case LayoutType.Filler:
			return Elasticity.Semi;
		case LayoutType.Spacer:
			return Elasticity.No;
		}
	}
	//}}}

	//{{{ _bestSize()
	private Size _bestSize() {
		switch(type) {
		case LayoutType.Control:
			return control.bestSize;
		case LayoutType.Table:
			scope colsInfo = new ColRowInfo[numColumns];
			scope rowsInfo = new ColRowInfo[numRows];
			TableInfo info;
			getTableSizes(colsInfo, rowsInfo, info);
			return info.bestSize;
		case LayoutType.Filler:
		case LayoutType.Spacer:
			return Size(0, 0);
		}
	}
	//}}}
	//{{{ _baseline()
	private int _baseline() {
		switch(type) {
		case LayoutType.Control:
			return control.baseline;
		case LayoutType.Table:
		case LayoutType.Filler:
		case LayoutType.Spacer:
			return 0;
		}
	}
	//}}}

	//{{{ layout()
	void layout(Rect rect) {
		switch(type) {
		case LayoutType.Control:
			control.location = Point(rect.x, rect.y);
			control.size = Size(rect.width, rect.height);
			return;
		case LayoutType.Table:
			scope colsInfo = new ColRowInfo[numColumns];
			scope rowsInfo = new ColRowInfo[numRows];
			TableInfo info;
			getTableSizes(colsInfo, rowsInfo, info);

			real extraWidth  = rect.width  - bestSize.width;
			real extraHeight = rect.height - bestSize.height;

			void distExtra(ref real extra, ref ColRowInfo info,
			              ref real totalElastic, ref int semis, Elasticity e) {
				if(info.elastic == Elasticity.No || extra <= 0)
					return;
				if(e == Elasticity.Semi &&
						info.elastic == Elasticity.Semi) {
					auto thisExtra = extra / semis;
					extra -= thisExtra;
					semis--;
					info.bestSize += thisExtra;
				} else if(e == Elasticity.Yes &&
						info.elastic == Elasticity.Yes) {
					auto thisExtra = extra * info.bestSize/totalElastic;
					extra -= thisExtra;
					totalElastic -= info.bestSize; // subtract original size
					info.bestSize += thisExtra;
				}
			}
			real y = 0;
			for(int row = 0; row < numRows; ++row) { // go over each row
				distExtra(extraHeight, rowsInfo[row], info.elasticHeight, info.semiRows, elasticY);

				real x = 0;
				for(int col = 0; col < numColumns; ++col) {
					distExtra(extraWidth, colsInfo[col], info.elasticWidth, info.semiColumns, elasticX);

					auto layout = children[row * numColumns + col];

					Rect r = Point(x, y) + layout.bestSize;

					if(layout.baseline > 0)
						r.y = r.y + rowsInfo[row].baseline - layout.baseline;
					if(layout.elasticX)
						r.width = colsInfo[col].bestSize;
					if(layout.elasticY)
						r.height = rowsInfo[row].bestSize;

					layout.layout(r + Point(rect.x, rect.y));

					x += colsInfo[col].bestSize +
					    (colsInfo[col].filler ? 0 : spacing);
				}
				y += rowsInfo[row].bestSize +
				    (rowsInfo[row].filler ? 0 : spacing);
			}
			return;
		case LayoutType.Filler:
		case LayoutType.Spacer:
			return;
		}
	}
	//}}}

	struct ColRowInfo {
		real bestSize = 0;  // large enough to hold the largest control
		Elasticity elastic = Elasticity.No;
		bool filler = true; // if the entire column/row is filler
		real baseline;      // only applies to rows: max baseline in row
	}
	struct TableInfo {
		// number of semi-elastic columns/rows
		int semiColumns = 0; int semiRows = 0;
		// the sum of fully elastic width/height, not including semi
		real elasticWidth = 0, elasticHeight = 0;
		Size bestSize = Size(0, 0);
	}
	//{{{ getTableSizes()
	// Fills in the passed in array with the column and row sizes, as well
	// as whether they are elastic. The passed in arrays must be the right
	// sizes. They may be stack allocated. The table best size does
	// including spacing, but column and row best sizes do not.
	private void getTableSizes(ColRowInfo[] colsInfo, ColRowInfo[] rowsInfo, ref TableInfo info) {
		assert(children.length % numColumns == 0);
		assert(type == LayoutType.Table);

		assert(colsInfo.length == numColumns);
		assert(rowsInfo.length == numRows);

		real max = 0, temp;
		LayoutGroup* l;

		int sp = 0;
		for(int col = 0; col < numColumns; ++col) { // go down each column
			for(int row = 0; row < numRows; ++row) {
				l = &children[row * numColumns + col];
				max = l.bestSize.width > max ? l.bestSize.width : max;
				if(l.elasticX > colsInfo[col].elastic)
					colsInfo[col].elastic = l.elasticX;
				if(l.type != LayoutType.Filler)
					colsInfo[col].filler = false;
			}
			colsInfo[col].bestSize = max;
			if(colsInfo[col].elastic == Elasticity.Yes)
				info.elasticWidth += max;
			else if(colsInfo[col].elastic == Elasticity.Semi)
				info.semiColumns++;
			info.bestSize.width = info.bestSize.width + sp + max;
			sp = (colsInfo[col].filler ? 0 : spacing);
			max = 0;
		}

		real maxBl = 0;
		sp = 0;
		for(int row = 0; row < numRows; ++row) { // go over each row
			for(int col = 0; col < numColumns; ++col) {
				l = &children[row * numColumns + col];
				max = l.bestSize.height > max ? l.bestSize.height : max;
				maxBl = l.baseline > maxBl ? l.baseline : maxBl;
				if(l.elasticY > rowsInfo[row].elastic)
					rowsInfo[row].elastic = l.elasticY;
				if(l.type != LayoutType.Filler)
					rowsInfo[row].filler = false;
			}
			rowsInfo[row].bestSize = max;
			rowsInfo[row].baseline = maxBl;
			if(rowsInfo[row].elastic == Elasticity.Yes)
				info.elasticHeight += max;
			else if(rowsInfo[row].elastic == Elasticity.Semi)
				info.semiRows++;
			info.bestSize.height = info.bestSize.height + sp + max;
			sp = (rowsInfo[row].filler ? 0 : spacing);
			max = maxBl = 0;
		}
	}
	//}}}
}

//{{{ LayoutPanel class
class LayoutPanel : Panel {
	LayoutGroup root;
	LayoutGroup* current;
	void startLayout(int ncolumns) {
		if(current is null) {
			root = LayoutGroup(LayoutType.Table, null);
			root.numColumns = ncolumns;
			current = &root;
			return;
		}
		current.children.length = current.children.length+1;
		current.children[$-1] = LayoutGroup(LayoutType.Table, current);
		current.children[$-1].numColumns = ncolumns;
		current = &current.children[$-1];
	}
	void endLayout() {
		current = current.parent;
	}
	override void add(Control c) {
		if(current is null)
			throw new Exception("Cannot add a control until a layout is started");
		current.children.length = current.children.length+1;
		current.children[$-1] = LayoutGroup(LayoutType.Control, current);
		current.children[$-1].control = c;
		super.add(c);
	}
	void addFiller() {
		current.children.length = current.children.length+1;
		current.children[$-1] = LayoutGroup(LayoutType.Filler, current);
	}
	void addSpacer() {
		current.children.length = current.children.length+1;
		current.children[$-1] = LayoutGroup(LayoutType.Spacer, current);
	}

	override Size bestSize() {
		return root.bestSize + Size(root.spacing*2, root.spacing*2);
	}
	override bool elasticX() { return root.elasticX == Elasticity.Yes; }
	override bool elasticY() { return root.elasticY == Elasticity.Yes; }
	override void layout() {
		//benchmarkAndWrite("layout", {
		root.setCache();
		int sp = root.spacing;
		root.layout(Rect(sp, sp, width-2*sp, height-2*sp));
		root.clearCache();
		//});
	}
}
//}}}

//{{{ createLayout() etc.
/**
 * Note: if you do this:
 * -----
 * char[] s = createLayout("V( b1 H(b2 b3) )");
 * -----
 * Then the program will crash when compiled with the -release flag. (I am
 * pretty sure it is a DMD bug, but I don't have time to make a testcase
 * for a bug that does not bother me.) This will work correctly:
 * -----
 * const char[] s = createLayout("V( b1 H(b2 b3) )");
 * -----
 * Because then the function is interpreted at compile time with CTFE.
 */
string createLayout(string layout) {
	string code = "delegate LayoutPanel() {\n";
	code ~= "auto panel = new LayoutPanel;\n";
	assert(getToken(layout) == "H" || getToken(layout) == "V" ||
		getToken(layout) == "T", "layout type 'H', 'V', or 'T' expected");
	code ~= parseLayout(layout);
	code ~= "return panel;\n";
	code ~= "}()";
	return code;
}

void skipWS(ref string str) {
	int i = 0;
	while(" \t\n\r\v\f".contains(str[i]))
		i++;
	str = str[i..$];
}
// advances to the next token and returns it
string nextToken(ref string str) {
	skipWS(str);
	str = str[getToken(str).length..$];
	return getToken(str);
}
// returns H or V or ( or ) or myControl
// gets the current token
string getToken(string str) {
	string idChars =
		"_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

	// TODO: // for line comments?
	skipWS(str);
	if("()~[]-".contains(str[0])) {
		return str[0..1];
	} else if(idChars.contains(str[0])) {
		int i = 1;
		while(idChars.contains(str[i]))
			i++;
		return str[0..i];
	} else {
		assert(0, "unknown character: " ~ str[0]);
	}
}

// {{{ copied from Phobos
char[] ctfeUintToString(uint u) {
	char[uint.sizeof * 3] buffer = void;
	int ndigits;
	char[] result;
	char[] digits = "0123456789";

	ndigits = 0;
	if (u < 10)
		// Avoid storage allocation for simple stuff
	result = digits[u .. u + 1];
	else
	{
		while (u)
		{
			uint c = (u % 10) + '0';
			u /= 10;
			ndigits++;
			buffer[buffer.length - ndigits] = cast(char)c;
		}
		result = new char[ndigits];
		result[] = buffer[buffer.length - ndigits .. buffer.length];
	}
	return result;
}
uint ctfeStringToUint(char[] s)
{
	int length = s.length;

	if (!length)
		return 0;

	uint v = 0;

	for (int i = 0; i < length; i++)
	{
		char c = s[i];
		if (c >= '0' && c <= '9')
		{
			if (v < uint.max/10 || (v == uint.max/10 && c <= '5'))
				v = v * 10 + (c - '0');
			else
				return 0;
		}
		else
			return 0;
    }
    return v;
}
//}}}

uint parseBody(ref string layout, ref string bcode) {
	uint count = 0;
	assert(nextToken(layout) == "(", "open parenthesis expected");
	while(nextToken(layout) != ")") {
		if(getToken(layout) == "~")
			bcode = bcode ~ "panel.addFiller();\n";
		else if(getToken(layout) == "-")
			bcode = bcode ~ "panel.addSpacer();\n";
		else
			bcode = bcode ~ parseLayout(layout);
		count++;
	}
	bcode = bcode ~ "panel.endLayout();\n";
	return count;
}

string parseLayout(ref string layout) {
	string code = "";

	if(getToken(layout) == "H") {
		string bodyCode;
		auto count = parseBody(layout, bodyCode);
		code ~= "panel.startLayout(" ~ ctfeUintToString(count) ~ ");\n";
		code ~= bodyCode;
	} else if(getToken(layout) == "V") {
		code ~= "panel.startLayout(1);\n";
		parseBody(layout, code);
	} else if(getToken(layout) == "T") {
		assert(nextToken(layout) == "[", "open bracket expected");
		nextToken(layout);
		assert("0123456789".contains(getToken(layout)[0]),
			"number of table columns expected");
		uint columns = ctfeStringToUint(getToken(layout));
		code ~= "panel.startLayout(" ~ getToken(layout) ~ ");\n";
		assert(nextToken(layout) == "]", "close bracket expected");
		assert(parseBody(layout, code) % columns == 0,
			"number of controls must be a multiple of number of columns");
	} else {
		code ~= "panel.add(" ~ getToken(layout) ~ ");\n";
	}

	return code;
}

//{{{ parser tests
static assert(createLayout("H()") != "not evaluatable at compile time");
//pragma(msg, createLayout("V()"));

static assert(createLayout("V(c1 c2)") ==
`delegate LayoutPanel() {
auto panel = new LayoutPanel;
panel.startLayout(1);
panel.add(c1);
panel.add(c2);
panel.endLayout();
return panel;
}()`);
static assert(createLayout("V(c1 ~ c2 H(c3 -) c4)") ==
`delegate LayoutPanel() {
auto panel = new LayoutPanel;
panel.startLayout(1);
panel.add(c1);
panel.addFiller();
panel.add(c2);
panel.startLayout(2);
panel.add(c3);
panel.addSpacer();
panel.endLayout();
panel.add(c4);
panel.endLayout();
return panel;
}()`);
static assert(createLayout("V( c1 T[2](c2 c3) c4 )") ==
`delegate LayoutPanel() {
auto panel = new LayoutPanel;
panel.startLayout(1);
panel.add(c1);
panel.startLayout(2);
panel.add(c2);
panel.add(c3);
panel.endLayout();
panel.add(c4);
panel.endLayout();
return panel;
}()`);
//}}}

//}}}

unittest {
	// TODO: set to basic theme
	// test a few basic layouts and verify pixel locations and sizes
}

