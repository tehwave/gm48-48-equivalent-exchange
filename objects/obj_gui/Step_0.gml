/// @description Handles bottom-left master audio controls.

/// @type {Real}
var gui_width = display_get_gui_width();
/// @type {Real}
var gui_height = display_get_gui_height();
/// @type {Struct}
var audio_ui_layout = game_audio_ui_get_layout(gui_width, gui_height);
/// @type {Real}
var mouse_gui_x = device_mouse_x_to_gui(0);
/// @type {Real}
var mouse_gui_y = device_mouse_y_to_gui(0);
/// @type {Bool}
var mouse_left_pressed = mouse_check_button_pressed(mb_left);

if (!mouse_left_pressed) exit;

if (point_in_rectangle(mouse_gui_x, mouse_gui_y, audio_ui_layout.mute_x1, audio_ui_layout.mute_y1, audio_ui_layout.mute_x2, audio_ui_layout.mute_y2)) {
  game_audio_toggle_mute();
  audio_play_variation(sfx_ship_highlight_01, sfx_ship_highlight_02, AUDIO_GAIN_UI * 0.45, 0.96, 1.06);
  exit;
}

if (point_in_rectangle(mouse_gui_x, mouse_gui_y, audio_ui_layout.minus_x1, audio_ui_layout.minus_y1, audio_ui_layout.minus_x2, audio_ui_layout.minus_y2)) {
  game_audio_adjust_master_gain(-AUDIO_MASTER_GAIN_STEP);
  audio_play_variation(sfx_ship_deselect_01, sfx_ship_deselect_02, AUDIO_GAIN_UI * 0.38, 0.93, 1.0);
  exit;
}

if (point_in_rectangle(mouse_gui_x, mouse_gui_y, audio_ui_layout.plus_x1, audio_ui_layout.plus_y1, audio_ui_layout.plus_x2, audio_ui_layout.plus_y2)) {
  game_audio_adjust_master_gain(AUDIO_MASTER_GAIN_STEP);
  audio_play_variation(sfx_ship_highlight_01, sfx_ship_highlight_02, AUDIO_GAIN_UI * 0.38, 1.0, 1.08);
  exit;
}
