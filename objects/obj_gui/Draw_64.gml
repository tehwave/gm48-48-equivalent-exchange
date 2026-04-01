/// @description Draws essential HUD and end-state overlays.

/// @type {Real}
var gui_width = display_get_gui_width();
/// @type {Real}
var hud_x = gui_width - 16;
/// @type {Real}
var hud_y = 16;
/// @type {Real}
var line_height = 24;
/// @type {Real}
var panel_width = 420;
/// @type {Real}
var panel_height = 178;

draw_set_halign(fa_right);
draw_set_valign(fa_top);

// Contrast panel for readability over bright backgrounds.
draw_set_alpha(0.55);
draw_set_colour(c_black);
draw_rectangle(hud_x - panel_width, hud_y - 8, hud_x + 8, hud_y + panel_height, false);
draw_set_alpha(1);
draw_set_colour(c_white);

draw_text(hud_x, hud_y + (line_height * 0), "Life: " + string(global.player_hp));
draw_text(hud_x, hud_y + (line_height * 1), "Coins: " + string(global.player_coins));
draw_text(hud_x, hud_y + (line_height * 2), "Wave: " + string(global.wave_index) + "/" + string(TOTAL_WAVES));
draw_text(hud_x, hud_y + (line_height * 3), "Build: " + scr_get_selected_tower_name() + " [Q/E or 1-5]");
draw_text(hud_x, hud_y + (line_height * 4), "Exchange Cost: " + string(TOWER_PLACEMENT_HP_COST) + " Life");

/// @type {Asset.GMObject|Real}
var selected_tower_object = scr_get_selected_tower_object();
/// @type {Asset.GMSprite|Real}
var selected_tower_sprite = (selected_tower_object != noone) ? object_get_sprite(selected_tower_object) : -1;
if (selected_tower_sprite != -1) {
  /// @type {Real}
  var preview_x = hud_x - panel_width + 42;
  /// @type {Real}
  var preview_y = hud_y + 72;
  /// @type {Real}
  var pulse = 1 + (0.06 * sin(current_time / 120));

  draw_set_alpha(0.85);
  draw_set_colour(c_black);
  draw_rectangle(preview_x - 30, preview_y - 30, preview_x + 30, preview_y + 30, false);
  draw_set_alpha(1);
  draw_set_colour(c_yellow);
  draw_rectangle(preview_x - 30, preview_y - 30, preview_x + 30, preview_y + 30, true);

  draw_sprite_ext(selected_tower_sprite, 0, preview_x, preview_y, pulse, pulse, 0, c_white, 1);
  draw_set_colour(c_white);
}

/// @type {String}
var upgrade_text = "Upgrade: Select tower";
if (instance_exists(global.selected_tower_id)) {
  /// @type {Real}
  var next_level = global.selected_tower_id.tower_level + 1;
  /// @type {Real}
  var cost = scr_tower_upgrade_cost(global.selected_tower_id.object_index, next_level);
  if (cost > 0) {
    upgrade_text = "Upgrade [U]: " + string(cost) + " coins";
  } else {
    upgrade_text = "Upgrade [U]: MAX";
  }
}
draw_text(hud_x, hud_y + (line_height * 5), upgrade_text);

/// @type {String}
var delete_text = "Delete [X]: Select tower";
if (instance_exists(global.selected_tower_id)) {
  delete_text = "Delete [X]: +" + string(TOWER_PLACEMENT_HP_COST) + " Life only (no coins)";
}
draw_text(hud_x, hud_y + (line_height * 6), delete_text);

if (global.boss_banner_timer_steps > 0) {
  /// @type {Real}
  var boss_center_x = display_get_gui_width() * 0.5;
  /// @type {Real}
  var boss_center_y = display_get_gui_height() * 0.5;
  /// @type {Real}
  var boss_pulse = 1 + (0.08 * sin(current_time / 90));

  draw_set_alpha(0.6);
  draw_set_colour(c_black);
  draw_rectangle(0, boss_center_y - 74, display_get_gui_width(), boss_center_y + 74, false);
  draw_set_alpha(1);

  draw_set_halign(fa_center);
  draw_set_valign(fa_middle);
  draw_set_colour(c_black);
  draw_text_transformed(boss_center_x + 4, boss_center_y + 4, "BOSS WAVE", boss_pulse * 1.6, boss_pulse * 1.6, 0);
  draw_set_colour(c_orange);
  draw_text_transformed(boss_center_x, boss_center_y, "BOSS WAVE", boss_pulse * 1.6, boss_pulse * 1.6, 0);
}

if (global.game_state == GAME_STATE_INTRO) {
  /// @type {Real}
  var intro_gui_width = display_get_gui_width();
  /// @type {Real}
  var intro_gui_height = display_get_gui_height();
  /// @type {Real}
  var intro_center_x = intro_gui_width * 0.5;
  /// @type {Real}
  var intro_center_y = intro_gui_height * 0.5;
  /// @type {Real}
  var intro_seconds_remaining = ceil(global.intro_lock_timer_steps / room_speed);
  /// @type {String}
  var continue_prompt = "Press SPACE to begin";

  if (global.intro_lock_timer_steps > 0) {
    continue_prompt = "Press SPACE in " + string(intro_seconds_remaining) + "s";
  }

  draw_set_alpha(0.72);
  draw_set_colour(c_black);
  draw_rectangle(0, 0, intro_gui_width, intro_gui_height, false);
  draw_set_alpha(1);

  draw_set_halign(fa_center);
  draw_set_valign(fa_middle);
  draw_set_colour(c_white);
  draw_text(
    intro_center_x,
    intro_center_y - 110,
    "EQUIVALENT EXCHANGE"
  );

  draw_set_colour(c_yellow);
  draw_text(
    intro_center_x,
    intro_center_y - 24,
    "Life is your currency.\nSpend Life to place towers."
  );

  draw_set_colour(c_aqua);
  draw_text(
    intro_center_x,
    intro_center_y + 48,
    "Leaks also cost Life.\nKills grant Coins for upgrades (U).\nDelete selected tower with X for Life only (no coins)."
  );

  draw_set_colour(c_white);
  draw_text(intro_center_x, intro_center_y + 118, continue_prompt);
}

