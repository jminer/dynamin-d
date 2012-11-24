
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.painting.text_layout;

import dynamin.painting_backend;
import dynamin.core.list;
import dynamin.core.string;
import dynamin.painting.color;
import dynamin.painting.coordinates;
import tango.text.convert.Utf;
import tango.io.Stdout;

//version = TextLayoutDebug;

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
	//Dashed,
	///
	//Wavy
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
	void setDataForType(FormatType type, FormatData data) {
		if(type == FormatType.FontFamily)
			fontFamily = data.family;
		else if(type == FormatType.FontSize)
			fontSize = data.size;
		else if(type == FormatType.Bold)
			bold = data.on;
		else if(type == FormatType.Italic)
			italic = data.on;
		else if(type == FormatType.Underline)
			underline = data.style;
		else if(type == FormatType.Strikethrough)
			strikethrough = data.style;
		else if(type == FormatType.Overline)
			overline = data.style;
		else if(type == FormatType.Small)
			small = data.type;
		else if(type == FormatType.ForeColor)
			foreColor = data.color;
		else if(type == FormatType.BackColor)
			backColor = data.color;
		else if(type == FormatType.Spacing)
			spacing = data.multiple;
		else
			throw new Exception("unknown type");
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
	/// The last line of justified text will be natural aligned.
	Justify,
	/// Left aligned for left-to-right text and right aligned for right-to-left text.
	Natural
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

struct Run {
	cairo_scaled_font_t* font;
	float baseline;    // distance from position.y down to the baseline
	float height;
	Point position;    // the top-left corner of the run
	uint start;        // the first UTF-8 code unit in this run
	uint length;       // the number of UTF-8 code units in this run
	bool rightToLeft;
	uint[] clusterMap; // map from UTF-8 code units to the beginning of the glyph cluster they're in
	uint[] glyphs;     // glyphs are in visual order
	float[] advanceWidths;

	uint end() { return start + length; }
	float width() {
		float sum = 0;
		foreach(w; advanceWidths)
			sum += w;
		return sum;
	}
}
struct LogAttr {
	private ubyte data;
	// true if the line can be broken at this index
	bool softBreak() {
		return cast(bool)(data & 1);
	}
	void softBreak(bool b) {
		b ? (data |= 1) : (data &= ~1);
	}
	// true if the caret can be placed at this index
	bool clusterStart() {
		return cast(bool)(data & 2);
	}
	void clusterStart(bool b) {
		b ? (data |= 2) : (data &= ~2);
	}
	// true if the caret can be placed at this index when moving to the beginning of a word
	bool wordStart() {
		return cast(bool)(data & 4);
	}
	void wordStart(bool b) {
		b ? (data |= 4) : (data &= ~4);
	}
}
/**
 * Normally, at least for situations when paragraphs need to be formatted differently (e.g. one
 * centered and another justified), a separate TextLayout object is used for each paragraph.
 */
class TextLayout {
private:
	mixin TextLayoutBackend;
public:
	string text;
	Rect[] layoutBoxes;
	///
	void delegate(Rect line, List!(Rect) boxes) getLineBoxes;

	// character formatting
	List!(FormatChange) formatting; // Always sorted by FormatChange.index
	Format initialFormat;

	// paragraph formatting
	double lineSpacing = 1.0;
	double defaultTabStopLocations = 0; // 0 means default tabs every (4 * width of character '0')
	TabStop[] tabStops;
	TextAlignment alignment = TextAlignment.Natural;

	List!(Run) runs; // runs are in logical order
	LogAttr[] logAttrs;
	void clearRuns() {
		while(runs.count > 0)
			releaseScaledFont(runs.pop().font);
	}
	void defaultGetLineBoxes(Rect line, List!(Rect) boxes) {
		boxes.add(line);
	}
	this(string fontFamily, double fontSize) {
		getLineBoxes = &defaultGetLineBoxes;
		runs = new List!(Run);
		if(!runLists)
			runLists = new List!(List!(Run));
		runLists.add(runs); // to keep the runs list around until the destructor is called

		formatting = new List!(FormatChange);
		initialFormat.fontFamily = fontFamily;
		initialFormat.fontSize = fontSize;
	}
	~this() {
		clearRuns(); // have to call releaseScaledFont() so unused ones don't stay in font cache
		runLists.remove(runs);
	}
	/*invariant { // TODO: uncomment this when D no longer calls it right before the destructor
		// ensure that formatting is sorted correctly
		uint index = 0;
		foreach(change; formatting) {
			assert(change.index >= index);
			index = change.index;
		}
	}*/
	// The first number is the index of the run to put at the left of the first line.
	// The second number is the index of the run to put just right of that, and so on.
	uint[] visToLogMap;  // length == runs.count
	// Narrow down the visual to logical map to just the logical runs between startRun and endRun.
	// startRun is inclusive; endRun is exclusive
	// The first number in the return map is index of the run (between startRun and
	// endRun) that goes first visually. The second index goes just to right of it, and so on.
	void getVisualToLogicalMap(uint startRun, uint endRun, uint[] map) {
		assert(map.length == endRun - startRun);
		uint mapIndex = 0;
		for(int i = 0; i < visToLogMap.length; ++i) {
			// we are basically removing all numbers from visToLogMap except ones >= start and < end
			if(visToLogMap[i] >= startRun && visToLogMap[i] < endRun) {
				map[mapIndex] = visToLogMap[i];
				mapIndex++;
			}
		}
		assert(mapIndex == map.length - 1);

		// To use a logical to visual map to implement this function, you'd have to
		// loop through the entire map and find the smallest index. Then put that in the
		// return array. Then loop through and find the second smallest index, and put that in
		// the return array. Repeat until it is filled.
	}
	// Splits this run into two runs. This Run is the second one, and the first run is returned.
	void splitRun(uint runIndex, uint splitIndex) {
		// TODO: need to update visToLogMap
		// TODO: rename position to location?
		version(TextLayoutDebug) {
			Stdout.format("splitRun(): runIndex: {0}, text: {1}",
			              runIndex, text[runs[runIndex].start..runs[runIndex].end]).newline;
		}
		assert(splitIndex != runs[runIndex].start && splitIndex != runs[runIndex].end);
		assert(logAttrs[splitIndex].clusterStart);

		runs.insert(runs[runIndex], runIndex);

		Run* run1 = &runs.data[runIndex];
		auto glyphIndex = run1.clusterMap[splitIndex - run1.start];
		run1.length        = splitIndex - run1.start;
		run1.glyphs        = run1.glyphs[0..glyphIndex];
		run1.advanceWidths = run1.advanceWidths[0..glyphIndex];
		run1.clusterMap    = run1.clusterMap[0..run1.length];
		cairo_scaled_font_reference(run1.font);

		Run* run2 = &runs.data[runIndex+1];
		run2.length        = (run2.start + run2.length) - splitIndex;
		run2.start         = splitIndex;
		run2.glyphs        = run2.glyphs[glyphIndex..$];
		run2.advanceWidths = run2.advanceWidths[glyphIndex..$];
		run2.clusterMap    = run2.clusterMap[run1.length..$];
		// need to change the cluster map to account for the glyphs removed
		for(int i = 0; i < run2.clusterMap.length; ++i)
			run2.clusterMap[i] -= glyphIndex;

		backend_splitRun(runIndex, splitIndex);
	}

	///
	struct FormatRunsIter {
	private:
		TextLayout owner;
		FormatType[] filter;
		int delegate(uint index) splitter;
	public:
		///
		int opApply(int delegate(ref uint start, ref uint length, ref Format format) dg) {
			bool inFilter(FormatType type) {
				return filter.length == 0 || filter.contains(type);
			}
			with(owner) {
				int result;
				uint fIndex = 0; // index of formatting array
				uint sIndex = 0; // index passed to splitter
				Format format = initialFormat;

				uint start = 0;
				uint end;
				while(start != text.length) {
					end = text.length;
					// stop looping when one is found that is greater than start and in the filter
					while(fIndex < formatting.count && (formatting[fIndex].index <= start ||
					                                    !inFilter(formatting[fIndex].type))) {
						// the only ones that are greater are ones skipped due to filter
						assert(formatting[fIndex].index >= start);
						format.setDataForType(formatting[fIndex].type, formatting[fIndex].data);
						fIndex++;
					}
					if(fIndex < formatting.count)
						end = formatting[fIndex].index;

					if(splitter) {
						while(splitter(sIndex) != -1 && splitter(sIndex) <= start)
							sIndex++;
						if(splitter(sIndex) != -1 && splitter(sIndex) < end)
							end = splitter(sIndex);
					}
					if(end == start)
						end = text.length;

					uint _start = start;
					uint _length = end - start;
					result = dg(_start, _length, format);
					if(result)
						break;

					start = end;
				}

				return result;
			}
		}
	}

	/**
	 * Returns an iterator struct that can be used with foreach. The struct will iterate over
	 * each range of the text that has the same formatting.
	 *
	 * The difference between formatRuns and fontFormatRuns is that fontFormatRuns ignores
	 * all formatting except FontFamily, FontSize, Bold, Italic, and Small, whereas formatRuns
	 * does not ignore any formatting.
	 *
	 * If the optional delegate is specified, it will be called with index = 0, then index = 1,
	 * and so on. The delegate should return an index to split the ranges at. When there are no
	 * more indexes to split the ranges at, the delegate should return -1. It is a way of
	 * giving an array of indexes to split at without allocating an array.
	 *
	 * Example:
	 * -----
	 * foreach(start, length, format; textLayout.formatRuns) {
	 *     // code goes here
	 * }
	 * -----
	 */
	FormatRunsIter formatRuns(int delegate(uint index) splitter = null) {
		FormatRunsIter iter;
		iter.owner = this;
		iter.splitter = splitter;
		return iter;
	}

	/// ditto
	FormatRunsIter fontFormatRuns(int delegate(uint index) splitter = null) {
		FormatRunsIter iter;
		iter.owner = this;
		iter.filter = [FormatType.FontFamily,
		               FormatType.FontSize,
		               FormatType.Bold,
		               FormatType.Italic,
		               FormatType.Small];
		iter.splitter = splitter;
		return iter;
	}

	/**
	 *
	 */
	TextAlignment naturalAlignment() {
		return TextAlignment.Left; // TODO:
	}
	/**
	 *
	 */
	TextAlignment resolvedAlignment() {
		if(alignment == TextAlignment.Left || alignment == TextAlignment.Right)
			return alignment;
		else
			return naturalAlignment;
	}

	/*
	Point indexToPoint(uint index) {
	}
	uint pointToIndex(Point pt) {
	}
	uint nextLeft(uint index) {
	}
	uint nextRight(uint index) {
	}
	uint nextWordLeft(uint index) {
	}
	uint nextWordRight(uint index) {
	}
	*/

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
		// NOTE: Do not use cropRight(). It is broken. It will cut off an ending code point even
		// when it is a perfectly valid string. Thankfully, cropLeft() works.
		if(cropLeft!(char)(text[index..$]).length != text.length-index)
			throw new Exception("index must be at a valid code point, not inside one");
	}

	// {{{ layout()
	protected void layout(Graphics g) {
		if(layoutBoxes.length == 0)
			throw new Exception("layoutBoxes must be set");
		// TODO: need to be able to set just one rect, not an array of layoutBoxes

		backend_preprocess(g);

		version(TextLayoutDebug)
			Stdout("-----layout start-----").newline;
		int lastRunIndex = 0; // used in case of a bug
		LayoutProgress progress;
		lineLoop:
		// loop once for each line until done laying out text
		while(progress.runIndex < runs.count) {
			// Try laying out the line at the height of the first run.
			// If a taller run is found, try the line at that height, and so on
			// If no taller run is found, or if laying out the line at the taller height didn't
			// fit more characters on, then we've found the height that works best.
			double baseline;
			double height = 0;    // height of the line
			uint prevLength = 0;  // how many chars fit on when the line is that tall
			double heightToTry = runs[progress.runIndex].height;
			while(true) {
				baseline = 0;
				double newHeightToTry = heightToTry;
				uint length = layoutLine(newHeightToTry, baseline, progress, true);
				if(length == 0) { // we ran out of layout boxes--no place to put text
					while(runs.count > progress.runIndex)
						runs.removeAt(runs.count-1);
					break lineLoop;
				}
				version(TextLayoutDebug)
					Stdout.format("^ length: {0}, runIndex: {1}, y: {2}", length, progress.runIndex, progress.y).newline;
				if(length > prevLength) { // if more fit on at heightToTry than height
					height = heightToTry;
					prevLength = length;
					if(newHeightToTry <= heightToTry) // if no need to try again
						break;
					heightToTry = newHeightToTry;
				} else {
					break;
				}
			}
			// now that we have found the right height and baseline for the line,
			// actually do the layout
			layoutLine(height, baseline, progress, false);

			version(TextLayoutDebug) {
				Stdout.format("^^ rI: {0}, y: {1}", progress.runIndex, progress.y).newline;
				if(runIndex == lastRunIndex)
					Stdout("assert failed").newline;
			}
			assert(progress.runIndex > lastRunIndex);
			// should never happen, but if there is a bug, it is better than an infinite loop
			if(progress.runIndex == lastRunIndex)
				break;
			lastRunIndex = progress.runIndex;
		}
		// if wrapping around an object, a tab should go on the other side of the object
	}
	// }}}

	struct LayoutProgress {
		int runIndex = 0;
		int boxIndex = 0;
		double y = 0;     // y is relative to the top of the layout box
	}

	// {{{ layoutLine()
	// Returns how many chars fit on the line when it is the specified height tall.
	// When this method returns, height will have been set to a new height that layoutLine() can
	// be called with.
	// runIndex and totalY are only updated if dryRun is false
	// totalY is the total height of text layed out before this
	// note that this includes empty space at the bottom of a layout box where a line couldn't fit
	List!(Rect) lineBoxes; // try to reuse the same memory for each call
	uint layoutLine(ref double height, ref double baseline,
	                 ref LayoutProgress progress, bool dryRun) {
		// make local copies in case of dryRun
		int boxIndex = progress.boxIndex;
		double y = progress.y; // for now, y is relative to the top of the layout box
		// if the line won't fit on, go to the top of the next box
		while(y + height > layoutBoxes[boxIndex].height) {
			boxIndex++;
			if(boxIndex == layoutBoxes.length)
				return 0;
			y = 0;
		}
		Rect layoutBox = layoutBoxes[boxIndex];
		if(!dryRun) {
			progress.boxIndex = boxIndex;
			progress.y = y + height; // top of line after this one
		}
		// change y to absolute
		y += layoutBox.y;

		/*
		double top = totalY; // top will be the space from layoutBox.y to the top of the line
		foreach(i, box; layoutBoxes) {
			layoutBox = box; // use the last box if we never break
			if(top >= box.height) {
				top -= box.height;
				if(i == layoutBoxes.length - 1)
					return 0; // if we are out of layout boxes, there is no place to put text
			} else if(top + height > box.height) {
				// add on empty space at bottom of box
				totalY += dryRun ? 0 : top + height - box.height;
				top = 0; // loop to next box, then break
				if(i == layoutBoxes.length - 1)
					return 0; // if we are out of layout boxes, there is no place to put text
			} else {
				break;
			}
		}
		totalY += dryRun ? 0 : height;*/

		if(!lineBoxes)
			lineBoxes = new List!(Rect);
		lineBoxes.clear();
		getLineBoxes(Rect(layoutBox.x, y, layoutBox.width, height), lineBoxes);


		version(TextLayoutDebug) {
			Stdout.format("layoutLine(): height: {0}, runIndex: {1}, dryRun: {2}, runs[rI]: {3}",
			              height, runIndex, dryRun,
			              text[runs[runIndex].start..runs[runIndex].end]).newline;
		}
		int totalWidth = 0;
		foreach(box; lineBoxes)
			totalWidth += box.width;
		wordsLoop:
		for(int words = getMaxWords(progress.runIndex, totalWidth); words >= 1; --words) {
			// then for right-aligned, start with the last line box and last run, and work left
			// for left-aligned, start with the first line box and first run, and work right

			// loop over each glyph/char from left to right
			//
			int endRun, runSplit;
			getRuns(words, progress.runIndex, endRun, runSplit);
			version(TextLayoutDebug) {
				Stdout.format("    words: {0}, endRun: {1}, runSplit: {2}",
				              words, endRun, runSplit).newline;
			}
			assert(runSplit > 0);

			GlyphIter lastSoftBreak;
			GlyphIter iter;
			iter.runs = runs;
			iter.startRun = progress.runIndex;
			iter.endRun = endRun;
			iter.endSplit = runSplit;
			lastSoftBreak = iter;

			int boxI = 0;

			int lastRunIndex = iter.runIndex;
			cairo_font_extents_t lastRunExtents;
			lastRunExtents.ascent = lastRunExtents.descent = lastRunExtents.height = 0;

			float x = lineBoxes[0].x;
			while(iter.next()) {
				if(iter.runIndex != lastRunIndex) {
					// If this isn't a dry run, blindly trust the height and baseline.
					// nothing we could do if they were wrong
					if(!dryRun) {
						iter.run.position = Point(x, y);
						iter.run.baseline = baseline;
					} else {
						// if this new run is taller, return the taller height and baseline
						cairo_font_extents_t extents;
						cairo_scaled_font_extents(iter.run.font, &extents);
						auto below = max(extents.height-extents.ascent,
										 lastRunExtents.height-lastRunExtents.ascent);
						baseline = max(baseline, extents.ascent, lastRunExtents.ascent);
						// floats aren't exact, so require a tenth of a pixel higher
						if(baseline + below > height + 0.1) {
							height = baseline + below;
							return iter.charCount;
						}
						lastRunExtents = extents;
					}
				}
				lastRunIndex = iter.runIndex;

				if(logAttrs[iter.charIndex+iter.run.start].softBreak)
					lastSoftBreak = iter;

				x += iter.advanceWidth;
				// we always have to put at least one word per line
				if(x > lineBoxes[boxI].right && words > 1) {
					version(TextLayoutDebug)
						Stdout.format("    hit end of line box, boxI: {0}", boxI).newline;
					boxI++;
					if(boxI == lineBoxes.count)  // we failed at getting all the text on
						continue wordsLoop;      // try again with one fewer word
					x = lineBoxes[boxI].x;

					if(!dryRun) {
						splitRun(lastSoftBreak.runIndex, lastSoftBreak.charIndex+lastSoftBreak.run.start);
						lastSoftBreak.endRun += 1;
					}
					iter = lastSoftBreak;
				}
				// if LTR, loop over clusterMap and logAttrs forward; if RTL, loop reverse
			}
			// getting to here means that we were successful in getting the text on


			if(!dryRun) {
				if(runSplit != 0 && runSplit != runs[iter.endRun-1].length) {
					splitRun(iter.endRun-1, runSplit+runs[iter.endRun-1].start);
				}
				// now that we know for sure what runs are on the line, set their height
				for(int i = progress.runIndex; i < iter.endRun; ++i)
					runs.data[i].height = height;
				progress.runIndex = iter.endRun;
			}
			return iter.charCount;

			/*if(resolvedAlignment == TextAlignment.Left) {
			} else if(resolvedAlignment == TextAlignment.Right) {
			} else {
				assert(false);
			}*/
		}
		assert(false, "reached end of layoutLine()");
	}
	// }}}

	// {{{ getMaxWords()
	// returns the maximum number of words, starting at runIndex, that could fit in
	// the specified width
	int getMaxWords(int runIndex, float width) {
		int start = runs[runIndex].start;

		// find out how many glyphs will fit in the width
		int glyphIndex;
		both:
		for(; runIndex < runs.count; ++runIndex) {
			// have to go over runs and glyphs in logical order because all the characters on
			// the first line are logically before all the runs on the second line, and so on.
			glyphIndex = runs[runIndex].rightToLeft ? runs[runIndex].glyphs.length-1 : 0;
			while(glyphIndex >= 0 && glyphIndex < runs[runIndex].glyphs.length) {
				width -= runs[runIndex].advanceWidths[glyphIndex];
				if(width < 0)
					break both;
				glyphIndex += runs[runIndex].rightToLeft ? -1 : 1;
			}
		}
		if(runIndex == runs.count)
			runIndex--;

		// find which character goes with the last glyph
		int charIndex = 0;
		while(charIndex < runs[runIndex].length) {
			if(runs[runIndex].rightToLeft && runs[runIndex].clusterMap[charIndex] < glyphIndex)
				break;
			if(!runs[runIndex].rightToLeft && runs[runIndex].clusterMap[charIndex] > glyphIndex)
				break;
			charIndex++;
		}
		int end = charIndex + runs[runIndex].start;

		// find out how many words are in the character range (and thus in the glyphs)
		int words = 0;
		for(int i = start; i < end; ++i) {
			if(logAttrs[i].softBreak)
				words++;
		}
		if(end == text.length || words == 0) // consider the end as the start of another word
			words++;
		return words;
	}
	// }}}

	// {{{ struct GlyphIter
	// TODO: need to loop using visualToLogicalOrder
	struct GlyphIter {
		List!(Run) runs;
		void startRun(int index) { runIndex = index - 1; }
		int endRun;
		int endGlyphSplit; // the number of glyphs in the last run
		// sets the number of characters in the last run
		void endSplit(int split) {
			assert(split <= runs[endRun-1].length);
			if(split == runs[endRun-1].length)
				endGlyphSplit = runs[endRun-1].glyphs.length;
			else
				endGlyphSplit = runs[endRun-1].clusterMap[split];
		}

		int runIndex = -1;
		// usually the character that produced the current glyph (except when reordered)
		int charIndex = 0;  // counting from the start of the run
		int glyphIndex = -1;
		int charCount = 1; // charIndex starts at 0; it has already advanced to the first char

		Run* run() { return &runs.data[runIndex]; }

		// need to call once before getting the first glyph
		// returns true if there is another valid glyph to use
		// if false is returned, do not access any more glyphs or call next() again
		bool next() {
			assert(runIndex < endRun);
			//Stdout("glyphIndex: ")(glyphIndex)("  runIndex: ")(runIndex).newline;

			if(glyphIndex == -1 || glyphIndex == runs[runIndex].glyphs.length-1) {
				runIndex++;
				if(runIndex == endRun)
					return false;
				glyphIndex = 0;
				charCount += run.rightToLeft ? charIndex : run.length-charIndex;
				charIndex = run.rightToLeft ? run.length-1 : 0;
				if(runIndex == endRun-1 && runs[runIndex].rightToLeft)
					glyphIndex = endGlyphSplit-1;
			} else {
				glyphIndex++;
			}
			if(runIndex == endRun-1) {
				if(!runs[runIndex].rightToLeft && glyphIndex == endGlyphSplit)
					return false;
				if(runs[runIndex].rightToLeft && glyphIndex == runs[runIndex].glyphs.length)
					return false;
			}

			// advance charIndex, if needed
			auto newChar = charIndex;
			while(newChar >= 0 && newChar < run.length) {
				// if we found the next cluster
				if(run.clusterMap[newChar] != run.clusterMap[charIndex]) {
					// if the next char produced a glyph after where we are, then stay put
					if(run.clusterMap[newChar] > glyphIndex)
						break;
					charCount += newChar-charIndex > 0 ? newChar-charIndex : charIndex-newChar;
					charIndex = newChar;
				}
				newChar += run.rightToLeft ? -1 : 1;
			}

			//Stdout("  *glyphIndex: ")(glyphIndex)("  runIndex: ")(runIndex).newline;
			return true;
		}
		float advanceWidth() { return runs[runIndex].advanceWidths[glyphIndex]; }
	}
	// }}}

	// words is the number of words the runs should contain
	// startRun is the index of the first run to count words for
	// endRun is the index of the last run plus 1 (the last run exclusive)
	// endRunSplit is how many characters in the last run it takes to get the specified word count
	void getRuns(int words, int startRun, out int lastRun, out int lastRunSplit) {
		assert(words >= 1);  // TODO: change endRun to lastRun and make it inclusive
		lastRun = startRun;
		// add 1 to start with so that if a run begins with a word, it doesn't count
		for(int i = runs[startRun].start + 1; i < text.length; ++i) {
			if(runs[lastRun].end < i)
				lastRun++;
			if(logAttrs[i].softBreak) {
				words--;
				if(words == 0) {
					lastRunSplit = i - runs[lastRun].start;
					lastRun++; // TODO: hack
					return;
				}
			}
		}
		lastRun = runs.count - 1;
		lastRunSplit = runs[lastRun].length;
		lastRun++; //hack
	}

	// {{{ draw()
	// TODO: make layout() protected
	// functions should call it automatically when needed
	List!(cairo_glyph_t) glyphs;
	void draw(Graphics g) { // TODO: take a layoutBoxIndex parameter to only draw one of them?
		layout(g); // TODO: fix to only call if needed

		if(!glyphs)
			glyphs = new List!(cairo_glyph_t)(80);

		/*
		 * If runs are removed because not all the text will fit in the layout boxes,
		 * then we need to split at the end of the last one in splitter(), and break out
		 * of the loop when we reach the last run, since otherwise it goes to the end of
		 * the text.
		 */
		int splitter(uint i) {
			return i < runs.count ? runs[i].start : (i == runs.count ? runs[runs.count-1].end : -1);
		}
		int runIndex = 0;
		double x = runs[runIndex].position.x;
		foreach(start, length, format; formatRuns(&splitter)) {
			uint end = start + length;

			if(runs[runIndex].end == start) {
				runIndex++;
				if(runIndex == runs.count) // happens if runs were removed because they didn't fit
					break;
				x = runs[runIndex].position.x;
				if(runs[runIndex].rightToLeft)
					x += runs[runIndex].width;
			}
			Run* r = &runs[runIndex];
			assert(r.end >= end);

			cairo_matrix_t ctm;
			cairo_get_matrix(g.handle, &ctm);
			double x0 = ctm.x0, y0 = ctm.y0;
			cairo_scaled_font_get_ctm(r.font, &ctm);
			ctm.x0 = x0, ctm.y0 = y0;
			cairo_set_matrix(g.handle, &ctm);
			cairo_set_scaled_font(g.handle, r.font);

			//Stdout(r.position)("  ")(text[start..end]).newline;
			// note: using 'length' in a slice doesn't mean the 'length' in scope--it means the
			// length of the array you are slicing...arg, wasted 15 minutes

			// find glyphs to draw
			int glyphStart;
			int glyphEnd;
			// TODO: I believe this setting glyphStart/End works right, but can it be shortened?
			// besides the places the index equals the length, could just swap gStart and gEnd?
			if(r.rightToLeft) {
				if(start-r.start == 0)
					glyphEnd = r.glyphs.length;
				else
					glyphEnd = r.clusterMap[start-r.start];
				if(end-r.start == r.clusterMap.length)
					glyphStart = 0;
				else
					glyphStart = r.clusterMap[end-r.start];
			} else {
				glyphStart = r.clusterMap[start-r.start];
				if(end-r.start == r.clusterMap.length)
					glyphEnd = r.glyphs.length;
				else
					glyphEnd = r.clusterMap[end-r.start];
			}
			//if(r.rightToLeft)
			//	Stdout(glyphStart)(" -- ")(glyphEnd).newline;

			// draw backColor
			float width = 0;
			for(int i = glyphStart; i < glyphEnd; ++i)
				width += r.advanceWidths[i];
			Rect rect = Rect(r.rightToLeft ? x-width : x, r.position.y, width, r.height);
			g.source = format.backColor;
			g.rectangle(rect);
			g.fill();

			// draw glyphs
			int j = r.rightToLeft ? glyphEnd-1 : glyphStart;
			while(j >= glyphStart && j < glyphEnd) {
				if(r.rightToLeft)
					x -= r.advanceWidths[j];
				cairo_glyph_t cairoGlyph;
				cairoGlyph.index = r.glyphs[j];
				cairoGlyph.x = x;
				cairoGlyph.y = r.position.y + r.baseline;
				//Stdout.format("x {0} y {1}", cairoGlyph.x, cairoGlyph.y).newline;
				glyphs.add(cairoGlyph);
				if(!r.rightToLeft)
					x += r.advanceWidths[j];
				r.rightToLeft ? j-- : j++;
			}
			//Stdout.format("start {0}, color: {1}", start, format.foreColor.B).newline;
			g.source = format.foreColor;
			cairo_show_glyphs(g.handle, glyphs.data.ptr, glyphs.count);
			glyphs.clear();
		}
	}
	// }}}

private:
	// {{{ font cache
	// Returns a scaled font matching the specified look. If the font is in the font cache
	// it will be returned from there. If it isn't in the cache, it will be created using a
	// backend specific function.
	// Note that the reference count on the scaled font is increased each time this function
	// is called. Therefore, releaseScaledFont() needs to be called once for each time
	// getScaledFont() is called.
	static cairo_scaled_font_t* getScaledFont(string family,
	                                          double size,
	                                          bool bold,
	                                          bool italic,
	                                          cairo_matrix_t ctm) {
		if(!fontCache)
			fontCache = new List!(FontCacheEntry);
		// set the translation to zero so that
		// 1. entryCtm == ctm can be used when searching through the cache, and it will still
		//    ignore the translation
		// 2. the CTM of every scaled font in the font cache has a translation of zero
		ctm.x0 = 0;
		ctm.y0 = 0;
		foreach(entry; fontCache) {
			if(entry.family == family && entry.size == size &&
			   entry.bold == bold && entry.italic == italic) {
				cairo_matrix_t entryCtm;
				cairo_scaled_font_get_ctm(entry.font, &entryCtm);
				// a font can only match another if they have the same CTM (except the
				// transformation can be different), so check that the CTMs are the same
				if(entryCtm == ctm) {
					cairo_scaled_font_reference(entry.font);
					return entry.font;
				}
			}
		}

		// since a matching font wasn't found in the cache, create it and add it to the cache
		FontCacheEntry entry;
		entry.font = backend_createScaledFont(family, size, bold, italic, &ctm);
		entry.family = family;
		entry.size = size;
		entry.bold = bold;
		entry.italic = italic;
		fontCache.add(entry);
		return entry.font;
	}
	// Decreases the reference count of the scaled font and removes it from the cache when its
	// reference count reaches zero.
	static void releaseScaledFont(cairo_scaled_font_t* font) {
		if(cairo_scaled_font_get_reference_count(font) == 1) {
			bool found = false;
			foreach(i, entry; fontCache) {
				if(entry.font == font) {
					fontCache.removeAt(i);
					found = true;
					break;
				}
			}
			assert(found);
		}
		cairo_scaled_font_destroy(font);
	}
	//}}}
}

