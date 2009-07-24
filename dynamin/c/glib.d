module dynamin.c.glib;

/*
 * A binding to at least the part of Glib that Dynamin uses.
 */

import tango.sys.SharedLib;

extern(C):

//{{{ gtypes
static if((void*).sizeof == 4) {
	alias uint gsize;
} else static if((void*).sizeof == 8) {
	alias ulong gsize;
}
alias char gchar;
alias short gshort;
alias int glong;
alias int gint;
alias gint gboolean;

alias ubyte guchar;
alias ushort gushort;
alias uint gulong;
alias uint guint;

alias float gfloat;
alias double gdouble;

alias byte gint8;
alias ubyte guint8;
alias short gint16;
alias ushort guint16;
alias int gint32;
alias uint guint32;
alias long gint64;
alias ulong guint64;

enum : gint8 {
	G_MININT8 = cast(gint8)0x80,
	G_MAXINT8 = 0x7f
}
enum : guint8 {
	G_MAXUINT8 = 0xff
}
enum : gint16 {
	G_MININT16 = cast(gint16)0x8000,
	G_MAXINT16 = 0x7fff
}
enum : guint16 {
	G_MAXUINT16 = 0xffff
}

enum : gint32 {
	G_MININT32 = 0x80000000,
	G_MAXINT32 = 0x7fffffff
}
enum : guint32 {
	G_MAXUINT32 = 0xffffffff
}

enum : gint64 {
	G_MININT64 = 0x8000000000000000,
	G_MAXINT64 = 0x7fffffffffffffff
}
enum : guint64 {
	G_MAXUINT64 = 0xffffffffffffffffU
}


alias void* gpointer;
alias /*const*/ void* gconstpointer;

alias gint function(gconstpointer a, gconstpointer b) GCompareFunc;
alias gint function(gconstpointer a, gconstpointer b,
	gpointer user_data) GCompareDataFunc;
alias gboolean function(gconstpointer a, gconstpointer b) GEqualFunc;
alias void function(gpointer data) GDestroyNotify;
alias void function(gpointer data, gpointer user_data) GFunc;
alias guint function(gconstpointer key) GHashFunc;
alias void function(gpointer key, gpointer value,
	gpointer user_data) GHFunc;
alias void function(gpointer data) GFreeFunc;
alias /*const*/ gchar* function(/*const*/ gchar* str,
	gpointer data) GTranslateFunc;

const real G_E     = 2.7182818284590452353602874713526624977572470937000;
const real G_LN2   = 0.69314718055994530941723212145817656807550013436026;
const real G_LN10  = 2.3025850929940456840179914546843642076011014886288;
const real G_PI    = 3.1415926535897932384626433832795028841971693993751;
const real G_PI_2  = 1.5707963267948966192313216916397514420985846996876;
const real G_PI_4  = 0.78539816339744830961566084581987572104929234984378;
const real G_SQRT2 = 1.4142135623730950488016887242096980785696718753769;

version(LittleEndian) {
	enum {
		G_BYTE_ORDER = 1234
	}
} else {
	enum {
		G_BYTE_ORDER = 4321
	}
}
enum {
	G_LITTLE_ENDIAN = 1234,
	G_BIG_ENDIAN    = 4321
}
//}}}

//{{{ gtype
const G_TYPE_FUNDAMENTAL_SHIFT = 2;
const G_TYPE_FUNDAMENTAL_MAX = 255 << G_TYPE_FUNDAMENTAL_SHIFT;
GType G_TYPE_MAKE_FUNDAMENTAL(uint x) {
	return x << G_TYPE_FUNDAMENTAL_SHIFT;
}
enum {
	G_TYPE_INVALID         = 0  << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_NONE            = 1  << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_INTERFACE       = 2  << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_CHAR            = 3  << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_UCHAR           = 4  << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_BOOLEAN         = 5  << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_INT             = 6  << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_UINT            = 7  << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_LONG            = 8  << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_ULONG           = 9  << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_INT64           = 10 << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_UINT64          = 11 << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_ENUM            = 12 << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_FLAGS           = 13 << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_FLOAT           = 14 << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_DOUBLE          = 15 << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_STRING          = 16 << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_POINTER         = 17 << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_BOXED           = 18 << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_PARAM           = 19 << G_TYPE_FUNDAMENTAL_SHIFT,
	G_TYPE_OBJECT          = 20 << G_TYPE_FUNDAMENTAL_SHIFT,
}
const G_TYPE_RESERVED_GLIB_FIRST = 21;
const G_TYPE_RESERVED_GLIB_LAST  = 31;
const G_TYPE_RESERVED_BSE_FIRST  = 32;
const G_TYPE_RESERVED_BSE_LAST   = 48;
const G_TYPE_RESERVED_USER_FIRST = 49;

