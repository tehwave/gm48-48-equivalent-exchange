/// @description Initializes dropped coin pickup state and bounce launch.

sprite_index = spr_coin;
image_speed = 0;

depth = COIN_DROP_DEPTH;

/// @type {Real}
coin_value = max(1, round(variable_instance_exists(id, "coin_value") ? coin_value : 1));
/// @type {Real}
coin_ground_y = variable_instance_exists(id, "coin_ground_y") ? coin_ground_y : y;

/// @type {Real}
coin_life_steps = COIN_DROP_LIFETIME_STEPS;
/// @type {Bool}
coin_collected = false;
/// @type {Real}
coin_collect_vfx_total_steps = 52;
/// @type {Real}
coin_collect_vfx_steps = 0;
/// @type {Real}
coin_collect_elapsed_steps = 0;
/// @type {Real}
coin_collect_start_gui_x = 0;
/// @type {Real}
coin_collect_start_gui_y = 0;
/// @type {Real}
coin_collect_target_gui_x = 0;
/// @type {Real}
coin_collect_target_gui_y = 0;
/// @type {Real}
coin_collect_arc_height = 46;
/// @type {Real}
coin_collect_path_index = 0;
/// @type {Real}
coin_collect_path_arc_mult = 1;
/// @type {Real}
coin_collect_path_lateral = 0;
/// @type {Real}
coin_collect_path_wobble = 0;
/// @type {Real}
coin_collect_path_wobble_freq = 1;
/// @type {Real}
coin_collect_path_ease_power = 3;
/// @type {Real}
coin_collect_launch_dir_x = 0;
/// @type {Real}
coin_collect_launch_dir_y = 0;
/// @type {Real}
coin_collect_launch_distance = 34;
/// @type {Real}
coin_collect_launch_phase_t = 0.18;
/// @type {Real}
coin_collect_draw_x = x;
/// @type {Real}
coin_collect_draw_y = y;
/// @type {Real}
coin_collect_text_origin_x = x;
/// @type {Real}
coin_collect_text_origin_y = y;
/// @type {Real}
coin_collect_text_offset_x = 0;
/// @type {Real}
coin_expire_warn_steps_remaining = 0;

/// @type {Real}
coin_velocity_x = random_range(-COIN_DROP_HORIZONTAL_SPEED, COIN_DROP_HORIZONTAL_SPEED);
/// @type {Real}
coin_velocity_y = -random_range(COIN_DROP_BOUNCE_MIN, COIN_DROP_BOUNCE_MAX);

/// @type {Real}
coin_rotation_speed = random_range(-9, 9);
image_angle = random_range(0, 359);
