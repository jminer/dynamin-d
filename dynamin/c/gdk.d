module dynamin.c.gdk;

/*
 * A binding to at least the part of GDK that Dynamin uses.
 */

import dynamin.c.glib;
import tango.sys.SharedLib;

extern(C):

//{{{ gdktypes
enum {
	GDK_CURRENT_TIME     = 0L,
	GDK_PARENT_RELATIVE  = 1L
}

alias guint32 GdkWChar;

/*alias struct _GdkAtom* GdkAtom;*/
alias void* GdkAtom;

gpointer GDK_ATOM_TO_POINTER(GdkAtom atom) { return atom; }
GdkAtom GDK_POINTER_TO_ATOM(gpointer ptr) { return ptr; }

GdkAtom _GDK_MAKE_ATOM(guint64 val) { return cast(GdkAtom)val; }
GdkAtom GDK_NONE() { return _GDK_MAKE_ATOM(0); }

alias guint32 GdkNativeWindow;

enum {
	GDK_LSB_FIRST,
	GDK_MSB_FIRST
}
alias uint GdkByteOrder;

enum {
	GDK_SHIFT_MASK    = 1 << 0,
	GDK_LOCK_MASK     = 1 << 1,
	GDK_CONTROL_MASK  = 1 << 2,
	GDK_MOD1_MASK     = 1 << 3,
	GDK_MOD2_MASK     = 1 << 4,
	GDK_MOD3_MASK     = 1 << 5,
	GDK_MOD4_MASK     = 1 << 6,
	GDK_MOD5_MASK     = 1 << 7,
	GDK_BUTTON1_MASK  = 1 << 8,
	GDK_BUTTON2_MASK  = 1 << 9,
	GDK_BUTTON3_MASK  = 1 << 10,
	GDK_BUTTON4_MASK  = 1 << 11,
	GDK_BUTTON5_MASK  = 1 << 12,

	GDK_SUPER_MASK    = 1 << 26,
	GDK_HYPER_MASK    = 1 << 27,
	GDK_META_MASK     = 1 << 28,

	GDK_RELEASE_MASK  = 1 << 30,

	GDK_MODIFIER_MASK = 0x5c001fff
}
alias uint GdkModifierType;

enum {
	GDK_INPUT_READ       = 1 << 0,
	GDK_INPUT_WRITE      = 1 << 1,
	GDK_INPUT_EXCEPTION  = 1 << 2
}
alias uint GdkInputCondition;

enum {
	GDK_OK          = 0,
	GDK_ERROR          = -1,
	GDK_ERROR_PARAM = -2,
	GDK_ERROR_FILE  = -3,
	GDK_ERROR_MEM          = -4
}
alias uint GdkStatus;

enum {
	GDK_GRAB_SUCCESS         = 0,
	GDK_GRAB_ALREADY_GRABBED = 1,
	GDK_GRAB_INVALID_TIME    = 2,
	GDK_GRAB_NOT_VIEWABLE    = 3,
	GDK_GRAB_FROZEN          = 4
}
alias uint GdkGrabStatus;

alias void function(gpointer data,
	gint source,
	GdkInputCondition condition) GdkInputFunction;

struct GdkPoint {
	gint x;
	gint y;
}

struct GdkRectangle {
	gint x;
	gint y;
	gint width;
	gint height;
}

struct GdkSegment {
	gint x1;
	gint y1;
	gint x2;
	gint y2;
}

struct GdkSpan {
	gint x;
	gint y;
	gint width;
}
//}}}

//{{{ gdkwindow
//}}}

static this() {
	auto lib = SharedLib.load("libgdk-x11-2.0.so.0");

	//{{{ gdkwindow
	//}}}

}
