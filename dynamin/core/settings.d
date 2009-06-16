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

module dynamin.core.settings;

import dynamin.core.string;
import tango.io.device.Conduit;
import tango.io.device.File;
import tango.io.device.Array;
import tango.io.stream.Text;
import tango.io.Stdout;
import tango.util.Convert;
import tango.core.Exception;

// TODO:
align(1)
struct Pixel32 {
version(BigEndian) {
	ubyte A;
	ubyte R;
	ubyte G;
	ubyte B;
} else {
	ubyte B;
	ubyte G;
	ubyte R;
	ubyte A;
}
}
class Color2 {
	Pixel32 ToPixel32() {
		Pixel32 px;
		return px;
	}
	string ToSetting() {
		auto px = ToPixel32();
		return format("{}, {}, {}", px.R, px.G, px.B);
	}
	static Color2 FromSetting(string str) {
		// allow "#AB00F2", "171, 0, 242"
		return null;
	}
}

string test = r"
; Here is a comment
[Main]
UndoLevels=500
# Here is another comment
CaretColor=255, 0, 0
LineNumsVisible=true

[RubyMode]
TabSize=4
";
unittest {
	auto settings = new Settings;
	settings.loadFromString(test);
	assert(settings.get("UndoLevels") == "500");
	assert(settings.get("TabSize", "RubyMode") == "4");
	assert(getSetting!(int)(settings, "UndoLevels") == 500);
	assert(getSetting!(bool)(settings, "LineNumsVisible") == true);
	Stdout(settings.saveToString()).newline;
}

/**
 * This class will read from and write to what is basically a Windows INI file.
 * Here is what a file would look like:
 * Example:
 * -----
 * ; Here is a comment
 * [Main]
 * UndoLevels=500
 * # Here is another comment
 * CaretColor=255, 0, 0
 * LineNumsVisible=true
 *
 * [RubyMode]
 * TabSize=4
 * -----
 */
class Settings {
protected:
	string[string][string] sections;
	string[] comment;
	void loadFromStream(InputStream stream) {
		auto input = new TextInput(stream);
		string section = MainSectionName;
		bool inStartComment = true;
		int lineNum = 0;
		foreach(string line; input) {
			lineNum++;
			// check for a line with just whitespace
			if(line.trim().length == 0)
				continue;

			// check for a comment
			if(line.trimLeft().startsWith(";") ||
					line.trimLeft().startsWith("#")) {
				if(inStartComment) {
					comment.length = comment.length + 1;
					comment[$-1] = line.trimLeft()[1..$].dup;
				}
				continue;
			}
			inStartComment = false;

			// check for a section header
			if(line.startsWith("[")) {
				if(!line.endsWith("]") || line.length < 3)
					throw new Exception("Invalid section on line " ~ to!(string)(lineNum));
				section = line[1..$-1].dup;
				continue;
			}

			// parse key=value line (quickly)
			int eqIndex;
			for(eqIndex = 0; eqIndex < line.length; ++eqIndex)
				if(line[eqIndex] == '=')
					break;
			if(eqIndex == line.length)
				throw new Exception("Invalid format on line " ~ to!(string)(lineNum));
			string value = line[eqIndex+1..$].unescape();
			sections[section][line[0..eqIndex].dup] = value;
		}
	}
	void saveToStream(OutputStream stream) {
		auto output = new TextOutput(stream);
		foreach(line; comment)
			output(';')(line).newline;
		foreach(string sectionName, string[string] sectionData; sections) {
			output('[')(sectionName)(']').newline;// TODO: newline before each section
			foreach(key, value; sectionData)
				output(key)('=')(value).newline; // TODO: escape?
		}
	}
public:
	const string MainSectionName = "Main";
	/**
	 * Parses the specified file.
	 */
	void load(string file) {
		scope f = new File(file);
		loadFromStream(f);
	}
	void loadFromString(string str) {
		scope a = new Array(str);
		loadFromStream(a);
	}
	string saveToString() {
		scope a = new Array(256, 80);
		saveToStream(a);
		return cast(string)a.slice(a.readable);
	}
	/**
	 *
	 * Examples:
	 * -----
	 * settings.get("UndoLevels");
	 * settings.get("TabSize", "RubyMode");
	 * -----
	 */
	string get(string name, string section = MainSectionName) {
		auto sect = section in sections;
		if(sect) {
			auto val = name in *sect;
			if(val)
				return *val;
		}
		return "";
	}

	/**
	 * Examples:
	 * -----
	 * settings.set("UndoLevels", "500")
	 * settings.set("TabSize", "4", "RubyMode");
	 * -----
	 */
	void set(string name, string value, string section = MainSectionName) {
		if(section.contains('[') || section.contains(']'))
			throw new IllegalArgumentException(
				"Section name cannot contain a bracket");
		if(name.contains('='))
			throw new IllegalArgumentException(
				"name cannot contain an equal sign");
		sections[section][name] = value;
	}
	/**
	 * Gets or sets the comment that appears at the beginning of the settings
	 * file. This is set when a file is read in.
	 */
	string[] commentLines() {
		return comment;
	}
	/// ditto
	void commentLines(string[] lines) {
		comment = lines;
	}
}

/**
 * Examples:
 * -----
 * getSetting!(int)(settings, "UndoLevels");
 * getSetting!(int)(settings, "TabSize", "RubyMode");
 * -----
 */
T getSetting(T)(Settings settings,
		string name, string section = Settings.MainSectionName) {
	string str = settings.get(name, section);
	static if(is(T == bool))
		return str == "true" || str == "yes" || str == "on";
	else static if(is(T : long))
		return cast(T)to!(T)(str);
	else
		return T.FromSetting(str);
}

/**
 * Examples:
 * -----
 * setSetting!(int)(settings, "UndoLevels", 500);
 * setSetting!(int)(settings, "TabSize", 4, "RubyMode");
 * -----
 */
void setSetting(T)(Settings settings,
		string name, T value, string section = Settings.MainSectionName) {
	string str;
	static if(is(T == bool))
		str = value ? "true" : "false";
	else static if(is(T : long))
		str = to!(string)(value);
	else
		str = T.ToSetting();

	settings.Set(name, str, section);
}