bool G_TYPE_IS_FUNDAMENTAL(GType type) {
	return type <= G_TYPE_FUNDAMENTAL_MAX;
}
bool G_TYPE_IS_DERIVED(GType type) {
	return type > G_TYPE_FUNDAMENTAL_MAX;
}
/*bool G_TYPE_IS_INTERFACE(GType type) {
	return G_TYPE_FUNDAMENTAL(type) == G_TYPE_INTERFACE;
}
bool G_TYPE_IS_CLASSED(GType type) {
	return g_type_test_flags(type, G_TYPE_FLAG_CLASSED);
}
bool G_TYPE_IS_INSTANTIATABLE(GType type) {
	return g_type_test_flags(type, G_TYPE_FLAG_INSTANTIATABLE);
}
bool G_TYPE_IS_DERIVABLE(GType type) {
	return g_type_test_flags(type, G_TYPE_FLAG_DERIVABLE);
}
bool G_TYPE_IS_DEEP_DERIVABLE(GType type) {
	return g_type_test_flags(type, G_TYPE_FLAG_DEEP_DERIVABLE);
}
bool G_TYPE_IS_ABSTRACT(GType type) {
	return g_type_test_flags(type, G_TYPE_FLAG_ABSTRACT);
}
bool G_TYPE_IS_VALUE_ABSTRACT(GType type) {
	return g_type_test_flags(type, G_TYPE_FLAG_VALUE_ABSTRACT);
}
bool G_TYPE_IS_VALUE_TYPE(GType type) {
	return g_type_check_is_value_type(type);
}
bool G_TYPE_HAS_VALUE_TABLE(GType type) {
	return g_type_value_table_peek(type) != NULL;
}
*/
alias gsize GType;

struct GTypeClass {
	GType g_type;
}
struct GTypeInstance {
	GTypeClass* g_class;
}
struct GTypeInterface {
	GType g_type;
	GType g_instance_type;
}
struct GTypeQuery {
	GType type;
	/*const*/ gchar* type_name;
	guint class_size;
	guint instance_size;
}

// plus a lot more
//GType function(GType type_id) g_type_fundamental;
//alias g_type_fundamental G_TYPE_FUNDAMENTAL;
gboolean function(GType type, guint flags) g_type_test_flags;
//}}}

//{{{ gquark
typedef guint32 GQuark;

GQuark function(/*const*/ gchar* string) g_quark_try_string;
GQuark function(/*const*/ gchar* string) g_quark_from_static_string;
GQuark function(/*const*/ gchar* string) g_quark_from_string;
gchar* function(GQuark quark) g_quark_to_string;

gchar* function(/*const*/ gchar* string) g_intern_string;
gchar* function(/*const*/ gchar* string) g_intern_static_string;
//}}}

//{{{ gerror
struct GError {
	GQuark domain;
	gint code;
	gchar* message;
}

GError* function(GQuark domain,
	gint code,
	/*const*/ gchar* format,
	...) g_error_new;

GError* function(GQuark domain,
	gint code,
	/*const*/ gchar* message) g_error_new_literal;

void function(GError* error) g_error_free;
GError* function(/*const*/ GError* error) g_error_copy;

gboolean function(/*const*/ GError* error,
	GQuark domain,
	gint code) g_error_matches;

void function(GError** err,
	GQuark domain,
	gint code,
	/*const*/ gchar* format,
	...) g_set_error;

void function(GError** err,
	GQuark domain,
	gint code,
	/*const*/ gchar* message) g_set_error_literal;

void function(GError** dest,
	GError* src) g_propagate_error;

void function(GError** err) g_clear_error;

void function(GError** err,
	/*const*/ gchar* format,
	...) g_prefix_error;

void function(GError** dest,
	GError* src,
	/*const*/ gchar* format,
	...) g_propagate_prefixed_error;
//}}}

//{{{ gslist
struct GSList {
	gpointer data;
	GSList* next;
}

