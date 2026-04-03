/// @description Draw enemy sprite and HP bar overlay.

/// @type {Real}
var draw_x = x + enemy_spawn_offset_x;
/// @type {Real}
var draw_y = y + enemy_spawn_offset_y;

if (is_dead) {
	/// @type {Real}
	var death_progress = 1 - (enemy_death_vfx_timer / max(1, enemy_death_vfx_total_steps));
	/// @type {Real}
	var burst_radius = 4 + (death_progress * 18);
	/// @type {Real}
	var core_radius = max(1, 7 - (death_progress * 6));

	draw_set_alpha(1 - death_progress);
	if (global.debug_mode) {
		draw_set_colour(c_orange);
		draw_circle(draw_x, draw_y - 2, burst_radius, true);
		draw_set_colour(c_yellow);
		draw_circle(draw_x, draw_y - 2, core_radius, false);
	}
	draw_set_alpha(1);
	exit;
}

/// Basic ground blob shadow for readability.
/// @type {Real}
var shadow_wide_width_scale = (
	object_index == obj_enemy_boss ||
	sprite_index == spr_spider_blue ||
	sprite_index == spr_spider_green ||
	sprite_index == spr_spider_purple
) ? 1.75 : 1;
/// @type {Real}
var shadow_wide_height_scale = (
	object_index == obj_enemy_boss ||
	sprite_index == spr_spider_blue ||
	sprite_index == spr_spider_green ||
	sprite_index == spr_spider_purple
) ? 1.45 : 1;
/// @type {Real}
var shadow_phase = (current_time * 0.018) + (draw_x * 0.06) + (draw_y * 0.04);
/// @type {Real}
var shadow_radius_x = (enemy_draw_radius * 1.5 * shadow_wide_width_scale) + (1.26 * sin(shadow_phase));
/// @type {Real}
var shadow_radius_y = (enemy_draw_radius * 0.45 * shadow_wide_height_scale) + (0.2 * sin(shadow_phase));
/// @type {Real}
var shadow_center_x = draw_x + 1;
/// @type {Real}
var shadow_center_y = draw_y + 1;

draw_set_alpha(0.22);
draw_set_colour(make_color_rgb(48, 54, 58));
draw_ellipse(
	shadow_center_x - shadow_radius_x,
	shadow_center_y - shadow_radius_y,
	shadow_center_x + shadow_radius_x,
	shadow_center_y + shadow_radius_y,
	false
);
draw_set_alpha(1);
draw_set_colour(c_white);

if (sprite_index != -1) {
	/// @type {Real}
	var bounce_phase = (current_time * 0.02) + (x * 0.17) + (y * 0.11);
	/// @type {Real}
	var bounce_offset_x = cos(bounce_phase * 0.6) * 1.25;
	/// @type {Real}
	var bounce_scale_y = 1 + (sin(bounce_phase) * 0.06);
	/// @type {Bool}
	var has_slow = enemy_slow_timer_steps > 0;
	/// @type {Bool}
	var has_freeze = enemy_freeze_timer_steps > 0;
	/// @type {Real}
	var slow_tint_strength = clamp(1 - enemy_slow_factor, 0.12, 0.55);
	/// @type {Real}
	var freeze_tint_strength = has_freeze ? 0.65 : 0;
	/// @type {Real}
	var sprite_tint = c_white;

	if (has_slow) {
		/// @type {Real}
		var slow_tint_mix = clamp(slow_tint_strength, 0, 1);
		sprite_tint = merge_colour(c_white, make_colour_rgb(146, 100, 58), slow_tint_mix);
	}

	if (has_freeze) {
		sprite_tint = merge_colour(sprite_tint, make_colour_rgb(110, 190, 255), clamp(freeze_tint_strength, 0, 1));
	}
	/// @type {Real}
	var hit_flash_mix = 0;
	if (enemy_hit_flash_steps_remaining > 0) {
		hit_flash_mix = ENEMY_HIT_FLASH_STRENGTH * (enemy_hit_flash_steps_remaining / max(1, enemy_hit_flash_steps_total));
	}
	hit_flash_mix = clamp(hit_flash_mix, 0, 1);
	/// @type {Real}
	var boss_draw_scale = (object_index == obj_enemy_boss) ? 2 : 1;

	// Draw with a per-instance visual offset while gameplay coordinates stay on-path.
	draw_sprite_ext(
		sprite_index,
		image_index,
		draw_x + bounce_offset_x,
		draw_y,
		image_xscale * boss_draw_scale,
		image_yscale * bounce_scale_y * boss_draw_scale,
		image_angle,
		sprite_tint,
		image_alpha
	);

	if (hit_flash_mix > 0) {
		gpu_set_blendmode(bm_add);
		draw_set_alpha(hit_flash_mix * 0.7);
		draw_sprite_ext(
			sprite_index,
			image_index,
			draw_x + bounce_offset_x,
			draw_y,
			image_xscale * boss_draw_scale,
			image_yscale * bounce_scale_y * boss_draw_scale,
			image_angle,
			c_white,
			image_alpha
		);
		draw_set_alpha(1);
		gpu_set_blendmode(bm_normal);
	}
}

