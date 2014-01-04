module dynamin.c.cairo;

/*
 * A complete binding to the core of
 * the cairo graphics library version 1.3.16.
 */

version(Windows) {
	pragma(lib, "cairo.lib");
}
version(Posix) {
	static assert(false); // TODO: fix lib name
	pragma(lib, "cairo.a");
}

extern(C):

int CAIRO_VERSION_ENCODE(int major, int minor, int micro) {
	return major * 10000 + minor * 100 + micro * 1;
}

int cairo_version();

char* cairo_version_string();

alias int cairo_bool_t;

alias void cairo_t;

alias void cairo_surface_t;

struct cairo_matrix_t {
	double xx; double yx;
	double xy; double yy;
	double x0; double y0;
}

alias void cairo_pattern_t;

alias void function(void* data) cairo_destroy_func_t;

struct cairo_user_data_key_t {
	int unused;
}

alias int cairo_status_t;
enum {
	CAIRO_STATUS_SUCCESS = 0,
	CAIRO_STATUS_NO_MEMORY,
	CAIRO_STATUS_INVALID_RESTORE,
	CAIRO_STATUS_INVALID_POP_GROUP,
	CAIRO_STATUS_NO_CURRENT_POINT,
	CAIRO_STATUS_INVALID_MATRIX,
	CAIRO_STATUS_INVALID_STATUS,
	CAIRO_STATUS_NULL_POINTER,
	CAIRO_STATUS_INVALID_STRING,
	CAIRO_STATUS_INVALID_PATH_DATA,
	CAIRO_STATUS_READ_ERROR,
	CAIRO_STATUS_WRITE_ERROR,
	CAIRO_STATUS_SURFACE_FINISHED,
	CAIRO_STATUS_SURFACE_TYPE_MISMATCH,
	CAIRO_STATUS_PATTERN_TYPE_MISMATCH,
	CAIRO_STATUS_INVALID_CONTENT,
	CAIRO_STATUS_INVALID_FORMAT,
	CAIRO_STATUS_INVALID_VISUAL,
	CAIRO_STATUS_FILE_NOT_FOUND,
	CAIRO_STATUS_INVALID_DASH,
	CAIRO_STATUS_INVALID_DSC_COMMENT,
	CAIRO_STATUS_INVALID_INDEX,
	CAIRO_STATUS_CLIP_NOT_REPRESENTABLE
}

alias int cairo_content_t;
enum {
	CAIRO_CONTENT_COLOR       = 0x1000,
	CAIRO_CONTENT_ALPHA       = 0x2000,
	CAIRO_CONTENT_COLOR_ALPHA = 0x3000
}

alias cairo_status_t function(void* closure, char* data, uint length) cairo_write_func_t;

alias cairo_status_t function(void* closure, char* data, uint length) cairo_read_func_t;

cairo_t* cairo_create(cairo_surface_t* target);

cairo_t* cairo_reference(cairo_t* cr);

void cairo_destroy(cairo_t* cr);

uint cairo_get_reference_count(cairo_t* cr);

void* cairo_get_user_data(cairo_t* cr, cairo_user_data_key_t* key);

cairo_status_t cairo_set_user_data(
	cairo_t* cr,
	cairo_user_data_key_t* key,
	void* user_data,
	cairo_destroy_func_t destroy);

void cairo_save(cairo_t* cr);

void cairo_restore(cairo_t* cr);

void cairo_push_group(cairo_t* cr);

void cairo_push_group_with_content(cairo_t* cr, cairo_content_t content);

cairo_pattern_t* cairo_pop_group(cairo_t* cr);

void cairo_pop_group_to_source(cairo_t* cr);

alias int cairo_operator_t;
enum {
	CAIRO_OPERATOR_CLEAR,

	CAIRO_OPERATOR_SOURCE,
	CAIRO_OPERATOR_OVER,
	CAIRO_OPERATOR_IN,
	CAIRO_OPERATOR_OUT,
	CAIRO_OPERATOR_ATOP,

