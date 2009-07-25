module dynamin.c.xlib;

/*
 * A binding to at least the part of the X Window System that Dynamin uses. This
 * binding is incomplete as it is made only for Dynamin's use.
 */

import dynamin.c.x_types;

version(build) { pragma(link, X11); }

extern(C):

alias ubyte* XPointer;
alias uint XID;
// export these with an X prefix so they won't as easily conflict
alias uint XMask;
alias uint XAtom;
alias uint XVisualID;
alias uint XTime;
alias XID XWindow;
alias XID XDrawable;
alias XID XPixmap;
alias XID XCursor;
alias XID XColormap;
alias XID XKeySym;
alias ubyte XKeyCode;
alias int XBool;
alias int XStatus;

alias void XScreen;
alias void XDisplay;

const None            = 0;
const ParentRelative  = 1;
const CopyFromParent  = 0;
const PointerWindow   = 0;
const InputFocus      = 1;
const PointerRoot     = 1;
const AnyPropertyType = 0;
const AnyKey          = 0;
const AnyButton       = 0;
const AllTemporary    = 0;
const CurrentTime     = 0;
const NoSymbol        = 0;

//{{{ display functions
Display* XOpenDisplay(char* display_name);

int XNextEvent(Display* display, XEvent* event_return);

int XEventsQueued(Display* display, int mode);

int XPending(Display* display);

int XPutBackEvent(Display* display, XEvent* event);

Status XSendEvent(
	Display* display,
	Window w,
	Bool propagate,
	int event_mask,
	XEvent* event_send);

int XCloseDisplay(Display* display);

char* XDisplayString(Display* display);

int XFlush(Display* display);

int XSync(Display* display, Bool discard);

int XDisplayWidth(Display* display, int screen_number);

int XDisplayHeight(Display* display, int screen_number);

int XProtocolRevision(Display* display);

int XProtocolVersion(Display* display);

Colormap XDefaultColormap(Display* display, int screen_number);

Status XAllocColor(Display* display, Colormap colormap, XColor* screen_in_out);
//}}}

//{{{ window functions
Window XCreateSimpleWindow(
	Display* display,
	Window parent,
	int x,
	int y,
	uint width,
	uint height,
	uint border_width,
	uint border,
	uint background);

Window XCreateWindow(
	Display* display,
	Window parent,
	int x,
	int y,
	uint width,
	uint height,
	uint border_width,
	int depth,
	uint c_class,
	Visual* visual,
	uint valuemask,
	XSetWindowAttributes* attributes);

int XDestroyWindow(Display* display, Window w);

int XClearArea(
	Display* display,
	Window w,
	int x,
	int y,
	uint width,
	uint height,
	Bool exposures);

Window XRootWindow(Display* display, int screen_number);

Window XDefaultRootWindow(Display* display);

Status XQueryTree(
	Display* display,
	Window w,
	Window* root_return,
	Window* parent_return,
	Window** children_return,
	uint* nchildren_return);

Bool XTranslateCoordinates(
	Display* display,
	Window src_w,
	Window dest_w,
	int src_x,
	int src_y,
	int* dest_x_return,
	int* dest_y_return,
	Window* child_return);

Window XRootWindowOfScreen(Screen* screen);

Status XIconifyWindow(Display* display, Window w, int screen_number);

Status XWithdrawWindow(Display* display, Window w, int screen_number);

int XChangeProperty(
	Display* display,
	Window w,
	Atom property,
	Atom type,
	int format,
	int mode,
	void* data,
	int nelements);

Bool XCheckIfEvent(
	Display* display,
	XEvent* event_return,
	Bool function(Display* display,
		XEvent* event,
		XPointer arg) predicate,
	XPointer arg);

int XGetWindowProperty(
	Display* display,
	Window w,
	Atom property,
	int long_offset,
	int long_length,
	Bool should_delete,
	Atom req_type,
	Atom* actual_type_return,
	int* actual_format_return,
	uint* nitems_return,
	uint* bytes_after_return,
	void** prop_return);

int XDeleteProperty(Display* display, Window w, Atom property);

int XMapWindow(Display* display, Window w);

int XUnmapWindow(Display* display, Window w);

int XMoveWindow(Display* display, Window w, int x, int y);

int XResizeWindow(Display* display, Window w, uint width, uint height);

int XMoveResizeWindow(Display* display, Window w,
	int x, int y, uint width, uint height);

int XSelectInput(Display* display, Window w, int event_mask);

int XReparentWindow(Display* display, Window w, Window parent, int x, int y);

int XRestackWindows(Display* display, Window* windows, int nwindows);

int XChangeWindowAttributes(
	Display* display,
	Window w,
	uint valuemask,
	XSetWindowAttributes* attributes);

Status XGetWindowAttributes(
	Display* display,
	Window w,
	XWindowAttributes* window_attributes_return);
//}}}

//{{{ screen functions
int XDefaultScreen(Display* display);

Screen* XDefaultScreenOfDisplay(Display* display);

int XScreenCount(Display* display);

Screen* XScreenOfDisplay(Display* display, int screen_number);

Display* XDisplayOfScreen(Screen* screen);

