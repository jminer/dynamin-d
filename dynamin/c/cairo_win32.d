module dynamin.c.cairo_win32;

/*
 * A complete binding to the win32 backend of
 * the cairo graphics library version 1.3.16.
 */

import dynamin.c.cairo;
import dynamin.c.windows;

extern(C):

cairo_surface_t* cairo_win32_surface_create(HDC hdc);

cairo_surface_t* cairo_win32_surface_create_with_ddb(
	HDC hdc,
	cairo_format_t format,
	int width, int height);

cairo_surface_t* cairo_win32_surface_create_with_dib(
	cairo_format_t format,
	int width, int height);

HDC cairo_win32_surface_get_dc(cairo_surface_t* surface);

cairo_surface_t* cairo_win32_surface_get_image(cairo_surface_t* surface);

cairo_font_face_t* cairo_win32_font_face_create_for_logfontw(LOGFONTW* logfont);

cairo_font_face_t* cairo_win32_font_face_create_for_hfont(HFONT font);

cairo_status_t cairo_win32_scaled_font_select_font(
	cairo_scaled_font_t* scaled_font,
	HDC hdc);

void cairo_win32_scaled_font_done_font(cairo_scaled_font_t* scaled_font);

double cairo_win32_scaled_font_get_metrics_factor(
	cairo_scaled_font_t* scaled_font);

void cairo_win32_scaled_font_get_logical_to_device(
	cairo_scaled_font_t* scaled_font,
	cairo_matrix_t* logical_to_device);

void cairo_win32_scaled_font_get_device_to_logical(
	cairo_scaled_font_t* scaled_font,
	cairo_matrix_t* device_to_logical);

