/// @description Draws a subtle pulse and expiry flash to communicate pickup urgency.

/// @type {Real}
var height_above_ground = max(0, coin_ground_y - y);
/// @type {Real}
var shadow_t = clamp(height_above_ground / 92, 0, 1);
/// @type {Real}
var shadow_alpha = lerp(0.34, 0.09, power(shadow_t, 1.08));
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
/// @type {Real}
var shadow_colour = make_color_rgb(48, 54, 58);

draw_set_alpha(max(0.05, shadow_alpha));
draw_set_colour(shadow_colour);
draw_ellipse(
  shadow_center_x - shadow_radius_x,
  shadow_center_y - shadow_radius_y,
  shadow_center_x + shadow_radius_x,
  shadow_center_y + shadow_radius_y,
  false
);

// Contact core makes the coin feel grounded when it is near the floor.
draw_set_alpha(0.12 * power(max(0, contact_shadow_t), 1.5));
draw_ellipse(
  shadow_center_x - (shadow_radius_x * 0.48),
  shadow_center_y - (shadow_radius_y * 0.56),
  shadow_center_x + (shadow_radius_x * 0.48),
  shadow_center_y + (shadow_radius_y * 0.56),
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
  /// @type {Real}
  var collect_spin_width = max(coin_spin_min_width, abs(cos(coin_spin_phase)));

  draw_sprite_ext(
    sprite_index,
    0,
    draw_collect_x,
    draw_collect_y,
    collect_scale * collect_spin_width,
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
/// @type {Real}
var spin_cos = cos(coin_spin_phase);
/// @type {Real}
var spin_width = max(coin_spin_min_width, abs(spin_cos));
/// @type {Real}
var spin_side_tint = (spin_cos >= 0) ? c_white : make_color_rgb(214, 182, 116);
/// @type {Real}
var edge_glint_alpha = power(1 - clamp(spin_width / max(0.001, coin_spin_min_width * 1.9), 0, 1), 1.9) * 0.58;

draw_sprite_ext(
  sprite_index,
  0,
  x,
  y,
  pulse * spin_width,
  pulse,
  0,
  spin_side_tint,
  expiry_alpha
);

if (edge_glint_alpha > 0.01) {
  draw_set_alpha(edge_glint_alpha * expiry_alpha);
  draw_set_colour(make_color_rgb(255, 243, 201));
  draw_rectangle(
    x - 1,
    y - (7 * pulse),
    x + 1,
    y + (7 * pulse),
    false
  );
  draw_set_alpha(1);
  draw_set_colour(c_white);
}
