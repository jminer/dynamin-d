
/*
 * Copyright Jordan Miner
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

module dynamin.painting.windows_text_layout;

public import dynamin.c.cairo;
public import dynamin.c.cairo_win32;
public import dynamin.c.windows;
public import dynamin.c.uniscribe;
public import dynamin.painting.graphics;
public import tango.io.Stdout;
public import tango.text.convert.Utf;
public import tango.math.Math;

//version = TextLayoutDebug;

template TextLayoutBackend() {
	uint charToWcharIndex(uint index) {
		uint wcharIndex = 0;
		foreach(wchar c; text[0..index])
			wcharIndex++;
		return wcharIndex;
	}
	uint wcharToCharIndex(uint wcharIndex) {
		uint decoded = 0, ate = 0, index = 0;
		while(decoded < wcharIndex) {
			decoded += (decode(text[index..$], ate) <= 0xFFFF ? 1 : 2);
			index += ate;
		}
		return index;
	}

	uint nextRight(uint index) {
		uint wIndex = charToWcharIndex(index);
		// this requires using the output from ScriptLayout to move in visual order
		return 0;
	}

	//{{{ font fallback
	static {
		int Latin;
		int Greek;
		int Cyrillic;
		int Armenian;
		int Georgian;
		int Hebrew;
		int Arabic;
		int Syriac;
		int Thaana;
		int Thai;
		int Devanagari;
		int Tamil;
		int Bengali;
		int Gurmukhi;
		int Gujarati;
		int Oriya;
		int Telugu;
		int Kannada;
		int Malayalam;
		int Lao;
		int Tibetan;
		//int Japanese;
		int Bopomofo;
		int CjkIdeographs;
		int CjkSymbols;
		int KoreanHangul;
	}
	static this() {
		Latin              = getUniscribeScript("JKL");
		Greek              = getUniscribeScript("ΠΡΣ");
		Cyrillic           = getUniscribeScript("КЛМ");
		Armenian           = getUniscribeScript("ԺԻԼ");
		Georgian           = getUniscribeScript("ႩႪႫ");
		Hebrew             = getUniscribeScript("הוז");
		Arabic             = getUniscribeScript("ثجح");
		Syriac             = getUniscribeScript("ܕܗܚ");
		Thaana             = getUniscribeScript("ގޏސ");
		Thai               = getUniscribeScript("ฆงจ");
		Devanagari         = getUniscribeScript("जझञ");
		Tamil              = getUniscribeScript("ஜஞட");
		Bengali            = getUniscribeScript("জঝঞ");
		Gurmukhi           = getUniscribeScript("ਜਝਞ");
		Gujarati           = getUniscribeScript("જઝઞ");
		Oriya              = getUniscribeScript("ଜଝଞ");
		Telugu             = getUniscribeScript("జఝఞ");
		Kannada            = getUniscribeScript("ಜಝಞ");
		Malayalam          = getUniscribeScript("ജഝഞ");
		Lao                = getUniscribeScript("ຄງຈ");
		Tibetan            = getUniscribeScript("ཇཉཊ");
		//Japanese           = getUniscribeScript("せゼｶ"); // TODO: on XP, returned more than 1 item
		Bopomofo           = getUniscribeScript("ㄐㄓㄗ"); // Chinese
		CjkIdeographs      = getUniscribeScript("丛东丝");
		CjkSymbols         = getUniscribeScript("、〜㈬");
		KoreanHangul       = getUniscribeScript("갠흯㉡");
	}
	// returns the Uniscribe script number (SCRIPT_ANALYSIS.eScript) from the specified sample text
	static int getUniscribeScript(const(wchar)[] sample) {
		SCRIPT_ITEM[5] items;
		int itemsProcessed;
		HRESULT r = ScriptItemize(sample.ptr,
		                          sample.length,
		                          items.length-1,
		                          null,
		                          null,
		                          items.ptr,
		                          &itemsProcessed);
		assert(r == 0);
		assert(itemsProcessed == 1);
		return items[0].a.eScript.get();
	}

	// adds fallback fonts to the specified fallbacks array
	void getFontFallbacks(int script, const(wchar)[][] fallbacks) {
		int i = 0;
		void addFallback(const(wchar)[] str) {
			fallbacks[i++] = str;
		}
		if(script == Latin || script == Greek || script == Cyrillic)
			addFallback("Times New Roman");
		else if(script == Hebrew || script == Arabic)
			addFallback("Times New Roman");
		else if(script == Armenian || script == Georgian)
			addFallback("Sylfaen"); // fits in well with English fonts
		else if(script == Bengali)
			addFallback("Vrinda");
		else if(Devanagari)
			addFallback("Mangal");
		else if(script == Gujarati)
			addFallback("Shruti");
		else if(script == Gurmukhi)
			addFallback("Raavi");
		else if(script == Kannada)
			addFallback("Tunga");
		else if(script == Malayalam)
			addFallback("Kartika");
		else if(script == Syriac)
			addFallback("Estrangelo Edessa");
		else if(script == Tamil)
			addFallback("Latha");
		else if(script == Telugu)
			addFallback("Gautami");
		else if(script == Thaana)
			addFallback("MV Boli");
		else if(script == Thai)
			addFallback("Tahoma"); // fits in well with English fonts
		//else if(script == Japanese)
		//	addFallback("MS Mincho"); // Meiryo doesn't fit in with SimSun...
		else if(script == Bopomofo || script == CjkIdeographs || script == CjkSymbols)
			addFallback("SimSun");
		else if(script == KoreanHangul)
			addFallback("Batang");
		else if(script == Oriya)
			addFallback("Kalinga");    // new with Vista
		else if(script == Lao)
			addFallback("DokChampa");  // new with Vista
		else if(script == Tibetan)
			addFallback("Microsoft Himalaya"); // new with Vista

		// Arial Unicode MS is not shipped with Windows, but is with Office
		addFallback("Arial Unicode MS");
	}
	//}}}

	/*bool isRightAligned() {
		return alignment == TextAlignment.Right ||
		       ((alignment == TextAlignment.Justify || alignment == TextAlignment.Natural) &&
		        items[0].a.fRTL);
	}*/
	/*struct Run {
		double height;
		int wtextIndex;
		int itemIndex;
		WORD[] logClusters;        // length == length of text as UTF-16
		WORD[] glyphs;
		SCRIPT_VISATTR[] visAttrs; // length == glyphs.length
		int[] advanceWidths;       // length == glyphs.length
		GOFFSET[] offsets;         // length == glyphs.length
	}*/
	// TODO: should save memory if logClusters, glyphs, visAttrs, advanceWidths, & offsets
	//       were made as one big array and these were just slices of them
	//       Then reuse the big array every time in layout()

	void backend_splitRun(uint runIndex, uint splitIndex) {
		visAttrs.insert(visAttrs[runIndex], runIndex);
		visAttrs[runIndex]   = visAttrs[runIndex][0..runs[runIndex].glyphs.length];
		visAttrs[runIndex+1] = visAttrs[runIndex+1][runs[runIndex].glyphs.length..$];

		offsets.insert(offsets[runIndex], runIndex);
		offsets[runIndex]   = offsets[runIndex][0..runs[runIndex].glyphs.length];
		offsets[runIndex+1] = offsets[runIndex+1][runs[runIndex].glyphs.length..$];
	}
	// returns the number of UTF-8 code units (bytes) it takes to encode the
	// specified UTF-16 code unit; returns 4 for a high surrogate and 0 for a low surrogate
	int getUtf8Width(wchar c) {
		if(c >= 0x00 && c <= 0x7F) {
			return 1;
		} else if(c >= 0x0080 && c <= 0x07FF) {
			return 2;
		} else if(isHighSurrogate(c)) {
			return 4;
		} else if(isLowSurrogate(c)) {
			return 0;
		} else {
			return 3;
		}
	}

	SCRIPT_ITEM[] items;
	List!(SCRIPT_VISATTR[]) visAttrs; // one for each Run, same length as Run.glyphs
	List!(GOFFSET[]) offsets;         // one for each Run, same length as Run.glyphs
	void backend_preprocess(Graphics g) {
		wchar[] wtext = toString16(text);

		//{{{ call ScriptItemize() and ScriptBreak()
		SCRIPT_CONTROL scriptControl;
		SCRIPT_STATE scriptState;
		// TODO: digit substitution?

		if(items.length < 50)
			items.length = 50;
		int itemsProcessed;
		// On 7, ScriptItemize returns E_OUTOFMEMORY outright if the 3rd param isn't at least 12.
		// Every period, question mark, quotation mark, start of number, etc. starts a new item.
		// A short English sentence can easily have 10 items.
		while(ScriptItemize(wtext.ptr,
		                    wtext.length,
		                    items.length-1,
		                    &scriptControl,
		                    &scriptState,
		                    items.ptr,
		                    &itemsProcessed) == E_OUTOFMEMORY) {
			items.length = items.length * 2;
		}
		items = items[0..itemsProcessed+1]; // last item is the end of string

		for(int i = 0; i < logAttrs.length; ++i) // clear array from previous use
			logAttrs[i] = LogAttr.init;
		logAttrs.length = text.length;
		int laIndex = 0;

		SCRIPT_LOGATTR[] tmpAttrs;
		bool lastWhitespace = false;
		for(int i = 0; i < items.length-1; ++i) {
			wchar[] itemText = wtext[items[i].iCharPos..items[i+1].iCharPos];
			tmpAttrs.length = itemText.length;
			HRESULT result = ScriptBreak(itemText.ptr, itemText.length, &items[i].a, tmpAttrs.ptr);
			if(FAILED(result))
				throw new Exception("ScriptBreak() failed");

			// ScriptBreak() does not set fSoftBreak for the first character of items, even
			// when it needs to be (it doesn't know what comes before them...). This loop sets
			// it for characters after a breakable whitespace.
			for(int j = 0; j < tmpAttrs.length; ++j) {
				if(tmpAttrs[j].fWhiteSpace.get()) {
					lastWhitespace = true;
				} else {
					if(lastWhitespace) // not whitespace, but last char was
						tmpAttrs[j].fSoftBreak.set(true);
					lastWhitespace = false;
				}

				// have to convert the SCRIPT_LOGATTR array, which corresponds with the UTF-16
				// encoding, to the LogAttr array, which corresponds with the UTF-8 encoding
				if(tmpAttrs[j].fSoftBreak.get())
					logAttrs[laIndex].softBreak = true;
				if(tmpAttrs[j].fCharStop.get())
					logAttrs[laIndex].clusterStart = true;
				if(tmpAttrs[j].fWordStop.get())
					logAttrs[laIndex].wordStart = true;

				laIndex += getUtf8Width(itemText[j]);
				if(isHighSurrogate(itemText[j]))
					j++; // skip the low surrogate
			}
		}
		assert(laIndex == logAttrs.length);
		//}}}

		// ScriptShape and some other functions need an HDC. If the target surface is win32,
		// just use its DC. Otherwise, create a 1x1 DIB and use its DC.
		cairo_surface_t* targetSurface = cairo_get_target(g.handle);
		cairo_surface_flush(targetSurface);
		cairo_t* cr = g.handle;
		HDC hdc = cairo_win32_surface_get_dc(targetSurface);
		cairo_surface_t* tmpSurface;
		if(!hdc) {
			cairo_format_t format = CAIRO_FORMAT_ARGB32;
			if(cairo_surface_get_type(targetSurface) == CAIRO_SURFACE_TYPE_IMAGE)
				format = cairo_image_surface_get_format(targetSurface);
			tmpSurface = cairo_win32_surface_create_with_dib(format, 1, 1);
			cr = cairo_create(tmpSurface);
			hdc = cairo_win32_surface_get_dc(tmpSurface);
			assert(hdc != null);
		}
		scope(exit) {
			if(tmpSurface) {
				cairo_destroy(cr);
				cairo_surface_destroy(tmpSurface);
			}
		}

		clearRuns(); // releaseScaledFont() must be called when a run is removed

		if(!visAttrs)
			visAttrs = new List!(SCRIPT_VISATTR[]);
		visAttrs.clear();
		if(!offsets)
			offsets = new List!(GOFFSET[]);
		offsets.clear();
		List!(BYTE) levels = new List!(BYTE)(items.length+4); // 4 gives padding for 2 formattings

		SaveDC(hdc);
		int splitter(uint i) {
			return i < items.length ? wcharToCharIndex(items[i].iCharPos) : -1;
		}
		int itemIndex = 0;
		// Merge the SCRIPT_ITEMs with runs that have the same format
		// The only formats that matter here are the ones that affect the size or
		// shape of characters, so use &fontFormatRuns
		foreach(start, length, format; fontFormatRuns(&splitter)) {
			uint wstart = charToWcharIndex(start);
			uint wend = charToWcharIndex(start+length);
			if(items[itemIndex+1].iCharPos == wstart)
				itemIndex++;

			levels.add(cast(BYTE)items[itemIndex].a.s.uBidiLevel.get());

			cairo_matrix_t ctm;
			cairo_get_matrix(cr, &ctm);
			cairo_scaled_font_t* font = getScaledFont(format.fontFamily,
													  format.fontSize,
													  format.bold,
													  format.italic,
													  ctm);
			cairo_win32_scaled_font_select_font(font, hdc);
			// Cairo sets up the HDC to be scaled 32 times larger than stuff will be drawn.
			// get_metrics_factor returns the factor necessary to convert to font space units.
			// Font space units need multiplied by the font size to get device units
			// multipling by to_dev converts from logical units to device units
			double to_dev = cairo_win32_scaled_font_get_metrics_factor(font) * format.fontSize;

			SCRIPT_CACHE cache = null;
			scope(exit) ScriptFreeCache(&cache);

			wchar[] range = wtext[wstart..wend];

			WORD[] outGlyphs = new WORD[range.length * 3 / 2 + 16];
			WORD[] logClust = new WORD[range.length];
			SCRIPT_VISATTR[] sva = new SCRIPT_VISATTR[outGlyphs.length];
			int glyphsReturned;
			do {
				HRESULT result = ScriptShape(hdc,
											 &cache,
											 range.ptr,
											 range.length,
											 outGlyphs.length,
											 &items[itemIndex].a,
											 outGlyphs.ptr,
											 logClust.ptr,
											 sva.ptr,
											 &glyphsReturned);
				if(result == E_OUTOFMEMORY) {
					outGlyphs.length = outGlyphs.length * 3 / 2;
					sva.length = outGlyphs.length;
					continue;
				} else if(result == USP_E_SCRIPT_NOT_IN_FONT) {
					// TODO: font fallback
				}
				/*SCRIPT_FONTPROPERTIES fontProps;
				ScriptGetFontProperties(hdc, &cache, &fontProps);
				Stdout("*****Blank: ")(fontProps.wgBlank).newline;
				Stdout(fontProps.wgDefault).newline;*/
			} while(false);
			outGlyphs = outGlyphs[0..glyphsReturned];
			sva = sva[0..glyphsReturned];
			visAttrs.add(sva);

			int[] advance = new int[outGlyphs.length];
			GOFFSET[] goffset = new GOFFSET[outGlyphs.length];
			// the docs mistakenly say the GOFFSET array is optional,
			// but it is actually the ABC structure
			if(FAILED(ScriptPlace(hdc,
								  &cache,
								  outGlyphs.ptr,
								  outGlyphs.length,
								  sva.ptr,
								  &items[itemIndex].a,
								  advance.ptr,
								  goffset.ptr,
								  null)))
				throw new Exception("ScriptPlace failed");
			for(int i = 0; i < goffset.length; ++i) {
				goffset[i].du = cast(LONG)(goffset[i].du * to_dev);
				goffset[i].dv = cast(LONG)(goffset[i].dv * to_dev);
			}
			offsets.add(goffset);
			// TODO: handle errors well
			// TODO: kerning here

			Run run;
			run.font = font;
			cairo_font_extents_t extents;
			cairo_scaled_font_extents(run.font, &extents);
			run.height = extents.height;

			run.start = start;
			run.length = length;
			run.rightToLeft = items[itemIndex].a.fRTL.get() ? true : false;

			run.clusterMap = new uint[run.length];
			int clusterIndex = 0;
			for(int i = 0; i < logClust.length; ++i) {
				int width = getUtf8Width(range[i]);
				if(isHighSurrogate(range[i]))
					i++; // skip the low surrogate
				for(; width > 0; --width) {
					run.clusterMap[clusterIndex] = logClust[i];
					clusterIndex++;
				}
			}
			assert(clusterIndex == run.length);

			run.glyphs = new uint[outGlyphs.length];
			for(int i = 0; i < outGlyphs.length; ++i)
				run.glyphs[i] = outGlyphs[i];

			run.advanceWidths = new float[advance.length];
			for(int i = 0; i < advance.length; ++i)
				run.advanceWidths[i] = advance[i] * to_dev;

			runs.add(run);

			cairo_win32_scaled_font_done_font(font);

		}
		RestoreDC(hdc, -1);
		assert(itemIndex == items.length-2); // last item is end of string

		// fill in visToLogMap
		visToLogMap = new uint[runs.count];
		if(FAILED( ScriptLayout(levels.count, levels.data.ptr, cast(int*)visToLogMap.ptr, null) ))
			throw new Exception("ScriptLayout() failed");

	}

	static cairo_scaled_font_t* backend_createScaledFont(string family,
	                                                     double size,
	                                                     bool bold,
	                                                     bool italic,
	                                                     cairo_matrix_t* ctm) {
		LOGFONT lf;
		lf.lfHeight = -cast(int)size; // is this ignored by cairo? uses font_matrix instead?
		lf.lfWeight = bold ? 700 : 400;
		lf.lfItalic = italic;
		lf.lfCharSet = 1; // DEFAULT_CHARSET
		auto tmp = toString16(family);
		lf.lfFaceName[0..tmp.length] = tmp;
		lf.lfFaceName[tmp.length] = '\0';

		auto face = cairo_win32_font_face_create_for_logfontw(&lf);
		scope(exit) cairo_font_face_destroy(face);

		cairo_matrix_t font_matrix;
		cairo_matrix_init_scale(&font_matrix, size, size);
		return cairo_scaled_font_create(face, &font_matrix, ctm, cairo_font_options_create());
	}
}
