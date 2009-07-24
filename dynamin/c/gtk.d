module dynamin.c.gtk;

/*
 * A binding to at least the part of GTK that Dynamin uses.
 */

import dynamin.c.glib;
import dynamin.c.gdk;
import tango.sys.SharedLib;

extern(C):

alias void GtkWidget;
alias void GtkWindow;

//{{{ gtkmain
/*const*/ gchar* function(guint required_major,
	guint required_minor,
	guint required_micro) gtk_check_version;

gboolean function(int* argc,
	char*** argv) gtk_parse_args;

void function(int* argc,
	char*** argv) gtk_init;

gboolean function(int* argc,
	char*** argv) gtk_init_check;

// leaving some out

gboolean function() gtk_events_pending;
//void function(GdkEvent* event) gtk_main_do_event;
void function() gtk_main;
guint function() gtk_main_level;
void function() gtk_main_quit;
gboolean function() gtk_main_iteration;
gboolean function(gboolean blocking) gtk_main_iteration_do;
//}}}

//{{{ gtkwidget
void function(GtkWidget* widget) gtk_widget_destroy;
//}}}

//{{{ gtkdialog
enum {
	GTK_DIALOG_MODAL               = 1 << 0,
	GTK_DIALOG_DESTROY_WITH_PARENT = 1 << 1,
	GTK_DIALOG_NO_SEPARATOR        = 1 << 2
}
alias uint GtkDialogFlags;

enum {
	GTK_RESPONSE_NONE = -1,

	GTK_RESPONSE_REJECT = -2,
	GTK_RESPONSE_ACCEPT = -3,

	GTK_RESPONSE_DELETE_EVENT = -4,

	GTK_RESPONSE_OK     = -5,
	GTK_RESPONSE_CANCEL = -6,
	GTK_RESPONSE_CLOSE  = -7,
	GTK_RESPONSE_YES    = -8,
	GTK_RESPONSE_NO     = -9,
	GTK_RESPONSE_APPLY  = -10,
	GTK_RESPONSE_HELP   = -11
}
alias uint GtkResponseType;

alias void GtkDialog;

GType function() gtk_dialog_get_type;
alias gtk_dialog_get_type GTK_TYPE_DIALOG;
GtkWidget* function() gtk_dialog_new;

GtkWidget* function(/*const*/ gchar* title,
	GtkWindow* parent,
	GtkDialogFlags flags,
	/*const*/ gchar* first_button_text,
	...) gtk_dialog_new_with_buttons;

void function(GtkDialog* dialog,
	GtkWidget* child,
	gint response_id) gtk_dialog_add_action_widget;
GtkWidget* function(GtkDialog* dialog,
	/*const*/ gchar* button_text,
	gint response_id) gtk_dialog_add_button;
void function(GtkDialog* dialog,
	/*const*/ gchar* first_button_text,
	...) gtk_dialog_add_buttons;

void function(GtkDialog* dialog,
	gint response_id,
	gboolean setting) gtk_dialog_set_response_sensitive;
void function(GtkDialog* dialog,
	gint response_id) gtk_dialog_set_default_response;
gint function(GtkDialog* dialog,
	GtkWidget* widget) gtk_dialog_get_response_for_widget;

void function(GtkDialog* dialog,
	gboolean setting) gtk_dialog_set_has_separator;
gboolean function(GtkDialog* dialog) gtk_dialog_get_has_separator;

//gboolean function(GdkScreen* screen) gtk_alternative_dialog_button_order;
void function(GtkDialog* dialog,
	gint first_response_id,
	...) gtk_dialog_set_alternative_button_order;
void function(GtkDialog* dialog,
	gint n_params,
	gint* new_order) gtk_dialog_set_alternative_button_order_from_array;

void function(GtkDialog* dialog,
	gint response_id) gtk_dialog_response;

gint function(GtkDialog* dialog) gtk_dialog_run;

GtkWidget*  function(GtkDialog* dialog) gtk_dialog_get_action_area;
GtkWidget*  function(GtkDialog* dialog) gtk_dialog_get_content_area;
//}}}

//{{{ gtkfilefilter
alias void GtkFileFilter;

enum {
	GTK_FILE_FILTER_FILENAME     = 1 << 0,
	GTK_FILE_FILTER_URI          = 1 << 1,
	GTK_FILE_FILTER_DISPLAY_NAME = 1 << 2,
	GTK_FILE_FILTER_MIME_TYPE    = 1 << 3
}
alias uint GtkFileFilterFlags;

alias gboolean function(/*const*/ GtkFileFilterInfo* filter_info,
	gpointer data) GtkFileFilterFunc;

struct GtkFileFilterInfo {
	GtkFileFilterFlags contains;

	/*const*/ gchar* filename;
	/*const*/ gchar* uri;
	/*const*/ gchar* display_name;
	/*const*/ gchar* mime_type;
}

GType function() gtk_file_filter_get_type;

alias gtk_file_filter_get_type GTK_TYPE_FILE_FILTER;

GtkFileFilter*  function() gtk_file_filter_new;
void function(GtkFileFilter* filter,
	/*const*/ gchar* name) gtk_file_filter_set_name;
gchar* function(GtkFileFilter* filter) gtk_file_filter_get_name;