int XScreenNumberOfScreen(Screen* screen);

int XWidthOfScreen(Screen* screen);

int XHeightOfScreen(Screen* screen);

int XDefaultDepthOfScreen(Screen* screen);

//}}}

//{{{ pixmap functions
Pixmap XCreatePixmap(Display* display, Drawable d, uint width, uint height, uint depth);

Pixmap XCreatePixmapFromBitmapData(
	Display* display,
	Drawable d,
	ubyte* data,
	uint width,
	uint height,
	uint fg,
	uint bg,
	uint depth);

Pixmap XCreateBitmapFromData(
	Display* display,
	Drawable d,
	/*const*/ char* data,
	uint width,
	uint height);

int XFreePixmap(Display* display, Pixmap pixmap);
//}}}

//{{{ cursor functions
Cursor XCreatePixmapCursor(
	Display* display,
	Pixmap source,
	Pixmap mask,
	XColor* foreground_color,
	XColor* background_color,
	uint x,
	uint y);

Cursor XCreateFontCursor(Display* display, uint shape);

int XDefineCursor(Display* display, Window w, Cursor cursor);

int XUndefineCursor(Display* display, Window w);

int XFreeCursor(Display* display, Cursor cursor);

// cursorfont.h
enum {
	XC_num_glyphs        = 154,
	XC_X_cursor          = 0,
	XC_arrow             = 2,
	XC_based_arrow_down  = 4,
	XC_based_arrow_up    = 6,
	XC_boat              = 8,
	XC_bogosity          = 10,
	XC_bottom_left_corner  = 12,
	XC_bottom_right_corner = 14,
	XC_bottom_side       = 16,
	XC_bottom_tee        = 18,
	XC_box_spiral        = 20,
	XC_center_ptr        = 22,
	XC_circle            = 24,
	XC_clock             = 26,
	XC_coffee_mug        = 28,
	XC_cross             = 30,
	XC_cross_reverse     = 32,
	XC_crosshair         = 34,
	XC_diamond_cross     = 36,
	XC_dot               = 38,
	XC_dotbox            = 40,
	XC_double_arrow      = 42,
	XC_draft_large       = 44,
	XC_draft_small       = 46,
	XC_draped_box        = 48,
	XC_exchange          = 50,
	XC_fleur             = 52,
	XC_gobbler           = 54,
	XC_gumby             = 56,
	XC_hand1             = 58,
	XC_hand2             = 60,
	XC_heart             = 62,
	XC_icon              = 64,
	XC_iron_cross        = 66,
	XC_left_ptr          = 68,
	XC_left_side         = 70,
	XC_left_tee          = 72,
	XC_leftbutton        = 74,
	XC_ll_angle          = 76,
	XC_lr_angle          = 78,
	XC_man               = 80,
	XC_middlebutton      = 82,
	XC_mouse             = 84,
	XC_pencil            = 86,
	XC_pirate            = 88,
	XC_plus              = 90,
	XC_question_arrow    = 92,
	XC_right_ptr         = 94,
	XC_right_side        = 96,
	XC_right_tee         = 98,
	XC_rightbutton       = 100,
	XC_rtl_logo          = 102,
	XC_sailboat          = 104,
	XC_sb_down_arrow     = 106,
	XC_sb_h_double_arrow = 108,
	XC_sb_left_arrow     = 110,
	XC_sb_right_arrow    = 112,
	XC_sb_up_arrow       = 114,
	XC_sb_v_double_arrow = 116,
	XC_shuttle           = 118,
	XC_sizing            = 120,
	XC_spider            = 122,
	XC_spraycan          = 124,
	XC_star              = 126,
	XC_target            = 128,
	XC_tcross            = 130,
	XC_top_left_arrow    = 132,
	XC_top_left_corner   = 134,
	XC_top_right_corner  = 136,
	XC_top_side          = 138,
	XC_top_tee           = 140,
	XC_trek              = 142,
	XC_ul_angle          = 144,
	XC_umbrella          = 146,
	XC_ur_angle          = 148,
	XC_watch             = 150,
	XC_xterm             = 152,
}
//}}}

//{{{ keyboard functions
KeyCode XKeysymToKeycode(Display* display, KeySym keysym);

KeySym XKeycodeToKeysym(
	Display* display,
	// if NeedWidePrototypes
	uint keycode,
	// else
	//KeyCode keycode,
	int index);

char* XKeysymToString(KeySym keysym);

KeySym XStringToKeysym(char* string);
//}}}

char** XListExtensions(Display* display, int* nextensions_return);

int XFreeExtensionList(char** list);

XExtCodes* XInitExtension(Display* display, char* name);

uint XBlackPixel(Display* display, int screen_number);

uint XWhitePixel(Display* display, int screen_number);

int XDefaultDepth(Display* display, int screen_number);

int XFree(void* data);

int XNoOp(Display* display);

Visual* XDefaultVisual(Display* display, int screen_number);

Visual* XDefaultVisualOfScreen(Screen* screen);

Window XGetSelectionOwner(Display* display, Atom selection);

int XSetSelectionOwner(Display* display, Atom selection, Window owner, Time time);

