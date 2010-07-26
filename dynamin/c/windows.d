module dynamin.c.windows;

/*
 * A binding to at least the part of the Windows API that Dynamin uses. This
 * binding is obviously very incomplete but does contain _many_ functions
 * that the Phobos and Tango Windows bindings do not contain.
 */

version(Windows) {
} else {
	static assert(0);
}

version(build) { pragma(link, gdi32, comdlg32, shell32, ole32, winmm); }

extern(Windows):

alias char*  LPSTR;
alias wchar* LPWSTR;
alias char*  LPCSTR;
alias wchar* LPCWSTR;
// unicode
alias wchar   TCHAR;
alias LPWSTR  LPTSTR;
alias LPCWSTR LPCTSTR;

alias VOID*     HANDLE;
alias HANDLE    HBITMAP;
alias HANDLE    HBRUSH;
alias HANDLE    HICON;
alias HICON     HCURSOR;
alias HANDLE    HDC;
alias HANDLE    HGDIOBJ;
alias HANDLE    HGLOBAL;
alias int       HFILE;
alias HANDLE    HFONT;
alias HANDLE    HINSTANCE;
alias HANDLE    HKEY;
alias HANDLE    HMENU;
alias HINSTANCE HMODULE;
alias int       HRESULT;
alias HANDLE    HRGN;
alias HANDLE    HTHEME;
alias HANDLE    HWND;

version(Win64) {
	alias int   HALF_PTR;
	alias uint  UHALF_PTR;
	alias long  INT_PTR;
	alias ulong UINT_PTR;
	alias long  LONG_PTR;
	alias ulong ULONG_PTR;
} else {
	alias short  HALF_PTR;
	alias ushort UHALF_PTR;
	alias int    INT_PTR;
	alias uint   UINT_PTR;
	alias int    LONG_PTR;
	alias uint   ULONG_PTR;
}

alias INT_PTR function() FARPROC;
alias int       BOOL;
alias ubyte     BYTE;
alias char      CHAR;
alias wchar     WCHAR;
alias uint      DWORD;
alias ulong     DWORDLONG;
alias uint      DWORD32;
alias ulong     DWORD64;
alias float     FLOAT;
alias int       INT;
alias int       INT32;
alias long      INT64;
alias int       LONG;
alias int       LONG32;
alias long      LONG64;
alias UINT_PTR  WPARAM;
alias LONG_PTR  LPARAM;
alias LONG_PTR  LRESULT;
alias char      UCHAR;
alias uint      UINT;
alias uint      UINT32;
alias ulong     UINT64;
alias uint      ULONG;
alias uint      ULONG32;
alias ulong     ULONG64;
alias short     SHORT;
alias ushort    USHORT;
alias void      VOID;
alias ushort    WORD;
alias WORD      ATOM;
alias ULONG_PTR SIZE_T;
alias DWORD     COLORREF;
alias LONG      NTSTATUS;

const HRESULT S_OK    = 0;
const HRESULT S_FALSE = 1;
const HRESULT NOERROR = 0;

const int MAX_PATH = 260;

alias UINT_PTR function(HWND hdlg, UINT uiMsg, WPARAM wParam, LPARAM lParam) LPOFNHOOKPROC;
alias LRESULT function(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam) WNDPROC;
alias int function(HWND hwnd, UINT uMsg, LPARAM lParam, LPARAM lpData) BFFCALLBACK;

public import tango.sys.win32.Macros;
//public import tango.sys.win32.UserGdi : LOWORD, HIWORD, RGB;

WORD MAKEWORD(BYTE a, BYTE b) { return cast(WORD)a | cast(WORD)b << 8; }
LONG MAKELONG(WORD a, WORD b) { return cast(WORD)a | cast(WORD)b << 16; }
BYTE LOBYTE(WORD w) { return cast(BYTE)(w & 0xff); }
BYTE HIBYTE(WORD w) { return cast(BYTE)(w >> 8); }
LPWSTR MAKEINTRESOURCE(int i) { return cast(LPWSTR)cast(WORD)i; }
BYTE GetRValue(DWORD rgb) { return LOBYTE(rgb); }
BYTE GetGValue(DWORD rgb) { return LOBYTE(cast(WORD)rgb >> 8); }
BYTE GetBValue(DWORD rgb) { return LOBYTE(rgb >> 16); }

int MessageBoxW(HWND hWnd, LPCWSTR lpText, LPCWSTR lpCaption, UINT uType);

DWORD GetLastError();

enum : HRESULT {
	E_NOTIMPL                        = 0x80004001,
	E_OUTOFMEMORY                    = 0x8007000E,
	E_INVALIDARG                     = 0x80070057,
	E_NOINTERFACE                    = 0x80004002,
	E_POINTER                        = 0x80004003,
	E_HANDLE                         = 0x80070006,
	E_ABORT                          = 0x80004004,
	E_FAIL                           = 0x80004005,
	E_ACCESSDENIED                   = 0x80070005
}

// COM error codes
enum {
	SEVERITY_SUCCESS = 0,
	SEVERITY_ERROR   = 1,
}
enum {
	FACILITY_WIN32 = 7,
	FACILITY_ITF   = 4,
}

bool SUCCEEDED(HRESULT hr) { return hr >= 0; }
bool FAILED(HRESULT hr) { return hr < 0; }
bool IS_ERROR(HRESULT hr) { return (hr >> 31) == SEVERITY_ERROR; }
uint HRESULT_CODE(HRESULT hr) { return hr & 0xFFFF; }
uint HRESULT_FACILITY(HRESULT hr) { return (hr >> 16) & 0x1FFF; }
uint HRESULT_SEVERITY(HRESULT hr) { return (hr >> 31) & 0x1; }
HRESULT MAKE_HRESULT(uint sev, uint fac, uint code) { return (sev << 31) | (fac << 16) | code; }

int MultiByteToWideChar(
	UINT CodePage,
	DWORD dwFlags,
	LPCSTR lpMultiByteStr,
	int cbMultiByte,
	LPWSTR lpWideCharStr,
	int cchWideChar);

int WideCharToMultiByte(
	UINT CodePage,
	DWORD dwFlags,
	LPCWSTR lpWideCharStr,
	int cchWideChar,
	LPSTR lpMultiByteStr,
	int cbMultiByte,
	LPCSTR lpDefaultChar,
	BOOL* lpUsedDefaultChar);

//{{{ memory functions
HANDLE GetProcessHeap();

VOID* HeapAlloc(HANDLE hHeap, DWORD dwFlags, SIZE_T dwBytes);

VOID* HeapReAlloc(HANDLE hHeap, DWORD dwFlags, VOID* lpMem, SIZE_T dwBytes);

BOOL HeapFree(HANDLE hHeap, DWORD dwFlags, VOID* lpMem);

SIZE_T HeapSize(HANDLE hHeap, DWORD dwFlags, /*const*/ VOID* lpMem);

enum {
	HEAP_ZERO_MEMORY           = 0x0008,
	HEAP_REALLOC_IN_PLACE_ONLY = 0x0010
}

HGLOBAL GlobalAlloc(UINT uFlags, SIZE_T dwBytes);

HGLOBAL GlobalReAlloc(HGLOBAL hMem, SIZE_T dwBytes, UINT uFlags);

HGLOBAL GlobalFree(HGLOBAL hMem);

VOID* GlobalLock(HGLOBAL hMem);

BOOL GlobalUnlock(HGLOBAL hMem);

enum {
	GMEM_FIXED    = 0x0000,
	GMEM_MOVEABLE = 0x0002,
	GMEM_ZEROINIT = 0x0040,
	GPTR          = 0x0040,
	GHND          = 0x0042
}
//}}}

//{{{ window functions
enum {
	CS_VREDRAW         = 0x0001,
	CS_HREDRAW         = 0x0002,
	CS_DBLCLKS         = 0x0008,
	CS_OWNDC           = 0x0020,
	CS_CLASSDC         = 0x0040,
	CS_PARENTDC        = 0x0080,
	CS_NOCLOSE         = 0x0200,
	CS_SAVEBITS        = 0x0800,
	CS_BYTEALIGNCLIENT = 0x1000,
	CS_BYTEALIGNWINDOW = 0x2000,
	CS_GLOBALCLASS     = 0x4000,
	//Windows XP required
	CS_DROPSHADOW      = 0x00020000

}
ATOM RegisterClassExW(/*const*/ WNDCLASSEX* lpwcx);

