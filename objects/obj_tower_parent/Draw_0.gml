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
var draw_offset_x = 0;
/// @type {Real}
var tower_flash_overlay_alpha = 0;

if (tower_failed_upgrade_shake_steps_remaining > 0) {
  /// @type {Real}
  var shake_progress = tower_failed_upgrade_shake_steps_remaining / tower_failed_upgrade_shake_steps_total;
  /// @type {Real}
  var shake_phase = (1 - shake_progress) * pi * 5;
  /// @type {Real}
  var shake_fade = power(shake_progress, 0.85);
  draw_offset_x = sin(shake_phase) * tower_failed_upgrade_shake_strength * shake_fade * tower_failed_upgrade_shake_dir;
}

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
  if (!tower_directional_sprite_enabled && tower_sprite_rotates_to_target) {
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

/// @type {Asset.GMObject|Real}
var flamer_object = asset_get_index("obj_tower_flamer");
/// @type {Asset.GMObject|Real}
var freeze_object = asset_get_index("obj_tower_freeze");

if (is_selected && tower_range > 0) {
  /// @type {Real}
  var aura_alpha = 0.34;
  /// @type {Real}
  var ring_alpha = 0.62;
  /// @type {Real}
  var ring_radius = tower_range;
  /// @type {Real}
  var ring_thickness = max(2, ring_radius * 0.2);
  /// @type {Real}
  var ring_start = max(1, ring_radius - (ring_thickness * 0.5));
  /// @type {Real}
  var ring_end = ring_radius + (ring_thickness * 0.5);
  /// @type {Bool}
  var range_is_aoe = (object_index == obj_tower_cannon || (flamer_object != -1 && object_index == flamer_object));
  /// @type {Bool}
  var range_is_control = (object_index == obj_tower_slow || (freeze_object != -1 && object_index == freeze_object));
  /// @type {Real}
  var range_style = 0;
  /// @type {Colour}
  var range_colour = c_silver;

  if (range_is_aoe) {
    range_style = 1;
  } else if (range_is_control) {
    range_style = 2;
  }

  if (object_index == obj_tower_arrow) {
    range_colour = c_aqua;
  } else if (object_index == obj_tower_slow) {
    range_colour = c_blue;
  } else if (freeze_object != -1 && object_index == freeze_object) {
    range_colour = make_color_rgb(128, 196, 255);
  } else if (flamer_object != -1 && object_index == flamer_object) {
    range_colour = c_red;
  } else {
    range_colour = c_orange;
  }

  gpu_set_blendmode(bm_add);
  draw_set_colour(range_colour);
  draw_set_alpha(aura_alpha);
  if (range_style == 1) {
    /// @type {Real}
    var dash_step = 10;
    /// @type {Real}
    var dash_length = 6;
    for (var ring_step = ring_start; ring_step <= ring_end; ring_step += 1) {
      for (var dash_angle = 0; dash_angle < 360; dash_angle += dash_step) {
        if (((dash_angle div dash_step) mod 2) != 0) continue;
        draw_line(
          x + lengthdir_x(ring_step, dash_angle),
          y + lengthdir_y(ring_step, dash_angle),
          x + lengthdir_x(ring_step, dash_angle + dash_length),
          y + lengthdir_y(ring_step, dash_angle + dash_length)
        );
      }
    }
  } else if (range_style == 2) {
    /// @type {Real}
    var dot_step = 16;
    /// @type {Real}
    var dot_radius = 1.25;
    for (var ring_dot_step = ring_start; ring_dot_step <= ring_end; ring_dot_step += 1) {
      for (var dot_angle = 0; dot_angle < 360; dot_angle += dot_step) {
        draw_circle(
          x + lengthdir_x(ring_dot_step, dot_angle),
          y + lengthdir_y(ring_dot_step, dot_angle),
          dot_radius,
          true
        );
      }
    }
  } else {
    for (var ring_step = ring_start; ring_step <= ring_end; ring_step += 1) {
      draw_circle(x, y, ring_step, true);
    }
  }

  draw_set_alpha(ring_alpha);
  draw_set_colour(c_white);
  if (range_style == 1) {
    for (var ring_highlight_step = ring_start; ring_highlight_step <= ring_end; ring_highlight_step += 1) {
      for (var dash_highlight_angle = 0; dash_highlight_angle < 360; dash_highlight_angle += dash_step) {
        if (((dash_highlight_angle div dash_step) mod 2) != 0) continue;
        draw_line(
          x + lengthdir_x(ring_highlight_step - 1, dash_highlight_angle),
          y + lengthdir_y(ring_highlight_step - 1, dash_highlight_angle),
          x + lengthdir_x(ring_highlight_step - 1, dash_highlight_angle + dash_length),
          y + lengthdir_y(ring_highlight_step - 1, dash_highlight_angle + dash_length)
        );
      }
    }
  } else if (range_style == 2) {
    for (var ring_highlight_dot_step = ring_start; ring_highlight_dot_step <= ring_end; ring_highlight_dot_step += 1) {
      for (var highlight_dot_angle = 0; highlight_dot_angle < 360; highlight_dot_angle += dot_step) {
        draw_circle(
          x + lengthdir_x(ring_highlight_dot_step - 1, highlight_dot_angle),
          y + lengthdir_y(ring_highlight_dot_step - 1, highlight_dot_angle),
          dot_radius,
          true
        );
      }
    }
  } else {
    for (var ring_highlight_step = ring_start; ring_highlight_step <= ring_end; ring_highlight_step += 1) {
      draw_circle(x, y, ring_highlight_step - 1, true);
    }
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_colour(c_white);
}

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

/// @type {Bool}
var should_draw_attack_vfx = (tower_attack_vfx_sprite != -1 && tower_attack_vfx_steps_remaining > 0);
/// @type {Bool}
var draw_attack_vfx_above_tower = tower_attack_vfx_draw_above_tower;
/// @type {Real}
var vfx_anchor_x = x + draw_offset_x;
/// @type {Real}
var vfx_anchor_y = y + draw_offset_y;

if (tower_is_flamer && should_draw_attack_vfx) {
  /// Keep flamer VFX below tower except when aiming downward on screen.
  draw_attack_vfx_above_tower = (lengthdir_y(1, tower_attack_vfx_angle) > 0);
}

if (should_draw_attack_vfx) {
  vfx_anchor_y += tower_attack_vfx_origin_lift;
  if (tower_attack_vfx_origin_forward != 0) {
    /// Push the muzzle anchor forward so VFX starts near the tower head.
    vfx_anchor_x += lengthdir_x(tower_attack_vfx_origin_forward, tower_attack_vfx_angle);
    vfx_anchor_y += lengthdir_y(tower_attack_vfx_origin_forward, tower_attack_vfx_angle);
  }
}

if (should_draw_attack_vfx && !draw_attack_vfx_above_tower) {
  /// @type {Real}
  var frame_count = sprite_get_number(tower_attack_vfx_sprite);
  /// @type {Real}
  var frame_index = clamp(frame_count - tower_attack_vfx_steps_remaining, 0, frame_count - 1);
  if (tower_is_flamer) {
    // Flamer should restart on fire, but skip startup frames by starting mid-animation.
    /// @type {Real}
    var flamer_start_index = floor((frame_count - 1) * tower_attack_vfx_start_fraction);
    /// @type {Real}
    var flamer_span = max(1, frame_count - flamer_start_index);
    /// @type {Real}
    var flamer_progress = clamp((frame_count - tower_attack_vfx_steps_remaining) / frame_count, 0, 1);
    frame_index = clamp(flamer_start_index + floor(flamer_progress * flamer_span), 0, frame_count - 1);
  }
  /// @type {Real}
  var vfx_angle = tower_attack_vfx_angle + tower_attack_vfx_angle_offset;
  /// @type {Real}
  var vfx_x = vfx_anchor_x + lengthdir_x(tower_attack_vfx_distance, vfx_angle);
  /// @type {Real}
  var vfx_y = vfx_anchor_y + lengthdir_y(tower_attack_vfx_distance, vfx_angle);
  draw_sprite_ext(tower_attack_vfx_sprite, frame_index, vfx_x, vfx_y, tower_attack_vfx_scale, tower_attack_vfx_scale, vfx_angle, c_white, 1);
}

if (sprite_index != -1) {
  draw_sprite_ext(sprite_index, image_index, x + draw_offset_x, y + draw_offset_y, draw_scale_x, draw_scale_y, draw_angle, image_blend, image_alpha);
  if (tower_flash_overlay_alpha > 0) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x + draw_offset_x, y + draw_offset_y, draw_scale_x, draw_scale_y, draw_angle, c_yellow, tower_flash_overlay_alpha);
    gpu_set_blendmode(bm_normal);
  }
}

