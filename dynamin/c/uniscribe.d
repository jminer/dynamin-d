module dynamin.c.uniscribe;

/*
 * A complete binding to Uniscribe.
 */

import dynamin.c.windows;

version(build) { pragma(link, usp10); }

// TODO: move to a general place?
// http://www.digitalmars.com/webnews/newsgroups.php?art_group=digitalmars.D.learn&article_id=1507
template BitField(uint start, uint count, alias data, type = uint) {
	static assert((1L << (start + count)) - 1 <= data.max);

	const typeof(data) mask = (1UL << count) - 1;

	type get() {
		return cast(type) ((data >> start) & mask);
	}

	type set(type value) {
		data = (data & ~(mask << start)) |
			((cast(typeof(data)) value & mask) << start);
		return value;
	}
}

extern(C):

const int USPBUILD = 0400;

enum {
	SCRIPT_UNDEFINED = 0
}

//#define USP_E_SCRIPT_NOT_IN_FONT  MAKE_HRESULT(SEVERITY_ERROR,FACILITY_ITF,0x200)

alias void* SCRIPT_CACHE;

HRESULT ScriptFreeCache(SCRIPT_CACHE* psc);

struct SCRIPT_CONTROL { // 32 bits
	DWORD fields;
	mixin BitField!( 0, 16, fields) uDefaultLanguage;
	mixin BitField!(16,  1, fields) fContextDigits;
	mixin BitField!(17,  1, fields) fInvertPreBoundDir;
	mixin BitField!(18,  1, fields) fInvertPostBoundDir;
	mixin BitField!(19,  1, fields) fLinkStringBefore;
	mixin BitField!(20,  1, fields) fLinkStringAfter;
	mixin BitField!(21,  1, fields) fNeutralOverride;
	mixin BitField!(22,  1, fields) fNumericOverride;
	mixin BitField!(23,  1, fields) fLegacyBidiClass;
	mixin BitField!(24,  8, fields) fReserved;

	/*
	DWORD uDefaultLanguage    :16;
	DWORD fContextDigits      :1;

	DWORD fInvertPreBoundDir  :1;
	DWORD fInvertPostBoundDir :1;
	DWORD fLinkStringBefore   :1;
	DWORD fLinkStringAfter    :1;
	DWORD fNeutralOverride    :1;
	DWORD fNumericOverride    :1;
	DWORD fLegacyBidiClass    :1;
	DWORD fReserved           :8;
	*/
}

struct SCRIPT_STATE { // 16 bits
	WORD fields;
	mixin BitField!( 0, 5, fields, WORD) uBidiLevel;
	mixin BitField!( 5, 1, fields, WORD) fOverrideDirection;
	mixin BitField!( 6, 1, fields, WORD) fInhibitSymSwap;
	mixin BitField!( 7, 1, fields, WORD) fCharShape;
	mixin BitField!( 8, 1, fields, WORD) fDigitSubstitute;
	mixin BitField!( 9, 1, fields, WORD) fInhibitLigate;
	mixin BitField!(10, 1, fields, WORD) fDisplayZWG;
	mixin BitField!(11, 1, fields, WORD) fArabicNumContext;
	mixin BitField!(12, 1, fields, WORD) fGcpClusters;
	mixin BitField!(13, 1, fields, WORD) fReserved;
	mixin BitField!(14, 2, fields, WORD) fEngineReserved;

	/*
	WORD uBidiLevel         :5;
	WORD fOverrideDirection :1;
	WORD fInhibitSymSwap    :1;
	WORD fCharShape         :1;
	WORD fDigitSubstitute   :1;
	WORD fInhibitLigate     :1;
	WORD fDisplayZWG        :1;
	WORD fArabicNumContext  :1;
	WORD fGcpClusters       :1;
	WORD fReserved          :1;
	WORD fEngineReserved    :2;
	*/
}

struct SCRIPT_ANALYSIS { // 16 bits +
	WORD fields;
	mixin BitField!( 0, 10, fields, WORD) eScript;
	mixin BitField!(10,  1, fields, WORD) fRTL;
	mixin BitField!(11,  1, fields, WORD) fLayoutRTL;
	mixin BitField!(12,  1, fields, WORD) fLinkBefore;
	mixin BitField!(13,  1, fields, WORD) fLinkAfter;
	mixin BitField!(14,  1, fields, WORD) fLogicalOrder;
	mixin BitField!(15,  1, fields, WORD) fNoGlyphIndex;

	/*
	WORD eScript         :10;
	WORD fRTL            :1;
	WORD fLayoutRTL      :1;
	WORD fLinkBefore     :1;
	WORD fLinkAfter      :1;
	WORD fLogicalOrder   :1;
	WORD fNoGlyphIndex   :1;
	*/
	SCRIPT_STATE s;
}

