/// @description Release runtime surfaces on room teardown.

if (variable_global_exists("panel_blur_surface_a") && surface_exists(global.panel_blur_surface_a)) {
	surface_free(global.panel_blur_surface_a);
}

if (variable_global_exists("panel_blur_surface_b") && surface_exists(global.panel_blur_surface_b)) {
	surface_free(global.panel_blur_surface_b);
}

global.panel_blur_surface_a = -1;
global.panel_blur_surface_b = -1;
global.panel_blur_surface_w = 0;
global.panel_blur_surface_h = 0;

game_decals_shutdown();