	CAIRO_OPERATOR_DEST,
	CAIRO_OPERATOR_DEST_OVER,
	CAIRO_OPERATOR_DEST_IN,
	CAIRO_OPERATOR_DEST_OUT,
	CAIRO_OPERATOR_DEST_ATOP,

	CAIRO_OPERATOR_XOR,
	CAIRO_OPERATOR_ADD,
	CAIRO_OPERATOR_SATURATE
}

void cairo_set_operator(cairo_t* cr, cairo_operator_t op);

void cairo_set_source(cairo_t* cr, cairo_pattern_t* source);

void cairo_set_source_rgb(cairo_t* cr, double red, double green, double blue);

void cairo_set_source_rgba(cairo_t* cr, double red, double green, double blue, double alpha);

void cairo_set_source_surface(cairo_t* cr, cairo_surface_t* surface, double x, double y);

void cairo_set_tolerance(cairo_t* cr, double tolerance);

alias int cairo_antialias_t;
enum {
	CAIRO_ANTIALIAS_DEFAULT,
	CAIRO_ANTIALIAS_NONE,
	CAIRO_ANTIALIAS_GRAY,
	CAIRO_ANTIALIAS_SUBPIXEL
}

void cairo_set_antialias(cairo_t* cr, cairo_antialias_t antialias);

alias int cairo_fill_rule_t;
enum {
	CAIRO_FILL_RULE_WINDING,
	CAIRO_FILL_RULE_EVEN_ODD
}

void cairo_set_fill_rule(cairo_t* cr, cairo_fill_rule_t fill_rule);

void cairo_set_line_width(cairo_t* cr, double width);

alias int cairo_line_cap_t;
enum {
	CAIRO_LINE_CAP_BUTT,
	CAIRO_LINE_CAP_ROUND,
	CAIRO_LINE_CAP_SQUARE
}

void cairo_set_line_cap(cairo_t* cr, cairo_line_cap_t line_cap);

alias int cairo_line_join_t;
enum {
	CAIRO_LINE_JOIN_MITER,
	CAIRO_LINE_JOIN_ROUND,
	CAIRO_LINE_JOIN_BEVEL
}

void cairo_set_line_join(cairo_t* cr, cairo_line_join_t line_join);

void cairo_set_dash(cairo_t* cr, double* dashes, int num_dashes, double offset);

void cairo_set_miter_limit(cairo_t* cr, double limit);

void cairo_translate(cairo_t* cr, double tx, double ty);

void cairo_scale(cairo_t* cr, double sx, double sy);

void cairo_rotate(cairo_t* cr, double angle);

void cairo_transform(cairo_t* cr, cairo_matrix_t* matrix);

void cairo_set_matrix(cairo_t* cr, cairo_matrix_t* matrix);

void cairo_identity_matrix(cairo_t* cr);

void cairo_user_to_device(cairo_t* cr, double* x, double* y);

void cairo_user_to_device_distance(cairo_t* cr, double* dx, double* dy);

void cairo_device_to_user(cairo_t* cr, double* x, double* y);

void cairo_device_to_user_distance(cairo_t* cr, double* dx, double* dy);

void cairo_new_path(cairo_t* cr);

void cairo_move_to(cairo_t* cr, double x, double y);

void cairo_new_sub_path(cairo_t* cr);

void cairo_line_to(cairo_t* cr, double x, double y);

void cairo_curve_to(cairo_t* cr, double x1, double y1, double x2, double y2, double x3, double y3);

void cairo_arc(cairo_t* cr, double xc, double yc, double radius, double angle1, double angle2);

void cairo_arc_negative(cairo_t* cr, double xc, double yc, double radius, double angle1, double angle2);

void cairo_rel_move_to(cairo_t* cr, double dx, double dy);

void cairo_rel_line_to(cairo_t* cr, double dx, double dy);

void cairo_rel_curve_to(cairo_t* cr, double dx1, double dy1, double dx2, double dy2, double dx3, double dy3);

void cairo_rectangle(cairo_t* cr, double x, double y, double width, double height);

void cairo_close_path(cairo_t* cr);

