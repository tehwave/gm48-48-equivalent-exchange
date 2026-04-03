/// @description Applies enemy base stats and starts path movement.

/// @type {Bool}
var is_boss_type = object_index == obj_enemy_boss;

/// @type {Real}
var enemy_wave_index = variable_instance_exists(id, "enemy_wave") ? enemy_wave : global.wave_index;

/// @type {Real}
var hp_scale = scr_wave_enemy_hp_scale(enemy_wave_index);
/// @type {Real}
var speed_scale = scr_wave_enemy_speed_scale(enemy_wave_index);
/// @type {Real}
var reward_wave_progress = max(0, enemy_wave_index - 1);

if (is_boss_type) {
  enemy_hp_max = round(ENEMY_BOSS_BASE_HP * hp_scale * 2.3);
  enemy_move_speed = ENEMY_BOSS_BASE_SPEED * speed_scale;
  enemy_reward = round(ENEMY_BOSS_BASE_REWARD * (1 + (reward_wave_progress * ENEMY_BOSS_REWARD_SCALE_PER_WAVE)));
  enemy_leak_damage = ENEMY_BOSS_LEAK_DAMAGE;
  enemy_draw_radius = 16;
  image_xscale = 1.30;
  image_yscale = 1.30;
} else {
  enemy_hp_max = round(ENEMY_BASIC_BASE_HP * hp_scale);
  enemy_move_speed = ENEMY_BASIC_BASE_SPEED * speed_scale;
  enemy_reward = round(ENEMY_BASIC_BASE_REWARD * (1 + (reward_wave_progress * ENEMY_BASIC_REWARD_SCALE_PER_WAVE)));
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
enemy_last_damage_source = noone;
enemy_hit_flash_steps_total = max(1, round(room_speed * ENEMY_HIT_FLASH_SECONDS));
enemy_hit_flash_steps_remaining = 0;
enemy_hit_audio_cooldown_steps_total = max(1, round(room_speed * ENEMY_HIT_AUDIO_COOLDOWN_SECONDS));
enemy_hit_audio_cooldown_steps_remaining = 0;
enemy_status_slow_decal_cooldown_steps_remaining = 0;
enemy_status_burn_decal_cooldown_steps_remaining = 0;
enemy_status_freeze_decal_cooldown_steps_remaining = 0;
enemy_track_distance_accumulator = DECAL_TRACK_STAMP_SPACING;
enemy_track_last_x = x;
enemy_track_last_y = y;
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