void XSetWMName(Display* display, Window w, XTextProperty* text_prop);

Status XSetWMProtocols(Display* display, Window w, Atom* protocols, int count);

int XConvertSelection(
	Display* display,
	Atom selection,
	Atom target,
	Atom property,
	Window requestor,
	Time time);

//{{{ atoms
Atom XInternAtom(Display* display, char* atom_name, Bool only_if_exists);

Status XInternAtoms(
	Display* dpy,
	char** names,
	int count,
	Bool onlyIfExists,
	Atom* atoms_return);

enum : Atom {
	XA_PRIMARY             = 1,
	XA_SECONDARY           = 2,
	XA_ARC                 = 3,
	XA_ATOM                = 4,
	XA_BITMAP              = 5,
	XA_CARDINAL            = 6,
	XA_COLORMAP            = 7,
	XA_CURSOR              = 8,
	XA_CUT_BUFFER0         = 9,
	XA_CUT_BUFFER1         = 10,
	XA_CUT_BUFFER2         = 11,
	XA_CUT_BUFFER3         = 12,
	XA_CUT_BUFFER4         = 13,
	XA_CUT_BUFFER5         = 14,
	XA_CUT_BUFFER6         = 15,
	XA_CUT_BUFFER7         = 16,
	XA_DRAWABLE            = 17,
	XA_FONT                = 18,
	XA_INTEGER             = 19,
	XA_PIXMAP              = 20,
	XA_POINT               = 21,
	XA_RECTANGLE           = 22,
	XA_RESOURCE_MANAGER    = 23,
	XA_RGB_COLOR_MAP       = 24,
	XA_RGB_BEST_MAP        = 25,
	XA_RGB_BLUE_MAP        = 26,
	XA_RGB_DEFAULT_MAP     = 27,
	XA_RGB_GRAY_MAP        = 28,
	XA_RGB_GREEN_MAP       = 29,
	XA_RGB_RED_MAP         = 30,
	XA_STRING              = 31,
	XA_VISUALID            = 32,
	XA_WINDOW              = 33,
	XA_WM_COMMAND          = 34,
	XA_WM_HINTS            = 35,
	XA_WM_CLIENT_MACHINE   = 36,
	XA_WM_ICON_NAME        = 37,
	XA_WM_ICON_SIZE        = 38,
	XA_WM_NAME             = 39,
	XA_WM_NORMAL_HINTS     = 40,
	XA_WM_SIZE_HINTS       = 41,
	XA_WM_ZOOM_HINTS       = 42,
	XA_MIN_SPACE           = 43,
	XA_NORM_SPACE          = 44,
	XA_MAX_SPACE           = 45,
	XA_END_SPACE           = 46,
	XA_SUPERSCRIPT_X       = 47,
	XA_SUPERSCRIPT_Y       = 48,
	XA_SUBSCRIPT_X         = 49,
	XA_SUBSCRIPT_Y         = 50,
	XA_UNDERLINE_POSITION  = 51,
	XA_UNDERLINE_THICKNESS = 52,
	XA_STRIKEOUT_ASCENT    = 53,
	XA_STRIKEOUT_DESCENT   = 54,
	XA_ITALIC_ANGLE        = 55,
	XA_X_HEIGHT            = 56,
	XA_QUAD_WIDTH          = 57,
	XA_WEIGHT              = 58,
	XA_POINT_SIZE          = 59,
	XA_RESOLUTION          = 60,
	XA_COPYRIGHT           = 61,
	XA_NOTICE              = 62,
	XA_FONT_NAME           = 63,
	XA_FAMILY_NAME         = 64,
	XA_FULL_NAME           = 65,
	XA_CAP_HEIGHT          = 66,
	XA_WM_CLASS            = 67,
	XA_WM_TRANSIENT_FOR    = 68,

	XA_LAST_PREDEFINED     = 68
}
//}}}

Status XStringListToTextProperty(char** list, int count, XTextProperty* text_prop_return);

XSizeHints* XAllocSizeHints();

void XSetWMNormalHints(Display* display, Window w, XSizeHints* hints);

Status XGetWMNormalHints(
	Display* display,
	Window w,
	XSizeHints* hints_return,
	long* supplied_return);

XWMHints* XAllocWMHints();

int XSetWMHints(Display* display, Window w, XWMHints* wm_hints);

XWMHints *XGetWMHints(Display* display, Window w);

//{{{ enums
enum {
	InputHint        = 1 << 0,
	StateHint        = 1 << 1,
	IconPixmapHint   = 1 << 2,
	IconWindowHint   = 1 << 3,
	IconPositionHint = 1 << 4,
	IconMaskHint     = 1 << 5,
	WindowGroupHint  = 1 << 6,
	AllHints         = InputHint | StateHint | IconPixmapHint | IconWindowHint |
	                   IconPositionHint | IconMaskHint | WindowGroupHint,
	XUrgencyHint     = 1 << 8
}

enum {
	WithdrawnState = 0,
	NormalState = 1,
	IconicState = 3
}

enum {
	QueuedAlready      = 0,
	QueuedAfterReading = 1,
	QueuedAfterFlush   = 2
}