void cairo_paint(cairo_t* cr);

void cairo_paint_with_alpha(cairo_t* cr, double alpha);

void cairo_mask(cairo_t* cr, cairo_pattern_t* pattern);

void cairo_mask_surface(
	cairo_t* cr,
	cairo_surface_t* surface,
	double surface_x, double surface_y);

void cairo_stroke(cairo_t* cr);

void cairo_stroke_preserve(cairo_t* cr);

void cairo_fill(cairo_t* cr);

void cairo_fill_preserve(cairo_t* cr);

void cairo_copy_page(cairo_t* cr);

void cairo_show_page(cairo_t* cr);

cairo_bool_t cairo_in_stroke(cairo_t* cr, double x, double y);

cairo_bool_t cairo_in_fill(cairo_t* cr, double x, double y);

void cairo_stroke_extents(
	cairo_t* cr,
	double* x1, double* y1,
	double* x2, double* y2);

void cairo_fill_extents(
	cairo_t* cr,
	double* x1, double* y1,
	double* x2, double* y2);

void cairo_reset_clip(cairo_t* cr);

void cairo_clip(cairo_t* cr);

void cairo_clip_preserve(cairo_t* cr);

void cairo_clip_extents(
	cairo_t* cr,
	double* x1, double* y1,
	double* x2, double* y2);

struct cairo_rectangle_t {
	double x, y, width, height;
}

struct cairo_rectangle_list_t {
	cairo_status_t     status;
	cairo_rectangle_t* rectangles;
	int                num_rectangles;
}

cairo_rectangle_list_t* cairo_copy_clip_rectangle_list(cairo_t* cr);

void cairo_rectangle_list_destroy(cairo_rectangle_list_t* rectangle_list);

alias void cairo_scaled_font_t;

alias void cairo_font_face_t;

struct cairo_glyph_t {
	uint index;
	double x;
	double y;
}

struct cairo_text_extents_t {
	double x_bearing;
	double y_bearing;
	double width;
	double height;
	double x_advance;
	double y_advance;
}

struct cairo_font_extents_t {
	double ascent;
	double descent;
	double height;
	double max_x_advance;
	double max_y_advance;
}

alias int cairo_font_slant_t;
enum {
	CAIRO_FONT_SLANT_NORMAL,
	CAIRO_FONT_SLANT_ITALIC,
	CAIRO_FONT_SLANT_OBLIQUE
}

alias int cairo_font_weight_t;
enum {
	CAIRO_FONT_WEIGHT_NORMAL,
	CAIRO_FONT_WEIGHT_BOLD
}

alias int cairo_subpixel_order_t;
enum {
	CAIRO_SUBPIXEL_ORDER_DEFAULT,
	CAIRO_SUBPIXEL_ORDER_RGB,
	CAIRO_SUBPIXEL_ORDER_BGR,
	CAIRO_SUBPIXEL_ORDER_VRGB,
	CAIRO_SUBPIXEL_ORDER_VBGR
}

alias int cairo_hint_style_t;
enum {
	CAIRO_HINT_STYLE_DEFAULT,
	CAIRO_HINT_STYLE_NONE,
	CAIRO_HINT_STYLE_SLIGHT,
	CAIRO_HINT_STYLE_MEDIUM,
	CAIRO_HINT_STYLE_FULL
}

alias int cairo_hint_metrics_t;
enum {
	CAIRO_HINT_METRICS_DEFAULT,
	CAIRO_HINT_METRICS_OFF,
	CAIRO_HINT_METRICS_ON
}

alias void cairo_font_options_t;

cairo_font_options_t* cairo_font_options_create();

cairo_font_options_t* cairo_font_options_copy(cairo_font_options_t* original);

void cairo_font_options_destroy(cairo_font_options_t* options);

cairo_status_t cairo_font_options_status(cairo_font_options_t* options);

void cairo_font_options_merge(cairo_font_options_t* options, cairo_font_options_t* other);

cairo_bool_t cairo_font_options_equal(
	cairo_font_options_t* options,
	cairo_font_options_t* other);

