// testing with word العربية al-arabiyyah

/*
I may need to keep some info around (especially advance widths) so I can pass it to ScriptCPtoX(), ScriptXtoCP(), and other functions.

First, call ScriptItemize(). It will return *items* that have one script and direction.

My code will have a list of ranges where the formatting is the same. I need to split the items from ScriptItemize() into *runs* that have the same format, script, and direction. The run is an array of WCHARs (should be a slice).

Then, I call ScriptShape once for each of these runs, and it returns an array of the glyphs, among other things.

Now that I have the glyphs, I can pass them to ScriptPlace(), which returns an array of the advance widths for each of them. (By default they are in visual order, but you can request them in logical order.) I can edit these to apply the letter spacing. Kerning would also take place here, I believe. I think I would edit tab widths here too.

If the text needs justified, I can call ScriptJustify() with the advance widths (and other data) for the entire line. It will return updated advance widths.

I can call ScriptBreak() for each item from ScriptItemize(), passing it the info for the item. It will return an array with:

- Places in the item where it can be broken across lines
- Places in the item that the caret can move when left or right is pressed
- Places in the item the caret can move when Ctrl+Left/Right is pressed (words)
*/

import tango.io.Stdout;
import dynamin.c.windows;
import dynamin.core.string;
import dynamin.painting.text_layout;
import dynamin.all;
extern(Windows):
int callback(ENUMLOGFONTEX* elf, TEXTMETRIC*, DWORD, LPARAM) {
	int i = 0;
	for(; i < LF_FULLFACESIZE; i++)
		if(elf.elfFullName[i] == 0)
			break;

	int j = 0;
	for(; j < LF_FACESIZE; j++)
		if(elf.elfStyle[j] == 0)
			break;

	Stdout(elf.elfFullName[0..i])(" ... ")(elf.elfStyle[0..j]).newline;
	return 1;
}

void main() {
	//string text = "The first text to draw.";

	// a reasonable size of a paragraph
	//scope buf = new wchar[text.length < 256 ? 256 : 1536];
	//wchar[] wtext = text.toString16(buf);

	LOGFONT lf;
	lf.lfCharSet = 1; // DEFAULT_CHARSET
	lf.lfFaceName[0] = '\0';
	//EnumFontFamiliesEx(GetDC(null), &lf, &callback, 0, 0);
	Window w = new Window;
	w.text = "TextLayout test";
	auto t = new TextLayout("Garamond", 20);
	//t.text = "John said, 'I bought 24 eggs.' How many did you buy?";
	t.text = "Whenyouhaveareallylongword you approach -look, colors!- Fort Sutch, you will encounter a group of Imperial Guards, including an Imperial Guard Captain, who will request your assistance in defeating the Daedra pouring out of the nearby Oblivion Gate. The final Daedra you will need to defeat will be a leveled Dremora, who will emerge through the Gate as you approach it. When all the Daedra are defeated, return to the Captain. Speak with him, he will tell you to close the gate if you wish, but informs you that he will be staying at Fort Sutch per his orders.";
	//t.setForeColor(Color.Blue, 26, 5);
	t.setBold(true, 5, 4);
	t.setItalic(true, 2, 7);
	t.setFontFamily("Tahoma", 31, 3);
	t.setFontSize(35, 35, 4);
	t.setForeColor(Color.Blue, 40, 7);
	t.setForeColor(Color.Red, 47, 8);
	t.setBackColor(Color.Gold, 47, 8);
	w.content.painting += (PaintingEventArgs args) {
		try {
			t.draw(args.graphics);
		} catch(Exception e) {
			Stdout("Exception: (")(e.line)(") ")(e.msg).newline;
		}
	};
	w.content.resized += {
		auto sz = w.content.size;
		t.layoutBoxes = [Rect(0, 0, sz.width/2, sz.height/2), Rect(sz.width/2, sz.height/2, sz.width/2, sz.height/2)];
	};
	w.size = [640, 480];

	w.visible = true;
	Application.run(w);

}
/*
// Build thorough tests into showcase
class TextParagraph {
	// support kerning? GetKerningPairs() and KERNINGPAIR
	void layout(char[] text, ) {
	}

	char[] text;
	Tab[] tabs;
	uint defaultTabLocations = 0; // no default tabs
	// newLineSpacing = old * mul + delta
	// spacing after line, as part of it
	real lineSpacingMul = 1.0;   // percent
	real lineSpacingDelta = 0; // pixels
	Alignment alignment;

	uint width;
	delegate wrap

}
// Word uses SOH as placeholder for embedded obj
// Word uses VT for a soft return

struct Tab {
	int location;
	TabType type;
	TabLeading leading;
}
struct EmbeddedObject {
	Point location;
	Size size;
}
Format {
	string family;
	real size;
	bool bold;
	bool italic;
	// spaces are not underlined, overlined, or strikethrough unless
	// words on both sides are
	LineStyle underlined;
	LineStyle strikethrough;
	LineStyle overlined;
	bool superscript; // 2/3 of the height
	bool subscript;   // 2/3 of the height
	real letterSpacingMul = 1.0; // after letter, as part of it
	real letterSpacingAdd = 0;
	// ( ^ useful for Hexplore's column spacing)
	Color foreColor;
	Color backColor;


	offsetof
}
// underline, strikethrough, and overline line styles
enum LineStyle {
	None,
	Single,
	Double,
	Dotted,
	Dashed,
	Wavy
}
FormatChange {
	FormatType type;
	void apply(ref Format format) {

	}
	union Data {
		string family;
		real size;
		bool on; // bold and italic
		LineStyle lineStyle;
		real letterSpacing;
		Color color;
	}
}
enum FormatType : ubyte {
	Family, Size, Bold, Italic, Underline, Strikethrough, Overline,

}
*/
