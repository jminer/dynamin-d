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
 * Portions created by the Initial Developer are Copyright (C) 2007-2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Jordan Miner <jminer7@gmail.com>
 *
 */

module dynamin.painting.text_layout;

import dynamin.core.list;
import dynamin.core.string;
import dynamin.painting.color;
import tango.text.convert.Utf;
import tango.io.Stdout;

//{{{ character formatting types
/// The line style of an underline, strikethrough, or overline.
// TODO: add images of what these line styles look like
enum LineStyle {
	///
	None,
	///
	Single,
	///
	Double,
	///
	Dotted,
	///
	Dashed,
	///
	Wavy
}

///
enum SmallType {
	// Specifies normal text.
	Normal,
	// Specifies text smaller than normal and raised above the normal baseline.
	Superscript,
	// Specifies text smaller than normal and lowered below the normal baseline.
	Subscript
}

/// A change in character formatting.
struct FormatChange {
	uint index;
	FormatType type;
	FormatData data;

	static FormatChange opCall(uint i, FormatType t, FormatData d) {
		FormatChange c;
		c.index = i;
		c.type = t;
		c.data = d;
		return c;
	}
}
/**
  * Returns true if data1 is equal to data2.
  */
bool formatDataEqual(FormatType type, FormatData data1, FormatData data2) {
	if(type == FormatType.FontFamily)
		return data1.family == data2.family;
	else if(type == FormatType.FontSize)
		return data1.size == data2.size;
	else if(type == FormatType.Bold || type == FormatType.Italic)
		return data1.on == data2.on;
	else if(type == FormatType.Underline || type == FormatType.Strikethrough ||
		type == FormatType.Overline)
		return data1.style == data2.style;
	else if(type == FormatType.Small)
		return data1.type == data2.type;
	else if(type == FormatType.ForeColor || type == FormatType.BackColor)
		return data1.color == data2.color;
	else if(type == FormatType.Spacing)
		return data1.multiple == data2.multiple;
	else
		throw new Exception("unknown type");
}

///
enum FormatType : ubyte {
	///
	FontFamily = 1,
	///
	FontSize,
	///
	Bold,
	///
	Italic,
	///
	Underline,
	///
	Strikethrough,
	///
	Overline,
	///
	Small,
	///
	ForeColor,
	///
	BackColor,
	///
	Spacing
}

///
union FormatData {
	/// Valid for FontFamily
	string family;
	/// Valid for FontSize
	double size;
	/// Valid for Bold and Italic
	bool on;
	/// Valid for Underline, Strikethrough, and Overline
	LineStyle style;
	/// Valid for Small
	SmallType type;
	/// Valid for ForeColor and BackColor
	Color color;
	/// Valid for Spacing
	double multiple;
}

struct Format {
	string fontFamily; // no default
	double fontSize;   // no default
	bool bold   = false;
	bool italic = false;
	LineStyle underline     = LineStyle.None;
	LineStyle strikethrough = LineStyle.None;
	LineStyle overline      = LineStyle.None;
	SmallType small = SmallType.Normal;
	Color foreColor = Color(255, 0, 0, 0); // black
	Color backColor = Color(  0, 0, 0, 0); // transparent
	double spacing = 1.0;

	FormatData getDataForType(FormatType type) {
		FormatData data;
		if(type == FormatType.FontFamily)
			data.family = fontFamily;
		else if(type == FormatType.FontSize)
			data.size = fontSize;
		else if(type == FormatType.Bold)
			data.on = bold;
		else if(type == FormatType.Italic)
			data.on = italic;
		else if(type == FormatType.Underline)
			data.style = underline;
		else if(type == FormatType.Strikethrough)
			data.style = strikethrough;
		else if(type == FormatType.Overline)
			data.style = overline;
		else if(type == FormatType.Small)
			data.type = small;
		else if(type == FormatType.ForeColor)
			data.color = foreColor;
		else if(type == FormatType.BackColor)
			data.color = backColor;
		else if(type == FormatType.Spacing)
			data.multiple = spacing;
		else
			throw new Exception("unknown type");
		return data;
	}
}
//}}}