void function(GtkFileFilter* filter,
	/*const*/ gchar* mime_type) gtk_file_filter_add_mime_type;
void function(GtkFileFilter* filter,
	/*const*/ gchar* pattern) gtk_file_filter_add_pattern;
void function(GtkFileFilter* filter) gtk_file_filter_add_pixbuf_formats;
void function(GtkFileFilter* filter,
	GtkFileFilterFlags needed,
	GtkFileFilterFunc func,
	gpointer data,
	GDestroyNotify notify) gtk_file_filter_add_custom;

GtkFileFilterFlags function(GtkFileFilter* filter) gtk_file_filter_get_needed;
gboolean function(GtkFileFilter* filter,
	/*const*/ GtkFileFilterInfo* filter_info) gtk_file_filter_filter;
//}}}

//{{{ gtkfilechooser
alias void GtkFileChooser;

enum {
	GTK_FILE_CHOOSER_ACTION_OPEN,
	GTK_FILE_CHOOSER_ACTION_SAVE,
	GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER,
	GTK_FILE_CHOOSER_ACTION_CREATE_FOLDER
}
alias uint GtkFileChooserAction;

enum {
	GTK_FILE_CHOOSER_CONFIRMATION_CONFIRM,
	GTK_FILE_CHOOSER_CONFIRMATION_ACCEPT_FILENAME,
	GTK_FILE_CHOOSER_CONFIRMATION_SELECT_AGAIN
}
alias uint GtkFileChooserConfirmation;

GType function() gtk_file_chooser_get_type;

alias gtk_file_chooser_get_type GTK_TYPE_FILE_CHOOSER;

enum {
	GTK_FILE_CHOOSER_ERROR_NONEXISTENT,
	GTK_FILE_CHOOSER_ERROR_BAD_FILENAME,
	GTK_FILE_CHOOSER_ERROR_ALREADY_EXISTS,
	GTK_FILE_CHOOSER_ERROR_INCOMPLETE_HOSTNAME
}
alias uint GtkFileChooserError;

GQuark function() gtk_file_chooser_error_quark;

alias gtk_file_chooser_error_quark GTK_FILE_CHOOSER_ERROR;

void function(GtkFileChooser* chooser,
	GtkFileChooserAction action) gtk_file_chooser_set_action;
GtkFileChooserAction function(GtkFileChooser* chooser) gtk_file_chooser_get_action;
void function(GtkFileChooser* chooser,
	gboolean local_only) gtk_file_chooser_set_local_only;
gboolean function(GtkFileChooser* chooser) gtk_file_chooser_get_local_only;
void function(GtkFileChooser* chooser,
	gboolean select_multiple) gtk_file_chooser_set_select_multiple;
gboolean function(GtkFileChooser* chooser) gtk_file_chooser_get_select_multiple;
void function(GtkFileChooser* chooser,
	gboolean show_hidden) gtk_file_chooser_set_show_hidden;
gboolean function(GtkFileChooser* chooser) gtk_file_chooser_get_show_hidden;
void function(GtkFileChooser* chooser,
	gboolean do_overwrite_confirmation) gtk_file_chooser_set_do_overwrite_confirmation;
gboolean function(GtkFileChooser* chooser) gtk_file_chooser_get_do_overwrite_confirmation;

void function(GtkFileChooser* chooser,
	/*const*/ gchar* name) gtk_file_chooser_set_current_name;

gchar* function(GtkFileChooser* chooser) gtk_file_chooser_get_filename;
gboolean function(GtkFileChooser* chooser,
	/*const*/ char* filename) gtk_file_chooser_set_filename;
gboolean function(GtkFileChooser* chooser,
	/*const*/ char* filename) gtk_file_chooser_select_filename;
void function(GtkFileChooser* chooser,
	/*const*/ char* filename) gtk_file_chooser_unselect_filename;
void function(GtkFileChooser* chooser) gtk_file_chooser_select_all;
void function(GtkFileChooser* chooser) gtk_file_chooser_unselect_all;
GSList* function(GtkFileChooser* chooser) gtk_file_chooser_get_filenames;
gboolean function(GtkFileChooser* chooser,
	/*const*/ gchar* filename) gtk_file_chooser_set_current_folder;
gchar* function(GtkFileChooser* chooser) gtk_file_chooser_get_current_folder;

gchar* function(GtkFileChooser* chooser) gtk_file_chooser_get_uri;
gboolean function(GtkFileChooser* chooser,
	/*const*/ char* uri) gtk_file_chooser_set_uri;
gboolean function(GtkFileChooser* chooser,
	/*const*/ char* uri) gtk_file_chooser_select_uri;
void function(GtkFileChooser* chooser,
	/*const*/ char* uri) gtk_file_chooser_unselect_uri;
GSList* function(GtkFileChooser* chooser) gtk_file_chooser_get_uris;
gboolean function(GtkFileChooser* chooser,
	/*const*/ gchar* uri) gtk_file_chooser_set_current_folder_uri;