enum {
	USPosition  = 1 << 0,
	USSize      = 1 << 1,
	PPosition   = 1 << 2,
	PSize       = 1 << 3,
	PMinSize    = 1 << 4,
	PMaxSize    = 1 << 5,
	PResizeInc  = 1 << 6,
	PAspect     = 1 << 7,
	PBaseSize   = 1 << 8,
	PWinGravity = 1 << 9
}

enum {
	ShiftMask   = 1 << 0,
	LockMask    = 1 << 1,
	ControlMask = 1 << 2,
	Mod1Mask    = 1 << 3,
	Mod2Mask    = 1 << 4,
	Mod3Mask    = 1 << 5,
	Mod4Mask    = 1 << 6,
	Mod5Mask    = 1 << 7
}

enum {
	ShiftMapIndex   = 0,
	LockMapIndex    = 1,
	ControlMapIndex = 2,
	Mod1MapIndex    = 3,
	Mod2MapIndex    = 4,
	Mod3MapIndex    = 5,
	Mod4MapIndex    = 6,
	Mod5MapIndex    = 7
}

enum {
	Button1Mask = 1 << 8,
	Button2Mask = 1 << 9,
	Button3Mask = 1 << 10,
	Button4Mask = 1 << 11,
	Button5Mask = 1 << 12
}

enum {
	AnyModifier = 1 << 15
}

enum {
	Button1 = 1,
	Button2 = 2,
	Button3 = 3,
	Button4 = 4,
	Button5 = 5
}

enum {
	NotifyNormal       = 0,
	NotifyGrab         = 1,
	NotifyUngrab       = 2,
	NotifyWhileGrabbed = 3
}

enum {
	NotifyHint = 1
}

enum {
	NotifyAncestor         = 0,
	NotifyVirtual          = 1,
	NotifyInferior         = 2,
	NotifyNonlinear        = 3,
	NotifyNonlinearVirtual = 4,
	NotifyPointer          = 5,
	NotifyPointerRoot      = 6,
	NotifyDetailNone       = 7
}

enum {
	VisibilityUnobscured        = 0,
	VisibilityPartiallyObscured = 1,
	VisibilityFullyObscured     = 2
}

enum {
	PlaceOnTop    = 0,
	PlaceOnBottom = 1
}

enum {
	FamilyInternet  = 0,
	FamilyDECnet    = 1,
	FamilyChaos     = 2,
	FamilyInternet6 = 6
}

enum {
	FamilyServerInterpreted = 5
}

enum {
	PropertyNewValue = 0,
	PropertyDelete   = 1
}

enum {
	ColormapUninstalled = 0,
	ColormapInstalled   = 1
}

enum {
	GrabModeSync  = 0,
	GrabModeAsync = 1
}

enum {
	GrabSuccess     = 0,
	AlreadyGrabbed  = 1,
	GrabInvalidTime = 2,
	GrabNotViewable = 3,
	GrabFrozen      = 4
}

enum {
	AsyncPointer   = 0,
	SyncPointer    = 1,
	ReplayPointer  = 2,
	AsyncKeyboard  = 3,
	SyncKeyboard   = 4,
	ReplayKeyboard = 5,
	AsyncBoth      = 6,
	SyncBoth       = 7
}

enum {
	RevertToNone        = None,
	RevertToPointerRoot = PointerRoot,
	RevertToParent      = 2
}

enum {
	InputOutput = 1,
	InputOnly   = 2
}

enum {
	CWBackPixmap       = 1 << 0,
	CWBackPixel        = 1 << 1,
	CWBorderPixmap     = 1 << 2,
	CWBorderPixel      = 1 << 3,
	CWBitGravity       = 1 << 4,
	CWWinGravity       = 1 << 5,
	CWBackingStore     = 1 << 6,
	CWBackingPlanes    = 1 << 7,
	CWBackingPixel     = 1 << 8,
	CWOverrideRedirect = 1 << 9,
	CWSaveUnder        = 1 << 10,
	CWEventMask        = 1 << 11,
	CWDontPropagate    = 1 << 12,
	CWColormap         = 1 << 13,
	CWCursor           = 1 << 14,
}

enum {
	CWX           = 1 << 0,
	CWY           = 1 << 1,
	CWWidth       = 1 << 2,
	CWHeight      = 1 << 3,
	CWBorderWidth = 1 << 4,
	CWSibling     = 1 << 5,
	CWStackMode   = 1 << 6
}

enum {
	ForgetGravity    = 0,
	NorthWestGravity = 1,
	NorthGravity     = 2,
	NorthEastGravity = 3,
	WestGravity      = 4,
	CenterGravity    = 5,
	EastGravity      = 6,
	SouthWestGravity = 7,
	SouthGravity     = 8,
	SouthEastGravity = 9,
	StaticGravity    = 10
}

enum {
	UnmapGravity = 0
}

enum {
	NotUseful  = 0,
	WhenMapped = 1,
	Always     = 2
}

enum {
	IsUnmapped   = 0,
	IsUnviewable = 1,
	IsViewable   = 2
}

enum {
	SetModeInsert = 0,
	SetModeDelete = 1
}

