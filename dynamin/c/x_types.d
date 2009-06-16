module dynamin.c.x_types;

extern(C):

// Most of these types were foolishly not prefixed with X

alias ubyte* XPointer;
alias uint XID;
alias uint Mask;
alias uint Atom;
alias uint VisualID;
alias uint Time;
alias XID Window;
alias XID Drawable;
alias XID Pixmap;
alias XID Cursor;
alias XID Colormap;
alias XID KeySym;
alias ubyte KeyCode;
alias int Bool;
alias int Status;

alias void Screen;
alias void Display;

