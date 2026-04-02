/// @description Move toward target and apply direct damage on impact.

if (!game_is_running()) {
  instance_destroy();
  exit;
}

// Keep projectile y-sorted with other world instances.
depth = -y;

if (proj_has_impacted) {
  var impact_frame_count = sprite_get_number(sprite_index);
  if (impact_frame_count <= 0 || image_index >= impact_frame_count - 1) {
    instance_destroy();
  }
  exit;
}

if (instance_exists(proj_target_id)) {
  proj_target_x = proj_target_id.x;
  proj_target_y = proj_target_id.y;
}

/// @type {Real}
var direction_to_target = point_direction(x, y, proj_target_x, proj_target_y);
image_angle = direction_to_target + proj_angle_offset;

x += lengthdir_x(proj_speed, direction_to_target);
y += lengthdir_y(proj_speed, direction_to_target);

if (point_distance(x, y, proj_target_x, proj_target_y) > proj_speed + 1) exit;

audio_play_variation(WAV_Fireball_Impact_1, WAV_Fireball_Impact_2, AUDIO_GAIN_COMBAT, 0.96, 1.06);

if (instance_exists(proj_target_id)) {
  enemy_take_damage(proj_target_id, proj_damage, proj_source_tower_id);
}

proj_has_impacted = true;
x = proj_target_x;
y = proj_target_y;
sprite_index = proj_impact_vfx_sprite;
image_index = 0;
image_speed = 1;
image_xscale = 0.5;
image_yscale = 0.5;
image_angle = 0;