enum {
	DestroyAll      = 0,
	RetainPermanent = 1,
	RetainTemporary = 2
}

enum {
	Above    = 0,
	Below    = 1,
	TopIf    = 2,
	BottomIf = 3,
	Opposite = 4
}

enum {
	RaiseLowest  = 0,
	LowerHighest = 1
}

enum {
	PropModeReplace = 0,
	PropModePrepend = 1,
	PropModeAppend  = 2
}
//}}}

struct XSizeHints {
	int flags;
	int x, y;
	int width, height;
	int min_width, min_height;
	int max_width, max_height;
	int width_inc, height_inc;
	struct _aspect {
		int x;
		int y;
	}
	_aspect min_aspect, max_aspect;
	int base_width, base_height;
	int win_gravity;
}

struct XWMHints {
	int flags;
	Bool input;
	int initial_state;
	Pixmap icon_pixmap;
	Window icon_window;
	int icon_x, icon_y;
	Pixmap icon_mask;
	XID window_group;
}

struct XTextProperty {
	char* value;
	Atom encoding;
	int format;
	uint nitems;
}

struct XColor {
	uint pixel;
	ushort red, green, blue;
	ubyte flags;
	ubyte pad;
}

struct Visual {
	XExtData* ext_data;
	VisualID visualid;
	int c_class;
	uint red_mask, green_mask, blue_mask;
	int bits_per_rgb;
	int map_entries;
}

struct XExtCodes {
	int extension;
	int major_opcode;
	int first_event;
	int first_error;
}

struct XExtData {
	int number;
	XExtData* next;
	int function(XExtData* extension) free_private;
	XPointer private_data;
}

struct XSetWindowAttributes {
	Pixmap background_pixmap;
	uint background_pixel;
	Pixmap border_pixmap;
	uint border_pixel;
	int bit_gravity;
	int win_gravity;
	int backing_store;
	uint backing_planes;
	uint backing_pixel;
	Bool save_under;
	int event_mask;
	int do_not_propagate_mask;
	Bool override_redirect;
	Colormap colormap;
	Cursor cursor;
}

struct XWindowAttributes {
	int x, y;
	int width, height;
	int border_width;
	int depth;
	Visual* visual;
	Window root;
	int c_class;
	int bit_gravity;
	int win_gravity;
	int backing_store;
	uint backing_planes;
	uint backing_pixel;
	Bool save_under;
	Colormap colormap;
	Bool map_installed;
	int map_state;
	int all_event_masks;
	int your_event_mask;
	int do_not_propagate_mask;
	Bool override_redirect;
	Screen* screen;
}

//{{{ events
struct XKeyEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window window;
	Window root;
	Window subwindow;
	Time time;
	int x, y;
	int x_root, y_root;
	uint state;
	uint keycode;
	Bool same_screen;
}
alias XKeyEvent XKeyPressedEvent;
alias XKeyEvent XKeyReleasedEvent;

struct XButtonEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window window;
	Window root;
	Window subwindow;
	Time time;
	int x, y;
	int x_root, y_root;
	uint state;
	uint button;
	Bool same_screen;
}
alias XButtonEvent XButtonPressedEvent;
alias XButtonEvent XButtonReleasedEvent;


struct XMotionEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window window;
	Window root;
	Window subwindow;
	Time time;
	int x, y;
	int x_root, y_root;
	uint state;
	char is_hint;
	Bool same_screen;
}
alias XMotionEvent XPointerMovedEvent;

struct XCrossingEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window window;
	Window root;
	Window subwindow;
	Time time;
	int x, y;
	int x_root, y_root;
	int mode;
	int detail;
	Bool same_screen;
	Bool focus;
	uint state;
}
alias XCrossingEvent XEnterWindowEvent;
alias XCrossingEvent XLeaveWindowEvent;

struct XFocusChangeEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window window;
	int mode;
	int detail;
}
alias XFocusChangeEvent XFocusInEvent;
alias XFocusChangeEvent XFocusOutEvent;

struct XKeymapEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window window;
	char key_vector[32];
}

struct XExposeEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window window;
	int x, y;
	int width, height;
	int count;
}

struct XGraphicsExposeEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Drawable drawable;
	int x, y;
	int width, height;
	int count;
	int major_code;
	int minor_code;
}

struct XNoExposeEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Drawable drawable;
	int major_code;
	int minor_code;
}

struct XVisibilityEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window window;
	int state;
}

struct XCreateWindowEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window parent;
	Window window;
	int x, y;
	int width, height;
	int border_width;
	Bool override_redirect;
}

struct XDestroyWindowEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window event;
	Window window;
}

struct XUnmapEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window event;
	Window window;
	Bool from_configure;
}

struct XMapEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window event;
	Window window;
	Bool override_redirect;
}

struct XMapRequestEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window parent;
	Window window;
}

struct XReparentEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window event;
	Window window;
	Window parent;
	int x, y;
	Bool override_redirect;
}

struct XConfigureEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window event;
	Window window;
	int x, y;
	int width, height;
	int border_width;
	Window above;
	Bool override_redirect;
}

struct XGravityEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window event;
	Window window;
	int x, y;
}

struct XResizeRequestEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window window;
	int width, height;
}

