module dynamin.c.xmu;

/*
 * A binding to at least the part of Xmu that Dynamin uses. This
 * binding is incomplete as it is made only for Dynamin's use.
 */

import dynamin.c.xlib;
import dynamin.c.x_types;

version(build) { pragma(link, Xmu); }

extern(C):

/***************************** Atoms.h *****************************/
alias void* AtomPtr;

extern AtomPtr
	_XA_ATOM_PAIR,
	_XA_CHARACTER_POSITION,
	_XA_CLASS,
	_XA_CLIENT_WINDOW,
	_XA_CLIPBOARD,
	_XA_COMPOUND_TEXT,
	_XA_DECNET_ADDRESS,
	_XA_DELETE,
	_XA_FILENAME,
	_XA_HOSTNAME,
	_XA_IP_ADDRESS,
	_XA_LENGTH,
	_XA_LIST_LENGTH,
	_XA_NAME,
	_XA_NET_ADDRESS,
	_XA_NULL,
	_XA_OWNER_OS,
	_XA_SPAN,
	_XA_TARGETS,
	_XA_TEXT,
	_XA_TIMESTAMP,
	_XA_USER,
	_XA_UTF8_STRING;

Atom XA_ATOM_PAIR(Display* d)      { return XmuInternAtom(d, _XA_ATOM_PAIR); }
Atom XA_CHARACTER_POSITION(Display* d) {
	return XmuInternAtom(d, _XA_CHARACTER_POSITION);
}
Atom XA_CLASS(Display* d)          { return XmuInternAtom(d, _XA_CLASS); }
Atom XA_CLIENT_WINDOW(Display* d)  {
	return XmuInternAtom(d, _XA_CLIENT_WINDOW);
}
Atom XA_CLIPBOARD(Display* d)      { return XmuInternAtom(d, _XA_CLIPBOARD); }
Atom XA_COMPOUND_TEXT(Display* d)  {
	return XmuInternAtom(d, _XA_COMPOUND_TEXT);
}
Atom XA_DECNET_ADDRESS(Display* d) {
	return XmuInternAtom(d, _XA_DECNET_ADDRESS);
}
Atom XA_DELETE(Display* d)         { return XmuInternAtom(d, _XA_DELETE); }
Atom XA_FILENAME(Display* d)       { return XmuInternAtom(d, _XA_FILENAME); }
Atom XA_HOSTNAME(Display* d)       { return XmuInternAtom(d, _XA_HOSTNAME); }
Atom XA_IP_ADDRESS(Display* d)     { return XmuInternAtom(d, _XA_IP_ADDRESS); }
Atom XA_LENGTH(Display* d)         { return XmuInternAtom(d, _XA_LENGTH); }
Atom XA_LIST_LENGTH(Display* d)    { return XmuInternAtom(d, _XA_LIST_LENGTH); }
Atom XA_NAME(Display* d)           { return XmuInternAtom(d, _XA_NAME); }
Atom XA_NET_ADDRESS(Display* d)    { return XmuInternAtom(d, _XA_NET_ADDRESS); }
Atom XA_NULL(Display* d)           { return XmuInternAtom(d, _XA_NULL); }
Atom XA_OWNER_OS(Display* d)       { return XmuInternAtom(d, _XA_OWNER_OS); }
Atom XA_SPAN(Display* d)           { return XmuInternAtom(d, _XA_SPAN); }
Atom XA_TARGETS(Display* d)        { return XmuInternAtom(d, _XA_TARGETS); }
Atom XA_TEXT(Display* d)           { return XmuInternAtom(d, _XA_TEXT); }
Atom XA_TIMESTAMP(Display* d)      { return XmuInternAtom(d, _XA_TIMESTAMP); }
Atom XA_USER(Display* d)           { return XmuInternAtom(d, _XA_USER); }
Atom XA_UTF8_STRING(Display* d)    { return XmuInternAtom(d, _XA_UTF8_STRING); }

char* XmuGetAtomName(Display* dpy, Atom atom);

Atom XmuInternAtom(Display* dpy, AtomPtr atom_ptr);

//void XmuInternStrings(
//	Display* dpy, String* names, Cardinal count, Atom* atoms_return);

AtomPtr XmuMakeAtom(char* name);

char* XmuNameOfAtom(AtomPtr atom_ptr);

/*******************************************************************/