struct FontCacheEntry {
	cairo_scaled_font_t* font;
	string family;
	double size;
	bool bold;
	bool italic;
}

private List!(FontCacheEntry) fontCache; // global in D1, thread local in D2

// this is to keep the TextLayout.runs List around until the destructor is called
List!(List!(Run)) runLists;

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

unittest {
	auto t = new TextLayout("Arial", 14);
	t.text = "The computer is black.";
	int[][] runs = [[0, 22]];
	int delegate(uint index) splitter;
	void checkRuns() {
		int i = 0;
		foreach(s, l, f; t.formatRuns(splitter)) {
			assert(runs[i][0] == s && runs[i][1] == l);
			i++;
		}
	}
	// no formatting or splitter
	checkRuns();

	// with a splitter but no formatting
	splitter = delegate int(uint i) { return [0, -1][i]; };
	checkRuns();
	splitter = delegate int(uint i) { return [22, -1][i]; };
	checkRuns();
	splitter = delegate int(uint i) { return [10, 15, -1][i]; };
	runs = [[0, 10], [10, 5], [15, 7]];
	checkRuns();
	splitter = null;

	// with formatting but no splitter
	t.setFontFamily("Tahoma", 4, 8);  // "computer"
	runs = [[0, 4], [4, 8], [12, 10]];
	checkRuns();

	t.setUnderline(LineStyle.Single, 12, 3);  // " is"
	runs = [[0, 4], [4, 8], [12, 3], [15,7]];
	checkRuns();  // test two FormatChanges at the same index

	t.setUnderline(LineStyle.Double, 0, 22);
	runs = [[0, 4], [4, 8], [12, 10]];
	checkRuns();  // test a FormatChange at beginning and at end

	splitter = delegate int(uint i) { return [2, 4, 21, -1][i]; };
	runs = [[0, 2], [2, 2], [4, 8], [12, 9], [21, 1]];
	checkRuns();  // test a split in middle of a format run and at the same index as a format run

	// TODO: test fontFormatRuns
}

