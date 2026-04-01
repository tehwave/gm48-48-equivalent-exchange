/// @description Draw tower base with ghosted opacity and hover pulse when placement is valid.

if (occupied) exit;

/// @type {Bool}
var hovered = position_meeting(mouse_x, mouse_y, id);
/// @type {Bool}
var can_place = !occupied && game_is_running() && (global.player_hp >= TOWER_PLACEMENT_HP_COST);
/// @type {Real}
var draw_alpha = 1;

if (!occupied) {
  draw_alpha = 0.5;
}

if (hovered && can_place) {
  // Slow pulse between 0.4 and 0.6 alpha to signal valid placement.
  draw_alpha = 0.75 + (sin(current_time * 0.004) * 0.1);
}

if (sprite_index != -1) {
  draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, draw_alpha);
}