gchar* function(GtkFileChooser* chooser) gtk_file_chooser_get_current_folder_uri;
/*
GFile* function(GtkFileChooser* chooser) gtk_file_chooser_get_file;
gboolean function(GtkFileChooser* chooser,
	GFile* file,
	GError** error) gtk_file_chooser_set_file;
gboolean function(GtkFileChooser* chooser,
	GFile* file,
	GError** error) gtk_file_chooser_select_file;
void function(GtkFileChooser* chooser,
	GFile* file) gtk_file_chooser_unselect_file;
GSList* function(GtkFileChooser* chooser) gtk_file_chooser_get_files;
gboolean function(GtkFileChooser* chooser,
	GFile* file,
	GError** error) gtk_file_chooser_set_current_folder_file;
GFile* function(GtkFileChooser* chooser) gtk_file_chooser_get_current_folder_file;
*/
/*
void function(GtkFileChooser* chooser,
	GtkWidget* preview_widget) gtk_file_chooser_set_preview_widget;
GtkWidget* function(GtkFileChooser* chooser) gtk_file_chooser_get_preview_widget;
void function(GtkFileChooser* chooser,
	gboolean active) gtk_file_chooser_set_preview_widget_active;
gboolean function(GtkFileChooser* chooser) gtk_file_chooser_get_preview_widget_active;
void function(GtkFileChooser* chooser,
	gboolean use_label) gtk_file_chooser_set_use_preview_label;
gboolean function(GtkFileChooser* chooser) gtk_file_chooser_get_use_preview_label;

char* function(GtkFileChooser* chooser) gtk_file_chooser_get_preview_filename;
char* function(GtkFileChooser* chooser) gtk_file_chooser_get_preview_uri;
GFile* function(GtkFileChooser* chooser) gtk_file_chooser_get_preview_file;

void function(GtkFileChooser* chooser,
	GtkWidget* extra_widget) gtk_file_chooser_set_extra_widget;
GtkWidget* function(GtkFileChooser* chooser) gtk_file_chooser_get_extra_widget;
*/
void function(GtkFileChooser* chooser,
	GtkFileFilter* filter) gtk_file_chooser_add_filter;
void function(GtkFileChooser* chooser,
	GtkFileFilter* filter) gtk_file_chooser_remove_filter;
GSList* function(GtkFileChooser* chooser) gtk_file_chooser_list_filters;

void function(GtkFileChooser* chooser,
	GtkFileFilter* filter) gtk_file_chooser_set_filter;
GtkFileFilter* function(GtkFileChooser* chooser) gtk_file_chooser_get_filter;

gboolean function(GtkFileChooser* chooser,
	/*const*/ char* folder,
	GError** error) gtk_file_chooser_add_shortcut_folder;
gboolean function(GtkFileChooser* chooser,
	/*const*/ char* folder,
	GError** error) gtk_file_chooser_remove_shortcut_folder;
GSList* function(GtkFileChooser* chooser) gtk_file_chooser_list_shortcut_folders;

gboolean function(GtkFileChooser* chooser,
	/*const*/ char* uri,
	GError** error) gtk_file_chooser_add_shortcut_folder_uri;
gboolean function(GtkFileChooser* chooser,
	/*const*/ char* uri,
	GError** error) gtk_file_chooser_remove_shortcut_folder_uri;
GSList* function(GtkFileChooser* chooser) gtk_file_chooser_list_shortcut_folder_uris;
//}}}

//{{{ gtkfilechooserdialog
alias void GtkFileChooserDialog;

GType function() gtk_file_chooser_dialog_get_type;
alias gtk_file_chooser_dialog_get_type GTK_TYPE_FILE_CHOOSER_DIALOG;
GtkWidget* function(/*const*/ gchar* title,
	GtkWindow* parent,
	GtkFileChooserAction action,
	/*const*/ gchar* first_button_text,
	...) gtk_file_chooser_dialog_new;
//}}}

//{{{ gtkstock
struct GtkStockItem {
	gchar* stock_id;
	gchar* label;
	GdkModifierType modifier;
	guint keyval;
	gchar* translation_domain;
}

void function(/*const*/ GtkStockItem* items,
	guint n_items) gtk_stock_add;
void function(/*const*/ GtkStockItem* items,
	guint n_items) gtk_stock_add_static;
gboolean function(/*const*/ gchar* stock_id,
	GtkStockItem* item) gtk_stock_lookup;

GSList* function() gtk_stock_list_ids;

GtkStockItem* function(/*const*/ GtkStockItem* item) gtk_stock_item_copy;
void function(GtkStockItem* item) gtk_stock_item_free;

//void function(/*const*/ gchar* domain,
//	GtkTranslateFunc func,
//	gpointer data,
//	GDestroyNotify notify) gtk_stock_set_translate_func;

const gchar* GTK_STOCK_DIALOG_AUTHENTICATION = "gtk-dialog-authentication";
const gchar* GTK_STOCK_DIALOG_INFO      = "gtk-dialog-info";
const gchar* GTK_STOCK_DIALOG_WARNING   = "gtk-dialog-warning";
const gchar* GTK_STOCK_DIALOG_ERROR     = "gtk-dialog-error";
const gchar* GTK_STOCK_DIALOG_QUESTION  = "gtk-dialog-question";

const gchar* GTK_STOCK_DND              = "gtk-dnd";
const gchar* GTK_STOCK_DND_MULTIPLE     = "gtk-dnd-multiple";

