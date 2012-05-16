
/*
 * Copyright Jordan Miner
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file BOOST_LICENSE.txt or copy at
 * http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module dynamin.core.file;

import dynamin.core.string;
import tango.io.device.File;
import tango.io.UnicodeFile;

ubyte[] readFileBytes(string file) {
	return cast(ubyte[])File.get(file);
	//scope f = new File(file);
	//return cast(ubyte[])f.read();
}
string readFileText(string file) {
	scope f = new UnicodeFile!(char)(file, Encoding.UTF_8);
	return f.read();
}

