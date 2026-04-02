/// @description Simulates bounce physics and expires coin after a short timer.

if (coin_collected) {
  coin_collect_vfx_steps -= 1;
  coin_collect_elapsed_steps += 1;

  /// @type {Real}
  var collect_t = clamp(coin_collect_elapsed_steps / max(1, coin_collect_vfx_total_steps), 0, 1);
  /// @type {Real}
  var launch_phase_t = clamp(coin_collect_launch_phase_t, 0.05, 0.45);
  /// @type {Real}
  var launch_t = clamp(collect_t / launch_phase_t, 0, 1);
  /// @type {Real}
  var launch_ease_t = 1 - power(1 - launch_t, 2.4);
  /// @type {Real}
  var launch_origin_x = coin_collect_start_gui_x;
  /// @type {Real}
  var launch_origin_y = coin_collect_start_gui_y;
  /// @type {Real}
  var launch_end_x = launch_origin_x + (coin_collect_launch_dir_x * coin_collect_launch_distance);
  /// @type {Real}
  var launch_end_y = launch_origin_y + (coin_collect_launch_dir_y * coin_collect_launch_distance);

  /// @type {Real}
  var fly_t = clamp((collect_t - launch_phase_t) / max(0.001, 1 - launch_phase_t), 0, 1);
  /// @type {Real}
  var ease_out_t = 1 - power(1 - fly_t, coin_collect_path_ease_power);

  /// @type {Real}
  var gui_x = launch_end_x;
  /// @type {Real}
  var gui_y = launch_end_y;

  if (collect_t < launch_phase_t) {
    gui_x = lerp(launch_origin_x, launch_end_x, launch_ease_t);
    gui_y = lerp(launch_origin_y, launch_end_y, launch_ease_t);
  } else {
    gui_x = lerp(launch_end_x, coin_collect_target_gui_x, ease_out_t);
    gui_x += sin(fly_t * pi) * coin_collect_path_lateral;
    gui_x += sin((fly_t * pi) * coin_collect_path_wobble_freq) * coin_collect_path_wobble;

    gui_y = lerp(launch_end_y, coin_collect_target_gui_y, ease_out_t);
    gui_y -= sin(fly_t * pi) * coin_collect_arc_height * coin_collect_path_arc_mult;
  }

  /// @type {Real}
  var camera_id_collect = view_camera[0];
  /// @type {Real}
  var view_x_collect = (camera_id_collect != -1) ? camera_get_view_x(camera_id_collect) : 0;
  /// @type {Real}
  var view_y_collect = (camera_id_collect != -1) ? camera_get_view_y(camera_id_collect) : 0;
  /// @type {Real}
  var view_w_collect = (camera_id_collect != -1) ? camera_get_view_width(camera_id_collect) : room_width;
  /// @type {Real}
  var view_h_collect = (camera_id_collect != -1) ? camera_get_view_height(camera_id_collect) : room_height;
  /// @type {Real}
  var gui_w_collect = display_get_gui_width();
  /// @type {Real}
  var gui_h_collect = display_get_gui_height();

  /// @type {Real}
  var safe_view_w_collect = max(1, view_w_collect);
  /// @type {Real}
  var safe_view_h_collect = max(1, view_h_collect);
  /// @type {Real}
  var safe_gui_w_collect = max(1, gui_w_collect);
  /// @type {Real}
  var safe_gui_h_collect = max(1, gui_h_collect);

  coin_collect_draw_x = view_x_collect + ((gui_x / safe_gui_w_collect) * safe_view_w_collect);
  coin_collect_draw_y = view_y_collect + ((gui_y / safe_gui_h_collect) * safe_view_h_collect);

  x = coin_collect_draw_x;
  y = coin_collect_draw_y;
  image_angle += 14;

  if (coin_collect_vfx_steps <= 0) {
    instance_destroy();
  }

  exit;
}

if (!game_is_running()) {
  instance_destroy();
  exit;
}

coin_life_steps -= 1;
if (coin_life_steps <= 0) {
  instance_destroy();
  exit;
}

coin_velocity_y += COIN_DROP_GRAVITY;
x += coin_velocity_x;
y += coin_velocity_y;

if (y >= coin_ground_y) {
  y = coin_ground_y;
  coin_velocity_y = -abs(coin_velocity_y) * COIN_DROP_BOUNCE_DAMPING;
  coin_velocity_x *= COIN_DROP_GROUND_FRICTION;

  if (abs(coin_velocity_y) < COIN_DROP_MIN_BOUNCE_TO_SETTLE) {
    coin_velocity_y = 0;
  }
}

if (coin_life_steps <= COIN_DROP_EXPIRE_FLASH_STEPS) {
  /// @type {Real}
  var expiry_t = clamp(1 - (coin_life_steps / max(1, COIN_DROP_EXPIRE_FLASH_STEPS)), 0, 1);

  coin_expire_warn_steps_remaining -= 1;
  if (coin_expire_warn_steps_remaining <= 0) {
    audio_play_variation(WAV_Small_Spark_1, WAV_Small_Spark_2, AUDIO_GAIN_UI * (0.24 + (0.28 * expiry_t)), 1.08, 1.28);
    coin_expire_warn_steps_remaining = max(2, round(lerp(12, 3, expiry_t)));
  }
}

image_angle += coin_rotation_speed;
coin_rotation_speed *= 0.96;
