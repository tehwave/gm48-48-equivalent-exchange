/// @description Draws a subtle pulse and expiry flash to communicate pickup urgency.

/// @type {Real}
var height_above_ground = max(0, coin_ground_y - y);
/// @type {Real}
var shadow_t = clamp(height_above_ground / 36, 0, 1);
/// @type {Real}
var shadow_alpha = 0.28 - (0.14 * shadow_t);
/// @type {Real}
var shadow_radius_x = 11 - (4 * shadow_t);
/// @type {Real}
var shadow_radius_y = 4 - (1.5 * shadow_t);

draw_set_alpha(max(0.08, shadow_alpha));
draw_set_colour(c_black);
draw_ellipse(
  x - shadow_radius_x,
  coin_ground_y + 2 - shadow_radius_y,
  x + shadow_radius_x,
  coin_ground_y + 2 + shadow_radius_y,
  false
);
draw_set_alpha(1);
draw_set_colour(c_white);

if (coin_collected) {
  /// @type {Real}
  var collect_t = 1 - (coin_collect_vfx_steps / max(1, coin_collect_vfx_total_steps));
  /// @type {Real}
  var burst_alpha = 1 - collect_t;
  /// @type {Real}
  var ring_radius = 10 + (22 * collect_t);
  /// @type {Real}
  var collect_scale = 1 + (0.4 * collect_t);

  draw_sprite_ext(
    sprite_index,
    image_index,
    x,
    y,
    collect_scale,
    collect_scale,
    image_angle,
    c_yellow,
    burst_alpha
  );

  draw_set_alpha(burst_alpha);
  draw_set_colour(c_yellow);
  draw_circle(x, y, ring_radius, true);
  draw_set_alpha(burst_alpha * 0.8);
  draw_set_colour(c_white);
  draw_circle(x, y, ring_radius * 0.55, true);

  draw_set_alpha(burst_alpha);
  draw_set_halign(fa_center);
  draw_set_valign(fa_middle);
  draw_set_colour(c_lime);
  /// @type {Real}
  var text_scale = 1.8 + (0.35 * collect_t);
  draw_text_transformed(
    x,
    y - 28,
    "+" + string(coin_value),
    text_scale,
    text_scale,
    0
  );

  draw_set_alpha(1);
  draw_set_colour(c_white);
  exit;
}

/// @type {Real}
var expiry_alpha = 1;
if (coin_life_steps <= COIN_DROP_EXPIRE_FLASH_STEPS) {
  expiry_alpha = 0.45 + (0.55 * abs(sin(current_time * 0.02)));
}

/// @type {Real}
var pulse = 1 + (COIN_DROP_PULSE_AMOUNT * sin((current_time * 0.016) + (x * 0.08)));

draw_sprite_ext(
  sprite_index,
  image_index,
  x,
  y,
  pulse,
  pulse,
  image_angle,
  c_white,
  expiry_alpha
);