GSList* function() g_slist_alloc;
void function(GSList* list) g_slist_free;
void function(GSList* list) g_slist_free_1;
alias g_slist_free_1 g_slist_free1;
GSList* function(GSList* list, gpointer data) g_slist_append;
GSList* function(GSList* list, gpointer data) g_slist_prepend;
GSList* function(GSList* list, gpointer data, gint position) g_slist_insert;
GSList* function(GSList* list, gpointer data, GCompareFunc func) g_slist_insert_sorted;
GSList* function(
	GSList* list,
	gpointer data,
	GCompareDataFunc func,
	gpointer user_data) g_slist_insert_sorted_with_data;
GSList* function(GSList* slist, GSList* sibling, gpointer data) g_slist_insert_before;
GSList* function(GSList* list1, GSList* list2) g_slist_concat;
GSList* function(GSList* list, gconstpointer data) g_slist_remove;
GSList* function(GSList* list, gconstpointer data) g_slist_remove_all;
GSList* function(GSList* list, GSList* link_) g_slist_remove_link;
GSList* function(GSList* list, GSList* link_) g_slist_delete_link;
GSList* function(GSList* list) g_slist_reverse;
GSList* function(GSList* list) g_slist_copy;
GSList* function(GSList* list, guint n) g_slist_nth;
GSList* function(GSList* list, gconstpointer data) g_slist_find;
GSList* function(
	GSList* list,
	gconstpointer data,
	GCompareFunc func) g_slist_find_custom;
gint function(GSList* list, GSList* llink) g_slist_position;
gint function(GSList* list, gconstpointer data) g_slist_index;
GSList* function(GSList* list) g_slist_last;
guint function(GSList* list) g_slist_length;
void function(GSList* list, GFunc func, gpointer user_data) g_slist_foreach;
GSList* function(GSList* list, GCompareFunc compare_func) g_slist_sort;
GSList* function(GSList* list,
	GCompareDataFunc compare_func,
	gpointer user_data) g_slist_sort_with_data;
gpointer function(GSList* list, guint n) g_slist_nth_data;

GSList* g_slist_next(GSList* slist) {
	return slist ? slist.next : null;
}
//}}}

//{{{ gmem
gpointer function(gsize n_bytes) g_malloc;
gpointer function(gsize n_bytes) g_malloc0;
gpointer function(gpointer mem,
	gsize n_bytes) g_realloc;
void function(gpointer mem) g_free;
gpointer function(gsize n_bytes) g_try_malloc;
gpointer function(gsize n_bytes) g_try_malloc0;
gpointer function(gpointer mem,
	gsize n_bytes) g_try_realloc;
//}}}

