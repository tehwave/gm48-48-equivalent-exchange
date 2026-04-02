/// @description Draws essential HUD and end-state overlays.

/// @type {Real}
var gui_width = display_get_gui_width();
/// @type {Real}
var gui_height = display_get_gui_height();

draw_set_halign(fa_left);
draw_set_valign(fa_top);

/// @type {Real}
var top_left_x = 16;
/// @type {Real}
var top_left_y = 16;
/// @type {Real}
var top_left_width = 318;
/// @type {Real}
var top_left_height = 86;

scr_draw_rounded_panel(top_left_x, top_left_y, top_left_width, top_left_height, 0.58, 14);

draw_set_colour(c_white);
draw_text(top_left_x + 14, top_left_y + 10, "Wave " + string(global.wave_index) + "/" + string(TOTAL_WAVES));

/// @type {String}
var enemies_text = "Enemies: " + string(global.enemies_alive);
draw_set_colour(c_ltgray);
draw_text(top_left_x + 14, top_left_y + 40, enemies_text);

if (global.wave_index > 0 && scr_wave_is_boss(global.wave_index)) {
  draw_set_colour(c_orange);
  draw_text(top_left_x + top_left_width - 120, top_left_y + 10, "BOSS WAVE");
}

/// @type {Real}
var top_right_width = 224;
/// @type {Real}
var top_right_height = 82;
/// @type {Real}
var top_right_x = gui_width - top_right_width - 16;
/// @type {Real}
var top_right_y = 16;

scr_draw_rounded_panel(top_right_x, top_right_y, top_right_width, top_right_height, 0.58, 14);

draw_set_colour(c_red);
draw_text(top_right_x + 14, top_right_y + 10, "Life: " + string(global.player_hp));
draw_set_colour(c_yellow);
draw_text(top_right_x + 14, top_right_y + 42, "Coins: " + string(global.player_coins));

if (game_is_running() && !global.build_mode && !instance_exists(global.selected_tower_id)) {
  scr_draw_rounded_panel(top_right_x, top_right_y + top_right_height + 10, top_right_width, 40, 0.48, 12);
  draw_set_colour(c_ltgray);
  draw_text(top_right_x + 14, top_right_y + top_right_height + 20, "Click a base to build");
}

if (global.build_mode && instance_exists(global.build_base_id)) {
  /// @type {Real}
  var camera_id = view_camera[0];
  /// @type {Real}
  var view_x = (camera_id != -1) ? camera_get_view_x(camera_id) : 0;
  /// @type {Real}
  var view_y = (camera_id != -1) ? camera_get_view_y(camera_id) : 0;
  /// @type {Real}
  var base_gui_x = global.build_base_id.x - view_x;
  /// @type {Real}
  var base_gui_y = global.build_base_id.y - view_y;

  /// @type {Real}
  var build_panel_width = 420;
  /// @type {Real}
  var build_panel_height = 260;
  /// @type {Real}
  var build_panel_x = clamp(base_gui_x + 22, 10, gui_width - build_panel_width - 10);
  /// @type {Real}
  var build_panel_y = clamp(base_gui_y - 38, 10, gui_height - build_panel_height - 10);

  scr_draw_rounded_panel(build_panel_x, build_panel_y, build_panel_width, build_panel_height, 0.74, 14);

  draw_set_colour(c_white);
  draw_text(build_panel_x + 12, build_panel_y + 10, "Build Tower");
  draw_set_colour(c_ltgray);
  draw_text(build_panel_x + 12, build_panel_y + 34, "Select: Q/E or 1-5");

  for (var tower_index = 0; tower_index < 5; tower_index += 1) {
    /// @type {Struct}
    var tower_description = scr_get_tower_description(tower_index);
    /// @type {Bool}
    var tower_selected = global.selected_tower_type == tower_index;
    /// @type {Real}
    var row_y = build_panel_y + 62 + (tower_index * 36);

    if (tower_selected) {
      scr_draw_rounded_panel(build_panel_x + 8, row_y - 4, build_panel_width - 16, 32, 0.38, 8);
    }

    draw_set_colour(tower_selected ? c_yellow : c_white);
    draw_text(
      build_panel_x + 14,
      row_y,
      "[" + string(tower_index + 1) + "] " + tower_description.name + "  |  " + tower_description.damage_type + "  |  " + string(tower_description.hp_cost) + " Life"
    );

    draw_set_colour(c_ltgray);
    draw_text(build_panel_x + 24, row_y + 16, tower_description.special);
  }

  draw_set_colour(c_aqua);
  draw_text(build_panel_x + 12, build_panel_y + build_panel_height - 28, "Click base or Enter to build  |  RMB / Esc cancel");
}