const gchar* GTK_STOCK_ABOUT            = "gtk-about";
const gchar* GTK_STOCK_ADD              = "gtk-add";
const gchar* GTK_STOCK_APPLY            = "gtk-apply";
const gchar* GTK_STOCK_BOLD             = "gtk-bold";
const gchar* GTK_STOCK_CANCEL           = "gtk-cancel";
const gchar* GTK_STOCK_CAPS_LOCK_WARNING = "gtk-caps-lock-warning";
const gchar* GTK_STOCK_CDROM            = "gtk-cdrom";
const gchar* GTK_STOCK_CLEAR            = "gtk-clear";
const gchar* GTK_STOCK_CLOSE            = "gtk-close";
const gchar* GTK_STOCK_COLOR_PICKER     = "gtk-color-picker";
const gchar* GTK_STOCK_CONVERT          = "gtk-convert";
const gchar* GTK_STOCK_CONNECT          = "gtk-connect";
const gchar* GTK_STOCK_COPY             = "gtk-copy";
const gchar* GTK_STOCK_CUT              = "gtk-cut";
const gchar* GTK_STOCK_DELETE           = "gtk-delete";
const gchar* GTK_STOCK_DIRECTORY        = "gtk-directory";
const gchar* GTK_STOCK_DISCARD          = "gtk-discard";
const gchar* GTK_STOCK_DISCONNECT       = "gtk-disconnect";
const gchar* GTK_STOCK_EDIT             = "gtk-edit";
const gchar* GTK_STOCK_EXECUTE          = "gtk-execute";
const gchar* GTK_STOCK_FILE             = "gtk-file";
const gchar* GTK_STOCK_FIND             = "gtk-find";
const gchar* GTK_STOCK_FIND_AND_REPLACE = "gtk-find-and-replace";
const gchar* GTK_STOCK_FLOPPY           = "gtk-floppy";
const gchar* GTK_STOCK_FULLSCREEN       = "gtk-fullscreen";
const gchar* GTK_STOCK_GOTO_BOTTOM      = "gtk-goto-bottom";
const gchar* GTK_STOCK_GOTO_FIRST       = "gtk-goto-first";
const gchar* GTK_STOCK_GOTO_LAST        = "gtk-goto-last";
const gchar* GTK_STOCK_GOTO_TOP         = "gtk-goto-top";
const gchar* GTK_STOCK_GO_BACK          = "gtk-go-back";
const gchar* GTK_STOCK_GO_DOWN          = "gtk-go-down";
const gchar* GTK_STOCK_GO_FORWARD       = "gtk-go-forward";
const gchar* GTK_STOCK_GO_UP            = "gtk-go-up";
const gchar* GTK_STOCK_HARDDISK         = "gtk-harddisk";
const gchar* GTK_STOCK_HELP             = "gtk-help";
const gchar* GTK_STOCK_HOME             = "gtk-home";
const gchar* GTK_STOCK_INDEX            = "gtk-index";
const gchar* GTK_STOCK_INDENT           = "gtk-indent";
const gchar* GTK_STOCK_INFO             = "gtk-info";
const gchar* GTK_STOCK_UNINDENT         = "gtk-unindent";
const gchar* GTK_STOCK_ITALIC           = "gtk-italic";
const gchar* GTK_STOCK_JUMP_TO          = "gtk-jump-to";
const gchar* GTK_STOCK_JUSTIFY_CENTER   = "gtk-justify-center";
const gchar* GTK_STOCK_JUSTIFY_FILL     = "gtk-justify-fill";
const gchar* GTK_STOCK_JUSTIFY_LEFT     = "gtk-justify-left";
const gchar* GTK_STOCK_JUSTIFY_RIGHT    = "gtk-justify-right";
const gchar* GTK_STOCK_LEAVE_FULLSCREEN = "gtk-leave-fullscreen";
const gchar* GTK_STOCK_MISSING_IMAGE    = "gtk-missing-image";
const gchar* GTK_STOCK_MEDIA_FORWARD    = "gtk-media-forward";
const gchar* GTK_STOCK_MEDIA_NEXT       = "gtk-media-next";
const gchar* GTK_STOCK_MEDIA_PAUSE      = "gtk-media-pause";
const gchar* GTK_STOCK_MEDIA_PLAY       = "gtk-media-play";
const gchar* GTK_STOCK_MEDIA_PREVIOUS   = "gtk-media-previous";
const gchar* GTK_STOCK_MEDIA_RECORD     = "gtk-media-record";
const gchar* GTK_STOCK_MEDIA_REWIND     = "gtk-media-rewind";
const gchar* GTK_STOCK_MEDIA_STOP       = "gtk-media-stop";
const gchar* GTK_STOCK_NETWORK          = "gtk-network";
const gchar* GTK_STOCK_NEW              = "gtk-new";
const gchar* GTK_STOCK_NO               = "gtk-no";
const gchar* GTK_STOCK_OK               = "gtk-ok";
const gchar* GTK_STOCK_OPEN             = "gtk-open";
const gchar* GTK_STOCK_ORIENTATION_PORTRAIT = "gtk-orientation-portrait";
const gchar* GTK_STOCK_ORIENTATION_LANDSCAPE = "gtk-orientation-landscape";
const gchar* GTK_STOCK_ORIENTATION_REVERSE_LANDSCAPE = "gtk-orientation-reverse-landscape";
const gchar* GTK_STOCK_ORIENTATION_REVERSE_PORTRAIT = "gtk-orientation-reverse-portrait";
const gchar* GTK_STOCK_PAGE_SETUP       = "gtk-page-setup";
const gchar* GTK_STOCK_PASTE            = "gtk-paste";
const gchar* GTK_STOCK_PREFERENCES      = "gtk-preferences";
const gchar* GTK_STOCK_PRINT            = "gtk-print";
const gchar* GTK_STOCK_PRINT_ERROR      = "gtk-print-error";
const gchar* GTK_STOCK_PRINT_PAUSED     = "gtk-print-paused";
const gchar* GTK_STOCK_PRINT_PREVIEW    = "gtk-print-preview";
const gchar* GTK_STOCK_PRINT_REPORT     = "gtk-print-report";
const gchar* GTK_STOCK_PRINT_WARNING    = "gtk-print-warning";
const gchar* GTK_STOCK_PROPERTIES       = "gtk-properties";
const gchar* GTK_STOCK_QUIT             = "gtk-quit";
const gchar* GTK_STOCK_REDO             = "gtk-redo";
const gchar* GTK_STOCK_REFRESH          = "gtk-refresh";
const gchar* GTK_STOCK_REMOVE           = "gtk-remove";
const gchar* GTK_STOCK_REVERT_TO_SAVED  = "gtk-revert-to-saved";
const gchar* GTK_STOCK_SAVE             = "gtk-save";
const gchar* GTK_STOCK_SAVE_AS          = "gtk-save-as";
const gchar* GTK_STOCK_SELECT_ALL       = "gtk-select-all";
const gchar* GTK_STOCK_SELECT_COLOR     = "gtk-select-color";
const gchar* GTK_STOCK_SELECT_FONT      = "gtk-select-font";
const gchar* GTK_STOCK_SORT_ASCENDING   = "gtk-sort-ascending";
const gchar* GTK_STOCK_SORT_DESCENDING  = "gtk-sort-descending";
const gchar* GTK_STOCK_SPELL_CHECK      = "gtk-spell-check";
const gchar* GTK_STOCK_STOP             = "gtk-stop";
const gchar* GTK_STOCK_STRIKETHROUGH    = "gtk-strikethrough";
const gchar* GTK_STOCK_UNDELETE         = "gtk-undelete";
const gchar* GTK_STOCK_UNDERLINE        = "gtk-underline";
const gchar* GTK_STOCK_UNDO             = "gtk-undo";
const gchar* GTK_STOCK_YES              = "gtk-yes";
const gchar* GTK_STOCK_ZOOM_100         = "gtk-zoom-100";
const gchar* GTK_STOCK_ZOOM_FIT         = "gtk-zoom-fit";
const gchar* GTK_STOCK_ZOOM_IN          = "gtk-zoom-in";
const gchar* GTK_STOCK_ZOOM_OUT         = "gtk-zoom-out";
//}}}