LRESULT DefWindowProcW(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

//{{{ window styles
enum {
	WS_OVERLAPPED   = 0x00000000,
	WS_MAXIMIZEBOX  = 0x00010000,
	WS_TABSTOP      = 0x00010000,
	WS_GROUP        = 0x00020000,
	WS_MINIMIZEBOX  = 0x00020000,
	WS_THICKFRAME   = 0x00040000,
	WS_SYSMENU      = 0x00080000,
	WS_HSCROLL      = 0x00100000,
	WS_VSCROLL      = 0x00200000,
	WS_DLGFRAME     = 0x00400000,
	WS_BORDER       = 0x00800000,
	WS_CAPTION      = 0x00C00000,
	WS_MAXIMIZE     = 0x01000000,
	WS_CLIPCHILDREN = 0x02000000,
	WS_CLIPSIBLINGS = 0x04000000,
	WS_DISABLED     = 0x08000000,
	WS_VISIBLE      = 0x10000000,
	WS_MINIMIZE     = 0x20000000,
	WS_CHILD        = 0x40000000,
	WS_POPUP        = 0x80000000,
	WS_OVERLAPPEDWINDOW = WS_OVERLAPPED |
	                      WS_CAPTION |
	                      WS_SYSMENU |
	                      WS_THICKFRAME |
	                      WS_MINIMIZEBOX |
	                      WS_MAXIMIZEBOX,
	WS_POPUPWINDOW  = WS_POPUP |
	                  WS_BORDER |
	                  WS_SYSMENU,
	WS_CHILDWINDOW  = WS_CHILD,
	WS_TILED        = WS_OVERLAPPED,
	WS_ICONIC       = WS_MINIMIZE,
	WS_SIZEBOX      = WS_THICKFRAME,
	WS_TILEDWINDOW  = WS_OVERLAPPEDWINDOW
}
//}}}

//{{{ extended window styles
enum {
	WS_EX_DLGMODALFRAME    = 0x00000001,
	WS_EX_TOPMOST          = 0x00000008,
	WS_EX_TOOLWINDOW       = 0x00000080,
	WS_EX_WINDOWEDGE       = 0x00000100,
	WS_EX_CLIENTEDGE       = 0x00000200,
	WS_EX_CONTROLPARENT    = 0x00010000,
	WS_EX_STATICEDGE       = 0x00020000,
	WS_EX_APPWINDOW        = 0x00040000,
	WS_EX_LAYERED          = 0x00080000,
	WS_EX_OVERLAPPEDWINDOW = WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE,
	WS_EX_COMPOSITED       = 0x02000000
}
//}}}

//{{{ CreateWindowEx()
HWND CreateWindowExW(
	DWORD dwExStyle,
	LPCWSTR lpClassName,
	LPCWSTR lpWindowName,
	DWORD dwStyle,
	int x,
	int y,
	int nWidth,
	int nHeight,
	HWND hWndParent,
	HMENU hMenu,
	HINSTANCE hInstance,
	VOID* lpParam);
//}}}

BOOL DestroyWindow(HWND hWnd);

BOOL ClientToScreen(HWND hWnd, POINT* lpPoint);

BOOL ScreenToClient(HWND hWnd, POINT* lpPoint);

BOOL SetForegroundWindow(HWND hWnd);

//{{{ messages
enum {
	WM_NULL                   = 0x0000,
	WM_CREATE                 = 0x0001,
	WM_DESTROY                = 0x0002,
	WM_MOVE                   = 0x0003,
	WM_SIZE                   = 0x0005,
	WM_ACTIVATE               = 0x0006,
	WM_SETFOCUS               = 0x0007,
	WM_KILLFOCUS              = 0x0008,
	WM_ENABLE                 = 0x000A,
	WM_SETREDRAW              = 0x000B,
	WM_SETTEXT                = 0x000C,
	WM_GETTEXT                = 0x000D,
	WM_GETTEXTLENGTH          = 0x000E,
	WM_PAINT                  = 0x000F,
	WM_CLOSE                  = 0x0010,
	WM_QUERYENDSESSION        = 0x0011,
	WM_QUERYOPEN              = 0x0013,
	WM_ENDSESSION             = 0x0016,
	WM_QUIT                   = 0x0012,
	WM_ERASEBKGND             = 0x0014,
	WM_SYSCOLORCHANGE         = 0x0015,
	WM_SHOWWINDOW             = 0x0018,
	WM_WININICHANGE           = 0x001A,
	WM_SETTINGCHANGE          = WM_WININICHANGE,
	WM_DEVMODECHANGE          = 0x001B,
	WM_ACTIVATEAPP            = 0x001C,
	WM_FONTCHANGE             = 0x001D,
	WM_TIMECHANGE             = 0x001E,
	WM_CANCELMODE             = 0x001F,
	WM_SETCURSOR              = 0x0020,
	WM_MOUSEACTIVATE          = 0x0021,
	WM_CHILDACTIVATE          = 0x0022,
	WM_QUEUESYNC              = 0x0023,
	WM_GETMINMAXINFO          = 0x0024,
	WM_PAINTICON              = 0x0026,
	WM_ICONERASEBKGND         = 0x0027,
	WM_NEXTDLGCTL             = 0x0028,
	WM_SPOOLERSTATUS          = 0x002A,
	WM_DRAWITEM               = 0x002B,
	WM_MEASUREITEM            = 0x002C,
	WM_DELETEITEM             = 0x002D,
	WM_VKEYTOITEM             = 0x002E,
	WM_CHARTOITEM             = 0x002F,
	WM_SETFONT                = 0x0030,
	WM_GETFONT                = 0x0031,
	WM_SETHOTKEY              = 0x0032,
	WM_GETHOTKEY              = 0x0033,
	WM_QUERYDRAGICON          = 0x0037,
	WM_COMPAREITEM            = 0x0039,
	WM_GETOBJECT              = 0x003D,
	WM_COMPACTING             = 0x0041,
	WM_WINDOWPOSCHANGING      = 0x0046,
	WM_WINDOWPOSCHANGED       = 0x0047,
	WM_POWER                  = 0x0048,
	WM_COPYDATA               = 0x004A,
	WM_CANCELJOURNAL          = 0x004B,
	WM_NOTIFY                 = 0x004E,
	WM_INPUTLANGCHANGEREQUEST = 0x0050,
	WM_INPUTLANGCHANGE        = 0x0051,
	WM_TCARD                  = 0x0052,
	WM_HELP                   = 0x0053,
	WM_USERCHANGED            = 0x0054,
	WM_NOTIFYFORMAT           = 0x0055,
	WM_CONTEXTMENU            = 0x007B,
	WM_STYLECHANGING          = 0x007C,
	WM_STYLECHANGED           = 0x007D,
	WM_DISPLAYCHANGE          = 0x007E,
	WM_GETICON                = 0x007F,
	WM_SETICON                = 0x0080,
	WM_NCCREATE               = 0x0081,
	WM_NCDESTROY              = 0x0082,
	WM_NCCALCSIZE             = 0x0083,
	WM_NCHITTEST              = 0x0084,
	WM_NCPAINT                = 0x0085,
	WM_NCACTIVATE             = 0x0086,
	WM_GETDLGCODE             = 0x0087,
	WM_SYNCPAINT              = 0x0088,
	WM_NCMOUSEMOVE            = 0x00A0,
	WM_NCLBUTTONDOWN          = 0x00A1,
	WM_NCLBUTTONUP            = 0x00A2,
	WM_NCLBUTTONDBLCLK        = 0x00A3,
	WM_NCRBUTTONDOWN          = 0x00A4,
	WM_NCRBUTTONUP            = 0x00A5,
	WM_NCRBUTTONDBLCLK        = 0x00A6,
	WM_NCMBUTTONDOWN          = 0x00A7,
	WM_NCMBUTTONUP            = 0x00A8,
	WM_NCMBUTTONDBLCLK        = 0x00A9,
	WM_NCXBUTTONDOWN          = 0x00AB,
	WM_NCXBUTTONUP            = 0x00AC,
	WM_NCXBUTTONDBLCLK        = 0x00AD,
	WM_INPUT                  = 0x00FF,
	WM_KEYDOWN                = 0x0100,
	WM_KEYUP                  = 0x0101,
	WM_CHAR                   = 0x0102,
	WM_DEADCHAR               = 0x0103,
	WM_SYSKEYDOWN             = 0x0104,
	WM_SYSKEYUP               = 0x0105,
	WM_SYSCHAR                = 0x0106,
	WM_SYSDEADCHAR            = 0x0107,
	WM_UNICHAR                = 0x0109,
	WM_IME_STARTCOMPOSITION   = 0x010D,
	WM_IME_ENDCOMPOSITION     = 0x010E,
	WM_IME_COMPOSITION        = 0x010F,
	WM_IME_KEYLAST            = 0x010F,
	WM_INITDIALOG             = 0x0110,
	WM_COMMAND                = 0x0111,
	WM_SYSCOMMAND             = 0x0112,
	WM_TIMER                  = 0x0113,
	WM_HSCROLL                = 0x0114,
	WM_VSCROLL                = 0x0115,
	WM_INITMENU               = 0x0116,
	WM_INITMENUPOPUP          = 0x0117,
	WM_MENUSELECT             = 0x011F,
	WM_MENUCHAR               = 0x0120,
	WM_ENTERIDLE              = 0x0121,
	WM_MENURBUTTONUP          = 0x0122,
	WM_MENUDRAG               = 0x0123,
	WM_MENUGETOBJECT          = 0x0124,
	WM_UNINITMENUPOPUP        = 0x0125,
	WM_MENUCOMMAND            = 0x0126,
	WM_CHANGEUISTATE          = 0x0127,
	WM_UPDATEUISTATE          = 0x0128,
	WM_QUERYUISTATE           = 0x0129,
	WM_CTLCOLORMSGBOX         = 0x0132,
	WM_CTLCOLOREDIT           = 0x0133,
	WM_CTLCOLORLISTBOX        = 0x0134,
	WM_CTLCOLORBTN            = 0x0135,
	WM_CTLCOLORDLG            = 0x0136,
	WM_CTLCOLORSCROLLBAR      = 0x0137,
	WM_CTLCOLORSTATIC         = 0x0138,
	WM_MOUSEFIRST             = 0x0200,
	WM_MOUSEMOVE              = 0x0200,
	WM_LBUTTONDOWN            = 0x0201,
	WM_LBUTTONUP              = 0x0202,
	WM_LBUTTONDBLCLK          = 0x0203,
	WM_RBUTTONDOWN            = 0x0204,
	WM_RBUTTONUP              = 0x0205,
	WM_RBUTTONDBLCLK          = 0x0206,
	WM_MBUTTONDOWN            = 0x0207,
	WM_MBUTTONUP              = 0x0208,
	WM_MBUTTONDBLCLK          = 0x0209,
	WM_MOUSEWHEEL             = 0x020A,
	WM_XBUTTONDOWN            = 0x020B,
	WM_XBUTTONUP              = 0x020C,
	WM_XBUTTONDBLCLK          = 0x020D,
	WM_PARENTNOTIFY           = 0x0210,
	WM_ENTERMENULOOP          = 0x0211,
	WM_EXITMENULOOP           = 0x0212,
	WM_NEXTMENU               = 0x0213,
	WM_SIZING                 = 0x0214,
	WM_CAPTURECHANGED         = 0x0215,
	WM_MOVING                 = 0x0216,
	WM_POWERBROADCAST         = 0x0218,
	WM_DEVICECHANGE           = 0x0219,
	WM_MDICREATE              = 0x0220,
	WM_MDIDESTROY             = 0x0221,
	WM_MDIACTIVATE            = 0x0222,
	WM_MDIRESTORE             = 0x0223,
	WM_MDINEXT                = 0x0224,
	WM_MDIMAXIMIZE            = 0x0225,
	WM_MDITILE                = 0x0226,
	WM_MDICASCADE             = 0x0227,
	WM_MDIICONARRANGE         = 0x0228,
	WM_MDIGETACTIVE           = 0x0229,
	WM_MDISETMENU             = 0x0230,
	WM_ENTERSIZEMOVE          = 0x0231,
	WM_EXITSIZEMOVE           = 0x0232,
	WM_DROPFILES              = 0x0233,
	WM_MDIREFRESHMENU         = 0x0234,
	WM_IME_SETCONTEXT         = 0x0281,
	WM_IME_NOTIFY             = 0x0282,
	WM_IME_CONTROL            = 0x0283,
	WM_IME_COMPOSITIONFULL    = 0x0284,
	WM_IME_SELECT             = 0x0285,
	WM_IME_CHAR               = 0x0286,
	WM_IME_REQUEST            = 0x0288,
	WM_IME_KEYDOWN            = 0x0290,
	WM_IME_KEYUP              = 0x0291,
	WM_MOUSEHOVER             = 0x02A1,
	WM_MOUSELEAVE             = 0x02A3,
	WM_NCMOUSEHOVER           = 0x02A0,
	WM_NCMOUSELEAVE           = 0x02A2,
	WM_WTSSESSION_CHANGE      = 0x02B1,
	WM_TABLET_FIRST           = 0x02C0,
	WM_TABLET_LAST            = 0x02DF,
	WM_CUT                    = 0x0300,
	WM_COPY                   = 0x0301,
	WM_PASTE                  = 0x0302,
	WM_CLEAR                  = 0x0303,
	WM_UNDO                   = 0x0304,
	WM_RENDERFORMAT           = 0x0305,
	WM_RENDERALLFORMATS       = 0x0306,
	WM_DESTROYCLIPBOARD       = 0x0307,
	WM_DRAWCLIPBOARD          = 0x0308,
	WM_PAINTCLIPBOARD         = 0x0309,
	WM_VSCROLLCLIPBOARD       = 0x030A,
	WM_SIZECLIPBOARD          = 0x030B,
	WM_ASKCBFORMATNAME        = 0x030C,
	WM_CHANGECBCHAIN          = 0x030D,
	WM_HSCROLLCLIPBOARD       = 0x030E,
	WM_QUERYNEWPALETTE        = 0x030F,
	WM_PALETTEISCHANGING      = 0x0310,
	WM_PALETTECHANGED         = 0x0311,
	WM_HOTKEY                 = 0x0312,
	WM_PRINT                  = 0x0317,
	WM_PRINTCLIENT            = 0x0318,
	WM_APPCOMMAND             = 0x0319,
	WM_THEMECHANGED           = 0x031A,
	WM_HANDHELDFIRST          = 0x0358,
	WM_HANDHELDLAST           = 0x035F,
	WM_AFXFIRST               = 0x0360,
	WM_AFXLAST                = 0x037F,
	WM_PENWINFIRST            = 0x0380,
	WM_PENWINLAST             = 0x038F,
	WM_APP                    = 0x8000,
	WM_USER                   = 0x0400
}
enum {
	PBT_APMQUERYSUSPEND       = 0x0000,
	PBT_APMQUERYSTANDBY       = 0x0001,
	PBT_APMQUERYSUSPENDFAILED = 0x0002,
	PBT_APMQUERYSTANDBYFAILED = 0x0003,
	PBT_APMSUSPEND            = 0x0004,
	PBT_APMSTANDBY            = 0x0005,
	PBT_APMRESUMECRITICAL     = 0x0006,
	PBT_APMRESUMESUSPEND      = 0x0007,
	PBT_APMRESUMESTANDBY      = 0x0008,
	PBTF_APMRESUMEFROMFAILURE = 0x00000001,
	PBT_APMBATTERYLOW         = 0x0009,
	PBT_APMPOWERSTATUSCHANGE  = 0x000A,
	PBT_APMOEMEVENT           = 0x000B,
	PBT_APMRESUMEAUTOMATIC    = 0x0012
}
//}}}

enum {
	MK_LBUTTON  = 0x0001,
	MK_RBUTTON  = 0x0002,
	MK_SHIFT    = 0x0004,
	MK_CONTROL  = 0x0008,
	MK_MBUTTON  = 0x0010,
	MK_XBUTTON1 = 0x0020,
	MK_XBUTTON2 = 0x0040
}

enum {
	WMSZ_LEFT        = 1,
	WMSZ_RIGHT       = 2,
	WMSZ_TOP         = 3,
	WMSZ_TOPLEFT     = 4,
	WMSZ_TOPRIGHT    = 5,
	WMSZ_BOTTOM      = 6,
	WMSZ_BOTTOMLEFT  = 7,
	WMSZ_BOTTOMRIGHT = 8
}

enum {
	SIZE_RESTORED  = 0,
	SIZE_MINIMIZED = 1,
	SIZE_MAXIMIZED = 2,
	SIZE_MAXSHOW   = 3,
	SIZE_MAXHIDE   = 4
}

enum {
	SW_HIDE            = 0,
	SW_SHOWNORMAL      = 1,
	SW_NORMAL          = 1,
	SW_SHOWMINIMIZED   = 2,
	SW_SHOWMAXIMIZED   = 3,
	SW_MAXIMIZE        = 3,
	SW_SHOWNOACTIVATE  = 4,
	SW_SHOW            = 5,
	SW_MINIMIZE        = 6,
	SW_SHOWMINNOACTIVE = 7,
	SW_SHOWNA          = 8,
	SW_RESTORE         = 9,
	SW_SHOWDEFAULT     = 10,
	SW_FORCEMINIMIZE   = 11,
	SW_MAX             = 11
}

enum {
	GWL_STYLE   = -16,
	GWL_EXSTYLE = -20
}

DWORD GetClassLongW(HWND hWnd, int nIndex);

DWORD SetClassLongW(HWND hWnd, int nIndex, LONG dwNewLong);

ULONG_PTR GetClassLongPtrW(HWND hWnd, int nIndex);

ULONG_PTR SetClassLongPtrW(HWND hWnd, int nIndex, LONG_PTR dwNewLong);

LONG GetWindowLongW(HWND hWnd, int nIndex);

LONG SetWindowLongW(HWND hWnd, int nIndex, LONG dwNewLong);

LONG_PTR GetWindowLongPtrW(HWND hWnd, int nIndex);

LONG_PTR SetWindowLongPtrW(HWND hWnd, int nIndex, LONG_PTR dwNewLong);

BOOL ShowWindow(HWND hWnd, int nCmdShow);

//Windows 98 required
BOOL AnimateWindow(HWND hWnd, DWORD dwTime, DWORD dwFlags);

BOOL IsWindowVisible(HWND hWnd);

BOOL IsWindow(HWND hWnd);

BOOL GetWindowRect(HWND hWnd, RECT* lpRect);

BOOL GetClientRect(HWND hWnd, RECT* lpRect);

enum {
	SWP_NOSIZE       = 0x0001,
	SWP_NOMOVE       = 0x0002,
	SWP_NOZORDER     = 0x0004,
	SWP_NOACTIVATE   = 0x0010,
	SWP_FRAMECHANGED = 0x0020
}

BOOL SetWindowPos(HWND hWnd, HWND hWndInsertAfter, int x, int y, int cx, int cy, UINT uFlags);

BOOL MoveWindow(HWND hWnd, int x, int y, int nWidth, int nHeight, BOOL bRepaint);

int SetWindowRgn(HWND hWnd, HRGN hRgn, BOOL bRedraw);

enum {
	ULW_COLORKEY = 0x00000001,
	ULW_ALPHA    = 0x00000002,
	ULW_OPAQUE   = 0x00000004
}

BOOL UpdateLayeredWindow(
	HWND hWnd,
	HDC hdcDst,
	POINT* pptDst,
	SIZE* psize,
	HDC hdcSrc,
	POINT* pptSrc,
	COLORREF crKey,
	BLENDFUNCTION* pblend,
	DWORD dwFlags);

HWND SetParent(HWND hWndChild, HWND hWndNewParent);

HWND GetParent(HWND hWnd);

BOOL IsChild(HWND hWndParent, HWND hWnd);

BOOL EnableWindow(HWND hWnd, BOOL bEnable);

enum {
	GW_HWNDFIRST = 0,
	GW_HWNDLAST  = 1,
	GW_HWNDNEXT  = 2,
	GW_HWNDPREV  = 3,
	GW_OWNER     = 4,
	GW_CHILD     = 5
}

HWND GetWindow(HWND hWnd, UINT uCmd);

BOOL GetWindowInfo(HWND hwnd, WINDOWINFO* pwi);

int GetWindowTextLength(HWND hWnd);

int GetWindowTextW(HWND hWnd, LPWSTR lpString, int nMaxCount);

BOOL SetWindowTextW(HWND hWnd, LPCWSTR lpString);

UINT GetWindowModuleFileNameW(HWND hWnd, LPWSTR lpszFileName, UINT cchFileNameMax);

BOOL SetPropW(HWND hWnd, LPCWSTR lpString, HANDLE hData);

HANDLE GetPropW(HWND hWnd, LPCWSTR lpString);

HANDLE RemovePropW(HWND hWnd, LPCWSTR lpString);

DWORD CommDlgExtendedError();
enum { FNERR_BUFFERTOOSMALL = 0x3003 }

enum {
	OFN_READONLY             = 0x00000001,
	OFN_OVERWRITEPROMPT      = 0x00000002,
	OFN_HIDEREADONLY         = 0x00000004,
	OFN_NOCHANGEDIR          = 0x00000008,
	OFN_SHOWHELP             = 0x00000010,
	OFN_ENABLEHOOK           = 0x00000020,
	OFN_ENABLETEMPLATE       = 0x00000040,
	OFN_ENABLETEMPLATEHANDLE = 0x00000080,
	OFN_NOVALIDATE           = 0x00000100,
	OFN_ALLOWMULTISELECT     = 0x00000200,
	OFN_EXTENSIONDIFFERENT   = 0x00000400,
	OFN_PATHMUSTEXIST        = 0x00000800,
	OFN_FILEMUSTEXIST        = 0x00001000,
	OFN_CREATEPROMPT         = 0x00002000,
	OFN_SHAREAWARE           = 0x00004000,
	OFN_NOREADONLYRETURN     = 0x00008000,
	OFN_NOTESTFILECREATE     = 0x00010000,
	OFN_NONETWORKBUTTON      = 0x00020000,
	OFN_NOLONGNAMES          = 0x00040000,
	OFN_EXPLORER             = 0x00080000,
	OFN_NODEREFERENCELINKS   = 0x00100000,
	OFN_LONGNAMES            = 0x00200000,
	OFN_ENABLEINCLUDENOTIFY  = 0x00400000,
	OFN_ENABLESIZING         = 0x00800000,
	OFN_DONTADDTORECENT      = 0x02000000,
	OFN_FORCESHOWHIDDEN      = 0x10000000
}

BOOL GetOpenFileNameW(OPENFILENAME* lpofn);

BOOL GetSaveFileNameW(OPENFILENAME* lpofn);

//}}}

//{{{ painting functions
BOOL InvalidateRect(HWND hWnd, RECT* lpRect, BOOL bErase);

BOOL ValidateRect(HWND hWnd, RECT* lpRect);

BOOL UpdateWindow(HWND hWnd);

HWND WindowFromDC(HDC hdc);

HDC BeginPaint(HWND hWnd, PAINTSTRUCT* lpPaint);

BOOL EndPaint(HWND hWnd, PAINTSTRUCT* lpPaint);
//}}}

//{{{ device context functions
HDC GetDC(HWND hWnd);

int ReleaseDC(HWND hWnd, HDC hDC);

HDC CreateCompatibleDC(HDC hdc);

BOOL DeleteDC(HDC hdc);

HGDIOBJ SelectObject(HDC hdc, HGDIOBJ hObject);

BOOL DeleteObject(HGDIOBJ hObject);

int GetObjectW(HANDLE h, int c, VOID* pv);

HBITMAP CreateCompatibleBitmap(HDC hdc, int cx, int cy);

HBITMAP CreateDIBSection(
	HDC hdc,
	BITMAPINFO* lpbmi,
	UINT usage,
	VOID** ppvBits,
	HANDLE hSection,
	DWORD offset);

int GetDIBits(HDC hdc, HBITMAP hbm, UINT start, UINT cLines, VOID* lpvBits, BITMAPINFO* lpbmi, UINT usage);

enum {
	DIB_RGB_COLORS = 0
}
enum {
	BI_RGB = 0
}

enum {
	SRCCOPY = 0x00CC0020
}

BOOL BitBlt(HDC hdc, int x, int y, int cx, int cy, HDC hdcSrc, int x1, int y1, DWORD rop);

enum {
	AC_SRC_OVER  = 0x00,
	AC_SRC_ALPHA = 0x01
}

int EnumFontFamiliesExW(
	HDC hdc, LOGFONT* lpLogfont,
	FONTENUMPROCW lpProc, LPARAM lParam, DWORD dwFlags);

alias int function(ENUMLOGFONTEX*, TEXTMETRIC*, DWORD, LPARAM) FONTENUMPROCW;
//}}}

//{{{ message functions
BOOL GetMessageW(MSG* lpMsg, HWND hWnd, UINT wMsgFilterMin, UINT wMsgFilterMax);

BOOL TranslateMessage(MSG* lpMsg);

LRESULT DispatchMessageW(MSG* lpMsg);

BOOL PostMessageW(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam);

void PostQuitMessage(int nExitCode);

LRESULT SendMessageW(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam);

BOOL InSendMessage();

BOOL ReplyMessage(LRESULT lResult);
//}}}

//{{{ clipboard functions
enum {
	CF_TEXT         = 1,
	CF_BITMAP       = 2,
	CF_METAFILEPICT = 3,
	CF_SYLK         = 4,
	CF_DIF          = 5,
	CF_TIFF         = 6,
	CF_OEMTEXT      = 7,
	CF_DIB          = 8,
	CF_PALETTE      = 9,
	CF_PENDATA      = 10,
	CF_RIFF         = 11,
	CF_WAVE         = 12,
	CF_UNICODETEXT  = 13,
	CF_ENHMETAFILE  = 14,
	CF_HDROP        = 15,
	CF_LOCALE       = 16
}

BOOL OpenClipboard(HWND hWndNewOwner);

BOOL CloseClipboard();

BOOL IsClipboardFormatAvailable(UINT format);

HANDLE GetClipboardData(UINT uFormat);

HANDLE SetClipboardData(UINT uFormat, HANDLE hMem);

BOOL EmptyClipboard();
//}}}

//{{{ mouse functions
enum {
	XBUTTON1 = 0x0001,
	XBUTTON2 = 0x0002
}

HWND SetCapture(HWND hWnd);

BOOL ReleaseCapture();

enum {
	TME_HOVER     = 0x00000001,
	TME_LEAVE     = 0x00000002,
	TME_NONCLIENT = 0x00000010
}
BOOL TrackMouseEvent(TRACKMOUSEEVENT* lpEventTrack);

HCURSOR SetCursor(HCURSOR hCursor);

BOOL GetCursorPos(POINT* lpPoint);

DWORD GetMessagePos();
//}}}

//{{{ keyboard functions
//{{{ keys
enum {
	VK_LBUTTON             = 0x01,
	VK_RBUTTON             = 0x02,
	VK_CANCEL              = 0x03,
	VK_MBUTTON             = 0x04,
	VK_XBUTTON1            = 0x05,
	VK_XBUTTON2            = 0x06,
	VK_BACK                = 0x08,
	VK_TAB                 = 0x09,
	VK_CLEAR               = 0x0C,
	VK_RETURN              = 0x0D,
	VK_SHIFT               = 0x10,
	VK_CONTROL             = 0x11,
	VK_MENU                = 0x12,
	VK_PAUSE               = 0x13,
	VK_CAPITAL             = 0x14,
	VK_KANA                = 0x15,
	VK_HANGEUL             = 0x15,
	VK_HANGUL              = 0x15,
	VK_JUNJA               = 0x17,
	VK_FINAL               = 0x18,
	VK_HANJA               = 0x19,
	VK_KANJI               = 0x19,
	VK_ESCAPE              = 0x1B,
	VK_CONVERT             = 0x1C,
	VK_NONCONVERT          = 0x1D,
	VK_ACCEPT              = 0x1E,
	VK_MODECHANGE          = 0x1F,
	VK_SPACE               = 0x20,
	VK_PRIOR               = 0x21,
	VK_NEXT                = 0x22,
	VK_END                 = 0x23,
	VK_HOME                = 0x24,
	VK_LEFT                = 0x25,
	VK_UP                  = 0x26,
	VK_RIGHT               = 0x27,
	VK_DOWN                = 0x28,
	VK_SELECT              = 0x29,
	VK_PRINT               = 0x2A,
	VK_EXECUTE             = 0x2B,
	VK_SNAPSHOT            = 0x2C,
	VK_INSERT              = 0x2D,
	VK_DELETE              = 0x2E,
	VK_HELP                = 0x2F,
	VK_LWIN                = 0x5B,
	VK_RWIN                = 0x5C,
	VK_APPS                = 0x5D,
	VK_SLEEP               = 0x5F,
	VK_NUMPAD0             = 0x60,
	VK_NUMPAD1             = 0x61,
	VK_NUMPAD2             = 0x62,
	VK_NUMPAD3             = 0x63,
	VK_NUMPAD4             = 0x64,
	VK_NUMPAD5             = 0x65,
	VK_NUMPAD6             = 0x66,
	VK_NUMPAD7             = 0x67,
	VK_NUMPAD8             = 0x68,
	VK_NUMPAD9             = 0x69,
	VK_MULTIPLY            = 0x6A,
	VK_ADD                 = 0x6B,
	VK_SEPARATOR           = 0x6C,
	VK_SUBTRACT            = 0x6D,
	VK_DECIMAL             = 0x6E,
	VK_DIVIDE              = 0x6F,
	VK_F1                  = 0x70,
	VK_F2                  = 0x71,
	VK_F3                  = 0x72,
	VK_F4                  = 0x73,
	VK_F5                  = 0x74,
	VK_F6                  = 0x75,
	VK_F7                  = 0x76,
	VK_F8                  = 0x77,
	VK_F9                  = 0x78,
	VK_F10                 = 0x79,
	VK_F11                 = 0x7A,
	VK_F12                 = 0x7B,
	VK_F13                 = 0x7C,
	VK_F14                 = 0x7D,
	VK_F15                 = 0x7E,
	VK_F16                 = 0x7F,
	VK_F17                 = 0x80,
	VK_F18                 = 0x81,
	VK_F19                 = 0x82,
	VK_F20                 = 0x83,
	VK_F21                 = 0x84,
	VK_F22                 = 0x85,
	VK_F23                 = 0x86,
	VK_F24                 = 0x87,
	VK_NUMLOCK             = 0x90,
	VK_SCROLL              = 0x91,
	VK_OEM_NEC_EQUAL       = 0x92,
	VK_OEM_FJ_JISHO        = 0x92,
	VK_OEM_FJ_MASSHOU      = 0x93,
	VK_OEM_FJ_TOUROKU      = 0x94,
	VK_OEM_FJ_LOYA         = 0x95,
	VK_OEM_FJ_ROYA         = 0x96,
	VK_LSHIFT              = 0xA0,
	VK_RSHIFT              = 0xA1,
	VK_LCONTROL            = 0xA2,
	VK_RCONTROL            = 0xA3,
	VK_LMENU               = 0xA4,
	VK_RMENU               = 0xA5,
	VK_BROWSER_BACK        = 0xA6,
	VK_BROWSER_FORWARD     = 0xA7,
	VK_BROWSER_REFRESH     = 0xA8,
	VK_BROWSER_STOP        = 0xA9,
	VK_BROWSER_SEARCH      = 0xAA,
	VK_BROWSER_FAVORITES   = 0xAB,
	VK_BROWSER_HOME        = 0xAC,
	VK_VOLUME_MUTE         = 0xAD,
	VK_VOLUME_DOWN         = 0xAE,
	VK_VOLUME_UP           = 0xAF,
	VK_MEDIA_NEXT_TRACK    = 0xB0,
	VK_MEDIA_PREV_TRACK    = 0xB1,
	VK_MEDIA_STOP          = 0xB2,
	VK_MEDIA_PLAY_PAUSE    = 0xB3,
	VK_LAUNCH_MAIL         = 0xB4,
	VK_LAUNCH_MEDIA_SELECT = 0xB5,
	VK_LAUNCH_APP1         = 0xB6,
	VK_LAUNCH_APP2         = 0xB7,
	VK_OEM_1               = 0xBA,
	VK_OEM_PLUS            = 0xBB,
	VK_OEM_COMMA           = 0xBC,
	VK_OEM_MINUS           = 0xBD,
	VK_OEM_PERIOD          = 0xBE,
	VK_OEM_2               = 0xBF,
	VK_OEM_3               = 0xC0,
	VK_OEM_4               = 0xDB,
	VK_OEM_5               = 0xDC,
	VK_OEM_6               = 0xDD,
	VK_OEM_7               = 0xDE,
	VK_OEM_8               = 0xDF,
	VK_OEM_AX              = 0xE1,
	VK_OEM_102             = 0xE2,
	VK_ICO_HELP            = 0xE3,
	VK_ICO_00              = 0xE4,
	VK_PROCESSKEY          = 0xE5,
	VK_ICO_CLEAR           = 0xE6,
	VK_PACKET              = 0xE7,
	VK_OEM_RESET           = 0xE9,
	VK_OEM_JUMP            = 0xEA,
	VK_OEM_PA1             = 0xEB,
	VK_OEM_PA2             = 0xEC,
	VK_OEM_PA3             = 0xED,
	VK_OEM_WSCTRL          = 0xEE,
	VK_OEM_CUSEL           = 0xEF,
	VK_OEM_ATTN            = 0xF0,
	VK_OEM_FINISH          = 0xF1,
	VK_OEM_COPY            = 0xF2,
	VK_OEM_AUTO            = 0xF3,
	VK_OEM_ENLW            = 0xF4,
	VK_OEM_BACKTAB         = 0xF5,
	VK_ATTN                = 0xF6,
	VK_CRSEL               = 0xF7,
	VK_EXSEL               = 0xF8,
	VK_EREOF               = 0xF9,
	VK_PLAY                = 0xFA,
	VK_ZOOM                = 0xFB,
	VK_NONAME              = 0xFC,
	VK_PA1                 = 0xFD,
	VK_OEM_CLEAR           = 0xFE
}
//}}}

SHORT GetKeyState(int nVirtKey);
//}}}

//{{{ system functions
//const LPTSTR IDC_ARROW       = cast(LPTSTR)32512u;
//const LPTSTR IDC_IBEAM       = cast(LPTSTR)32513u;
//const LPTSTR IDC_WAIT        = cast(LPTSTR)32514u;
//const LPTSTR IDC_CROSS       = cast(LPTSTR)32515u;
//const LPTSTR IDC_UPARROW     = cast(LPTSTR)32516u;
//const LPTSTR IDC_SIZE        = cast(LPTSTR)32640u;
//const LPTSTR IDC_ICON        = cast(LPTSTR)32641u;
//const LPTSTR IDC_SIZENWSE    = cast(LPTSTR)32642u;
//const LPTSTR IDC_SIZENESW    = cast(LPTSTR)32643u;
//const LPTSTR IDC_SIZEWE      = cast(LPTSTR)32644u;
//const LPTSTR IDC_SIZENS      = cast(LPTSTR)32645u;
//const LPTSTR IDC_SIZEALL     = cast(LPTSTR)32646u;
//const LPTSTR IDC_NO          = cast(LPTSTR)32648u;
//const LPTSTR IDC_HAND        = cast(LPTSTR)32649u;
//const LPTSTR IDC_APPSTARTING = cast(LPTSTR)32650u;
//const LPTSTR IDC_HELP        = cast(LPTSTR)32651u;

//const LPTSTR IDI_APPLICATION = cast(LPTSTR)32512;
//const LPTSTR IDI_HAND        = cast(LPTSTR)32513;
//const LPTSTR IDI_QUESTION    = cast(LPTSTR)32514;
//const LPTSTR IDI_EXCLAMATION = cast(LPTSTR)32515;
//const LPTSTR IDI_ASTERISK    = cast(LPTSTR)32516;
//const LPTSTR IDI_WINLOGO     = cast(LPTSTR)32517;
//const LPTSTR IDI_WARNING     = IDI_EXCLAMATION;
//const LPTSTR IDI_ERROR       = IDI_HAND;
//const LPTSTR IDI_INFORMATION = IDI_ASTERISK;

enum {
	OIC_SAMPLE      = 32512,
	OIC_HAND        = 32513,
	OIC_QUES        = 32514,
	OIC_BANG        = 32515,
	OIC_NOTE        = 32516,
	OIC_WINLOGO     = 32517,
	OIC_WARNING     = OIC_BANG,
	OIC_ERROR       = OIC_HAND,
	OIC_INFORMATION = OIC_NOTE
}

enum {
	OCR_NORMAL      = 32512,
	OCR_IBEAM       = 32513,
	OCR_WAIT        = 32514,
	OCR_CROSS       = 32515,
	OCR_UP          = 32516,
	OCR_SIZENWSE    = 32642,
	OCR_SIZENESW    = 32643,
	OCR_SIZEWE      = 32644,
	OCR_SIZENS      = 32645,
	OCR_SIZEALL     = 32646,
	OCR_NO          = 32648,
	OCR_HAND        = 32649,
	OCR_APPSTARTING = 32650
}

enum {
	IMAGE_BITMAP = 0,
	IMAGE_ICON   = 1,
	IMAGE_CURSOR = 2
}

enum {
	LR_DEFAULTCOLOR     = 0x0000,
	LR_MONOCHROME       = 0x0001,
	LR_COLOR            = 0x0002,
	LR_COPYRETURNORG    = 0x0004,
	LR_COPYDELETEORG    = 0x0008,
	LR_LOADFROMFILE     = 0x0010,
	LR_LOADTRANSPARENT  = 0x0020,
	LR_DEFAULTSIZE      = 0x0040,
	LR_VGACOLOR         = 0x0080,
	LR_LOADMAP3DCOLORS  = 0x1000,
	LR_CREATEDIBSECTION = 0x2000,
	LR_COPYFROMRESOURCE = 0x4000,
	LR_SHARED           = 0x8000
}

HANDLE LoadImageW(
	HINSTANCE hInst,
	LPCWSTR name,
	UINT type,
	int cx,
	int cy,
	UINT fuLoad);

HICON CreateIconFromResource(
	BYTE* presbits,
	DWORD dwResSize,
	BOOL fIcon,
	DWORD dwVer);

enum {
	SPI_GETNONCLIENTMETRICS = 0x0029,
	SPI_GETWORKAREA         = 0x0030,
	SPI_GETWHEELSCROLLLINES = 0x0068
}

BOOL SystemParametersInfoW(UINT uiAction, UINT uiParam, VOID* pvParam, UINT fWinIni);

enum {
	COLOR_SCROLLBAR       = 0,
	COLOR_BACKGROUND      = 1,
	COLOR_ACTIVECAPTION   = 2,
	COLOR_INACTIVECAPTION = 3,
	COLOR_MENU            = 4,
	COLOR_WINDOW          = 5,
	COLOR_WINDOWFRAME     = 6,
	COLOR_MENUTEXT        = 7,
	COLOR_WINDOWTEXT      = 8,
	COLOR_CAPTIONTEXT     = 9,
	COLOR_ACTIVEBORDER    = 10,
	COLOR_INACTIVEBORDER  = 11,
	COLOR_APPWORKSPACE    = 12,
	COLOR_HIGHLIGHT       = 13,
	COLOR_HIGHLIGHTTEXT   = 14,
	COLOR_BTNFACE         = 15,
	COLOR_BTNSHADOW       = 16,
	COLOR_GRAYTEXT        = 17,
	COLOR_BTNTEXT         = 18,
	COLOR_INACTIVECAPTIONTEXT = 19,
	COLOR_BTNHIGHLIGHT    = 20,

	COLOR_3DDKSHADOW      = 21,
	COLOR_3DLIGHT         = 22,
	COLOR_INFOTEXT        = 23,
	COLOR_INFOBK          = 24,

	COLOR_HOTLIGHT        = 26,
	COLOR_GRADIENTACTIVECAPTION = 27,
	COLOR_GRADIENTINACTIVECAPTION = 28,
	COLOR_MENUHILIGHT     = 29,
	COLOR_MENUBAR         = 30,

	COLOR_DESKTOP         = COLOR_BACKGROUND,
	COLOR_3DFACE          = COLOR_BTNFACE,
	COLOR_3DSHADOW        = COLOR_BTNSHADOW,
	COLOR_3DHIGHLIGHT     = COLOR_BTNHIGHLIGHT,
	COLOR_3DHILIGHT       = COLOR_BTNHIGHLIGHT,
	COLOR_BTNHILIGHT      = COLOR_BTNHIGHLIGHT
}

DWORD GetSysColor(int nIndex);

enum {
	SM_CXSCREEN          = 0,
	SM_CYSCREEN          = 1,
	SM_CXVSCROLL         = 2,
	SM_CYHSCROLL         = 3,
	SM_CYCAPTION         = 4,
	SM_CXBORDER          = 5,
	SM_CYBORDER          = 6,
	SM_CXDLGFRAME        = 7,
	SM_CYDLGFRAME        = 8,
	SM_CYVTHUMB          = 9,
	SM_CXHTHUMB          = 10,
	SM_CXICON            = 11,
	SM_CYICON            = 12,
	SM_CXCURSOR          = 13,
	SM_CYCURSOR          = 14,
	SM_CYMENU            = 15,
	SM_CXFULLSCREEN      = 16,
	SM_CYFULLSCREEN      = 17,
	SM_CYKANJIWINDOW     = 18,
	SM_MOUSEPRESENT      = 19,
	SM_CYVSCROLL         = 20,
	SM_CXHSCROLL         = 21,
	SM_DEBUG             = 22,
	SM_SWAPBUTTON        = 23,
	SM_RESERVED1         = 24,
	SM_RESERVED2         = 25,
	SM_RESERVED3         = 26,
	SM_RESERVED4         = 27,
	SM_CXMIN             = 28,
	SM_CYMIN             = 29,
	SM_CXSIZE            = 30,
	SM_CYSIZE            = 31,
	SM_CXFRAME           = 32,
	SM_CYFRAME           = 33,
	SM_CXMINTRACK        = 34,
	SM_CYMINTRACK        = 35,
	SM_CXDOUBLECLK       = 36,
	SM_CYDOUBLECLK       = 37,
	SM_CXICONSPACING     = 38,
	SM_CYICONSPACING     = 39,
	SM_MENUDROPALIGNMENT = 40,
	SM_PENWINDOWS        = 41,
	SM_DBCSENABLED       = 42,
	SM_CMOUSEBUTTONS     = 43,
	SM_CXFIXEDFRAME      = SM_CXDLGFRAME,
	SM_CYFIXEDFRAME      = SM_CYDLGFRAME,
	SM_CXSIZEFRAME       = SM_CXFRAME,
	SM_CYSIZEFRAME       = SM_CYFRAME,
	SM_SECURE            = 44,
	SM_CXEDGE            = 45,
	SM_CYEDGE            = 46,
	SM_CXMINSPACING      = 47,
	SM_CYMINSPACING      = 48,
	SM_CXSMICON          = 49,
	SM_CYSMICON          = 50,
	SM_CYSMCAPTION       = 51,
	SM_CXSMSIZE          = 52,
	SM_CYSMSIZE          = 53,
	SM_CXMENUSIZE        = 54,
	SM_CYMENUSIZE        = 55,
	SM_ARRANGE           = 56,
	SM_CXMINIMIZED       = 57,
	SM_CYMINIMIZED       = 58,
	SM_CXMAXTRACK        = 59,
	SM_CYMAXTRACK        = 60,
	SM_CXMAXIMIZED       = 61,
	SM_CYMAXIMIZED       = 62,
	SM_NETWORK           = 63,
	SM_CLEANBOOT         = 67,
	SM_CXDRAG            = 68,
	SM_CYDRAG            = 69,
	SM_SHOWSOUNDS        = 70,
	SM_CXMENUCHECK       = 71,
	SM_CYMENUCHECK       = 72,
	SM_SLOWMACHINE       = 73,
	SM_MIDEASTENABLED    = 74,
	SM_MOUSEWHEELPRESENT = 75,
	SM_XVIRTUALSCREEN    = 76,
	SM_YVIRTUALSCREEN    = 77,
	SM_CXVIRTUALSCREEN   = 78,
	SM_CYVIRTUALSCREEN   = 79,
	SM_CMONITORS         = 80,
	SM_SAMEDISPLAYFORMAT = 81,
	SM_IMMENABLED        = 82,
	SM_CXFOCUSBORDER     = 83,
	SM_CYFOCUSBORDER     = 84,
	SM_TABLETPC          = 86,
	SM_MEDIACENTER       = 87,
	SM_STARTER           = 88,
	SM_SERVERR2          = 89
}

int GetSystemMetrics(int nIndex);

VOID GetSystemInfo(SYSTEM_INFO* lpSystemInfo);

BOOL GetVersionExW(OSVERSIONINFO* lpVersionInformation);

HMODULE GetModuleHandleW(LPCWSTR lpModuleName);

HMODULE LoadLibraryW(LPCWSTR lpLibFileName);

FARPROC GetProcAddress(HMODULE hModule, LPCSTR lpProcName);

//Requires Internet Explorer 4.0 (but will work on Windows 95 with IE 4)
BOOL SHGetSpecialFolderPathW(HWND hWndOwner, LPWSTR lpszPath, int nFolder, BOOL fCreate);

BOOL QueryPerformanceFrequency(ulong* lpFrequency);

BOOL QueryPerformanceCounter(ulong* lpPerformanceCount);

VOID GetSystemTimeAsFileTime(FILETIME* lpSystemTimeAsFileTime);

BOOL SystemTimeToFileTime(SYSTEMTIME* lpSystemTime, FILETIME* lpFileTime);

HANDLE GetCurrentThread();

VOID Sleep(DWORD dwMilliseconds);

BOOL GetProcessAffinityMask(
	HANDLE hProcess,
	ULONG_PTR* lpProcessAffinityMask,
	ULONG_PTR* lpSystemAffinityMask);

ULONG_PTR SetThreadAffinityMask(HANDLE hThread, ULONG_PTR dwThreadAffinityMask);
//}}}

//{{{ file functions

BOOL GetFileSizeEx(HANDLE hFile, long* lpFileSize);

BOOL ReadFile(
	HANDLE hFile,
	VOID* lpBuffer,
	DWORD nNumberOfBytesToRead,
	DWORD* lpNumberOfBytesRead,
	OVERLAPPED* lpOverlapped);

BOOL WriteFile(
	HANDLE hFile,
	VOID* lpBuffer,
	DWORD nNumberOfBytesToWrite,
	DWORD* lpNumberOfBytesWritten,
	OVERLAPPED* lpOverlapped);
//}}}

//{{{ console functions
BOOL AllocConsole();

BOOL FreeConsole();

BOOL GetConsoleMode(HANDLE hConsoleHandle, DWORD* lpMode);

BOOL SetConsoleMode(HANDLE hConsoleHandle, DWORD dwMode);

DWORD GetConsoleTitleW(LPWSTR lpConsoleTitle, DWORD nSize);

BOOL SetConsoleTitleW(LPCWSTR lpConsoleTitle);

BOOL ReadConsoleW(
	HANDLE hConsoleInput,
	LPWSTR lpBuffer,
	DWORD nNumberOfCharsToRead,
	DWORD* lpNumberOfCharsRead,
	VOID* lpReserved);

BOOL WriteConsoleW(
	HANDLE hConsoleOutput,
	LPCWSTR lpBuffer,
	DWORD nNumberOfCharsToWrite,
	DWORD* lpNumberOfCharsWritten,
	VOID* lpReserved);

enum {
	FOREGROUND_BLUE      = 0x0001,
	FOREGROUND_GREEN     = 0x0002,
	FOREGROUND_RED       = 0x0004,
	FOREGROUND_INTENSITY = 0x0008,
	BACKGROUND_BLUE      = 0x0010,
	BACKGROUND_GREEN     = 0x0020,
	BACKGROUND_RED       = 0x0040,
	BACKGROUND_INTENSITY = 0x0080
}

BOOL SetConsoleTextAttribute(HANDLE hConsoleOutput, WORD wAttributes);

BOOL GetConsoleScreenBufferInfo(
	HANDLE hConsoleOutput,
	CONSOLE_SCREEN_BUFFER_INFO* lpConsoleScreenBufferInfo);

BOOL SetConsoleActiveScreenBuffer(HANDLE hConsoleOutput);

enum {
	STD_INPUT_HANDLE  = -10,
	STD_OUTPUT_HANDLE = -11,
	STD_ERROR_HANDLE  = -12
}

HANDLE GetStdHandle(DWORD nStdHandle);

UINT GetConsoleCP();

UINT GetConsoleOutputCP();

//}}}

//{{{ COM functions
enum {
	COINIT_APARTMENTTHREADED = 0x2,
}

HRESULT CoInitializeEx(VOID* pvReserved, DWORD dwCoInit);
void CoUninitialize();

VOID* CoTaskMemAlloc(SIZE_T cb);
VOID* CoTaskMemRealloc(VOID* pv, SIZE_T cb);
void CoTaskMemFree(VOID* pv);

enum {
	BIF_RETURNONLYFSDIRS = 0x0001,
	BIF_EDITBOX          = 0x0010,
	BIF_NEWDIALOGSTYLE   = 0x0040,
	BIF_USENEWUI         = (BIF_NEWDIALOGSTYLE | BIF_EDITBOX)
}

enum {
	BFFM_INITIALIZED     = 1,
	BFFM_SELCHANGED      = 2,
	BFFM_VALIDATEFAILEDA = 3,
	BFFM_VALIDATEFAILEDW = 4,
	BFFM_IUNKNOWN        = 5,

	BFFM_SETSTATUSTEXTA = WM_USER + 100,
	BFFM_ENABLEOK       = WM_USER + 101,
	BFFM_SETSELECTIONA  = WM_USER + 102,
	BFFM_SETSELECTIONW  = WM_USER + 103,
	BFFM_SETSTATUSTEXTW = WM_USER + 104,
	BFFM_SETOKTEXT      = WM_USER + 105,
	BFFM_SETEXPANDED    = WM_USER + 106,
}

ITEMIDLIST* SHBrowseForFolderW(BROWSEINFO* lpbi);

BOOL SHGetPathFromIDListW(ITEMIDLIST* pidl, LPWSTR pszPath);

HRESULT SHGetFolderPathW(HWND hwnd, int csidl, HANDLE hToken, DWORD dwFlags, LPWSTR pszPath);

HRESULT SHGetDesktopFolder(IShellFolder* ppshf);

struct GUID {
align(1):
	uint Data1;
	ushort Data2;
	ushort Data3;
	ubyte[8] Data4;
}
alias GUID IID;
alias GUID CLSID;

interface IUnknown {
	HRESULT QueryInterface(IID* riid, void** ppvObject);
	ULONG AddRef();
	ULONG Release();
}
alias void IBindCtx;
interface IShellFolder : IUnknown {
	HRESULT ParseDisplayName(
		HWND hwnd,
		IBindCtx* pbc,
		wchar* pszDisplayName,
		ULONG* pchEaten,
		ITEMIDLIST** ppidl,
		ULONG* pdwAttributes);

	//other methods omitted
}
//}}}

//{{{ Multimedia functions
alias uint MMRESULT;
alias HANDLE HWAVEOUT;
struct TIMECAPS {
	UINT wPeriodMin;
	UINT wPeriodMax;
}
DWORD timeGetTime();
MMRESULT timeGetDevCaps(TIMECAPS* ptc, UINT cbtc);
MMRESULT timeBeginPeriod(UINT uPeriod);
MMRESULT timeEndPeriod(UINT uPeriod);

struct WAVEHDR {
	LPSTR     lpData;
	DWORD     dwBufferLength;
	DWORD     dwBytesRecorded;
	ULONG_PTR dwUser;
	DWORD     dwFlags;
	DWORD     dwLoops;
	WAVEHDR*  lpNext;
	ULONG_PTR reserved;
}
enum {
	WHDR_DONE      = 0x00000001,
	WHDR_PREPARED  = 0x00000002,
	WHDR_BEGINLOOP = 0x00000004,
	WHDR_ENDLOOP   = 0x00000008,
	WHDR_INQUEUE   = 0x00000010
}
alias uint MMVERSION;
struct WAVEOUTCAPSW {
	WORD      wMid;
	WORD      wPid;
	MMVERSION vDriverVersion;
	WCHAR[32] szPname;
	DWORD     dwFormats;
	WORD      wChannels;
	WORD      wReserved1;
	DWORD     dwSupport;
}
struct MMTIME {
	UINT wType;
	union _u {
		DWORD ms;
		DWORD sample;
		DWORD cb;
		DWORD ticks;

		struct _smpte {
			BYTE hour;
			BYTE min;
			BYTE sec;
			BYTE frame;
			BYTE fps;
			BYTE dummy;
			BYTE pad[2];
		}
		_smpte smpte;

		struct _midi {
			DWORD songptrpos;
		}
		_midi midi;
	}
	_u u;
}
enum {
	TIME_MS      = 0x0001,
	TIME_SAMPLES = 0x0002,
	TIME_BYTES   = 0x0004,
	TIME_SMPTE   = 0x0008,
	TIME_MIDI    = 0x0010,
	TIME_TICKS   = 0x0020
}
struct WAVEFORMATEX {
	WORD  wFormatTag;
	WORD  nChannels;
	DWORD nSamplesPerSec;
	DWORD nAvgBytesPerSec;
	WORD  nBlockAlign;
	WORD  wBitsPerSample;
	WORD  cbSize;

}

MMRESULT waveOutGetVolume(HWAVEOUT hwo, DWORD* pdwVolume);
MMRESULT waveOutSetVolume(HWAVEOUT hwo, DWORD dwVolume);
MMRESULT waveOutOpen(
	HWAVEOUT* phwo,
	UINT uDeviceID,
	WAVEFORMATEX* pwfx,
	ULONG_PTR dwCallback,
	ULONG_PTR dwInstance,
	DWORD fdwOpen);
MMRESULT waveOutClose(HWAVEOUT hwo);
MMRESULT waveOutPrepareHeader(HWAVEOUT hwo, WAVEHDR* pwh, UINT cbwh);
MMRESULT waveOutUnprepareHeader(HWAVEOUT hwo, WAVEHDR* pwh, UINT cbwh);
MMRESULT waveOutWrite(HWAVEOUT hwo, WAVEHDR* pwh, UINT cbwh);
MMRESULT waveOutPause(HWAVEOUT hwo);
MMRESULT waveOutRestart(HWAVEOUT hwo);
MMRESULT waveOutReset(HWAVEOUT hwo);
MMRESULT waveOutBreakLoop(HWAVEOUT hwo);
MMRESULT waveOutGetPosition(HWAVEOUT hwo, MMTIME* pmmt, UINT cbmmt);
MMRESULT waveOutGetPitch(HWAVEOUT hwo, DWORD* pdwPitch);
MMRESULT waveOutSetPitch(HWAVEOUT hwo, DWORD dwPitch);
MMRESULT waveOutGetPlaybackRate(HWAVEOUT hwo, DWORD* pdwRate);
MMRESULT waveOutSetPlaybackRate(HWAVEOUT hwo, DWORD dwRate);

//}}}

//{{{ alias ...W -> ...
alias MessageBoxW              MessageBox;
alias RegisterClassExW         RegisterClassEx;
alias CreateWindowExW          CreateWindowEx;
alias DefWindowProcW           DefWindowProc;
alias GetWindowLongW           GetWindowLong;
alias SetWindowLongW           SetWindowLong;
alias GetWindowLongPtrW        GetWindowLongPtr;
alias SetWindowLongPtrW        SetWindowLongPtr;
alias GetWindowTextW           GetWindowText;
alias SetWindowTextW           SetWindowText;
alias GetWindowModuleFileNameW GetWindowModuleFileName;
alias SetPropW                 SetProp;
alias GetPropW                 GetProp;
alias RemovePropW              RemoveProp;
alias GetOpenFileNameW         GetOpenFileName;
alias GetSaveFileNameW         GetSaveFileName;
alias GetMessageW              GetMessage;
alias DispatchMessageW         DispatchMessage;
alias PostMessageW             PostMessage;
alias SendMessageW             SendMessage;
alias LoadImageW               LoadImage;
alias GetObjectW               GetObject;
alias EnumFontFamiliesExW      EnumFontFamiliesEx;
alias SystemParametersInfoW    SystemParametersInfo;
alias GetVersionExW            GetVersionEx;
alias GetModuleHandleW         GetModuleHandle;
alias LoadLibraryW             LoadLibrary;
alias SHGetSpecialFolderPathW  SHGetSpecialFolderPath;
alias GetConsoleTitleW         GetConsoleTitle;
alias SetConsoleTitleW         SetConsoleTitle;
alias ReadConsoleW             ReadConsole;
alias WriteConsoleW            WriteConsole;
alias SHBrowseForFolderW       SHBrowseForFolder;
alias SHGetPathFromIDListW     SHGetPathFromIDList;
alias SHGetFolderPathW         SHGetFolderPath;
alias BFFM_VALIDATEFAILEDW     BFFM_VALIDATEFAILED;
alias BFFM_SETSELECTIONW       BFFM_SETSELECTION;
alias BFFM_SETSTATUSTEXTW      BFFM_SETSTATUSTEXT;

alias LOGFONTW          LOGFONT;
alias NONCLIENTMETRICSW NONCLIENTMETRICS;
alias ENUMLOGFONTEXW    ENUMLOGFONTEX;
alias TEXTMETRICW       TEXTMETRIC;
alias OSVERSIONINFOW    OSVERSIONINFO;
//}}}

struct POINT {
	LONG x;
	LONG y;
}
struct SIZE {
	LONG cx;
	LONG cy;
}
struct RECT {
	LONG left;
	LONG top;
	LONG right;
	LONG bottom;
}
struct BLENDFUNCTION {
	BYTE BlendOp;
	BYTE BlendFlags;
	BYTE SourceConstantAlpha;
	BYTE AlphaFormat;
}
const int LF_FACESIZE = 32;
struct LOGFONTW {
	LONG               lfHeight;
	LONG               lfWidth;
	LONG               lfEscapement;
	LONG               lfOrientation;
	LONG               lfWeight;
	BYTE               lfItalic;
	BYTE               lfUnderline;
	BYTE               lfStrikeOut;
	BYTE               lfCharSet;
	BYTE               lfOutPrecision;
	BYTE               lfClipPrecision;
	BYTE               lfQuality;
	BYTE               lfPitchAndFamily;
	WCHAR[LF_FACESIZE] lfFaceName;
}
struct NONCLIENTMETRICSW {
	UINT     cbSize;
	int      iBorderWidth;
	int      iScrollWidth;
	int      iScrollHeight;
	int      iCaptionWidth;
	int      iCaptionHeight;
	LOGFONTW lfCaptionFont;
	int      iSmCaptionWidth;
	int      iSmCaptionHeight;
	LOGFONTW lfSmCaptionFont;
	int      iMenuWidth;
	int      iMenuHeight;
	LOGFONTW lfMenuFont;
	LOGFONTW lfStatusFont;
	LOGFONTW lfMessageFont;
}
const int LF_FULLFACESIZE = 64;
struct ENUMLOGFONTEXW {
	LOGFONT                elfLogFont;
	WCHAR[LF_FULLFACESIZE] elfFullName;
	WCHAR[LF_FACESIZE]     elfStyle;
	WCHAR[LF_FACESIZE]     elfScript;
}
struct TEXTMETRICW {
	LONG  tmHeight;
	LONG  tmAscent;
	LONG  tmDescent;
	LONG  tmInternalLeading;
	LONG  tmExternalLeading;
	LONG  tmAveCharWidth;
	LONG  tmMaxCharWidth;
	LONG  tmWeight;
	LONG  tmOverhang;
	LONG  tmDigitizedAspectX;
	LONG  tmDigitizedAspectY;
	WCHAR tmFirstChar;
	WCHAR tmLastChar;
	WCHAR tmDefaultChar;
	WCHAR tmBreakChar;
	BYTE  tmItalic;
	BYTE  tmUnderlined;
	BYTE  tmStruckOut;
	BYTE  tmPitchAndFamily;
	BYTE  tmCharSet;
}
struct RGBQUAD {
	BYTE rgbBlue;
	BYTE rgbGreen;
	BYTE rgbRed;
	BYTE rgbReserved;
}
struct BITMAPINFO {
	BITMAPINFOHEADER bmiHeader;
	RGBQUAD[1]       bmiColors;
}
struct BITMAPINFOHEADER {
	DWORD biSize;
	LONG  biWidth;
	LONG  biHeight;
	WORD  biPlanes;
	WORD  biBitCount;
	DWORD biCompression;
	DWORD biSizeImage;
	LONG  biXPelsPerMeter;
	LONG  biYPelsPerMeter;
	DWORD biClrUsed;
	DWORD biClrImportant;
}
struct DIBSECTION {
	BITMAP           dsBm;
	BITMAPINFOHEADER dsBmih;
	DWORD[3]         dsBitfields;
	HANDLE           dshSection;
	DWORD            dsOffset;
}
struct BITMAP {
	LONG  bmType;
	LONG  bmWidth;
	LONG  bmHeight;
	LONG  bmWidthBytes;
	WORD  bmPlanes;
	WORD  bmBitsPixel;
	VOID* bmBits;
}
struct MSG {
	HWND hWnd;
	UINT message;
	WPARAM wParam;
	LPARAM lParam;
	DWORD time;
	POINT pt;
}
struct WNDCLASSEX {
	UINT      cbSize;
	UINT      style;
	WNDPROC   lpfnWndProc;
	int       cbClsExtra;
	int       cbWndExtra;
	HINSTANCE hInstance;
	HICON     hIcon;
	HCURSOR   hCursor;
	HBRUSH    hbrBackground;
	LPCTSTR   lpszMenuName;
	LPCTSTR   lpszClassName;
	HICON      hIconSm;
}
struct WINDOWINFO {
	DWORD cbSize;
	RECT  rcWindow;
	RECT  rcClient;
	DWORD dwStyle;
	DWORD dwExStyle;
	DWORD dwWindowStatus;
	UINT  cxWindowBorders;
	UINT  cyWindowBorders;
	ATOM  atomWindowType;
	WORD  wCreatorVersion;
}
struct PAINTSTRUCT {
	HDC      hdc;
	BOOL     fErase;
	RECT     rcPaint;
	BOOL     fRestore;
	BOOL     fIncUpdate;
	BYTE[32] rgbReserved;
}
struct TRACKMOUSEEVENT {
	DWORD cbSize;
	DWORD dwFlags;
	HWND  hWndTrack;
	DWORD dwHoverTime;
}
struct OPENFILENAME {
	DWORD         lStructSize;
	HWND          hWndOwner;
	HINSTANCE     hInstance;
	LPCTSTR       lpstrFilter;
	LPTSTR        lpstrCustomFilter;
	DWORD         nMaxCustFilter;
	DWORD         nFilterIndex;
	LPTSTR        lpstrFile;
	DWORD         nMaxFile;
	LPTSTR        lpstrFileTitle;
	DWORD         nMaxFileTitle;
	LPCTSTR       lpstrInitialDir;
	LPCTSTR       lpstrTitle;
	DWORD         Flags;
	WORD          nFileOffset;
	WORD          nFileExtension;
	LPCTSTR       lpstrDefExt;
	LPARAM        lCustData;
	LPOFNHOOKPROC lpfnHook;
	LPCTSTR       lpTemplateName;
	// if(_WIN32_WINNT >= 0x0500)
	//void*       pvReserved;
	//DWORD       dwReserved;
	//DWORD       FlagsEx;
}
struct SHITEMID {
	USHORT  cb;
	BYTE[1] abID;
}
struct ITEMIDLIST {
	SHITEMID mkid;
}
struct BROWSEINFO {
	HWND        hwndOwner;
	ITEMIDLIST* pidlRoot;
	LPTSTR      pszDisplayName;
	LPCTSTR     lpszTitle;
	UINT        ulFlags;
	BFFCALLBACK lpfn;
	LPARAM      lParam;
	int         iImage;
}
struct OVERLAPPED {
	ULONG_PTR Internal;
	ULONG_PTR InternalHigh;
	union {
		struct {
			DWORD Offset;
			DWORD OffsetHigh;
		}

		VOID* Pointer;
	}

	HANDLE hEvent;
}
struct OSVERSIONINFOW {
	DWORD dwOSVersionInfoSize;
	DWORD dwMajorVersion;
	DWORD dwMinorVersion;
	DWORD dwBuildNumber;
	DWORD dwPlatformId;
	WCHAR[128] szCSDVersion;
}
struct SYSTEM_INFO {
	WORD wProcessorArchitecture;
	WORD wReserved;
	DWORD dwPageSize;
	VOID* lpMinimumApplicationAddress;
	VOID* lpMaximumApplicationAddress;
	ULONG_PTR dwActiveProcessorMask;
	DWORD dwNumberOfProcessors;
	DWORD dwProcessorType;
	DWORD dwAllocationGranularity;
	WORD wProcessorLevel;
	WORD wProcessorRevision;
}
struct CONSOLE_SCREEN_BUFFER_INFO {
	COORD dwSize;
	COORD dwCursorPosition;
	WORD wAttributes;
	SMALL_RECT srWindow;
	COORD dwMaximumWindowSize;
}
struct FILETIME {
	DWORD dwLowDateTime;
	DWORD dwHighDateTime;
}
struct SYSTEMTIME {
	WORD wYear;
	WORD wMonth;
	WORD wDayOfWeek;
	WORD wDay;
	WORD wHour;
	WORD wMinute;
	WORD wSecond;
	WORD wMilliseconds;
}
struct COORD {
	SHORT X;
	SHORT Y;
}
struct SMALL_RECT {
	SHORT Left;
	SHORT Top;
	SHORT Right;
	SHORT Bottom;
}

