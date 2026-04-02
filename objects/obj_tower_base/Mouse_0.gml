/// @description Enter build mode on empty base or select existing tower.

if (!game_is_running()) exit;

if (occupied) {
  if (instance_exists(tower_instance_id)) {
    global.build_mode = false;
    global.build_base_id = noone;
    global.selected_tower_id = tower_instance_id;
  }
  exit;
}

global.build_mode = true;
global.build_base_id = id;
global.selected_tower_id = noone;
global.confirm_action = "";
global.confirm_timer_steps = 0;