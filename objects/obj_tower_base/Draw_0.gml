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
  draw_alpha = 0.88;
}

if (sprite_index != -1) {
  draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, draw_alpha);
}

if (is_selected_base) {
  /// @type {Real}
  var tower_phase_seed = (x * 0.013) + (y * 0.017);
  /// @type {Real}
  var select_time = (current_time * 0.018) + (tower_phase_seed * 0.17);
  /// @type {Real}
  var select_wave = (sin(select_time) + 1) * 0.5;
  /// @type {Real}
  var select_radius = 20 + (select_wave * 4);
  /// @type {Real}
  var select_alpha = 0.56 + (select_wave * 0.34);

  // Match selected tower marker style for uniform readability.
  draw_set_colour(c_yellow);
  draw_set_alpha(select_alpha * 0.42);
  draw_circle(x, y + 12, select_radius, true);

  gpu_set_blendmode(bm_add);
  draw_set_alpha(select_alpha * 0.72);
  draw_circle(x, y + 12, select_radius + 1, false);

  draw_set_colour(c_white);
  draw_set_alpha(select_alpha * 0.75);
  draw_circle(x, y + 12, select_radius - 2, false);

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

    draw_set_colour(c_ltgray);
    draw_set_alpha(aura_alpha * 0.5);
    draw_circle(x, y, ring_radius, true);

    draw_set_alpha(aura_alpha);
    draw_circle(x, y, ring_radius, false);

    draw_set_alpha(ring_alpha);
    draw_set_colour(c_white);
    draw_circle(x, y, ring_radius - 1, false);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_colour(c_white);
  draw_set_alpha(1);
}