if (enemy_burn_timer_steps > 0) {
	/// @type {Real}
	var burn_pulse = 0.75 + (0.25 * sin(current_time * 0.03 + (x * 0.08)));
	/// @type {Real}
	var burn_radius = enemy_draw_radius + (5 * burn_pulse);

	draw_set_alpha(0.35);
	draw_set_colour(c_orange);
	if (global.debug_mode) {
		draw_circle(draw_x, draw_y - 2, burn_radius, false);
	}
	draw_set_alpha(1);
}

if (enemy_slow_timer_steps > 0) {
	/// @type {Real}
	var slow_intensity = clamp(1 - enemy_slow_factor, 0.05, 0.6);
	/// @type {Real}
	// Use position-based phase seed for deterministic sparkle motion without relying on runtime instance ids.
	var slow_phase = (current_time * 0.018) + (draw_x * 0.061) + (draw_y * 0.047);
	/// @type {Real}
	var slow_ring_radius = enemy_draw_radius + 3 + (2.5 * (0.5 + (0.5 * sin(slow_phase))));
	/// @type {Real}
	var slow_alpha = 0.20 + (0.40 * slow_intensity);

	gpu_set_blendmode(bm_add);
	draw_set_alpha(slow_alpha);
	draw_set_colour(make_colour_rgb(184, 122, 70));
	if (global.debug_mode) {
		draw_circle(draw_x, draw_y - 2, slow_ring_radius, false);
	}

	/// @type {Real}
	var sparkle_orbit_radius = enemy_draw_radius + 5;
	/// @type {Real}
	var sparkle_angle_a = slow_phase * 110;
	/// @type {Real}
	var sparkle_angle_b = sparkle_angle_a + 180;

	draw_point(
		draw_x + lengthdir_x(sparkle_orbit_radius, sparkle_angle_a),
		draw_y - 2 + lengthdir_y(sparkle_orbit_radius, sparkle_angle_a)
	);
	draw_point(
		draw_x + lengthdir_x(sparkle_orbit_radius, sparkle_angle_b),
		draw_y - 2 + lengthdir_y(sparkle_orbit_radius, sparkle_angle_b)
	);

	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1);
}

if (enemy_freeze_timer_steps > 0) {
	/// @type {Real}
	var freeze_phase = (current_time * 0.025) + (draw_x * 0.053) + (draw_y * 0.041);
	/// @type {Real}
	var freeze_ring_radius = enemy_draw_radius + 5 + (1.5 * sin(freeze_phase));
	/// @type {Real}
	var freeze_alpha = 0.22 + (0.10 * sin(freeze_phase * 1.8));

	gpu_set_blendmode(bm_add);
	draw_set_alpha(freeze_alpha);
	draw_set_colour(c_blue);
	if (global.debug_mode) {
		draw_circle(draw_x, draw_y - 2, freeze_ring_radius, false);
	}
	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1);
}

/// @type {Real}
var hp_ratio = clamp(enemy_hp / max(1, enemy_hp_max), 0, 1);

draw_set_colour(c_black);
draw_rectangle(draw_x - 12, draw_y - enemy_draw_radius - 10, draw_x + 12, draw_y - enemy_draw_radius - 6, false);
draw_set_colour(c_lime);
draw_rectangle(draw_x - 12, draw_y - enemy_draw_radius - 10, draw_x - 12 + (24 * hp_ratio), draw_y - enemy_draw_radius - 6, false);

if (global.debug_mode) {
	// Debug anchor: this cross is the exact instance x/y used by path movement.
	draw_set_colour(c_fuchsia);
	draw_line(x - 2, y, x + 2, y);
	draw_line(x, y - 2, x, y + 2);
	draw_point(x, y);
}