static this() {
	auto lib = SharedLib.load("libglib-2.0.so.0");

	//{{{ gtype
	//g_type_fundamental = cast(typeof(g_type_fundamental))lib.getSymbol("g_type_fundamental");
	//g_type_test_flags = cast(typeof(g_type_test_flags))lib.getSymbol("g_type_test_flags");
	//}}}

	//{{{ gquark
	g_quark_try_string = cast(typeof(g_quark_try_string))lib.getSymbol("g_quark_try_string");
	g_quark_from_static_string = cast(typeof(g_quark_from_static_string))lib.getSymbol("g_quark_from_static_string");
	g_quark_from_string = cast(typeof(g_quark_from_string))lib.getSymbol("g_quark_from_string");
	g_quark_to_string = cast(typeof(g_quark_to_string))lib.getSymbol("g_quark_to_string");
	g_intern_string = cast(typeof(g_intern_string))lib.getSymbol("g_intern_string");
	g_intern_static_string = cast(typeof(g_intern_static_string))lib.getSymbol("g_intern_static_string");
	//}}}

	//{{{ gerror
	g_error_new = cast(typeof(g_error_new))lib.getSymbol("g_error_new");
	g_error_new_literal = cast(typeof(g_error_new_literal))lib.getSymbol("g_error_new_literal");
	g_error_free = cast(typeof(g_error_free))lib.getSymbol("g_error_free");
	g_error_copy = cast(typeof(g_error_copy))lib.getSymbol("g_error_copy");
	g_error_matches = cast(typeof(g_error_matches))lib.getSymbol("g_error_matches");
	g_set_error = cast(typeof(g_set_error))lib.getSymbol("g_set_error");
	//g_set_error_literal = cast(typeof(g_set_error_literal))lib.getSymbol("g_set_error_literal");
	g_propagate_error = cast(typeof(g_propagate_error))lib.getSymbol("g_propagate_error");
	g_clear_error = cast(typeof(g_clear_error))lib.getSymbol("g_clear_error");
	//g_prefix_error = cast(typeof(g_prefix_error))lib.getSymbol("g_prefix_error");
	//g_propagate_prefixed_error = cast(typeof(g_propagate_prefixed_error))lib.getSymbol("g_propagate_prefixed_error");
	//}}}

	//{{{ gslist
	g_slist_alloc = cast(typeof(g_slist_alloc))lib.getSymbol("g_slist_alloc");
	g_slist_free = cast(typeof(g_slist_free))lib.getSymbol("g_slist_free");
	g_slist_free_1 = cast(typeof(g_slist_free_1))lib.getSymbol("g_slist_free_1");
	g_slist_append = cast(typeof(g_slist_append))lib.getSymbol("g_slist_append");
	g_slist_prepend = cast(typeof(g_slist_prepend))lib.getSymbol("g_slist_prepend");
	g_slist_insert = cast(typeof(g_slist_insert))lib.getSymbol("g_slist_insert");
	g_slist_insert_sorted = cast(typeof(g_slist_insert_sorted))lib.getSymbol("g_slist_insert_sorted");
	g_slist_insert_sorted_with_data = cast(typeof(g_slist_insert_sorted_with_data))lib.getSymbol("g_slist_insert_sorted_with_data");
	g_slist_insert_before = cast(typeof(g_slist_insert_before))lib.getSymbol("g_slist_insert_before");
	g_slist_concat = cast(typeof(g_slist_concat))lib.getSymbol("g_slist_concat");
	g_slist_remove = cast(typeof(g_slist_remove))lib.getSymbol("g_slist_remove");
	g_slist_remove_all = cast(typeof(g_slist_remove_all))lib.getSymbol("g_slist_remove_all");
	g_slist_remove_link = cast(typeof(g_slist_remove_link))lib.getSymbol("g_slist_remove_link");
	g_slist_delete_link = cast(typeof(g_slist_delete_link))lib.getSymbol("g_slist_delete_link");
	g_slist_reverse = cast(typeof(g_slist_reverse))lib.getSymbol("g_slist_reverse");
	g_slist_copy = cast(typeof(g_slist_copy))lib.getSymbol("g_slist_copy");
	g_slist_nth = cast(typeof(g_slist_nth))lib.getSymbol("g_slist_nth");
	g_slist_find = cast(typeof(g_slist_find))lib.getSymbol("g_slist_find");
	g_slist_find_custom = cast(typeof(g_slist_find_custom))lib.getSymbol("g_slist_find_custom");
	g_slist_position = cast(typeof(g_slist_position))lib.getSymbol("g_slist_position");
	g_slist_index = cast(typeof(g_slist_index))lib.getSymbol("g_slist_index");
	g_slist_last = cast(typeof(g_slist_last))lib.getSymbol("g_slist_last");
	g_slist_length = cast(typeof(g_slist_length))lib.getSymbol("g_slist_length");
	g_slist_foreach = cast(typeof(g_slist_foreach))lib.getSymbol("g_slist_foreach");
	g_slist_sort = cast(typeof(g_slist_sort))lib.getSymbol("g_slist_sort");
	g_slist_sort_with_data = cast(typeof(g_slist_sort_with_data))lib.getSymbol("g_slist_sort_with_data");
	g_slist_nth_data = cast(typeof(g_slist_nth_data))lib.getSymbol("g_slist_nth_data");
	//}}}

	//{{{ gmem
	g_malloc = cast(typeof(g_malloc))lib.getSymbol("g_malloc");
	g_malloc0 = cast(typeof(g_malloc0))lib.getSymbol("g_malloc0");
	g_realloc = cast(typeof(g_realloc))lib.getSymbol("g_realloc");
	g_free = cast(typeof(g_free))lib.getSymbol("g_free");
	g_try_malloc = cast(typeof(g_try_malloc))lib.getSymbol("g_try_malloc");
	g_try_malloc0 = cast(typeof(g_try_malloc0))lib.getSymbol("g_try_malloc0");
	g_try_realloc = cast(typeof(g_try_realloc))lib.getSymbol("g_try_realloc");
	//}}}
}