struct XConfigureRequestEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window parent;
	Window window;
	int x, y;
	int width, height;
	int border_width;
	Window above;
	int detail;
	uint value_mask;
}

struct XCirculateEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window event;
	Window window;
	int place;
}

struct XCirculateRequestEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window parent;
	Window window;
	int place;
}

struct XPropertyEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window window;
	Atom atom;
	Time time;
	int state;
}

struct XSelectionClearEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window window;
	Atom selection;
	Time time;
}

struct XSelectionRequestEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window owner;
	Window requestor;
	Atom selection;
	Atom target;
	Atom property;
	Time time;
}

struct XSelectionEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window requestor;
	Atom selection;
	Atom target;
	Atom property;
	Time time;
}

struct XColormapEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window window;
	Colormap colormap;
	Bool is_new;
	int state;
}

struct XClientMessageEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window window;
	Atom message_type;
	int format;
	union _data {
		char[20] b;
		short[10] s;
		int[5] l;
	}
	_data data;
}

struct XMappingEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window window;
	int request;
	int first_keycode;
	int count;
}

struct XErrorEvent {
	int type;
	Display* display;
	XID resourceid;
	uint serial;
	ubyte error_code;
	ubyte request_code;
	ubyte minor_code;
}

struct XAnyEvent {
	int type;
	uint serial;
	Bool send_event;
	Display* display;
	Window window;
}

union XEvent {
		int type;
	XAnyEvent xany;
	XKeyEvent xkey;
	XButtonEvent xbutton;
	XMotionEvent xmotion;
	XCrossingEvent xcrossing;
	XFocusChangeEvent xfocus;
	XExposeEvent xexpose;
	XGraphicsExposeEvent xgraphicsexpose;
	XNoExposeEvent xnoexpose;
	XVisibilityEvent xvisibility;
	XCreateWindowEvent xcreatewindow;
	XDestroyWindowEvent xdestroywindow;
	XUnmapEvent xunmap;
	XMapEvent xmap;
	XMapRequestEvent xmaprequest;
	XReparentEvent xreparent;
	XConfigureEvent xconfigure;
	XGravityEvent xgravity;
	XResizeRequestEvent xresizerequest;
	XConfigureRequestEvent xconfigurerequest;
	XCirculateEvent xcirculate;
	XCirculateRequestEvent xcirculaterequest;
	XPropertyEvent xproperty;
	XSelectionClearEvent xselectionclear;
	XSelectionRequestEvent xselectionrequest;
	XSelectionEvent xselection;
	XColormapEvent xcolormap;
	XClientMessageEvent xclient;
	XMappingEvent xmapping;
	XErrorEvent xerror;
	XKeymapEvent xkeymap;
	int pad[24];
}
//}}}

//{{{ event types
enum {
	KeyPress         = 2,
	KeyRelease       = 3,
	ButtonPress      = 4,
	ButtonRelease    = 5,
	MotionNotify     = 6,
	EnterNotify      = 7,
	LeaveNotify      = 8,
	FocusIn          = 9,
	FocusOut         = 10,
	KeymapNotify     = 11,
	Expose           = 12,
	GraphicsExpose   = 13,
	NoExpose         = 14,
	VisibilityNotify = 15,
	CreateNotify     = 16,
	DestroyNotify    = 17,
	UnmapNotify      = 18,
	MapNotify        = 19,
	MapRequest       = 20,
	ReparentNotify   = 21,
	ConfigureNotify  = 22,
	ConfigureRequest = 23,
	GravityNotify    = 24,
	ResizeRequest    = 25,
	CirculateNotify  = 26,
	CirculateRequest = 27,
	PropertyNotify   = 28,
	SelectionClear   = 29,
	SelectionRequest = 30,
	SelectionNotify  = 31,
	ColormapNotify   = 32,
	ClientMessage    = 33,
	MappingNotify    = 34,
	LASTEvent        = 35 // must be bigger than any event #
}
//}}}

//{{{ event masks
enum {
	NoEventMask              = 0,
	KeyPressMask             = 1 << 0,
	KeyReleaseMask           = 1 << 1,
	ButtonPressMask          = 1 << 2,
	ButtonReleaseMask        = 1 << 3,
	EnterWindowMask          = 1 << 4,
	LeaveWindowMask          = 1 << 5,
	PointerMotionMask        = 1 << 6,
	PointerMotionHintMask    = 1 << 7,
	Button1MotionMask        = 1 << 8,
	Button2MotionMask        = 1 << 9,
	Button3MotionMask        = 1 << 10,
	Button4MotionMask        = 1 << 11,
	Button5MotionMask        = 1 << 12,
	ButtonMotionMask         = 1 << 13,
	KeymapStateMask          = 1 << 14,
	ExposureMask             = 1 << 15,
	VisibilityChangeMask     = 1 << 16,
	StructureNotifyMask      = 1 << 17,
	ResizeRedirectMask       = 1 << 18,
	SubstructureNotifyMask   = 1 << 19,
	SubstructureRedirectMask = 1 << 20,
	FocusChangeMask          = 1 << 21,
	PropertyChangeMask       = 1 << 22,
	ColormapChangeMask       = 1 << 23,
	OwnerGrabButtonMask      = 1 << 24
}
//}}}

