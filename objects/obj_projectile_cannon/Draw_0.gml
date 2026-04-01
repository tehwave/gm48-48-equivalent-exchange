/// @description Draw projectile sprite and a tiny outline for contrast.

if (sprite_index != -1) {
	draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
}

draw_set_colour(c_orange);
draw_circle(x, y, 4, false);