static this() {
	auto lib = SharedLib.load("libgtk-x11-2.0.so.0");

	//{{{ gtkmain
	gtk_check_version = cast(typeof(gtk_check_version))lib.getSymbol("gtk_check_version");
	gtk_parse_args = cast(typeof(gtk_parse_args))lib.getSymbol("gtk_parse_args");
	gtk_init = cast(typeof(gtk_init))lib.getSymbol("gtk_init");
	gtk_init_check = cast(typeof(gtk_init_check))lib.getSymbol("gtk_init_check");

	gtk_events_pending = cast(typeof(gtk_events_pending))lib.getSymbol("gtk_events_pending");
	//gtk_main_do_event = cast(typeof(gtk_main_do_event))lib.getSymbol("gtk_main_do_event");
	gtk_main = cast(typeof(gtk_main))lib.getSymbol("gtk_main");
	gtk_main_level = cast(typeof(gtk_main_level))lib.getSymbol("gtk_main_level");
	gtk_main_quit = cast(typeof(gtk_main_quit))lib.getSymbol("gtk_main_quit");
	gtk_main_iteration = cast(typeof(gtk_main_iteration))lib.getSymbol("gtk_main_iteration");
	gtk_main_iteration_do = cast(typeof(gtk_main_iteration_do))lib.getSymbol("gtk_main_iteration_do");
	//}}}

	//{{{ gtkwidget
	gtk_widget_destroy = cast(typeof(gtk_widget_destroy))lib.getSymbol("gtk_widget_destroy");
	//}}}

	//{{{ gtkdialog
	gtk_dialog_get_type = cast(typeof(gtk_dialog_get_type))lib.getSymbol("gtk_dialog_get_type");
	gtk_dialog_new = cast(typeof(gtk_dialog_new))lib.getSymbol("gtk_dialog_new");
	gtk_dialog_new_with_buttons = cast(typeof(gtk_dialog_new_with_buttons))lib.getSymbol("gtk_dialog_new_with_buttons");
	gtk_dialog_add_action_widget = cast(typeof(gtk_dialog_add_action_widget))lib.getSymbol("gtk_dialog_add_action_widget");
	gtk_dialog_add_button = cast(typeof(gtk_dialog_add_button))lib.getSymbol("gtk_dialog_add_button");
	gtk_dialog_add_buttons = cast(typeof(gtk_dialog_add_buttons))lib.getSymbol("gtk_dialog_add_buttons");
	gtk_dialog_set_response_sensitive = cast(typeof(gtk_dialog_set_response_sensitive))lib.getSymbol("gtk_dialog_set_response_sensitive");
	gtk_dialog_set_default_response = cast(typeof(gtk_dialog_set_default_response))lib.getSymbol("gtk_dialog_set_default_response");
	gtk_dialog_get_response_for_widget = cast(typeof(gtk_dialog_get_response_for_widget))lib.getSymbol("gtk_dialog_get_response_for_widget");
	gtk_dialog_set_has_separator = cast(typeof(gtk_dialog_set_has_separator))lib.getSymbol("gtk_dialog_set_has_separator");
	gtk_dialog_get_has_separator = cast(typeof(gtk_dialog_get_has_separator))lib.getSymbol("gtk_dialog_get_has_separator");
	//gtk_alternative_dialog_button_order = cast(typeof(gtk_alternative_dialog_button_order))lib.getSymbol("gtk_alternative_dialog_button_order");
	gtk_dialog_set_alternative_button_order = cast(typeof(gtk_dialog_set_alternative_button_order))lib.getSymbol("gtk_dialog_set_alternative_button_order");
	gtk_dialog_set_alternative_button_order_from_array = cast(typeof(gtk_dialog_set_alternative_button_order_from_array))lib.getSymbol("gtk_dialog_set_alternative_button_order_from_array");
	gtk_dialog_response = cast(typeof(gtk_dialog_response))lib.getSymbol("gtk_dialog_response");
	gtk_dialog_run = cast(typeof(gtk_dialog_run))lib.getSymbol("gtk_dialog_run");
	//gtk_dialog_get_action_area = cast(typeof(gtk_dialog_get_action_area))lib.getSymbol("gtk_dialog_get_action_area");
	//gtk_dialog_get_content_area = cast(typeof(gtk_dialog_get_content_area))lib.getSymbol("gtk_dialog_get_content_area");
	//}}}

	//{{{ gtkfilefilter
	gtk_file_filter_get_type = cast(typeof(gtk_file_filter_get_type))lib.getSymbol("gtk_file_filter_get_type");
	gtk_file_filter_new = cast(typeof(gtk_file_filter_new))lib.getSymbol("gtk_file_filter_new");
	gtk_file_filter_set_name = cast(typeof(gtk_file_filter_set_name))lib.getSymbol("gtk_file_filter_set_name");
	gtk_file_filter_get_name = cast(typeof(gtk_file_filter_get_name))lib.getSymbol("gtk_file_filter_get_name");
	gtk_file_filter_add_mime_type = cast(typeof(gtk_file_filter_add_mime_type))lib.getSymbol("gtk_file_filter_add_mime_type");
	gtk_file_filter_add_pattern = cast(typeof(gtk_file_filter_add_pattern))lib.getSymbol("gtk_file_filter_add_pattern");
	gtk_file_filter_add_pixbuf_formats = cast(typeof(gtk_file_filter_add_pixbuf_formats))lib.getSymbol("gtk_file_filter_add_pixbuf_formats");
	gtk_file_filter_add_custom = cast(typeof(gtk_file_filter_add_custom))lib.getSymbol("gtk_file_filter_add_custom");
	gtk_file_filter_get_needed = cast(typeof(gtk_file_filter_get_needed))lib.getSymbol("gtk_file_filter_get_needed");
	gtk_file_filter_filter = cast(typeof(gtk_file_filter_filter))lib.getSymbol("gtk_file_filter_filter");
	//}}}

	//{{{ gtkfilechooser
	gtk_file_chooser_get_type = cast(typeof(gtk_file_chooser_get_type))lib.getSymbol("gtk_file_chooser_get_type");
	gtk_file_chooser_error_quark = cast(typeof(gtk_file_chooser_error_quark))lib.getSymbol("gtk_file_chooser_error_quark");
	gtk_file_chooser_set_action = cast(typeof(gtk_file_chooser_set_action))lib.getSymbol("gtk_file_chooser_set_action");
	gtk_file_chooser_get_action = cast(typeof(gtk_file_chooser_get_action))lib.getSymbol("gtk_file_chooser_get_action");
	gtk_file_chooser_set_local_only = cast(typeof(gtk_file_chooser_set_local_only))lib.getSymbol("gtk_file_chooser_set_local_only");
	gtk_file_chooser_get_local_only = cast(typeof(gtk_file_chooser_get_local_only))lib.getSymbol("gtk_file_chooser_get_local_only");
	gtk_file_chooser_set_select_multiple = cast(typeof(gtk_file_chooser_set_select_multiple))lib.getSymbol("gtk_file_chooser_set_select_multiple");
	gtk_file_chooser_get_select_multiple = cast(typeof(gtk_file_chooser_get_select_multiple))lib.getSymbol("gtk_file_chooser_get_select_multiple");
	gtk_file_chooser_set_show_hidden = cast(typeof(gtk_file_chooser_set_show_hidden))lib.getSymbol("gtk_file_chooser_set_show_hidden");
	gtk_file_chooser_get_show_hidden = cast(typeof(gtk_file_chooser_get_show_hidden))lib.getSymbol("gtk_file_chooser_get_show_hidden");
	gtk_file_chooser_set_do_overwrite_confirmation = cast(typeof(gtk_file_chooser_set_do_overwrite_confirmation))lib.getSymbol("gtk_file_chooser_set_do_overwrite_confirmation");
	gtk_file_chooser_get_do_overwrite_confirmation = cast(typeof(gtk_file_chooser_get_do_overwrite_confirmation))lib.getSymbol("gtk_file_chooser_get_do_overwrite_confirmation");
	gtk_file_chooser_set_current_name = cast(typeof(gtk_file_chooser_set_current_name))lib.getSymbol("gtk_file_chooser_set_current_name");
	gtk_file_chooser_get_filename = cast(typeof(gtk_file_chooser_get_filename))lib.getSymbol("gtk_file_chooser_get_filename");
	gtk_file_chooser_set_filename = cast(typeof(gtk_file_chooser_set_filename))lib.getSymbol("gtk_file_chooser_set_filename");
	gtk_file_chooser_select_filename = cast(typeof(gtk_file_chooser_select_filename))lib.getSymbol("gtk_file_chooser_select_filename");
	gtk_file_chooser_unselect_filename = cast(typeof(gtk_file_chooser_unselect_filename))lib.getSymbol("gtk_file_chooser_unselect_filename");
	gtk_file_chooser_select_all = cast(typeof(gtk_file_chooser_select_all))lib.getSymbol("gtk_file_chooser_select_all");
	gtk_file_chooser_unselect_all = cast(typeof(gtk_file_chooser_unselect_all))lib.getSymbol("gtk_file_chooser_unselect_all");
	gtk_file_chooser_get_filenames = cast(typeof(gtk_file_chooser_get_filenames))lib.getSymbol("gtk_file_chooser_get_filenames");
	gtk_file_chooser_set_current_folder = cast(typeof(gtk_file_chooser_set_current_folder))lib.getSymbol("gtk_file_chooser_set_current_folder");
	gtk_file_chooser_get_current_folder = cast(typeof(gtk_file_chooser_get_current_folder))lib.getSymbol("gtk_file_chooser_get_current_folder");
	gtk_file_chooser_get_uri = cast(typeof(gtk_file_chooser_get_uri))lib.getSymbol("gtk_file_chooser_get_uri");
	gtk_file_chooser_set_uri = cast(typeof(gtk_file_chooser_set_uri))lib.getSymbol("gtk_file_chooser_set_uri");
	gtk_file_chooser_select_uri = cast(typeof(gtk_file_chooser_select_uri))lib.getSymbol("gtk_file_chooser_select_uri");
	gtk_file_chooser_unselect_uri = cast(typeof(gtk_file_chooser_unselect_uri))lib.getSymbol("gtk_file_chooser_unselect_uri");
	gtk_file_chooser_get_uris = cast(typeof(gtk_file_chooser_get_uris))lib.getSymbol("gtk_file_chooser_get_uris");
	gtk_file_chooser_set_current_folder_uri = cast(typeof(gtk_file_chooser_set_current_folder_uri))lib.getSymbol("gtk_file_chooser_set_current_folder_uri");
	gtk_file_chooser_get_current_folder_uri = cast(typeof(gtk_file_chooser_get_current_folder_uri))lib.getSymbol("gtk_file_chooser_get_current_folder_uri");
	/*
	gtk_file_chooser_get_file = cast(typeof(gtk_file_chooser_get_file))lib.getSymbol("gtk_file_chooser_get_file");
	gtk_file_chooser_set_file = cast(typeof(gtk_file_chooser_set_file))lib.getSymbol("gtk_file_chooser_set_file");
	gtk_file_chooser_select_file = cast(typeof(gtk_file_chooser_select_file))lib.getSymbol("gtk_file_chooser_select_file");
	gtk_file_chooser_unselect_file = cast(typeof(gtk_file_chooser_unselect_file))lib.getSymbol("gtk_file_chooser_unselect_file");
	gtk_file_chooser_get_files = cast(typeof(gtk_file_chooser_get_files))lib.getSymbol("gtk_file_chooser_get_files");
	gtk_file_chooser_set_current_folder_file = cast(typeof(gtk_file_chooser_set_current_folder_file))lib.getSymbol("gtk_file_chooser_set_current_folder_file");
	gtk_file_chooser_get_current_folder_file = cast(typeof(gtk_file_chooser_get_current_folder_file))lib.getSymbol("gtk_file_chooser_get_current_folder_file");
	gtk_file_chooser_set_preview_widget = cast(typeof(gtk_file_chooser_set_preview_widget))lib.getSymbol("gtk_file_chooser_set_preview_widget");
	gtk_file_chooser_get_preview_widget = cast(typeof(gtk_file_chooser_get_preview_widget))lib.getSymbol("gtk_file_chooser_get_preview_widget");
	gtk_file_chooser_set_preview_widget_active = cast(typeof(gtk_file_chooser_set_preview_widget_active))lib.getSymbol("gtk_file_chooser_set_preview_widget_active");
	gtk_file_chooser_get_preview_widget_active = cast(typeof(gtk_file_chooser_get_preview_widget_active))lib.getSymbol("gtk_file_chooser_get_preview_widget_active");
	gtk_file_chooser_set_use_preview_label = cast(typeof(gtk_file_chooser_set_use_preview_label))lib.getSymbol("gtk_file_chooser_set_use_preview_label");
	gtk_file_chooser_get_use_preview_label = cast(typeof(gtk_file_chooser_get_use_preview_label))lib.getSymbol("gtk_file_chooser_get_use_preview_label");
	gtk_file_chooser_get_preview_filename = cast(typeof(gtk_file_chooser_get_preview_filename))lib.getSymbol("gtk_file_chooser_get_preview_filename");
	gtk_file_chooser_get_preview_uri = cast(typeof(gtk_file_chooser_get_preview_uri))lib.getSymbol("gtk_file_chooser_get_preview_uri");
	gtk_file_chooser_get_preview_file = cast(typeof(gtk_file_chooser_get_preview_file))lib.getSymbol("gtk_file_chooser_get_preview_file");
	gtk_file_chooser_set_extra_widget = cast(typeof(gtk_file_chooser_set_extra_widget))lib.getSymbol("gtk_file_chooser_set_extra_widget");
	gtk_file_chooser_get_extra_widget = cast(typeof(gtk_file_chooser_get_extra_widget))lib.getSymbol("gtk_file_chooser_get_extra_widget");
	*/
	gtk_file_chooser_add_filter = cast(typeof(gtk_file_chooser_add_filter))lib.getSymbol("gtk_file_chooser_add_filter");
	gtk_file_chooser_remove_filter = cast(typeof(gtk_file_chooser_remove_filter))lib.getSymbol("gtk_file_chooser_remove_filter");
	gtk_file_chooser_list_filters = cast(typeof(gtk_file_chooser_list_filters))lib.getSymbol("gtk_file_chooser_list_filters");
	gtk_file_chooser_set_filter = cast(typeof(gtk_file_chooser_set_filter))lib.getSymbol("gtk_file_chooser_set_filter");
	gtk_file_chooser_get_filter = cast(typeof(gtk_file_chooser_get_filter))lib.getSymbol("gtk_file_chooser_get_filter");
	gtk_file_chooser_add_shortcut_folder = cast(typeof(gtk_file_chooser_add_shortcut_folder))lib.getSymbol("gtk_file_chooser_add_shortcut_folder");
	gtk_file_chooser_remove_shortcut_folder = cast(typeof(gtk_file_chooser_remove_shortcut_folder))lib.getSymbol("gtk_file_chooser_remove_shortcut_folder");
	gtk_file_chooser_list_shortcut_folders = cast(typeof(gtk_file_chooser_list_shortcut_folders))lib.getSymbol("gtk_file_chooser_list_shortcut_folders");
	gtk_file_chooser_add_shortcut_folder_uri = cast(typeof(gtk_file_chooser_add_shortcut_folder_uri))lib.getSymbol("gtk_file_chooser_add_shortcut_folder_uri");
	gtk_file_chooser_remove_shortcut_folder_uri = cast(typeof(gtk_file_chooser_remove_shortcut_folder_uri))lib.getSymbol("gtk_file_chooser_remove_shortcut_folder_uri");
	gtk_file_chooser_list_shortcut_folder_uris = cast(typeof(gtk_file_chooser_list_shortcut_folder_uris))lib.getSymbol("gtk_file_chooser_list_shortcut_folder_uris");
	//}}}

	//{{{ gtkfilechooserdialog
	gtk_file_chooser_dialog_get_type = cast(typeof(gtk_file_chooser_dialog_get_type))lib.getSymbol("gtk_file_chooser_dialog_get_type");
	gtk_file_chooser_dialog_new = cast(typeof(gtk_file_chooser_dialog_new))lib.getSymbol("gtk_file_chooser_dialog_new");
	//}}}

	//{{{ gtkstock
	gtk_stock_add = cast(typeof(gtk_stock_add))lib.getSymbol("gtk_stock_add");
	gtk_stock_add_static = cast(typeof(gtk_stock_add_static))lib.getSymbol("gtk_stock_add_static");
	gtk_stock_lookup = cast(typeof(gtk_stock_lookup))lib.getSymbol("gtk_stock_lookup");
	gtk_stock_list_ids = cast(typeof(gtk_stock_list_ids))lib.getSymbol("gtk_stock_list_ids");
	gtk_stock_item_copy = cast(typeof(gtk_stock_item_copy))lib.getSymbol("gtk_stock_item_copy");
	gtk_stock_item_free = cast(typeof(gtk_stock_item_free))lib.getSymbol("gtk_stock_item_free");
	//gtk_stock_set_translate_func = cast(typeof(gtk_stock_set_translate_func))lib.getSymbol("gtk_stock_set_translate_func");
	//}}}

	gtk_init(null, null);
}