//{{{ keys
enum {
	XK_BackSpace     = 0xFF08,
	XK_Tab           = 0xFF09,
	XK_Linefeed      = 0xFF0A,
	XK_Clear         = 0xFF0B,
	XK_Return        = 0xFF0D,
	XK_Pause         = 0xFF13,
	XK_Scroll_Lock   = 0xFF14,
	XK_Sys_Req       = 0xFF15,
	XK_Escape        = 0xFF1B,
	XK_Delete        = 0xFFFF,

	XK_Home          = 0xFF50,
	XK_Left          = 0xFF51,
	XK_Up            = 0xFF52,
	XK_Right         = 0xFF53,
	XK_Down          = 0xFF54,
	XK_Prior         = 0xFF55,
	XK_Page_Up       = 0xFF55,
	XK_Next          = 0xFF56,
	XK_Page_Down     = 0xFF56,
	XK_End           = 0xFF57,
	XK_Begin         = 0xFF58,

	XK_Select        = 0xFF60,
	XK_Print         = 0xFF61,
	XK_Execute       = 0xFF62,
	XK_Insert        = 0xFF63,
	XK_Undo          = 0xFF65,
	XK_Redo          = 0xFF66,
	XK_Menu          = 0xFF67,
	XK_Find          = 0xFF68,
	XK_Cancel        = 0xFF69,
	XK_Help          = 0xFF6A,
	XK_Break         = 0xFF6B,
	XK_Mode_switch   = 0xFF7E,
	XK_script_switch = 0xFF7E,
	XK_Num_Lock      = 0xFF7F,

	XK_KP_Space      = 0xFF80,
	XK_KP_Tab        = 0xFF89,
	XK_KP_Enter      = 0xFF8D,
	XK_KP_F1         = 0xFF91,
	XK_KP_F2         = 0xFF92,
	XK_KP_F3         = 0xFF93,
	XK_KP_F4         = 0xFF94,
	XK_KP_Home       = 0xFF95,
	XK_KP_Left       = 0xFF96,
	XK_KP_Up         = 0xFF97,
	XK_KP_Right      = 0xFF98,
	XK_KP_Down       = 0xFF99,
	XK_KP_Prior      = 0xFF9A,
	XK_KP_Page_Up    = 0xFF9A,
	XK_KP_Next       = 0xFF9B,
	XK_KP_Page_Down  = 0xFF9B,
	XK_KP_End        = 0xFF9C,
	XK_KP_Begin      = 0xFF9D,
	XK_KP_Insert     = 0xFF9E,
	XK_KP_Delete     = 0xFF9F,
	XK_KP_Equal      = 0xFFBD,
	XK_KP_Multiply   = 0xFFAA,
	XK_KP_Add        = 0xFFAB,
	XK_KP_Separator  = 0xFFAC,
	XK_KP_Subtract   = 0xFFAD,
	XK_KP_Decimal    = 0xFFAE,
	XK_KP_Divide     = 0xFFAF,

	XK_KP_0          = 0xFFB0,
	XK_KP_1          = 0xFFB1,
	XK_KP_2          = 0xFFB2,
	XK_KP_3          = 0xFFB3,
	XK_KP_4          = 0xFFB4,
	XK_KP_5          = 0xFFB5,
	XK_KP_6          = 0xFFB6,
	XK_KP_7          = 0xFFB7,
	XK_KP_8          = 0xFFB8,
	XK_KP_9          = 0xFFB9,

	XK_F1            = 0xFFBE,
	XK_F2            = 0xFFBF,
	XK_F3            = 0xFFC0,
	XK_F4            = 0xFFC1,
	XK_F5            = 0xFFC2,
	XK_F6            = 0xFFC3,
	XK_F7            = 0xFFC4,
	XK_F8            = 0xFFC5,
	XK_F9            = 0xFFC6,
	XK_F10           = 0xFFC7,
	XK_F11           = 0xFFC8,
	XK_L1            = 0xFFC8,
	XK_F12           = 0xFFC9,
	XK_L2            = 0xFFC9,
	XK_F13           = 0xFFCA,
	XK_L3            = 0xFFCA,
	XK_F14           = 0xFFCB,
	XK_L4            = 0xFFCB,
	XK_F15           = 0xFFCC,
	XK_L5            = 0xFFCC,
	XK_F16           = 0xFFCD,
	XK_L6            = 0xFFCD,
	XK_F17           = 0xFFCE,
	XK_L7            = 0xFFCE,
	XK_F18           = 0xFFCF,
	XK_L8            = 0xFFCF,
	XK_F19           = 0xFFD0,
	XK_L9            = 0xFFD0,
	XK_F20           = 0xFFD1,
	XK_L10           = 0xFFD1,
	XK_F21           = 0xFFD2,
	XK_R1            = 0xFFD2,
	XK_F22           = 0xFFD3,
	XK_R2            = 0xFFD3,
	XK_F23           = 0xFFD4,
	XK_R3            = 0xFFD4,
	XK_F24           = 0xFFD5,
	XK_R4            = 0xFFD5,
	XK_F25           = 0xFFD6,
	XK_R5            = 0xFFD6,
	XK_F26           = 0xFFD7,
	XK_R6            = 0xFFD7,
	XK_F27           = 0xFFD8,
	XK_R7            = 0xFFD8,
	XK_F28           = 0xFFD9,
	XK_R8            = 0xFFD9,
	XK_F29           = 0xFFDA,
	XK_R9            = 0xFFDA,
	XK_F30           = 0xFFDB,
	XK_R10           = 0xFFDB,
	XK_F31           = 0xFFDC,
	XK_R11           = 0xFFDC,
	XK_F32           = 0xFFDD,
	XK_R12           = 0xFFDD,
	XK_F33           = 0xFFDE,
	XK_R13           = 0xFFDE,
	XK_F34           = 0xFFDF,
	XK_R14           = 0xFFDF,
	XK_F35           = 0xFFE0,
	XK_R15           = 0xFFE0,

