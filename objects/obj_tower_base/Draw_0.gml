/// @description Draw tower base with ghosted opacity and hover pulse when placement is valid.

if (occupied) exit;

/// @type {Bool}
var hovered = position_meeting(mouse_x, mouse_y, id);
/// @type {Struct}
var selected_tower_description = scr_get_tower_description(global.selected_tower_type);
/// @type {Bool}
var can_place = !occupied && game_is_running() && (global.player_hp >= selected_tower_description.hp_cost);
/// @type {Bool}
var is_selected_base = global.build_mode && (global.build_base_id == id);
/// @type {Real}
var draw_alpha = 1;
/// @type {Real}
var draw_offset_x = 0;

if (base_failed_build_shake_steps_remaining > 0) {
  /// @type {Real}
  var shake_progress = base_failed_build_shake_steps_remaining / base_failed_build_shake_steps_total;
  /// @type {Real}
  var shake_phase = (1 - shake_progress) * pi * 5;
  /// @type {Real}
  var shake_fade = power(shake_progress, 0.85);
  draw_offset_x = sin(shake_phase) * base_failed_build_shake_strength * shake_fade * base_failed_build_shake_dir;
}

if (!occupied) {
  draw_alpha = 0.52;
}

/// @type {Real}
var proximity_alpha_radius = max(1, TOWER_BASE_PROXIMITY_ALPHA_RADIUS);
/// @type {Real}
var mouse_distance = point_distance(mouse_x, mouse_y, x, y);
/// @type {Real}
var mouse_proximity = clamp(1 - (mouse_distance / proximity_alpha_radius), 0, 1);
/// @type {Real}
var gated_mouse_proximity = clamp((mouse_proximity - 0.2) / 0.8, 0, 1);
/// @type {Real}
var proximity_alpha_boost = power(gated_mouse_proximity, 2.2) * TOWER_BASE_PROXIMITY_ALPHA_BOOST_MAX;

if (!is_selected_base) {
  draw_alpha = clamp(draw_alpha + proximity_alpha_boost, 0, 1);
}

if (hovered && can_place) {
  // Slow pulse between 0.4 and 0.6 alpha to signal valid placement.
  draw_alpha = 0.75 + (sin(current_time * 0.004) * 0.1);
}

if ((hovered && can_place) && !is_selected_base) {
  draw_alpha = clamp(draw_alpha + proximity_alpha_boost, 0, 1);
}

if (is_selected_base) {
  draw_alpha = 1;
}

if (is_selected_base) {
  /// @type {Real}
  var tower_range = max(0, selected_tower_description.range);
  if (tower_range > 0) {
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
    var range_is_aoe = (global.selected_tower_type == 2 || global.selected_tower_type == 3);
    /// @type {Bool}
    var range_is_control = (global.selected_tower_type == 1 || global.selected_tower_type == 4);
    /// @type {Real}
    var range_style = 0;
    /// @type {Colour}
    var range_colour = selected_tower_description.range_colour;

    if (range_is_aoe) {
      range_style = 1;
    } else if (range_is_control) {
      range_style = 2;
    }

    // Draw range ring first so it stays under the base sprite.
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
  }
}

if (sprite_index != -1) {
  draw_sprite_ext(sprite_index, image_index, x + draw_offset_x, y, image_xscale, image_yscale, image_angle, image_blend, draw_alpha);
}

draw_set_colour(c_white);
draw_set_alpha(1);