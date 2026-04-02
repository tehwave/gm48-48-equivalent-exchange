/// @description Draw tower sprite with lightweight readability overlays.

/// @type {Real}
var draw_scale_x = tower_scale_current;
/// @type {Real}
var draw_scale_y = tower_scale_current;
/// @type {Real}
var draw_angle = tower_directional_sprite_enabled ? 0 : image_angle;
/// @type {Real}
var draw_offset_y = 0;
/// @type {Real}
var tower_flash_overlay_alpha = 0;

if (tower_spawn_anim_steps_remaining > 0) {
  /// @type {Real}
  var spawn_progress = 1 - (tower_spawn_anim_steps_remaining / tower_spawn_anim_steps_total);
  /// @type {Real}
  var drop_offset = (1 - spawn_progress) * 18;
  /// @type {Real}
  var bounce_offset = max(0, sin(spawn_progress * pi * 2.2)) * (1 - spawn_progress) * 14;
  draw_offset_y += drop_offset - bounce_offset;

  /// @type {Real}
  var spawn_stretch = 1 + (1 - spawn_progress) * 0.10;
  draw_scale_x *= spawn_stretch;
  draw_scale_y *= 2 - spawn_stretch;
}

if (tower_fire_recoil_steps_remaining > 0) {
  /// @type {Real}
  var recoil_progress = tower_fire_recoil_steps_remaining / tower_fire_recoil_steps_total;
  /// @type {Real}
  var recoil_impulse = sin((1 - recoil_progress) * pi);
  draw_scale_x *= 1 + (0.12 * recoil_progress);
  draw_scale_y *= 1 - (0.10 * recoil_progress);
  if (!tower_directional_sprite_enabled) {
    draw_angle += tower_fire_wiggle_dir * recoil_impulse * 8 * recoil_progress;
  }
  draw_offset_y += recoil_progress * 3;
}

/// @type {Bool}
var is_selected = (global.selected_tower_id == id);
/// @type {Real}
var tower_phase_seed = (x * 0.013) + (y * 0.017);
/// @type {Real}
var select_wave = 0;

if (is_selected) {
  /// @type {Real}
  var shared_select_time = (current_time * 0.012) + (tower_phase_seed * 0.11);
  select_wave = (sin(shared_select_time) + 1) * 0.5;
}

if (is_selected) {
  /// @type {Real}
  var select_radius = 20 + (select_wave * 4);
  /// @type {Real}
  var select_alpha = 0.56 + (select_wave * 0.34);
  /// @type {Real}
  var select_scale_boost = 1.08 + (select_wave * 0.08);

  // Make selected towers clearly larger at a glance.
  draw_scale_x *= select_scale_boost;
  draw_scale_y *= select_scale_boost;

  // Draw a filled yellow marker under the tower.
  draw_set_colour(c_yellow);
  draw_set_alpha(select_alpha * 0.42);
  draw_circle(x, y + draw_offset_y + 12, select_radius, true);

  gpu_set_blendmode(bm_add);
  draw_set_alpha(select_alpha * 0.72);
  draw_circle(x, y + draw_offset_y + 12, select_radius + 1, false);

  draw_set_colour(c_white);
  draw_set_alpha(select_alpha * 0.75);
  draw_circle(x, y + draw_offset_y + 12, select_radius - 2, false);

  // Flash overlay pass that pulses to make selection unmistakable.
  tower_flash_overlay_alpha = 0.22 + (select_wave * 0.48);

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_colour(c_white);
}

if (is_selected && tower_range > 0) {
  /// @type {Real}
  var aura_alpha = 0.12 + (select_wave * 0.08);
  /// @type {Real}
  var ring_alpha = 0.24 + (select_wave * 0.12);
  /// @type {Real}
  var ring_radius = tower_range + (select_wave * 2);

  gpu_set_blendmode(bm_add);
  draw_set_colour(c_ltgray);
  draw_set_alpha(aura_alpha * 0.5);
  draw_circle(x, y, ring_radius, true);

  draw_set_alpha(aura_alpha);
  draw_circle(x, y, ring_radius, false);

  draw_set_alpha(ring_alpha);
  draw_set_colour(c_white);
  draw_circle(x, y, ring_radius - 1, false);

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_colour(c_white);
}

