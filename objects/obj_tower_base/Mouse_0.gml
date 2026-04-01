/// @description Place tower on click (costs 1 HP) or select existing tower.

if (!game_is_running()) exit;

if (occupied) {
  if (instance_exists(tower_instance_id)) {
    global.selected_tower_id = tower_instance_id;
  }
  exit;
}

/// @type {Asset.GMObject|Real}
var tower_object = scr_get_selected_tower_object();
if (tower_object == noone) exit;

if (!game_try_spend_hp(TOWER_PLACEMENT_HP_COST)) {
  audio_play_variation(WAV_Snake_Hiss_1, WAV_Snake_Hiss_2, AUDIO_GAIN_UI * 0.42, 0.95, 1.05);
  exit;
}

tower_instance_id = instance_create_layer(x, y, "Instances", tower_object, {
  base_owner_id : id
});

occupied = true;
global.selected_tower_id = tower_instance_id;
audio_play_variation(WAV_Small_Spark_1, WAV_Small_Spark_2, AUDIO_GAIN_UI, 0.97, 1.06);