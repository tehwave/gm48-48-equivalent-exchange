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

if (!occupied) {
  draw_alpha = 0.5;
}

if (hovered && can_place) {
  // Slow pulse between 0.4 and 0.6 alpha to signal valid placement.
  draw_alpha = 0.75 + (sin(current_time * 0.004) * 0.1);
}

if (is_selected_base) {
  draw_alpha = 1;
}

if (is_selected_base) {
  /// @type {Real}
  var tower_phase_seed = (x * 0.013) + (y * 0.017);

  /// @type {Real}
  var tower_range = max(0, selected_tower_description.range);
  if (tower_range > 0) {
    /// @type {Real}
    var pulse_time = (current_time * 0.006) + (tower_phase_seed * 0.07);
    /// @type {Real}
    var pulse_wave = (sin(pulse_time) + 1) * 0.5;
    /// @type {Real}
    var aura_alpha = 0.12 + (pulse_wave * 0.08);
    /// @type {Real}
    var ring_alpha = 0.24 + (pulse_wave * 0.12);
    /// @type {Real}
    var ring_radius = tower_range + (pulse_wave * 2);
    /// @type {Real}
    var ring_thickness = max(2, ring_radius * 0.2);
    /// @type {Real}
    var ring_start = max(1, ring_radius - (ring_thickness * 0.5));
    /// @type {Real}
    var ring_end = ring_radius + (ring_thickness * 0.5);

    // Draw range ring first so it stays under the base sprite.
    draw_set_colour(c_ltgray);
    draw_set_alpha(aura_alpha);
    for (var ring_step = ring_start; ring_step <= ring_end; ring_step += 1) {
      draw_circle(x, y, ring_step, true);
    }

    draw_set_alpha(ring_alpha);
    draw_set_colour(c_white);
    for (var ring_highlight_step = ring_start; ring_highlight_step <= ring_end; ring_highlight_step += 1) {
      draw_circle(x, y, ring_highlight_step - 1, true);
    }
  }
}

if (sprite_index != -1) {
  draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, draw_alpha);
}

draw_set_colour(c_white);
draw_set_alpha(1);