uint cairo_font_options_hash(cairo_font_options_t* options);

void cairo_font_options_set_antialias(cairo_font_options_t* options, cairo_antialias_t antialias);

cairo_antialias_t cairo_font_options_get_antialias(cairo_font_options_t* options);

void cairo_font_options_set_subpixel_order(cairo_font_options_t* options, cairo_subpixel_order_t subpixel_order);

cairo_subpixel_order_t cairo_font_options_get_subpixel_order(cairo_font_options_t* options);

void cairo_font_options_set_hint_style(cairo_font_options_t* options, cairo_hint_style_t hint_style);

cairo_hint_style_t cairo_font_options_get_hint_style(cairo_font_options_t* options);

void cairo_font_options_set_hint_metrics(cairo_font_options_t* options, cairo_hint_metrics_t hint_metrics);

cairo_hint_metrics_t cairo_font_options_get_hint_metrics(cairo_font_options_t* options);

void cairo_select_font_face(
	cairo_t* cr,
	char* family,
	cairo_font_slant_t slant,
	cairo_font_weight_t weight);

void cairo_set_font_size(cairo_t* cr, double size);

void cairo_set_font_matrix(cairo_t* cr, cairo_matrix_t* matrix);

void cairo_get_font_matrix(cairo_t* cr, cairo_matrix_t* matrix);

void cairo_set_font_options(cairo_t* cr, cairo_font_options_t* options);

void cairo_get_font_options(cairo_t* cr, cairo_font_options_t* options);

void cairo_set_font_face(cairo_t* cr, cairo_font_face_t* font_face);

cairo_font_face_t* cairo_get_font_face(cairo_t* cr);

void cairo_set_scaled_font(cairo_t* cr, cairo_scaled_font_t* scaled_font);

cairo_scaled_font_t* cairo_get_scaled_font(cairo_t* cr);

void cairo_show_text(cairo_t* cr, char* utf8);

void cairo_show_glyphs(cairo_t* cr, cairo_glyph_t* glyphs, int num_glyphs);

void cairo_text_path(cairo_t* cr, char* utf8);

void cairo_glyph_path(cairo_t* cr, cairo_glyph_t* glyphs, int num_glyphs);

void cairo_text_extents(cairo_t* cr, char* utf8, cairo_text_extents_t* extents);

void cairo_glyph_extents(
	cairo_t* cr,
	cairo_glyph_t* glyphs, int num_glyphs,
	cairo_text_extents_t* extents);

void cairo_font_extents(cairo_t* cr, cairo_font_extents_t* extents);

void cairo_text_path(cairo_t* cr, char* utf8);

void cairo_glyph_path(cairo_t* cr, cairo_glyph_t* glyphs, int num_glyphs);


cairo_font_face_t* cairo_font_face_reference(cairo_font_face_t* font_face);

void cairo_font_face_destroy(cairo_font_face_t* font_face);

uint cairo_font_face_get_reference_count(cairo_font_face_t* font_face);

cairo_status_t cairo_font_face_status(cairo_font_face_t* font_face);

alias int cairo_font_type_t;
enum {
	CAIRO_FONT_TYPE_TOY,
	CAIRO_FONT_TYPE_FT,
	CAIRO_FONT_TYPE_WIN32,
	CAIRO_FONT_TYPE_ATSUI
}

cairo_font_type_t cairo_font_face_get_type(cairo_font_face_t* font_face);

void* cairo_font_face_get_user_data(
	cairo_font_face_t* font_face,
	cairo_user_data_key_t* key);

cairo_status_t cairo_font_face_set_user_data(
	cairo_font_face_t* font_face,
	cairo_user_data_key_t* key,
	void* user_data,
	cairo_destroy_func_t destroy);

cairo_scaled_font_t* cairo_scaled_font_create(
	cairo_font_face_t* font_face,
	cairo_matrix_t* font_matrix,
	cairo_matrix_t* ctm,
	cairo_font_options_t* options);

cairo_scaled_font_t* cairo_scaled_font_reference(
	cairo_scaled_font_t* scaled_font);

