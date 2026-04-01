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

if (enemy_burn_timer_steps > 0) {
  enemy_burn_timer_steps -= 1;
  enemy_burn_tick_steps_remaining -= 1;

  if (enemy_burn_tick_steps_remaining <= 0) {
    enemy_take_damage(id, enemy_burn_damage_per_tick);
    enemy_burn_tick_steps_remaining = max(1, round(ENEMY_BURN_TICK_SECONDS * room_speed));
  }
} else {
  enemy_burn_damage_per_tick = 0;
  enemy_burn_tick_steps_remaining = 0;
}

/// @type {Real}
var move_factor = (enemy_freeze_timer_steps > 0) ? 0 : enemy_slow_factor;
path_speed = enemy_move_speed * move_factor;

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
  game_register_leak(enemy_leak_damage);
  instance_destroy();
  exit;
}

if (!is_dead && enemy_hp <= 0) {
  is_dead = true;
  audio_play_variation(WAV_Small_Spark_1, WAV_Small_Spark_2, AUDIO_GAIN_COMBAT, 0.96, 1.06);
  global.enemies_alive = max(0, global.enemies_alive - 1);
  game_spawn_coin_drop(x, y, enemy_reward);
  enemy_death_vfx_timer = enemy_death_vfx_total_steps;
}