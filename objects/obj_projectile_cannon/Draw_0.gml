/// @description Draw projectile sprite and a tiny outline for contrast.

if (sprite_index != -1) {
	var draw_x = x;
	var draw_y = y;

	if (proj_has_impacted) {
		var origin_center_offset_x = (sprite_get_width(sprite_index) * 0.5 - sprite_get_xoffset(sprite_index)) * image_xscale;
		var origin_center_offset_y = (sprite_get_height(sprite_index) * 0.5 - sprite_get_yoffset(sprite_index)) * image_yscale;
		draw_x += origin_center_offset_x;
		draw_y += origin_center_offset_y;
	}

	draw_sprite_ext(sprite_index, image_index, draw_x, draw_y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
}

if (!proj_has_impacted) {
	draw_set_colour(c_orange);
	draw_circle(x, y, 4, false);
}