void cairo_scaled_font_destroy(cairo_scaled_font_t* scaled_font);

uint cairo_scaled_font_get_reference_count(cairo_scaled_font_t* scaled_font);

cairo_status_t cairo_scaled_font_status(cairo_scaled_font_t* scaled_font);

cairo_font_type_t cairo_scaled_font_get_type(cairo_scaled_font_t* scaled_font);

void* cairo_scaled_font_get_user_data(
	cairo_scaled_font_t* scaled_font,
	cairo_user_data_key_t* key);

cairo_status_t cairo_scaled_font_set_user_data(
	cairo_scaled_font_t* scaled_font,
	cairo_user_data_key_t* key,
	void* user_data,
	cairo_destroy_func_t destroy);

void cairo_scaled_font_extents(cairo_scaled_font_t* scaled_font, cairo_font_extents_t* extents);

void cairo_scaled_font_text_extents(
	cairo_scaled_font_t* scaled_font,
	char* utf8,
	cairo_text_extents_t* extents);

void cairo_scaled_font_glyph_extents(
	cairo_scaled_font_t* scaled_font,
	cairo_glyph_t* glyphs, int num_glyphs,
	cairo_text_extents_t* extents);

cairo_font_face_t* cairo_scaled_font_get_font_face(cairo_scaled_font_t* scaled_font);

void cairo_scaled_font_get_font_matrix(
	cairo_scaled_font_t* scaled_font,
	cairo_matrix_t* font_matrix);

void cairo_scaled_font_get_ctm(
	cairo_scaled_font_t* scaled_font,
	cairo_matrix_t* ctm);

void cairo_scaled_font_get_font_options(
	cairo_scaled_font_t* scaled_font,
	cairo_font_options_t* options);


cairo_operator_t cairo_get_operator(cairo_t* cr);

cairo_pattern_t* cairo_get_source(cairo_t* cr);

double cairo_get_tolerance(cairo_t* cr);

cairo_antialias_t cairo_get_antialias(cairo_t* cr);

void cairo_get_current_point(cairo_t* cr, double* x, double* y);

cairo_fill_rule_t cairo_get_fill_rule(cairo_t* cr);

double cairo_get_line_width(cairo_t* cr);

cairo_line_cap_t cairo_get_line_cap(cairo_t* cr);

cairo_line_join_t cairo_get_line_join(cairo_t* cr);

double cairo_get_miter_limit(cairo_t* cr);

int cairo_get_dash_count(cairo_t* cr);

void cairo_get_dash(cairo_t* cr, double* dashes, double* offset);

void cairo_get_matrix(cairo_t* cr, cairo_matrix_t* matrix);

cairo_surface_t* cairo_get_target(cairo_t* cr);

cairo_surface_t* cairo_get_group_target(cairo_t* cr);

alias int cairo_path_data_type_t;
enum {
	CAIRO_PATH_MOVE_TO,
	CAIRO_PATH_LINE_TO,
	CAIRO_PATH_CURVE_TO,
	CAIRO_PATH_CLOSE_PATH
}

union cairo_path_data_t {
	struct _header {
		cairo_path_data_type_t type;
		int length;
	}
	struct _point {
		double x, y;
	}
	_header header;
	_point point;
}

struct cairo_path_t {
	cairo_status_t status;
	cairo_path_data_t* data;
	int num_data;
}

cairo_path_t* cairo_copy_path(cairo_t* cr);

cairo_path_t* cairo_copy_path_flat(cairo_t* cr);

void cairo_append_path(cairo_t* cr, cairo_path_t* path);

void cairo_path_destroy(cairo_path_t* path);

cairo_status_t cairo_status(cairo_t* cr);

char* cairo_status_to_string(cairo_status_t status);


cairo_surface_t* cairo_surface_create_similar(
	cairo_surface_t* other,
	cairo_content_t content,
	int width, int height);

cairo_surface_t* cairo_surface_reference(cairo_surface_t* surface);

void cairo_surface_finish(cairo_surface_t* surface);

