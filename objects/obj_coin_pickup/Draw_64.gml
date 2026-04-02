/// @description Draws coin value popup in GUI space so it always appears above world VFX.

if (!coin_collected) exit;

/// @type {Real}
var collect_t = 1 - (coin_collect_vfx_steps / max(1, coin_collect_vfx_total_steps));
/// @type {Real}
var text_scale = 1.7 + (0.2 * collect_t);
/// @type {Real}
var text_fade_t = clamp((collect_t - 0.88) / 0.12, 0, 1);
/// @type {Real}
var text_alpha = 1 - text_fade_t;

/// @type {Real}
var camera_id = view_camera[0];
/// @type {Real}
var view_x = (camera_id != -1) ? camera_get_view_x(camera_id) : 0;
/// @type {Real}
var view_y = (camera_id != -1) ? camera_get_view_y(camera_id) : 0;
/// @type {Real}
var view_w = (camera_id != -1) ? camera_get_view_width(camera_id) : room_width;
/// @type {Real}
var view_h = (camera_id != -1) ? camera_get_view_height(camera_id) : room_height;
/// @type {Real}
var gui_w = display_get_gui_width();
/// @type {Real}
var gui_h = display_get_gui_height();

/// @type {Real}
var safe_view_w = max(1, view_w);
/// @type {Real}
var safe_view_h = max(1, view_h);
/// @type {Real}
var safe_gui_w = max(1, gui_w);
/// @type {Real}
var safe_gui_h = max(1, gui_h);

/// @type {Real}
var text_world_x = coin_collect_text_origin_x + coin_collect_text_offset_x;
/// @type {Real}
var text_world_y = coin_collect_text_origin_y - 30 - (62 * collect_t);
/// @type {Real}
var text_gui_x = ((text_world_x - view_x) / safe_view_w) * safe_gui_w;
/// @type {Real}
var text_gui_y = ((text_world_y - view_y) / safe_view_h) * safe_gui_h;
/// @type {String}
var popup_text = "+" + string(coin_value);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Shadow pass first for readability against bright VFX/backgrounds.
draw_set_alpha(text_alpha);
draw_set_colour(c_black);
draw_text_transformed(text_gui_x + 2, text_gui_y + 2, popup_text, text_scale, text_scale, 0);

draw_set_colour(c_yellow);
draw_text_transformed(text_gui_x, text_gui_y, popup_text, text_scale, text_scale, 0);

draw_set_alpha(1);
draw_set_colour(c_white);
