/// @description Draw world decals between map layers and live entities.

if (!game_is_running()) {
  game_decals_draw();
  exit;
}

game_decals_draw();
