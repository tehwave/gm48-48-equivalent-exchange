/// @description Draw tower base with ghosted opacity and hover pulse when placement is valid.

if (!variable_instance_exists(id, "occupied")) {
  occupied = false;
}

if (!variable_instance_exists(id, "tower_instance_id")) {
  tower_instance_id = noone;
}

if (!variable_instance_exists(id, "base_failed_build_shake_steps_total")) {
  base_failed_build_shake_steps_total = max(3, round(room_speed * 0.28));
}

if (!variable_instance_exists(id, "base_failed_build_shake_steps_remaining")) {
  base_failed_build_shake_steps_remaining = 0;
}

if (!variable_instance_exists(id, "base_failed_build_shake_strength")) {
  base_failed_build_shake_strength = 6;
}

if (!variable_instance_exists(id, "base_failed_build_shake_dir")) {
  base_failed_build_shake_dir = 1;
}

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
/// @type {Real}
var base_flash_overlay_alpha = 0;

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
  var base_phase_seed = (x * 0.013) + (y * 0.017);
  /// @type {Real}
  var base_select_time = (current_time * 0.012) + (base_phase_seed * 0.11);
  /// @type {Real}
  var base_select_wave = (sin(base_select_time) + 1) * 0.5;
  /// @type {Real}
  var base_select_radius = 20 + (base_select_wave * 4);
  /// @type {Real}
  var base_select_alpha = 0.56 + (base_select_wave * 0.34);

  // Mirror selected tower pulse so selected bases read consistently.
  draw_set_colour(c_yellow);
  draw_set_alpha(base_select_alpha * 0.42);
  draw_circle(x + draw_offset_x, y + 12, base_select_radius, true);

  gpu_set_blendmode(bm_add);
  draw_set_alpha(base_select_alpha * 0.72);
  draw_circle(x + draw_offset_x, y + 12, base_select_radius + 1, false);

  draw_set_colour(c_white);
  draw_set_alpha(base_select_alpha * 0.75);
  draw_circle(x + draw_offset_x, y + 12, base_select_radius - 2, false);

  base_flash_overlay_alpha = 0.22 + (base_select_wave * 0.48);

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_colour(c_white);

  /// @type {Real}
  var tower_range = max(0, selected_tower_description.range);
  if (tower_range > 0) {
    /// @type {Asset.GMObject|Real}
    var selected_tower_object = scr_get_selected_tower_object();
    /// @type {Real}
    var range_style = scr_get_tower_range_indicator_style(selected_tower_object);
    // Draw range ring first so it stays under the base sprite.
    scr_draw_tower_range_indicator(x, y, tower_range, range_style, selected_tower_description.range_colour, false);
  }
}

if (sprite_index != -1) {
  draw_sprite_ext(sprite_index, image_index, x + draw_offset_x, y, image_xscale, image_yscale, image_angle, image_blend, draw_alpha);
  if (base_flash_overlay_alpha > 0) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x + draw_offset_x, y, image_xscale, image_yscale, image_angle, c_yellow, base_flash_overlay_alpha);
    gpu_set_blendmode(bm_normal);
  }
} else {
  /// @type {Real}
  var fallback_x = x + draw_offset_x;
  /// @type {Real}
  var fallback_outer_radius = 22;
  /// @type {Real}
  var fallback_inner_radius = 15;

  // Fallback marker so bases remain visible when no sprite is bound.
  draw_set_alpha(draw_alpha * 0.28);
  draw_set_colour(c_black);
  draw_circle(fallback_x, y, fallback_outer_radius, false);

  draw_set_alpha(draw_alpha * 0.7);
  draw_set_colour(c_white);
  draw_circle(fallback_x, y, fallback_inner_radius, false);
}

draw_set_colour(c_white);
draw_set_alpha(1);