struct SCRIPT_ITEM {
	int iCharPos;
	SCRIPT_ANALYSIS a;
}

HRESULT ScriptItemize(
	/*const*/ WCHAR* pwcInChars,
	int cInChars,
	int cMaxItems,
	/*const*/ SCRIPT_CONTROL* psControl,
	/*const*/ SCRIPT_STATE* psState,
	SCRIPT_ITEM* pItems,
	int* pcItems);

HRESULT ScriptLayout(
	int cRuns,
	/*const*/ BYTE* pbLevel,
	int* piVisualToLogical,
	int* piLogicalToVisual);

enum SCRIPT_JUSTIFY {
	SCRIPT_JUSTIFY_NONE           = 0,
	SCRIPT_JUSTIFY_ARABIC_BLANK   = 1,
	SCRIPT_JUSTIFY_CHARACTER      = 2,
	SCRIPT_JUSTIFY_RESERVED1      = 3,
	SCRIPT_JUSTIFY_BLANK          = 4,
	SCRIPT_JUSTIFY_RESERVED2      = 5,
	SCRIPT_JUSTIFY_RESERVED3      = 6,
	SCRIPT_JUSTIFY_ARABIC_NORMAL  = 7,
	SCRIPT_JUSTIFY_ARABIC_KASHIDA = 8,
	SCRIPT_JUSTIFY_ARABIC_ALEF    = 9,
	SCRIPT_JUSTIFY_ARABIC_HA      = 10,
	SCRIPT_JUSTIFY_ARABIC_RA      = 11,
	SCRIPT_JUSTIFY_ARABIC_BA      = 12,
	SCRIPT_JUSTIFY_ARABIC_BARA    = 13,
	SCRIPT_JUSTIFY_ARABIC_SEEN    = 14,
	SCRIPT_JUSTIFY_RESERVED4      = 15,
}

struct SCRIPT_VISATTR { // 16 bits
	WORD fields;
	mixin BitField!(0, 4, fields, WORD) uJustification;
	mixin BitField!(4, 1, fields, WORD) fClusterStart;
	mixin BitField!(5, 1, fields, WORD) fDiacritic;
	mixin BitField!(6, 1, fields, WORD) fZeroWidth;
	mixin BitField!(7, 1, fields, WORD) fReserved;
	mixin BitField!(8, 8, fields, WORD) fShapeReserved;

	/*
	WORD uJustification :4;
	WORD fClusterStart  :1;
	WORD fDiacritic     :1;
	WORD fZeroWidth     :1;
	WORD fReserved      :1;
	WORD fShapeReserved :8;
	*/
}

HRESULT ScriptShape(
	HDC hdc,
	SCRIPT_CACHE* psc,
	/*const*/ WCHAR* pwcChars,
	int cChars,
	int cMaxGlyphs,
	SCRIPT_ANALYSIS* psa,
	WORD* pwOutGlyphs,
	WORD* pwLogClust,
	SCRIPT_VISATTR* psva,
	int* pcGlyphs);

struct GOFFSET {
	LONG du;
	LONG dv;
}

HRESULT ScriptPlace(
	HDC hdc,
	SCRIPT_CACHE* psc,
	/*const*/ WORD* pwGlyphs,
	int cGlyphs,
	/*const*/ SCRIPT_VISATTR* psva,
	SCRIPT_ANALYSIS* psa,
	int* piAdvance,
	GOFFSET* pGoffset,
	ABC* pABC);

HRESULT ScriptTextOut(
	/*const*/ HDC hdc,
	SCRIPT_CACHE* psc,
	int x,
	int y,
	UINT fuOptions,
	/*const*/ RECT* lprc,
	/*const*/ SCRIPT_ANALYSIS* psa,
	/*const*/ WCHAR* pwcReserved,
	int iReserved,
	/*const*/ WORD* pwGlyphs,
	int cGlyphs,
	/*const*/ int* piAdvance,
	/*const*/ int* piJustify,
	/*const*/ GOFFSET* pGoffset);

HRESULT ScriptJustify(
	/*const*/ SCRIPT_VISATTR* psva,
	/*const*/ int* piAdvance,
	int cGlyphs,
	int iDx,
	int iMinKashida,
	int* piJustify);

struct SCRIPT_LOGATTR { // 8 bits
	BYTE fields;
	mixin BitField!(0, 1, fields, BYTE) fSoftBreak;
	mixin BitField!(1, 1, fields, BYTE) fWhiteSpace;
	mixin BitField!(2, 1, fields, BYTE) fCharStop;
	mixin BitField!(3, 1, fields, BYTE) fWordStop;
	mixin BitField!(4, 1, fields, BYTE) fInvalid;
	mixin BitField!(5, 3, fields, BYTE) fReserved;

