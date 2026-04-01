/// @description Applies enemy base stats and starts path movement.

/// @type {Bool}
var is_boss_type = object_index == obj_enemy_boss;

/// @type {Real}
var enemy_wave_index = variable_instance_exists(id, "enemy_wave") ? enemy_wave : global.wave_index;

/// @type {Real}
var hp_scale = scr_wave_enemy_hp_scale(enemy_wave_index);
/// @type {Real}
var speed_scale = scr_wave_enemy_speed_scale(enemy_wave_index);

if (is_boss_type) {
  enemy_hp_max = round(ENEMY_BOSS_BASE_HP * hp_scale * 2.3);
  enemy_move_speed = ENEMY_BOSS_BASE_SPEED * speed_scale;
  enemy_reward = round(ENEMY_BOSS_BASE_REWARD * (1 + (enemy_wave_index * 0.08)));
  enemy_leak_damage = ENEMY_BOSS_LEAK_DAMAGE;
  enemy_draw_radius = 16;
  image_xscale = 1.30;
  image_yscale = 1.30;
} else {
  enemy_hp_max = round(ENEMY_BASIC_BASE_HP * hp_scale);
  enemy_move_speed = ENEMY_BASIC_BASE_SPEED * speed_scale;
  enemy_reward = round(ENEMY_BASIC_BASE_REWARD * (1 + (enemy_wave_index * 0.04)));
  enemy_leak_damage = ENEMY_BASIC_LEAK_DAMAGE;
  enemy_draw_radius = 10;
  image_xscale = 1;
  image_yscale = 1;
}

image_speed = 0;

enemy_hp = enemy_hp_max;

is_dead = false;
has_leaked = false;

enemy_death_vfx_timer = 0;
enemy_death_vfx_total_steps = ENEMY_DEATH_VFX_STEPS;

enemy_slow_factor = 1;
enemy_slow_timer_steps = 0;
enemy_freeze_timer_steps = 0;
enemy_burn_damage_per_tick = 0;
enemy_burn_timer_steps = 0;
enemy_burn_tick_steps_remaining = 0;
enemy_spawn_offset_x = 0;
enemy_spawn_offset_y = 0;
enemy_call_steps_remaining = irandom_range(
  max(1, round(room_speed * AUDIO_ENEMY_CALL_MIN_SECONDS)),
  max(1, round(room_speed * AUDIO_ENEMY_CALL_MAX_SECONDS))
);

// Y-sort enemies using their visual draw position so overlap reads correctly.
depth = -(y + enemy_spawn_offset_y);

// Absolute mode keeps the instance on the authored path points.
path_start(path_main, enemy_move_speed, path_action_stop, true);