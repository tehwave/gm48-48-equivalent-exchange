/// @description Collects this coin on click and grants its value once.

if (coin_collected) exit;
if (!game_is_running()) exit;

coin_collected = true;
game_add_coins(coin_value, x, y);
audio_play_variation(WAV_Magical_Sparkle_Charge_Up_1, WAV_Magical_Sparkle_Charge_Up_2, AUDIO_GAIN_UI * 1.15, 1.04, 1.12);
audio_play_variation(WAV_Magical_Sparkle_Disappate_1, WAV_Magical_Sparkle_Disappate_2, AUDIO_GAIN_UI * 1.05, 1.08, 1.18);
coin_collect_vfx_steps = coin_collect_vfx_total_steps;
coin_collect_elapsed_steps = 0;
coin_collect_text_origin_x = x;
coin_collect_text_origin_y = y;
coin_collect_text_offset_x = random_range(-14, 14);

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
var gui_width = display_get_gui_width();
/// @type {Real}
var gui_height = display_get_gui_height();

/// @type {Real}
var safe_view_w = max(1, view_w);
/// @type {Real}
var safe_view_h = max(1, view_h);
/// @type {Real}
var safe_gui_w = max(1, gui_width);
/// @type {Real}
var safe_gui_h = max(1, gui_height);

coin_collect_start_gui_x = ((x - view_x) / safe_view_w) * safe_gui_w;
coin_collect_start_gui_y = ((y - view_y) / safe_view_h) * safe_gui_h;

/// Start with a quick upward-only burst before homing to UI.
coin_collect_launch_dir_x = 0;
coin_collect_launch_dir_y = -1;
coin_collect_launch_distance = random_range(28, 54);
coin_collect_launch_phase_t = random_range(0.14, 0.24);

/// Match the coin text anchor used in obj_gui.
/// @type {Real}
var top_right_width = 224;
/// @type {Real}
var top_right_x = gui_width - top_right_width - 16;
/// @type {Real}
var top_right_y = 16;
coin_collect_target_gui_x = top_right_x + 14;
coin_collect_target_gui_y = top_right_y + 42;

if (!variable_global_exists("coin_collect_path_count")) {
	global.coin_collect_path_count = 6;
}

if (!variable_global_exists("coin_collect_path_next_index")) {
	global.coin_collect_path_next_index = 0;
}

if (!variable_global_exists("coin_collect_path_last_index")) {
	global.coin_collect_path_last_index = -1;
}

/// @type {Real}
var path_count = max(1, round(global.coin_collect_path_count));
/// @type {Real}
var collect_path_index_local = global.coin_collect_path_next_index mod path_count;
if (collect_path_index_local == global.coin_collect_path_last_index && path_count > 1) {
	collect_path_index_local = (collect_path_index_local + 1) mod path_count;
}

coin_collect_path_index = collect_path_index_local;
global.coin_collect_path_last_index = collect_path_index_local;
global.coin_collect_path_next_index = (collect_path_index_local + 1) mod path_count;

switch (coin_collect_path_index) {
	case 0:
		coin_collect_path_arc_mult = 0.92;
		coin_collect_path_lateral = -26;
		coin_collect_path_wobble = 0;
		coin_collect_path_wobble_freq = 1;
		coin_collect_path_ease_power = 2.9;
		break;
	case 1:
		coin_collect_path_arc_mult = 1.22;
		coin_collect_path_lateral = -10;
		coin_collect_path_wobble = 9;
		coin_collect_path_wobble_freq = 2;
		coin_collect_path_ease_power = 3.1;
		break;
	case 2:
		coin_collect_path_arc_mult = 1.05;
		coin_collect_path_lateral = 18;
		coin_collect_path_wobble = -7;
		coin_collect_path_wobble_freq = 2;
		coin_collect_path_ease_power = 2.7;
		break;
	case 3:
		coin_collect_path_arc_mult = 1.36;
		coin_collect_path_lateral = 30;
		coin_collect_path_wobble = 0;
		coin_collect_path_wobble_freq = 1;
		coin_collect_path_ease_power = 3.35;
		break;
	case 4:
		coin_collect_path_arc_mult = 0.98;
		coin_collect_path_lateral = -34;
		coin_collect_path_wobble = 6;
		coin_collect_path_wobble_freq = 3;
		coin_collect_path_ease_power = 2.85;
		break;
	default:
		coin_collect_path_arc_mult = 1.18;
		coin_collect_path_lateral = 12;
		coin_collect_path_wobble = -10;
		coin_collect_path_wobble_freq = 3;
		coin_collect_path_ease_power = 3.2;
		break;
}

if (!variable_global_exists("coin_hud_pop_steps")) {
	global.coin_hud_pop_steps = 0;
}

global.coin_hud_pop_steps = max(global.coin_hud_pop_steps, 10);

coin_velocity_x = 0;
coin_velocity_y = 0;