///
enum TextAlignment {
	///
	Left,
	///
	Center,
	///
	Right,
	///
	Justify
}

///
enum TabStopType {
	///
	Left,
	///
	Center,
	///
	Right,
	///
	Decimal
}

///
struct TabStop {
	///
	uint location;
	///
	TabStopType type = TabStopType.Left;
	///
	char leading = '.';
}

/**
 *
 */
class TextLayout {
	string text;

	// character formatting
	List!(FormatChange) formatting; // Always sorted by FormatChange.index
	Format initialFormat;

	// paragraph formatting
	double lineSpacing = 1.0;
	double defaultTabStopLocations = 0; // 0 means default tabs every (4 * width of character '0')
	TabStop[] tabStops;
	TextAlignment alignment = TextAlignment.Left;

	this(string fontFamily, double fontSize) {
		formatting = new List!(FormatChange);
		initialFormat.fontFamily = fontFamily;
		initialFormat.fontSize = fontSize;
	}
	invariant {
		// ensure that formatting is sorted correctly
		uint index = 0;
		foreach(change; formatting) {
			assert(change.index >= index);
			index = change.index;
		}
	}

	//{{{ character formatting
	void setFontFamily(string family, uint start, uint length) {
		FormatData data;
		data.family = family;
		setFormat(FormatType.FontFamily, data, start, length);
	}
	void setFontSize(double size, uint start, uint length) {
		FormatData data;
		data.size = size;
		setFormat(FormatType.FontSize, data, start, length);
	}

	void setBold(bool on, uint start, uint length) {
		FormatData data;
		data.on = on;
		setFormat(FormatType.Bold, data, start, length);
	}
	void setItalic(bool on, uint start, uint length) {
		FormatData data;
		data.on = on;
		setFormat(FormatType.Italic, data, start, length);
	}
	void setUnderline(LineStyle style, uint start, uint length) {
		FormatData data;
		data.style = style;
		setFormat(FormatType.Underline, data, start, length);
	}
	void setStrikethrough(LineStyle style, uint start, uint length) {
		FormatData data;
		data.style = style;
		setFormat(FormatType.Strikethrough, data, start, length);
	}
	void setOverline(LineStyle style, uint start, uint length) {
		FormatData data;
		data.style = style;
		setFormat(FormatType.Overline, data, start, length);
	}

	/// Sets the text either superscript or subscript.
	void setSmall(SmallType type, uint start, uint length) {
		FormatData data;
		data.type = type;
		setFormat(FormatType.Small, data, start, length);
	}
	// see http://en.wikipedia.org/wiki/Subscript_and_superscript#Desktop_publishing for
	// info on positioning superscript and subscript

	void setForeColor(Color color, uint start, uint length) {
		FormatData data;
		data.color = color;
		setFormat(FormatType.ForeColor, data, start, length);
	}
	void setBackColor(Color color, uint start, uint length) {
		FormatData data;
		data.color = color;
		setFormat(FormatType.BackColor, data, start, length);
	}

	/**
	 * Sets the spacing between characters, given in multiples of a character's width.
	 * For example, a multiple of 2.0 would make drawn text take twice as much space
	 * horizontally, due to twice as much space being given to each character.
	 */
	void setSpacing(double multiple, uint start, uint length) {
		FormatData data;
		data.multiple = multiple;
		setFormat(FormatType.Spacing, data, start, length);
	}