if (!global.build_mode && instance_exists(global.selected_tower_id)) {
  /// @type {Real}
  var camera_id_selected = view_camera[0];
  /// @type {Real}
  var selected_view_x = (camera_id_selected != -1) ? camera_get_view_x(camera_id_selected) : 0;
  /// @type {Real}
  var selected_view_y = (camera_id_selected != -1) ? camera_get_view_y(camera_id_selected) : 0;
  /// @type {Real}
  var tower_gui_x = global.selected_tower_id.x - selected_view_x;
  /// @type {Real}
  var tower_gui_y = global.selected_tower_id.y - selected_view_y;

  /// @type {Real}
  var selected_panel_width = 320;
  /// @type {Real}
  var selected_panel_height = 190;
  /// @type {Real}
  var selected_panel_x = clamp(tower_gui_x + 22, 10, gui_width - selected_panel_width - 10);
  /// @type {Real}
  var selected_panel_y = clamp(tower_gui_y - 36, 10, gui_height - selected_panel_height - 10);

  scr_draw_rounded_panel(selected_panel_x, selected_panel_y, selected_panel_width, selected_panel_height, 0.74, 14);

  /// @type {Asset.GMObject|Real}
  var flamer_object = asset_get_index("obj_tower_flamer");
  /// @type {Asset.GMObject|Real}
  var freeze_object = asset_get_index("obj_tower_freeze");
  /// @type {Real}
  var selected_tower_type_index = 0;
  if (global.selected_tower_id.object_index == obj_tower_arrow) selected_tower_type_index = 0;
  if (global.selected_tower_id.object_index == obj_tower_slow) selected_tower_type_index = 1;
  if (global.selected_tower_id.object_index == obj_tower_cannon) selected_tower_type_index = 2;
  if (flamer_object != -1 && global.selected_tower_id.object_index == flamer_object) selected_tower_type_index = 3;
  if (freeze_object != -1 && global.selected_tower_id.object_index == freeze_object) selected_tower_type_index = 4;

  /// @type {Struct}
  var selected_description = scr_get_tower_description(selected_tower_type_index);

  draw_set_colour(c_white);
  draw_text(selected_panel_x + 12, selected_panel_y + 10, selected_description.name);

  /// @type {Real}
  var panel_pips_x = selected_panel_x + 16;
  /// @type {Real}
  var panel_pips_y = selected_panel_y + 40;
  for (var panel_pip_index = 1; panel_pip_index <= TOWER_MAX_LEVEL; panel_pip_index += 1) {
    /// @type {Bool}
    var panel_pip_filled = panel_pip_index <= global.selected_tower_id.tower_level;
    draw_set_colour(panel_pip_filled ? c_yellow : c_dkgray);
    draw_set_alpha(panel_pip_filled ? 1 : 0.78);
    draw_circle(panel_pips_x + ((panel_pip_index - 1) * 12), panel_pips_y, 3, panel_pip_filled);
    draw_set_colour(c_white);
    draw_set_alpha(0.8);
    draw_circle(panel_pips_x + ((panel_pip_index - 1) * 12), panel_pips_y, 3, false);
  }
  draw_set_alpha(1);

  draw_set_colour(c_ltgray);
  draw_text(
    selected_panel_x + 12,
    selected_panel_y + 52,
    "Kills: " + string(global.selected_tower_id.tower_kill_count)
  );

  /// @type {Real}
  var selected_next_level = global.selected_tower_id.tower_level + 1;
  /// @type {Real}
  var selected_upgrade_cost = scr_tower_upgrade_cost(global.selected_tower_id.object_index, selected_next_level);
  /// @type {String}
  var selected_upgrade_text = "[U] Upgrade: MAX";
  if (selected_upgrade_cost > 0) {
    selected_upgrade_text = "[U] Upgrade: " + string(selected_upgrade_cost) + " coins";
  }

  draw_set_colour(c_aqua);
  draw_text(selected_panel_x + 12, selected_panel_y + 84, selected_upgrade_text);
  draw_set_colour(c_orange);
  draw_text(selected_panel_x + 12, selected_panel_y + 112, "[X] Delete: +" + string(TOWER_PLACEMENT_HP_COST) + " Life");

  if (global.confirm_action != "") {
    /// @type {Real}
    var confirm_flash = (sin(current_time * 0.02) + 1) * 0.5;
    draw_set_colour(merge_colour(c_yellow, c_red, confirm_flash));
    if (global.confirm_action == "upgrade") {
      draw_text(selected_panel_x + 12, selected_panel_y + 145, "CONFIRM? Press U again");
    } else if (global.confirm_action == "delete") {
      draw_text(selected_panel_x + 12, selected_panel_y + 145, "CONFIRM? Press X again");
    }
  }
}

if (global.boss_banner_timer_steps > 0) {
  /// @type {Real}
  var boss_center_x = display_get_gui_width() * 0.5;
  /// @type {Real}
  var boss_center_y = display_get_gui_height() * 0.5;
  /// @type {Real}
  var boss_pulse = 1 + (0.08 * sin(current_time / 90));

  scr_draw_rounded_panel(16, boss_center_y - 74, gui_width - 32, 148, 0.62, 20);

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

  scr_draw_rounded_panel(0, 0, intro_gui_width, intro_gui_height, 0.72, 0);

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

  scr_draw_rounded_panel(
    end_center_x - (end_panel_width * 0.5),
    end_center_y - (end_panel_height * 0.5),
    end_panel_width,
    end_panel_height,
    0.78,
    20
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

  scr_draw_rounded_panel(
    victory_center_x - (victory_panel_width * 0.5),
    victory_center_y - (victory_panel_height * 0.5),
    victory_panel_width,
    victory_panel_height,
    0.78,
    20
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

draw_set_colour(c_white);
draw_set_alpha(1);