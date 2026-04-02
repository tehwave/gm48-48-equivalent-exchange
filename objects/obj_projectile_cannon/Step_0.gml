/// @description Move to target and apply splash damage on impact.

if (!game_is_running()) {
  instance_destroy();
  exit;
}

if (instance_exists(proj_target_id)) {
  proj_target_x = proj_target_id.x;
  proj_target_y = proj_target_id.y;
}

/// @type {Real}
var direction_to_target = point_direction(x, y, proj_target_x, proj_target_y);
x += lengthdir_x(proj_speed, direction_to_target);
y += lengthdir_y(proj_speed, direction_to_target);

if (point_distance(x, y, proj_target_x, proj_target_y) > proj_speed + 1) exit;

audio_play_variation(WAV_Bomb_Explosion_Small_1, WAV_Bomb_Explosion_Small_2, AUDIO_GAIN_COMBAT, 0.94, 1.04);

with (obj_enemy_parent) {
  if (is_dead || has_leaked) continue;
  if (point_distance(x, y, other.x, other.y) <= other.proj_radius) {
    enemy_take_damage(id, other.proj_damage, other.proj_source_tower_id);
  }
}

instance_destroy();