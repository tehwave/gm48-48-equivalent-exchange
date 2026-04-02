/// @description Updates movement, slow state, leak transactions, and death transactions.

if (!game_is_running()) {
  path_speed = 0;
  exit;
}

// Y-sort enemies so lower-on-screen enemies render in front.
depth = -(y + enemy_spawn_offset_y);

if (is_dead) {
  path_speed = 0;
  enemy_death_vfx_timer -= 1;

  if (enemy_death_vfx_timer <= 0) {
    instance_destroy();
  }

  exit;
}

if (enemy_slow_timer_steps > 0) {
  enemy_slow_timer_steps -= 1;
} else {
  enemy_slow_factor = 1;
}

if (enemy_freeze_timer_steps > 0) {
  enemy_freeze_timer_steps -= 1;
}

if (enemy_hit_flash_steps_remaining > 0) {
  enemy_hit_flash_steps_remaining -= 1;
}

if (enemy_hit_audio_cooldown_steps_remaining > 0) {
  enemy_hit_audio_cooldown_steps_remaining -= 1;
}

if (enemy_status_slow_decal_cooldown_steps_remaining > 0) {
  enemy_status_slow_decal_cooldown_steps_remaining -= 1;
}

if (enemy_status_burn_decal_cooldown_steps_remaining > 0) {
  enemy_status_burn_decal_cooldown_steps_remaining -= 1;
}

if (enemy_status_freeze_decal_cooldown_steps_remaining > 0) {
  enemy_status_freeze_decal_cooldown_steps_remaining -= 1;
}

if (enemy_burn_timer_steps > 0) {
  enemy_burn_timer_steps -= 1;
  enemy_burn_tick_steps_remaining -= 1;

  if (enemy_burn_tick_steps_remaining <= 0) {
    enemy_take_damage(id, enemy_burn_damage_per_tick, enemy_last_damage_source);
    enemy_burn_tick_steps_remaining = max(1, round(ENEMY_BURN_TICK_SECONDS * room_speed));
  }
} else {
  enemy_burn_damage_per_tick = 0;
  enemy_burn_tick_steps_remaining = 0;
}

/// @type {Real}
var move_factor = (enemy_freeze_timer_steps > 0) ? 0 : enemy_slow_factor;
path_speed = enemy_move_speed * move_factor;

/// Keep enemy art upright and only mirror when moving left.
/// @type {Real}
var delta_x = x - xprevious;
if (delta_x < -0.01) {
  image_xscale = -abs(image_xscale);
} else if (delta_x > 0.01) {
  image_xscale = abs(image_xscale);
}
image_angle = 0;

/// @type {Real}
var travel_step = point_distance(enemy_track_last_x, enemy_track_last_y, x, y);
if (travel_step > 0.01) {
  enemy_track_distance_accumulator += travel_step;

  /// @type {Real}
  var move_angle = point_direction(enemy_track_last_x, enemy_track_last_y, x, y);
  /// @type {Real}
  var speed_factor = clamp(path_speed / max(0.001, enemy_move_speed), 0, 1);

  while (enemy_track_distance_accumulator >= DECAL_TRACK_STAMP_SPACING) {
    enemy_track_distance_accumulator -= DECAL_TRACK_STAMP_SPACING;
    game_decals_stamp_track(x + enemy_spawn_offset_x, y + enemy_spawn_offset_y + 2, move_angle, speed_factor);
  }
}

enemy_track_last_x = x;
enemy_track_last_y = y;

enemy_call_steps_remaining -= 1;
if (enemy_call_steps_remaining <= 0) {
  game_audio_play_enemy_call("enemy");
  enemy_call_steps_remaining = irandom_range(
    max(1, round(room_speed * AUDIO_ENEMY_CALL_MIN_SECONDS)),
    max(1, round(room_speed * AUDIO_ENEMY_CALL_MAX_SECONDS))
  );
}

if (!has_leaked && path_position >= 1) {
  has_leaked = true;
  audio_play_one_shot(WAV_Hoof_sounds_on_grass, AUDIO_GAIN_COMBAT, 0.96, 1.04);
  global.enemies_alive = max(0, global.enemies_alive - 1);
  game_register_leak(enemy_leak_damage, x, y);
  instance_destroy();
  exit;
}

if (!is_dead && enemy_hp <= 0) {
  is_dead = true;
  audio_play_variation(WAV_Small_Spark_1, WAV_Small_Spark_2, AUDIO_GAIN_COMBAT, 0.96, 1.06);
  global.enemies_alive = max(0, global.enemies_alive - 1);
  game_spawn_coin_drop(x, y, enemy_reward);
  if (instance_exists(enemy_last_damage_source) && variable_instance_exists(enemy_last_damage_source, "tower_kill_count")) {
    enemy_last_damage_source.tower_kill_count += 1;
  }
  if (object_index == obj_enemy_boss) {
    game_add_hp(BOSS_KILL_HP_REWARD, x, y);
  }
  enemy_death_vfx_timer = enemy_death_vfx_total_steps;
}