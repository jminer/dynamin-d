module dynamin.c.cairo_xlib;

/*
 * A complete binding to the xlib backend of
 * the cairo graphics library version 1.3.16.
 */

import dynamin.c.cairo;
import dynamin.c.xlib;
import dynamin.c.x_types;

extern(C):

cairo_surface_t* cairo_xlib_surface_create(
	Display* dpy,
	Drawable drawable,
	Visual* visual,
	int width,
	int height);

cairo_surface_t* cairo_xlib_surface_create_for_bitmap(
	Display* dpy,
	Pixmap bitmap,
	Screen* screen,
	int width, int height);

void cairo_xlib_surface_set_size(
	cairo_surface_t* surface,
	int width, int height);

void cairo_xlib_surface_set_drawable(
	cairo_surface_t* surface,
	Drawable drawable,
	int width, int height);

Display* cairo_xlib_surface_get_display(cairo_surface_t* surface);

Drawable cairo_xlib_surface_get_drawable(cairo_surface_t* surface);

Screen* cairo_xlib_surface_get_screen(cairo_surface_t* surface);

Visual* cairo_xlib_surface_get_visual(cairo_surface_t* surface);

int cairo_xlib_surface_get_depth(cairo_surface_t* surface);

int cairo_xlib_surface_get_width(cairo_surface_t* surface);

int cairo_xlib_surface_get_height(cairo_surface_t* surface);