	XK_Shift_L       = 0xFFE1,
	XK_Shift_R       = 0xFFE2,
	XK_Control_L     = 0xFFE3,
	XK_Control_R     = 0xFFE4,
	XK_Caps_Lock     = 0xFFE5,
	XK_Shift_Lock    = 0xFFE6,

	XK_Meta_L        = 0xFFE7,
	XK_Meta_R        = 0xFFE8,
	XK_Alt_L         = 0xFFE9,
	XK_Alt_R         = 0xFFEA,
	XK_Super_L       = 0xFFEB,
	XK_Super_R       = 0xFFEC,
	XK_Hyper_L       = 0xFFED,
	XK_Hyper_R       = 0xFFEE,

	XK_space         = 0x020,
	XK_exclam        = 0x021,
	XK_quotedbl      = 0x022,
	XK_numbersign    = 0x023,
	XK_dollar        = 0x024,
	XK_percent       = 0x025,
	XK_ampersand     = 0x026,
	XK_apostrophe    = 0x027,
	XK_quoteright    = 0x027,
	XK_parenleft     = 0x028,
	XK_parenright    = 0x029,
	XK_asterisk      = 0x02A,
	XK_plus          = 0x02B,
	XK_comma         = 0x02C,
	XK_minus         = 0x02D,
	XK_period        = 0x02E,
	XK_slash         = 0x02F,
	XK_0             = 0x030,
	XK_1             = 0x031,
	XK_2             = 0x032,
	XK_3             = 0x033,
	XK_4             = 0x034,
	XK_5             = 0x035,
	XK_6             = 0x036,
	XK_7             = 0x037,
	XK_8             = 0x038,
	XK_9             = 0x039,
	XK_colon         = 0x03A,
	XK_semicolon     = 0x03B,
	XK_less          = 0x03C,
	XK_equal         = 0x03D,
	XK_greater       = 0x03E,
	XK_question      = 0x03F,
	XK_at            = 0x040,
	XK_A             = 0x041,
	XK_B             = 0x042,
	XK_C             = 0x043,
	XK_D             = 0x044,
	XK_E             = 0x045,
	XK_F             = 0x046,
	XK_G             = 0x047,
	XK_H             = 0x048,
	XK_I             = 0x049,
	XK_J             = 0x04A,
	XK_K             = 0x04B,
	XK_L             = 0x04C,
	XK_M             = 0x04D,
	XK_N             = 0x04E,
	XK_O             = 0x04F,
	XK_P             = 0x050,
	XK_Q             = 0x051,
	XK_R             = 0x052,
	XK_S             = 0x053,
	XK_T             = 0x054,
	XK_U             = 0x055,
	XK_V             = 0x056,
	XK_W             = 0x057,
	XK_X             = 0x058,
	XK_Y             = 0x059,
	XK_Z             = 0x05A,
	XK_bracketleft   = 0x05B,
	XK_backslash     = 0x05C,
	XK_bracketright  = 0x05D,
	XK_asciicircum   = 0x05E,
	XK_underscore    = 0x05F,
	XK_grave         = 0x060,
	XK_quoteleft     = 0x060,
	XK_a             = 0x061,
	XK_b             = 0x062,
	XK_c             = 0x063,
	XK_d             = 0x064,
	XK_e             = 0x065,
	XK_f             = 0x066,
	XK_g             = 0x067,
	XK_h             = 0x068,
	XK_i             = 0x069,
	XK_j             = 0x06A,
	XK_k             = 0x06B,
	XK_l             = 0x06C,
	XK_m             = 0x06D,
	XK_n             = 0x06E,
	XK_o             = 0x06F,
	XK_p             = 0x070,
	XK_q             = 0x071,
	XK_r             = 0x072,
	XK_s             = 0x073,
	XK_t             = 0x074,
	XK_u             = 0x075,
	XK_v             = 0x076,
	XK_w             = 0x077,
	XK_x             = 0x078,
	XK_y             = 0x079,
	XK_z             = 0x07A,
	XK_braceleft     = 0x07B,
	XK_bar           = 0x07C,
	XK_braceright    = 0x07D,
	XK_asciitilde    = 0x07E
}
//}}}