void cairo_surface_destroy(cairo_surface_t* surface);

uint cairo_surface_get_reference_count(cairo_surface_t* surface);

cairo_status_t cairo_surface_status(cairo_surface_t* surface);

alias int cairo_surface_type_t;
enum {
	CAIRO_SURFACE_TYPE_IMAGE,
	CAIRO_SURFACE_TYPE_PDF,
	CAIRO_SURFACE_TYPE_PS,
	CAIRO_SURFACE_TYPE_XLIB,
	CAIRO_SURFACE_TYPE_XCB,
	CAIRO_SURFACE_TYPE_GLITZ,
	CAIRO_SURFACE_TYPE_QUARTZ,
	CAIRO_SURFACE_TYPE_WIN32,
	CAIRO_SURFACE_TYPE_BEOS,
	CAIRO_SURFACE_TYPE_DIRECTFB,
	CAIRO_SURFACE_TYPE_SVG,
	CAIRO_SURFACE_TYPE_OS2
}

cairo_surface_type_t cairo_surface_get_type(cairo_surface_t* surface);

cairo_content_t cairo_surface_get_content(cairo_surface_t* surface);

void* cairo_surface_get_user_data(
	cairo_surface_t* surface,
	cairo_user_data_key_t* key);

cairo_status_t cairo_surface_set_user_data(
	cairo_surface_t* surface,
	cairo_user_data_key_t* key,
	void* user_data,
	cairo_destroy_func_t destroy);

void cairo_surface_get_font_options(cairo_surface_t* surface, cairo_font_options_t* options);

void cairo_surface_flush(cairo_surface_t* surface);

void cairo_surface_mark_dirty(cairo_surface_t* surface);

void cairo_surface_mark_dirty_rectangle(cairo_surface_t* surface, int x, int y, int width, int height);

void cairo_surface_set_device_offset(cairo_surface_t* surface, double x_offset, double y_offset);

void cairo_surface_get_device_offset(
	cairo_surface_t* surface,
	double* x_offset, double* y_offset);

void cairo_surface_set_fallback_resolution(
	cairo_surface_t* surface,
	double x_pixels_per_inch, double y_pixels_per_inch);

alias int cairo_format_t;
enum {
	CAIRO_FORMAT_ARGB32,
	CAIRO_FORMAT_RGB24,
	CAIRO_FORMAT_A8,
	CAIRO_FORMAT_A1
}

cairo_surface_t* cairo_image_surface_create(cairo_format_t format, int width, int height);

cairo_surface_t* cairo_image_surface_create_for_data(
	char* data,
	cairo_format_t format,
	int width, int height, int stride);

char* cairo_image_surface_get_data(cairo_surface_t* surface);

cairo_format_t cairo_image_surface_get_format(cairo_surface_t* surface);

int cairo_image_surface_get_width(cairo_surface_t* surface);

int cairo_image_surface_get_height(cairo_surface_t* surface);

int cairo_image_surface_get_stride(cairo_surface_t* surface);


cairo_pattern_t* cairo_pattern_create_rgb(double red, double green, double blue);

cairo_pattern_t* cairo_pattern_create_rgba(double red, double green, double blue, double alpha);

cairo_pattern_t* cairo_pattern_create_for_surface(cairo_surface_t* surface);

cairo_pattern_t* cairo_pattern_create_linear(double x0, double y0, double x1, double y1);

cairo_pattern_t* cairo_pattern_create_radial(double cx0, double cy0, double radius0, double cx1, double cy1, double radius1);

cairo_pattern_t* cairo_pattern_reference(cairo_pattern_t* pattern);

void cairo_pattern_destroy(cairo_pattern_t* pattern);

uint cairo_pattern_get_reference_count(cairo_pattern_t* pattern);

cairo_status_t cairo_pattern_status(cairo_pattern_t* pattern);

void* cairo_pattern_get_user_data(
	cairo_pattern_t* pattern,
	cairo_user_data_key_t* key);

cairo_status_t cairo_pattern_set_user_data(
	cairo_pattern_t* pattern,
	cairo_user_data_key_t* key,
	void* user_data,
	cairo_destroy_func_t destroy);