	/*
	BYTE fSoftBreak  :1;
	BYTE fWhiteSpace :1;
	BYTE fCharStop   :1;
	BYTE fWordStop   :1;
	BYTE fInvalid    :1;
	BYTE fReserved   :3;
	*/
}

HRESULT ScriptBreak(
	/*const*/ WCHAR* pwcChars,
	int cChars,
	/*const*/ SCRIPT_ANALYSIS* psa,
	SCRIPT_LOGATTR* psla);

HRESULT ScriptCPtoX(
	int iCP,
	BOOL fTrailing,
	int cChars,
	int cGlyphs,
	/*const*/ WORD* pwLogClust,
	/*const*/ SCRIPT_VISATTR* psva,
	/*const*/ int* piAdvance,
	/*const*/ SCRIPT_ANALYSIS* psa,
	int* piX);

HRESULT ScriptXtoCP(
	int iX,
	int cChars,
	int cGlyphs,
	/*const*/ WORD* pwLogClust,
	/*const*/ SCRIPT_VISATTR* psva,
	/*const*/ int* piAdvance,
	/*const*/ SCRIPT_ANALYSIS* psa,
	int* piCP,
	int* piTrailing);

HRESULT ScriptGetLogicalWidths(
	/*const*/ SCRIPT_ANALYSIS* psa,
	int cChars,
	int cGlyphs,
	/*const*/ int* piGlyphWidth,
	/*const*/ WORD* pwLogClust,
	/*const*/ SCRIPT_VISATTR* psva,
	int* piDx);

HRESULT ScriptApplyLogicalWidth(
	/*const*/ int* piDx,
	int cChars,
	int cGlyphs,
	/*const*/ WORD* pwLogClust,
	/*const*/ SCRIPT_VISATTR* psva,
	/*const*/ int* piAdvance,
	/*const*/ SCRIPT_ANALYSIS* psa,
	ABC* pABC,
	int* piJustify);

enum {
	SGCM_RTL = 0x00000001
}

HRESULT ScriptGetCMap(
	HDC hdc,
	SCRIPT_CACHE* psc,
	/*const*/ WCHAR* pwcInChars,
	int cChars,
	DWORD dwFlags,
	WORD* pwOutGlyphs);

HRESULT ScriptGetGlyphABCWidth(
	HDC hdc,
	SCRIPT_CACHE* psc,
	WORD wGlyph,
	ABC* pABC);

struct SCRIPT_PROPERTIES { // 37 bits
	DWORD fields1;
	DWORD fields2;
	mixin BitField!( 0, 16, fields1) langid;
	mixin BitField!(16,  1, fields1) fNumeric;
	mixin BitField!(17,  1, fields1) fComplex;
	mixin BitField!(18,  1, fields1) fNeedsWordBreaking;
	mixin BitField!(19,  1, fields1) fNeedsCaretInfo;
	mixin BitField!(20,  8, fields1) bCharSet;
	mixin BitField!(28,  1, fields1) fControl;
	mixin BitField!(29,  1, fields1) fPrivateUseArea;
	mixin BitField!(30,  1, fields1) fNeedsCharacterJustify;
	mixin BitField!(31,  1, fields1) fInvalidGlyph;
	mixin BitField!( 0,  1, fields2) fInvalidLogAttr;
	mixin BitField!( 1,  1, fields2) fCDM;
	mixin BitField!( 2,  1, fields2) fAmbiguousCharSet;
	mixin BitField!( 3,  1, fields2) fClusterSizeVaries;
	mixin BitField!( 4,  1, fields2) fRejectInvalid;

	/*
	DWORD langid                 :16;
	DWORD fNumeric               :1;
	DWORD fComplex               :1;
	DWORD fNeedsWordBreaking     :1;
	DWORD fNeedsCaretInfo        :1;
	DWORD bCharSet               :8;
	DWORD fControl               :1;
	DWORD fPrivateUseArea        :1;
	DWORD fNeedsCharacterJustify :1;
	DWORD fInvalidGlyph          :1;
	DWORD fInvalidLogAttr        :1;
	DWORD fCDM                   :1;
	DWORD fAmbiguousCharSet      :1;
	DWORD fClusterSizeVaries     :1;
	DWORD fRejectInvalid         :1;
	*/
}

HRESULT ScriptGetProperties(
	/*const*/ SCRIPT_PROPERTIES*** ppSp,
	int* piNumScripts);

struct SCRIPT_FONTPROPERTIES {
	int  cBytes;
	WORD wgBlank;
	WORD wgDefault;
	WORD wgInvalid;
	WORD wgKashida;
	int  iKashidaWidth;
}

HRESULT ScriptGetFontProperties(
	HDC hdc,
	SCRIPT_CACHE* psc,
	SCRIPT_FONTPROPERTIES* sfp);

HRESULT ScriptCacheGetHeight(
	HDC hdc,
	SCRIPT_CACHE* psc,
	int* tmHeight);