if (should_draw_attack_vfx && draw_attack_vfx_above_tower) {
  /// @type {Real}
  var frame_count_above = sprite_get_number(tower_attack_vfx_sprite);
  /// @type {Real}
  var frame_index_above = clamp(frame_count_above - tower_attack_vfx_steps_remaining, 0, frame_count_above - 1);
  if (tower_is_flamer) {
    // Flamer should restart on fire, but skip startup frames by starting mid-animation.
    /// @type {Real}
    var flamer_start_index_above = floor((frame_count_above - 1) * tower_attack_vfx_start_fraction);
    /// @type {Real}
    var flamer_span_above = max(1, frame_count_above - flamer_start_index_above);
    /// @type {Real}
    var flamer_progress_above = clamp((frame_count_above - tower_attack_vfx_steps_remaining) / frame_count_above, 0, 1);
    frame_index_above = clamp(flamer_start_index_above + floor(flamer_progress_above * flamer_span_above), 0, frame_count_above - 1);
  }
  /// @type {Real}
  var vfx_angle_above = tower_attack_vfx_angle + tower_attack_vfx_angle_offset;
  /// @type {Real}
  var vfx_x_above = vfx_anchor_x + lengthdir_x(tower_attack_vfx_distance, vfx_angle_above);
  /// @type {Real}
  var vfx_y_above = vfx_anchor_y + lengthdir_y(tower_attack_vfx_distance, vfx_angle_above);
  draw_sprite_ext(tower_attack_vfx_sprite, frame_index_above, vfx_x_above, vfx_y_above, tower_attack_vfx_scale, tower_attack_vfx_scale, vfx_angle_above, c_white, 1);
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
  draw_circle(x + draw_offset_x, y + draw_offset_y, shine_radius, false);

  draw_set_alpha(shine_alpha * 0.75);
  draw_set_colour(c_yellow);
  draw_line(
    x + draw_offset_x + lengthdir_x(shine_radius * 0.9, spin),
    y + draw_offset_y + lengthdir_y(shine_radius * 0.9, spin),
    x + draw_offset_x + lengthdir_x(shine_radius * 0.9, spin + 180),
    y + draw_offset_y + lengthdir_y(shine_radius * 0.9, spin + 180)
  );
  draw_line(
    x + draw_offset_x + lengthdir_x(shine_radius * 0.65, spin + 90),
    y + draw_offset_y + lengthdir_y(shine_radius * 0.65, spin + 90),
    x + draw_offset_x + lengthdir_x(shine_radius * 0.65, spin + 270),
    y + draw_offset_y + lengthdir_y(shine_radius * 0.65, spin + 270)
  );

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