alias int cairo_pattern_type_t;
enum {
	CAIRO_PATTERN_TYPE_SOLID,
	CAIRO_PATTERN_TYPE_SURFACE,
	CAIRO_PATTERN_TYPE_LINEAR,
	CAIRO_PATTERN_TYPE_RADIAL
}

cairo_pattern_type_t cairo_pattern_get_type(cairo_pattern_t* pattern);

void cairo_pattern_add_color_stop_rgb(
	cairo_pattern_t* pattern, double offset,
	double red, double green, double blue);

void cairo_pattern_add_color_stop_rgba(
	cairo_pattern_t* pattern, double offset,
	double red, double green, double blue, double alpha);

void cairo_pattern_set_matrix(cairo_pattern_t* pattern, cairo_matrix_t* matrix);

void cairo_pattern_get_matrix(cairo_pattern_t* pattern, cairo_matrix_t* matrix);

alias int cairo_extend_t;
enum {
	CAIRO_EXTEND_NONE,
	CAIRO_EXTEND_REPEAT,
	CAIRO_EXTEND_REFLECT,
	CAIRO_EXTEND_PAD
}

void cairo_pattern_set_extend(cairo_pattern_t* pattern, cairo_extend_t extend);

cairo_extend_t cairo_pattern_get_extend(cairo_pattern_t* pattern);

alias int cairo_filter_t;
enum {
	CAIRO_FILTER_FAST,
	CAIRO_FILTER_GOOD,
	CAIRO_FILTER_BEST,
	CAIRO_FILTER_NEAREST,
	CAIRO_FILTER_BILINEAR,
	CAIRO_FILTER_GAUSSIAN
}

void cairo_pattern_set_filter(cairo_pattern_t* pattern, cairo_filter_t filter);

cairo_filter_t cairo_pattern_get_filter(cairo_pattern_t* pattern);

cairo_status_t cairo_pattern_get_rgba(
	cairo_pattern_t* pattern,
	double* red, double* green,
	double* blue, double* alpha);

cairo_status_t cairo_pattern_get_surface(
	cairo_pattern_t* pattern,
	cairo_surface_t** surface);

cairo_status_t cairo_pattern_get_color_stop_rgba(
	cairo_pattern_t* pattern,
	int index, double* offset,
	double* red, double* green,
	double* blue, double* alpha);

cairo_status_t cairo_pattern_get_color_stop_count(
	cairo_pattern_t* pattern,
	int* count);

cairo_status_t cairo_pattern_get_linear_points(
	cairo_pattern_t* pattern,
	double* x0, double* y0,
	double* x1, double* y1);

cairo_status_t cairo_pattern_get_radial_circles(
	cairo_pattern_t* pattern,
	double* x0, double* y0, double* r0,
	double* x1, double* y1, double* r1);


void cairo_matrix_init(cairo_matrix_t* matrix, double xx, double yx, double xy, double yy, double x0, double y0);

void cairo_matrix_init_identity(cairo_matrix_t* matrix);

void cairo_matrix_init_translate(cairo_matrix_t* matrix, double tx, double ty);

void cairo_matrix_init_scale(cairo_matrix_t* matrix, double sx, double sy);

void cairo_matrix_init_rotate(cairo_matrix_t* matrix, double radians);

void cairo_matrix_translate(cairo_matrix_t* matrix, double tx, double ty);

void cairo_matrix_scale(cairo_matrix_t* matrix, double sx, double sy);

void cairo_matrix_rotate(cairo_matrix_t* matrix, double radians);

cairo_status_t cairo_matrix_invert(cairo_matrix_t* matrix);

void cairo_matrix_multiply(cairo_matrix_t* result, cairo_matrix_t* a, cairo_matrix_t* b);

void cairo_matrix_transform_distance(cairo_matrix_t* matrix, double* dx, double* dy);

void cairo_matrix_transform_point(cairo_matrix_t* matrix, double* x, double* y);

void cairo_debug_reset_static_data();

