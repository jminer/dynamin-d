// Written in the D programming language
// www.digitalmars.com/d/



Key XKeyCodeToKey(int code) {
	switch(code) {
	case XK_parenright:
	case XK_0: return Key.D0;
	case XK_exclam:
	case XK_1: return Key.D1;
	case XK_at:
	case XK_2: return Key.D2;
	case XK_numbersign:
	case XK_3: return Key.D3;
	case XK_dollar:
	case XK_4: return Key.D4;
	case XK_percent:
	case XK_5: return Key.D5;
	case XK_asciicircum:
	case XK_6: return Key.D6;
	case XK_ampersand:
	case XK_7: return Key.D7;
	case XK_asterisk:
	case XK_8: return Key.D8;
	case XK_parenleft:
	case XK_9: return Key.D9;

	case XK_F1: return Key.F1;
	case XK_F2: return Key.F2;
	case XK_F3: return Key.F3;
	case XK_F4: return Key.F4;
	case XK_F5: return Key.F5;
	case XK_F6: return Key.F6;
	case XK_F7: return Key.F7;
	case XK_F8: return Key.F8;
	case XK_F9: return Key.F9;
	case XK_F10: return Key.F10;
	case XK_F11: return Key.F11;
	case XK_F12: return Key.F12;

	case XK_Escape: return Key.Escape;
	case XK_Tab: return Key.Tab;
	case XK_BackSpace: return Key.Backspace;
	case XK_Return: return Key.Enter;
	case XK_KP_Enter: return Key.Enter;
	case XK_space: return Key.Space;

	case XK_KP_Left:
	case XK_Left: return Key.Left;
	case XK_KP_Right:
	case XK_Right: return Key.Right;
	case XK_KP_Up:
	case XK_Up: return Key.Up;
	case XK_KP_Down:
	case XK_Down: return Key.Down;

	case XK_KP_Insert:
	case XK_Insert: return Key.Insert;
	case XK_KP_Delete:
	case XK_Delete: return Key.Delete;
	case XK_KP_Home:
	case XK_Home: return Key.Home;
	case XK_KP_End:
	case XK_End: return Key.End;
	case XK_KP_Prior:
	case XK_Prior: return Key.PageUp;
	case XK_KP_Next:
	case XK_Next: return Key.PageDown;

	case XK_Sys_Req: return Key.PrintScreen;
	case XK_Pause: return Key.Pause;

	case XK_Caps_Lock: return Key.CapsLock;
	case XK_Num_Lock: return Key.NumLock;
	case XK_Scroll_Lock: return Key.ScrollLock;

	case XK_KP_0: return Key.NumPad0;
	case XK_KP_1: return Key.NumPad1;
	case XK_KP_2: return Key.NumPad2;
	case XK_KP_3: return Key.NumPad3;
	case XK_KP_4: return Key.NumPad4;
	case XK_KP_5: return Key.NumPad5;
	case XK_KP_6: return Key.NumPad6;
	case XK_KP_7: return Key.NumPad7;
	case XK_KP_8: return Key.NumPad8;
	case XK_KP_9: return Key.NumPad9;
	case XK_KP_Divide: return Key.NumPadDivide;
	case XK_KP_Multiply: return Key.NumPadMultiply;
	case XK_KP_Subtract: return Key.NumPadSubtract;
	case XK_KP_Add: return Key.NumPadAdd;
	case XK_KP_Decimal: return Key.NumPadDecimal;

	case XK_grave:
	case XK_asciitilde: return Key.Backquote;
	case XK_minus:
	case XK_underscore: return Key.Minus;
	case XK_equal:
	case XK_plus: return Key.Equals;
	case XK_bracketleft:
	case XK_braceleft: return Key.OpenBracket;
	case XK_bracketright:
	case XK_braceright: return Key.CloseBracket;
	case XK_backslash:
	case XK_bar: return Key.Backslash;
	case XK_semicolon:
	case XK_colon: return Key.Semicolon;
	case XK_apostrophe:
	case XK_quotedbl: return Key.Quote;
	case XK_comma:
	case XK_less: return Key.Comma;
	case XK_period:
	case XK_greater: return Key.Period;
	case XK_slash:
	case XK_question: return Key.Slash;

	//case XK_Menu: return Key.Menu;

	case XK_Shift_L:
	case XK_Shift_R: return Key.Shift;
	case XK_Control_L:
	case XK_Control_R: return Key.Control;
	case XK_Alt_L:
	case XK_Alt_R: return Key.Alt;

	//case XK_: return Key.;
	default:
		if(code >= 0x41 && code <= 0x5A) // Key.A - Key.Z
			return cast(Key)code;
		if(code >= 0x61 && code <= 0x7A) // Key.A - Key.Z
			return cast(Key)(code-32);
		return 0;
	}
}