	void setFormat(FormatType type, FormatData data, uint start, uint length) {
		uint end = start + length;
		checkIndex(start);
		checkIndex(end);

		FormatData endData = getFormat(type, end);

		for(int i = formatting.count-1; i >= 0; --i) {
			if(formatting[i].type == type && formatting[i].index <= end) {
				if(formatting[i].index >= start)
					formatting.removeAt(i);
				else
					break;
			}
		}

		if(!formatDataEqual(type, getFormat(type, start), data)) {
			insertFormatChange(FormatChange(start, type, data));
		}

		// make sure that the formatting >= end stays the same as it was
		if(!formatDataEqual(type, endData, getFormat(type, end))) {
			insertFormatChange(FormatChange(end, type, endData));
		}
	}
	FormatData getFormat(FormatType type, uint index) {
		checkIndex(index);
		FormatData data = initialFormat.getDataForType(type);
		for(int i = 0; i < formatting.count; ++i) {
			if(formatting[i].index > index)
				break;
			if(formatting[i].type == type)
				data = formatting[i].data;
		}
		return data;
	}
	private void insertFormatChange(FormatChange change) {
		int i = 0;
		while(i < formatting.count && formatting[i].index <= change.index)
			++i;
		formatting.insert(change, i);
	}
	//}}}
	private void checkIndex(uint index) {
		if(index == 0)
			return;
		if(cropRight!(char)(text[0..index]).length != index)
			throw new Exception("index must be at a valid code point, not inside one");
	}
}

unittest {
	auto t = new TextLayout("Tahoma", 15);
	t.text = "How are you doing today?";
	t.setBold(true, 4, 3); // "are"
	assert(t.formatting.count == 2);
	t.setBold(true, 7, 4); // " you"
	assert(t.formatting.count == 2);
	t.setBold(true, 1, 3); // "ow "
	assert(t.formatting.count == 2);
	t.setBold(true, 8, 9); // "you doing"
	assert(t.formatting.count == 2);
	t.setBold(true, 0, 18); // "How are you doing "
	assert(t.formatting.count == 2);
	assert(t.formatting[0].type == FormatType.Bold);
	assert(t.formatting[0].data.on == true);
	assert(t.formatting[1].type == FormatType.Bold);
	assert(t.formatting[1].data.on == false);
	t.setBold(false, 0, 24);
	assert(t.formatting.count == 0);

	t.setBold(true, 4, 3); // "are"
	assert(t.formatting.count == 2);
	t.setBold(true, 8, 3); // "you"
	assert(t.formatting.count == 4);
	t.setBold(true, 1, 16); // "ow are you doing"
	assert(t.formatting.count == 2);
	t.setBold(false, 4, 8); // "are you "
	assert(t.formatting.count == 4);
	assert(t.formatting[0].index == 1);
	assert(t.formatting[0].data.on == true);
	assert(t.formatting[1].index == 4);
	assert(t.formatting[1].data.on == false);
	assert(t.formatting[2].index == 12);
	assert(t.formatting[2].data.on == true);
	assert(t.formatting[3].index == 17);
	assert(t.formatting[3].data.on == false);
	t.setBold(false, 1, 3); // "ow "
	assert(t.formatting.count == 2);
	t.setUnderline(LineStyle.Double, 8, 9); // "you doing"
	assert(t.formatting.count == 4);
	t.setBold(false, 0, 20); // "How are you doing t"
	assert(t.formatting.count == 2);
	assert(t.formatting[0].type == FormatType.Underline);
	assert(t.formatting[1].type == FormatType.Underline);
	t.setUnderline(LineStyle.Single, 12, 11); // "doing today"
	assert(t.formatting.count == 3);
	assert(t.formatting[0].data.style == LineStyle.Double);
	assert(t.formatting[1].data.style == LineStyle.Single);
	assert(t.formatting[2].data.style == LineStyle.None);
	t.setUnderline(LineStyle.None, 4, 14); // "are you doing "
	assert(t.formatting.count == 2);
	assert(t.formatting[0].data.style == LineStyle.Single);
	assert(t.formatting[0].index == 18);
	t.setUnderline(LineStyle.None, 4, 20); // "are you doing today?"
	assert(t.formatting.count == 0);
}