enum {
	SSA_PASSWORD        = 0x00000001,
	SSA_TAB             = 0x00000002,
	SSA_CLIP            = 0x00000004,
	SSA_FIT             = 0x00000008,
	SSA_DZWG            = 0x00000010,
	SSA_FALLBACK        = 0x00000020,
	SSA_BREAK           = 0x00000040,
	SSA_GLYPHS          = 0x00000080,
	SSA_RTL             = 0x00000100,
	SSA_GCP             = 0x00000200,
	SSA_HOTKEY          = 0x00000400,
	SSA_METAFILE        = 0x00000800,
	SSA_LINK            = 0x00001000,
	SSA_HIDEHOTKEY      = 0x00002000,
	SSA_HOTKEYONLY      = 0x00002400,

	SSA_FULLMEASURE     = 0x04000000,
	SSA_LPKANSIFALLBACK = 0x08000000,
	SSA_PIDX            = 0x10000000,
	SSA_LAYOUTRTL       = 0x20000000,
	SSA_DONTGLYPH       = 0x40000000,
	SSA_NOKASHIDA       = 0x80000000,
}

struct SCRIPT_TABDEF {
	int cTabStops;
	int iScale;
	int* pTabStops;
	int iTabOrigin;
}

alias void* SCRIPT_STRING_ANALYSIS;

HRESULT ScriptStringAnalyse(
	HDC hdc,
	/*const*/ void* pString,
	int cString,
	int cGlyphs,
	int iCharset,
	DWORD dwFlags,
	int iReqWidth,
	SCRIPT_CONTROL* psControl,
	SCRIPT_STATE* psState,
	/*const*/ int* piDx,
	SCRIPT_TABDEF* pTabdef,
	/*const*/ BYTE* pbInClass,
	SCRIPT_STRING_ANALYSIS* pssa);

HRESULT ScriptStringFree(SCRIPT_STRING_ANALYSIS* pssa);

/*const*/ SIZE* ScriptString_pSize(SCRIPT_STRING_ANALYSIS ssa);

/*const*/ int* ScriptString_pcOutChars(SCRIPT_STRING_ANALYSIS ssa);

/*const*/ SCRIPT_LOGATTR* ScriptString_pLogAttr(SCRIPT_STRING_ANALYSIS ssa);

HRESULT ScriptStringGetOrder(SCRIPT_STRING_ANALYSIS ssa, UINT* puOrder);

HRESULT ScriptStringCPtoX(
	SCRIPT_STRING_ANALYSIS ssa,
	int icp,
	BOOL fTrailing,
	int* pX);

HRESULT ScriptStringXtoCP(
	SCRIPT_STRING_ANALYSIS ssa,
	int iX,
	int* piCh,
	int* piTrailing);

HRESULT ScriptStringGetLogicalWidths(SCRIPT_STRING_ANALYSIS ssa, int* piDx);

HRESULT ScriptStringValidate(SCRIPT_STRING_ANALYSIS ssa);

HRESULT ScriptStringOut(
	SCRIPT_STRING_ANALYSIS ssa,
	int iX,
	int iY,
	UINT uOptions,
	/*const*/ RECT* prc,
	int iMinSel,
	int iMaxSel,
	BOOL fDisabled);

enum {
	SIC_COMPLEX    = 1,
	SIC_ASCIIDIGIT = 2,
	SIC_NEUTRAL    = 4,
}

HRESULT ScriptIsComplex(
    /*const*/ WCHAR* pwcInChars,
    int cInChars,
    DWORD dwFlags);

struct SCRIPT_DIGITSUBSTITUTE {
	DWORD fields1;
	DWORD fields2;
	mixin BitField!( 0, 16, fields1) NationalDigitLanguage;
	mixin BitField!(16, 16, fields1) TraditionalDigitLanguage;
	mixin BitField!( 0,  8, fields2) DigitSubstitute;

	/*
	DWORD NationalDigitLanguage    :16;
	DWORD TraditionalDigitLanguage :16;
	DWORD DigitSubstitute          :8;
	*/
	DWORD dwReserved;
}

HRESULT ScriptRecordDigitSubstitution(
	LCID Locale,
	SCRIPT_DIGITSUBSTITUTE* psds);

enum {
	SCRIPT_DIGITSUBSTITUTE_CONTEXT     = 0,
	SCRIPT_DIGITSUBSTITUTE_NONE        = 1,
	SCRIPT_DIGITSUBSTITUTE_NATIONAL    = 2,
	SCRIPT_DIGITSUBSTITUTE_TRADITIONAL = 3,
}

HRESULT ScriptApplyDigitSubstitution(
	/*const*/ SCRIPT_DIGITSUBSTITUTE* psds,
	SCRIPT_CONTROL* psc,
	SCRIPT_STATE* pss);