if (global.game_state == GAME_STATE_GAME_OVER) {
  /// @type {Real}
  var end_time_ms = (global.run_end_time_ms >= 0) ? global.run_end_time_ms : current_time;
  /// @type {Real}
  var elapsed_seconds = max(0, floor((end_time_ms - global.run_start_time_ms) / 1000));
  /// @type {Real}
  var elapsed_minutes = floor(elapsed_seconds / 60);
  /// @type {Real}
  var elapsed_remainder_seconds = elapsed_seconds mod 60;
  /// @type {String}
  var run_time_text = string(elapsed_minutes) + ":" + string_format(elapsed_remainder_seconds, 2, 0);
  /// @type {Real}
  var end_center_x = display_get_gui_width() * 0.5;
  /// @type {Real}
  var end_center_y = display_get_gui_height() * 0.5;
  /// @type {Real}
  var end_panel_width = 520;
  /// @type {Real}
  var end_panel_height = 360;

  draw_set_alpha(0.72);
  draw_set_colour(c_black);
  draw_rectangle(
    end_center_x - (end_panel_width * 0.5),
    end_center_y - (end_panel_height * 0.5),
    end_center_x + (end_panel_width * 0.5),
    end_center_y + (end_panel_height * 0.5),
    false
  );

  draw_set_alpha(1);
  draw_set_colour(c_red);
  draw_rectangle(
    end_center_x - (end_panel_width * 0.5),
    end_center_y - (end_panel_height * 0.5),
    end_center_x + (end_panel_width * 0.5),
    end_center_y + (end_panel_height * 0.5),
    true
  );

  draw_set_halign(fa_center);
  draw_set_valign(fa_top);
  draw_set_colour(c_red);
  draw_text(end_center_x, end_center_y - 142, "GAME OVER");

  draw_set_colour(c_white);
  draw_text(
    end_center_x,
    end_center_y - 104,
    "The exchange failed.\n\nWave Reached: " + string(global.wave_index) + "/" + string(TOTAL_WAVES) +
    "\nLife Left: " + string(global.player_hp) +
    "\nCoins Left: " + string(global.player_coins) +
    "\nRun Time: " + run_time_text
  );

  draw_set_colour(c_yellow);
  draw_text(end_center_x, end_center_y + 126, "Press R to restart");
}

if (global.game_state == GAME_STATE_VICTORY) {
  /// @type {Real}
  var victory_end_time_ms = (global.run_end_time_ms >= 0) ? global.run_end_time_ms : current_time;
  /// @type {Real}
  var victory_elapsed_seconds = max(0, floor((victory_end_time_ms - global.run_start_time_ms) / 1000));
  /// @type {Real}
  var victory_elapsed_minutes = floor(victory_elapsed_seconds / 60);
  /// @type {Real}
  var victory_elapsed_remainder_seconds = victory_elapsed_seconds mod 60;
  /// @type {String}
  var victory_run_time_text = string(victory_elapsed_minutes) + ":" + string_format(victory_elapsed_remainder_seconds, 2, 0);
  /// @type {Real}
  var victory_center_x = display_get_gui_width() * 0.5;
  /// @type {Real}
  var victory_center_y = display_get_gui_height() * 0.5;
  /// @type {Real}
  var victory_panel_width = 520;
  /// @type {Real}
  var victory_panel_height = 360;

  draw_set_alpha(0.72);
  draw_set_colour(c_black);
  draw_rectangle(
    victory_center_x - (victory_panel_width * 0.5),
    victory_center_y - (victory_panel_height * 0.5),
    victory_center_x + (victory_panel_width * 0.5),
    victory_center_y + (victory_panel_height * 0.5),
    false
  );

  draw_set_alpha(1);
  draw_set_colour(c_lime);
  draw_rectangle(
    victory_center_x - (victory_panel_width * 0.5),
    victory_center_y - (victory_panel_height * 0.5),
    victory_center_x + (victory_panel_width * 0.5),
    victory_center_y + (victory_panel_height * 0.5),
    true
  );

  draw_set_halign(fa_center);
  draw_set_valign(fa_top);
  draw_set_colour(c_lime);
  draw_text(victory_center_x, victory_center_y - 142, "VICTORY");

  draw_set_colour(c_white);
  draw_text(
    victory_center_x,
    victory_center_y - 104,
    "The balance is settled.\n\nWaves Cleared: " + string(TOTAL_WAVES) + "/" + string(TOTAL_WAVES) +
    "\nLife Left: " + string(global.player_hp) +
    "\nCoins Left: " + string(global.player_coins) +
    "\nRun Time: " + victory_run_time_text
  );

  draw_set_colour(c_yellow);
  draw_text(victory_center_x, victory_center_y + 126, "Press R to restart");
}