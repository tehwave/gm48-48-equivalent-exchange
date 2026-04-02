/// @description Upgrade hook (User Event 0): spends coins and reapplies level stats.

if (!game_is_running()) exit;
if (tower_level >= TOWER_MAX_LEVEL) exit;

/// @type {Real}
var target_level = tower_level + 1;
/// @type {Real}
var upgrade_cost = scr_tower_upgrade_cost(object_index, target_level);

if (!game_try_spend_coins(upgrade_cost, x, y)) exit;

tower_level = target_level;
scr_tower_apply_level_stats(id, object_index, tower_level);

tower_scale_target = tower_base_scale + ((tower_level - 1) * 0.09);
tower_scale_current = tower_scale_target + 0.17;
tower_upgrade_shine_steps_remaining = tower_upgrade_shine_steps_total;
audio_play_variation(WAV_Otter_Squeak_1, WAV_Otter_Squeak_2, AUDIO_GAIN_UI, 0.95, 1.05);