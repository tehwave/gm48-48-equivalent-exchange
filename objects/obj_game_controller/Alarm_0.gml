/// @description Spawns enemies on interval while a wave is in progress.

if (!game_is_running()) exit;
if (!wave_in_progress) exit;
if (enemies_spawned >= enemies_to_spawn) exit;

/// @type {Bool}
var is_boss_spawn = current_wave_has_boss && (enemies_spawned == enemies_to_spawn - 1);

if (is_boss_spawn) {
  audio_play_one_shot(WAV_Hoof_sounds_on_grass, AUDIO_GAIN_ENEMY_CALL, 0.95, 1.03);
}

/// @type {Asset.GMObject|Real}
var enemy_object = is_boss_spawn ? obj_enemy_boss : obj_enemy_basic;

/// @type {Id.Instance}
var enemy_instance = instance_create_layer(PATH_START_X, PATH_START_Y, "Instances", enemy_object);
enemy_instance.enemy_spawn_offset_x = irandom_range(-ENEMY_SPAWN_OFFSET_X, ENEMY_SPAWN_OFFSET_X);
enemy_instance.enemy_spawn_offset_y = irandom_range(-ENEMY_SPAWN_OFFSET_Y, ENEMY_SPAWN_OFFSET_Y);
enemy_instance.enemy_wave = global.wave_index;

enemies_spawned += 1;
global.enemies_alive += 1;

if (enemies_spawned < enemies_to_spawn) {
  alarm[0] = max(1, round(room_speed * scr_wave_spawn_interval(global.wave_index)));
}