/// @type {Asset.GMObject|Real}
var flamer_object = asset_get_index("obj_tower_flamer");
/// @type {Asset.GMObject|Real}
var freeze_object = asset_get_index("obj_tower_freeze");

if (object_index == obj_tower_arrow) {
  draw_set_colour(c_aqua);
} else if (object_index == obj_tower_slow) {
  draw_set_colour(c_blue);
} else if (freeze_object != -1 && object_index == freeze_object) {
  draw_set_colour(make_color_rgb(128, 196, 255));
} else if (flamer_object != -1 && object_index == flamer_object) {
  draw_set_colour(c_red);
} else {
  draw_set_colour(c_orange);
}

if (global.debug_mode) {
  draw_circle(x, y, 16, false);
}

if (tower_attack_vfx_sprite != -1 && tower_attack_vfx_steps_remaining > 0) {
  /// @type {Real}
  var frame_count = sprite_get_number(tower_attack_vfx_sprite);
  /// @type {Real}
  var frame_index = clamp(frame_count - tower_attack_vfx_steps_remaining, 0, frame_count - 1);
  /// @type {Real}
  var vfx_angle = tower_attack_vfx_angle + tower_attack_vfx_angle_offset;
  /// @type {Real}
  var vfx_x = x + lengthdir_x(tower_attack_vfx_distance, vfx_angle);
  /// @type {Real}
  var vfx_y = y + draw_offset_y + lengthdir_y(tower_attack_vfx_distance, vfx_angle);
  draw_sprite_ext(tower_attack_vfx_sprite, frame_index, vfx_x, vfx_y, tower_attack_vfx_scale, tower_attack_vfx_scale, vfx_angle, c_white, 1);
}

if (sprite_index != -1) {
  draw_sprite_ext(sprite_index, image_index, x, y + draw_offset_y, draw_scale_x, draw_scale_y, draw_angle, image_blend, image_alpha);
  if (tower_flash_overlay_alpha > 0) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x, y + draw_offset_y, draw_scale_x, draw_scale_y, draw_angle, c_yellow, tower_flash_overlay_alpha);
    gpu_set_blendmode(bm_normal);
  }
}

if (tower_upgrade_shine_steps_remaining > 0) {
  /// @type {Real}
  var shine_progress = 1 - (tower_upgrade_shine_steps_remaining / tower_upgrade_shine_steps_total);
  /// @type {Real}
  var shine_fade = power(1 - shine_progress, 1.8);
  /// @type {Real}
  var shine_radius = 16 + (shine_progress * 24);
  /// @type {Real}
  var shine_alpha = shine_fade * 0.85;
  /// @type {Real}
  var spin_seed = (x * 0.31) + (y * 0.17) + (tower_level * 0.013);
  /// @type {Real}
  var spin = (shine_progress * 180) + spin_seed;

  gpu_set_blendmode(bm_add);
  draw_set_alpha(shine_alpha * 0.45);
  draw_set_colour(c_white);
  draw_circle(x, y + draw_offset_y, shine_radius, false);

  draw_set_alpha(shine_alpha * 0.75);
  draw_set_colour(c_yellow);
  draw_line(
    x + lengthdir_x(shine_radius * 0.9, spin),
    y + draw_offset_y + lengthdir_y(shine_radius * 0.9, spin),
    x + lengthdir_x(shine_radius * 0.9, spin + 180),
    y + draw_offset_y + lengthdir_y(shine_radius * 0.9, spin + 180)
  );
  draw_line(
    x + lengthdir_x(shine_radius * 0.65, spin + 90),
    y + draw_offset_y + lengthdir_y(shine_radius * 0.65, spin + 90),
    x + lengthdir_x(shine_radius * 0.65, spin + 270),
    y + draw_offset_y + lengthdir_y(shine_radius * 0.65, spin + 270)
  );

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