unittest {
	auto surf = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 1, 1);
	auto cr = cairo_create(surf);
	cairo_surface_destroy(surf);
	auto g = new Graphics(cr);
	cairo_destroy(cr);

	// with 0 being the first line
	void assertLineRange(TextLayout t, int line, int start, int length) {
		float lastLineY;
		int startAct = -1, lengthAct = -1; // actual start and length of line
		foreach(run; t.runs) {
			if(run.position.y != lastLineY) {
				line--;
				if(line == -1) {
					startAct = run.start;
				} else if(line == -2) {
					lengthAct = run.start - startAct;
					break;
				}
			}
			lastLineY = run.position.y;
		}
		assert(startAct >= 0);
		if(lengthAct == -1)
			lengthAct = t.text.length - startAct;
		Stdout.format("test start: {0} len: {1} startAct: {2} lenAct: {3}", start, length, startAct, lengthAct).newline;
		assert(start == startAct && length == lengthAct);
	}
	void assertLinePosition(TextLayout t, int line, float x, float y) {
		float lastLineY;
		foreach(run; t.runs) {
			if(run.position.y != lastLineY) {
				line--;
				if(line == -1) // test the x of the first run on the line
					assert(run.position.x < x+0.01 && run.position.x > x-0.01);
			}
			if(line == -1)  // and test the y of every run on the line
				assert(run.position.y < y+0.01 && run.position.y > y-0.01);
			else if(line < -1)
				break;
			lastLineY = run.position.y;
		}
		assert(line < 0); // assert that there were enough lines
	}

	auto t = new TextLayout("Ahem", 10);
	t.text = "The quick brown fox jumps over the lazy dog.";

	// Test that lines are moved down when text on them is larger than the beginning.
	// Test that the second line is not too tall, since no text on it is larger.
	// Test that having a one character run at the end is handled correctly. (doesn't crash)
	t.setFontSize(12, 15, 1); // " "
	t.setFontSize(13, 16, 4); // "fox "
	t.setFontSize( 8, 43, 1); // "."
	t.layoutBoxes = [Rect(40, 30, 225, 100)];
	//The quick brown fox /jumps over the lazy /dog./
	t.draw(g);
	assertLineRange(t, 0,  0, 20); // line 0 has first 20 chars
	assertLineRange(t, 1, 20, 20); // line 1 has next 20 chars
	assertLineRange(t, 2, 40,  4); // line 2 has next 4 chars
	assertLinePosition(t, 0, 40, 30);
	assertLinePosition(t, 1, 40, 43);
	assertLinePosition(t, 2, 40, 53);

	// Test that when runs are cut off due to not fitting in layout boxes,
	// there is no assert failure in draw()
	t.layoutBoxes = [Rect(40, 30, 225, 24)];
	t.draw(g);

	// Test that layout boxes work:
	// that lines are wrapped to the width of the layout box and
	// that they are positioned correctly vertically.
	t.setFontSize(10, 0, t.text.length);
	t.layoutBoxes = [Rect(20, 20, 170, 24), Rect(200, 1000, 60, 33)];
	//The quick brown /fox jumps over /the /lazy /dog./
	t.draw(g);
	assertLineRange(t, 0,  0, 16);
	assertLineRange(t, 1, 16, 15);
	assertLineRange(t, 2, 31,  4);
	assertLineRange(t, 3, 35,  5);
	assertLineRange(t, 4, 40,  4);
	assertLinePosition(t, 0,  20,   20);
	assertLinePosition(t, 1,  20,   30);
	assertLinePosition(t, 2, 200, 1000);
	assertLinePosition(t, 3, 200, 1010);
	assertLinePosition(t, 4, 200, 1020);

/*
test that the height of a run on a line is not set to the height of the line (stays the height of the text
test that having taller text on a line, then shorter text, then that the next line is the right height
test that text is broken for line boxes
test having bigger text near end of line, and when line is moved down, first line box is smaller, so text is broken sooner
test that if text needs to be moved down and fewer chars fit on, that it is not moved down
*/

	// Test that a whole word is put on a line, even when the layout box is not wide enough.
	// Test that there is no crash when the first word is wider than the layout box.
	t.text = "Somebodyforgottousespaces, oh, thisisbad, I say.";
	t.layoutBoxes = [Rect(40, 30, 85, 50)];
	t.draw(g);
	assertLineRange(t, 0,  0, 27);
	assertLineRange(t, 1, 27,  4);
	assertLineRange(t, 2, 31, 11);
	assertLineRange(t, 3, 42,  6);
	assertLinePosition(t, 0, 40, 30);
	assertLinePosition(t, 1, 40, 40);
	assertLinePosition(t, 2, 40, 50);
	assertLinePosition(t, 3, 40, 60);

// write manual tests into showcase
}

