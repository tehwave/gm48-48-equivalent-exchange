/// @description Draws a subtle pulse and expiry flash to communicate pickup urgency.

/// @type {Real}
var height_above_ground = max(0, coin_ground_y - y);
/// @type {Real}
var shadow_t = clamp(height_above_ground / 92, 0, 1);
/// @type {Real}
var shadow_alpha = lerp(0.54, 0.12, power(shadow_t, 1.08));
/// @type {Real}
var shadow_radius_x = lerp(13.5, 4.2, power(shadow_t, 0.78));
/// @type {Real}
var shadow_radius_y = lerp(5.2, 1.6, power(shadow_t, 0.74));
/// @type {Real}
var shadow_center_x = x + 2;
/// @type {Real}
var shadow_center_y = coin_ground_y + 4;
/// @type {Real}
var contact_shadow_t = 1 - shadow_t;

draw_set_alpha(max(0.09, shadow_alpha));
draw_set_colour(c_black);
draw_ellipse(
  shadow_center_x - shadow_radius_x,
  shadow_center_y - shadow_radius_y,
  shadow_center_x + shadow_radius_x,
  shadow_center_y + shadow_radius_y,
  false
);

// Contact core makes the coin feel grounded when it is near the floor.
draw_set_alpha(0.22 * power(max(0, contact_shadow_t), 1.4));
draw_ellipse(
  shadow_center_x - (shadow_radius_x * 0.56),
  shadow_center_y - (shadow_radius_y * 0.62),
  shadow_center_x + (shadow_radius_x * 0.56),
  shadow_center_y + (shadow_radius_y * 0.62),
  false
);

draw_set_alpha(1);
draw_set_colour(c_white);

if (coin_collected) {
  /// @type {Real}
  var draw_collect_x = coin_collect_draw_x;
  /// @type {Real}
  var draw_collect_y = coin_collect_draw_y;

  /// @type {Real}
  var collect_t = 1 - (coin_collect_vfx_steps / max(1, coin_collect_vfx_total_steps));
  /// @type {Real}
  var burst_alpha = 1 - collect_t;
  /// @type {Real}
  var collect_scale = 1 + (0.28 * (1 - collect_t));

  draw_sprite_ext(
    sprite_index,
    image_index,
    draw_collect_x,
    draw_collect_y,
    collect_scale,
    collect_scale,
    0,
    c_white,
    burst_alpha
  );

  draw_set_alpha(1);
  draw_set_colour(c_white);
  exit;
}

/// @type {Real}
var expiry_alpha = 1;
if (coin_life_steps <= COIN_DROP_EXPIRE_FLASH_STEPS) {
  /// @type {Real}
  var expiry_t = clamp(1 - (coin_life_steps / max(1, COIN_DROP_EXPIRE_FLASH_STEPS)), 0, 1);
  /// @type {Real}
  var flash_frequency = lerp(0.02, 0.11, expiry_t);
  /// @type {Real}
  var flash_wave = abs(sin(current_time * flash_frequency));
  expiry_alpha = lerp(1, 0.18 + (0.82 * flash_wave), expiry_t);
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
  0,
  c_white,
  expiry_alpha
);
