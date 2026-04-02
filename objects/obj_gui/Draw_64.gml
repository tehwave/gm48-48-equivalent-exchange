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
draw_text_shadow(top_left_x + 14, top_left_y + 10, "Wave " + string(global.wave_index) + "/" + string(TOTAL_WAVES));

/// @type {String}
var enemies_text = "Enemies: " + string(global.enemies_alive);
draw_set_colour(c_ltgray);
draw_text_shadow(top_left_x + 14, top_left_y + 40, enemies_text);

if (global.wave_index > 0 && scr_wave_is_boss(global.wave_index)) {
  draw_set_colour(c_orange);
  draw_text_shadow(top_left_x + top_left_width - 120, top_left_y + 10, "BOSS WAVE");
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

/// @type {Real}
var life_text_x = top_right_x + 14;
/// @type {Real}
var life_text_y = top_right_y + 10;

draw_set_colour(c_black);
draw_text_shadow(life_text_x + 1, life_text_y + 1, "Life: " + string(global.player_hp));
draw_set_colour(make_color_rgb(255, 134, 198));
draw_text_shadow(life_text_x, life_text_y, "Life: " + string(global.player_hp));

if (!variable_global_exists("coin_hud_pop_steps")) {
  global.coin_hud_pop_steps = 0;
}

if (!variable_global_exists("coin_spend_vfx_pending")) {
  global.coin_spend_vfx_pending = 0;
}

if (!variable_global_exists("coin_spend_particles")) {
  /// @type {Array<Struct>}
  global.coin_spend_particles = [];
}

if (!variable_global_exists("coin_spend_vfx_emit_steps_remaining")) {
  global.coin_spend_vfx_emit_steps_remaining = 0;
}

if (!variable_global_exists("coin_spend_vfx_emit_interval_steps")) {
  global.coin_spend_vfx_emit_interval_steps = 1;
}

if (!variable_global_exists("coin_spend_vfx_emit_tick")) {
  global.coin_spend_vfx_emit_tick = 0;
}

/// @type {Real}
var coin_text_x = top_right_x + 14;
/// @type {Real}
var coin_text_y = top_right_y + 42;
/// @type {String}
var coin_text = "Coins: " + string(global.player_coins);
/// @type {Real}
var pop_steps = global.coin_hud_pop_steps;
/// @type {Real}
var pop_t = clamp(pop_steps / 10, 0, 1);
/// @type {Real}
var pop_scale = 1 + (0.14 * sin(pop_t * pi));
/// @type {Real}
var pop_alpha = 1 - (0.18 * pop_t);

draw_set_colour(c_black);
draw_text_transformed(coin_text_x + 1, coin_text_y + 1, coin_text, pop_scale, pop_scale, 0);
draw_set_colour(c_yellow);
draw_set_alpha(pop_alpha);
draw_text_transformed(coin_text_x, coin_text_y, coin_text, pop_scale, pop_scale, 0);
draw_set_alpha(1);

if (global.coin_hud_pop_steps > 0) {
  global.coin_hud_pop_steps -= 1;
}

if (global.coin_spend_vfx_pending > 0 && global.coin_spend_vfx_emit_steps_remaining <= 0) {
  /// @type {Real}
  var emit_span_steps = max(1, round(room_speed * COIN_SPEND_UI_EMIT_SPAN_SECONDS));
  global.coin_spend_vfx_emit_steps_remaining = emit_span_steps;
  global.coin_spend_vfx_emit_interval_steps = max(1, floor(emit_span_steps / max(1, global.coin_spend_vfx_pending)));
  global.coin_spend_vfx_emit_tick = 0;
}

if (global.coin_spend_vfx_pending > 0) {
  if (global.coin_spend_vfx_emit_steps_remaining > 0) {
    global.coin_spend_vfx_emit_steps_remaining -= 1;
  }

  global.coin_spend_vfx_emit_tick -= 1;
  if (global.coin_spend_vfx_emit_tick <= 0) {
    /// @type {Struct}
    var spend_particle = {
      x : coin_text_x + 68,
      y : coin_text_y + 7,
      vy : random_range(COIN_SPEND_UI_PARTICLE_START_SPEED_MIN, COIN_SPEND_UI_PARTICLE_START_SPEED_MAX),
      life : COIN_SPEND_UI_PARTICLE_LIFE_STEPS,
      max_life : COIN_SPEND_UI_PARTICLE_LIFE_STEPS
    };

    array_push(global.coin_spend_particles, spend_particle);
    global.coin_spend_vfx_pending = max(0, global.coin_spend_vfx_pending - 1);
    global.coin_spend_vfx_emit_tick = max(1, global.coin_spend_vfx_emit_interval_steps);
  }
}

/// @type {Array<Struct>}
var active_spend_particles = [];
/// @type {Real}
var spend_particle_count = array_length(global.coin_spend_particles);
for (var particle_index = 0; particle_index < spend_particle_count; particle_index += 1) {
  /// @type {Struct}
  var spend_particle_state = global.coin_spend_particles[particle_index];
  spend_particle_state.life -= 1;

  if (spend_particle_state.life > 0) {
    spend_particle_state.vy += COIN_SPEND_UI_PARTICLE_GRAVITY;
    spend_particle_state.y += spend_particle_state.vy;

    /// @type {Real}
    var spend_life_t = spend_particle_state.life / max(1, spend_particle_state.max_life);
    /// @type {Real}
    var spend_fade_t = clamp((spend_life_t - 0.2) / 0.8, 0, 1);
    /// @type {Real}
    var spend_alpha = spend_fade_t;

    draw_set_alpha(spend_alpha);
    draw_set_colour(c_white);
    draw_sprite_ext(
      spr_coin,
      0,
      spend_particle_state.x,
      spend_particle_state.y,
      COIN_SPEND_UI_PARTICLE_SCALE,
      COIN_SPEND_UI_PARTICLE_SCALE,
      0,
      c_white,
      spend_alpha
    );

    array_push(active_spend_particles, spend_particle_state);
  }
}

draw_set_alpha(1);
draw_set_colour(c_white);
global.coin_spend_particles = active_spend_particles;

if (game_is_running() && !global.build_mode && !instance_exists(global.selected_tower_id)) {
  scr_draw_rounded_panel(top_right_x, top_right_y + top_right_height + 10, top_right_width, 40, 0.48, 12);
  draw_set_colour(c_ltgray);
  draw_text_shadow(top_right_x + 14, top_right_y + top_right_height + 20, "Click a base to build");
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
  var build_panel_width = 460;
  /// @type {Real}
  var build_panel_height = 456;
  /// @type {Real}
  var build_panel_x = clamp(base_gui_x + 22, 10, gui_width - build_panel_width - 10);
  /// @type {Real}
  var build_panel_y = clamp(base_gui_y - 38, 10, gui_height - build_panel_height - 10);

  scr_draw_rounded_panel(build_panel_x, build_panel_y, build_panel_width, build_panel_height, 0.86, 14);

  draw_set_colour(c_black);
  draw_text_shadow(build_panel_x + 13, build_panel_y + 11, "Build Tower");
  draw_set_colour(c_white);
  draw_text_shadow(build_panel_x + 12, build_panel_y + 10, "Build Tower");

  draw_set_colour(c_black);
  draw_text_shadow(build_panel_x + 13, build_panel_y + 35, "Select: [Q]/[E] or [1]-[5]");
  draw_set_colour(c_ltgray);
  draw_text_shadow(build_panel_x + 12, build_panel_y + 34, "Select: [Q]/[E] or [1]-[5]");

  /// @type {Asset.GMObject|Real}
  var selected_build_object = scr_get_selected_tower_object();
  /// @type {Asset.GMSprite|Real}
  var selected_build_sprite = (selected_build_object != noone) ? object_get_sprite(selected_build_object) : -1;
  if (selected_build_sprite != -1) {
    /// @type {Real}
    var preview_x = build_panel_x + build_panel_width - 48;
    /// @type {Real}
    var preview_y = build_panel_y + 38;
    /// @type {Real}
    var preview_scale = 0.85 + (0.04 * sin(current_time * 0.008));

    draw_set_colour(c_black);
    draw_set_alpha(0.8);
    draw_rectangle(preview_x - 26, preview_y - 26, preview_x + 26, preview_y + 26, false);
    draw_set_colour(c_white);
    draw_set_alpha(0.95);
    draw_rectangle(preview_x - 26, preview_y - 26, preview_x + 26, preview_y + 26, true);
    draw_set_alpha(1);
    draw_sprite_ext(selected_build_sprite, 0, preview_x, preview_y, preview_scale, preview_scale, 0, c_white, 1);
  }

  /// @type {Real}
  var build_controls_block_height = 124;
  /// @type {Real}
  var build_rows_start_y = build_panel_y + 98;
  /// @type {Real}
  var build_row_pitch = 52;
  /// @type {Real}
  var build_row_detail_offset = 24;

  for (var tower_index = 0; tower_index < 5; tower_index += 1) {
    /// @type {Struct}
    var tower_description = scr_get_tower_description(tower_index);
    /// @type {Bool}
    var tower_selected = global.selected_tower_type == tower_index;
    /// @type {Real}
    var row_y = build_rows_start_y + (tower_index * build_row_pitch);
    /// @type {String}
    var row_prefix = tower_selected ? "> " : "  ";

    if (tower_selected) {
      scr_draw_rounded_panel(build_panel_x + 8, row_y - 8, build_panel_width - 16, 50, 0.52, 8);
      draw_set_colour(c_white);
      draw_set_alpha(0.8);
      draw_roundrect_ext(build_panel_x + 8, row_y - 8, build_panel_x + build_panel_width - 8, row_y + 42, 8, 8, true);
      draw_set_alpha(1);
    }

    draw_set_colour(c_black);
    draw_text_shadow(
      build_panel_x + 15,
      row_y + 1,
      row_prefix + "[" + string(tower_index + 1) + "] " + tower_description.name + " | " + tower_description.damage_type + " | R " + string(tower_description.range) + " | " + string(tower_description.hp_cost) + " Life"
    );

    draw_set_colour(tower_selected ? c_yellow : c_silver);
    draw_text_shadow(
      build_panel_x + 14,
      row_y,
      row_prefix + "[" + string(tower_index + 1) + "] " + tower_description.name + " | " + tower_description.damage_type + " | R " + string(tower_description.range) + " | " + string(tower_description.hp_cost) + " Life"
    );

    draw_set_colour(c_black);
    draw_text_shadow(build_panel_x + 25, row_y + build_row_detail_offset + 1, tower_description.special);

    draw_set_colour(tower_selected ? c_white : c_ltgray);
    draw_text_shadow(build_panel_x + 24, row_y + build_row_detail_offset, tower_description.special);
  }

  draw_set_alpha(0.45);
  draw_set_colour(c_dkgray);
  draw_line(
    build_panel_x + 10,
    build_panel_y + build_panel_height - build_controls_block_height + 6,
    build_panel_x + build_panel_width - 10,
    build_panel_y + build_panel_height - build_controls_block_height + 6
  );
  draw_set_alpha(1);

  draw_set_colour(c_black);
  draw_text_shadow(build_panel_x + 13, build_panel_y + build_panel_height - 84, "Build selected base: [B] or [Enter]");
  draw_text_shadow(build_panel_x + 13, build_panel_y + build_panel_height - 52, "Click base to change | [RMB]/[Esc] cancel");
  draw_set_colour(c_white);
  draw_text_shadow(build_panel_x + 12, build_panel_y + build_panel_height - 85, "Build selected base: [B] or [Enter]");
  draw_text_shadow(build_panel_x + 12, build_panel_y + build_panel_height - 53, "Click base to change | [RMB]/[Esc] cancel");
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
  var selected_panel_width = 344;
  /// @type {Real}
  var selected_panel_height = 212;
  /// @type {Real}
  var panel_inner_pad = 16;
  /// @type {Real}
  var panel_row_gap = 22;
  /// @type {Real}
  var selected_panel_right_x = tower_gui_x + 26;
  /// @type {Real}
  var selected_panel_left_x = tower_gui_x - selected_panel_width - 26;
  /// @type {Real}
  var selected_panel_x = clamp(selected_panel_right_x, 10, gui_width - selected_panel_width - 10);
  if (selected_panel_right_x + selected_panel_width > gui_width - 10 && selected_panel_left_x >= 10) {
    selected_panel_x = selected_panel_left_x;
  }
  /// @type {Real}
  var selected_panel_y = clamp(tower_gui_y - 44, 10, gui_height - selected_panel_height - 10);

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
  /// @type {Real}
  var selected_level = global.selected_tower_id.tower_level;
  /// @type {Real}
  var selected_next_level_for_pips = selected_level + 1;
  /// @type {Real}
  var selected_upgrade_cost_for_pips = scr_tower_upgrade_cost(global.selected_tower_id.object_index, selected_next_level_for_pips);
  /// @type {Bool}
  var selected_next_level_affordable = (selected_upgrade_cost_for_pips > 0 && global.player_coins >= selected_upgrade_cost_for_pips);

  draw_set_colour(c_white);
  draw_text_shadow(selected_panel_x + panel_inner_pad, selected_panel_y + 12, selected_description.name);
  draw_set_colour(c_ltgray);
  draw_text_shadow(selected_panel_x + panel_inner_pad, selected_panel_y + 12 + panel_row_gap, "Lvl " + string(selected_level) + " / " + string(TOWER_MAX_LEVEL));

  /// @type {Real}
  var panel_pips_x = selected_panel_x + panel_inner_pad + 4;
  /// @type {Real}
  var panel_pips_y = selected_panel_y + 12 + (panel_row_gap * 2) - 2;
  for (var panel_pip_index = 1; panel_pip_index <= TOWER_MAX_LEVEL; panel_pip_index += 1) {
    /// @type {Bool}
    var panel_pip_upgraded = panel_pip_index <= selected_level;
    /// @type {Bool}
    var panel_pip_upgradeable = (!panel_pip_upgraded && selected_next_level_affordable && panel_pip_index == selected_next_level_for_pips);

    draw_set_colour(panel_pip_upgraded ? c_yellow : c_white);
    draw_set_alpha((panel_pip_upgraded || panel_pip_upgradeable) ? 1 : 0.9);
    draw_circle(panel_pips_x + ((panel_pip_index - 1) * 12), panel_pips_y, 3, panel_pip_upgraded || panel_pip_upgradeable);
    draw_set_colour(c_white);
    draw_set_alpha(0.8);
    draw_circle(panel_pips_x + ((panel_pip_index - 1) * 12), panel_pips_y, 3, false);
  }
  draw_set_alpha(1);

  draw_set_colour(c_ltgray);
  draw_text_shadow(
    selected_panel_x + panel_inner_pad,
    selected_panel_y + 12 + (panel_row_gap * 3),
    "Kills: " + string(global.selected_tower_id.tower_kill_count)
  );
  draw_text_shadow(
    selected_panel_x + panel_inner_pad,
    selected_panel_y + 12 + (panel_row_gap * 4),
    "Range: " + string(round(global.selected_tower_id.tower_range))
  );

  /// @type {Real}
  var selected_next_level = global.selected_tower_id.tower_level + 1;
  /// @type {Real}
  var selected_upgrade_cost = scr_tower_upgrade_cost(global.selected_tower_id.object_index, selected_next_level);
  /// @type {String}
  var selected_upgrade_text = "[U] Upgrade: MAX LEVEL";
  /// @type {Real}
  var selected_upgrade_colour = c_gray;
  if (selected_upgrade_cost > 0 && global.player_coins >= selected_upgrade_cost) {
    selected_upgrade_text = "[U] Upgrade: " + string(selected_upgrade_cost) + " coins";
    selected_upgrade_colour = c_aqua;
  } else if (selected_upgrade_cost > 0) {
    /// @type {Real}
    var missing_upgrade_coins = selected_upgrade_cost - global.player_coins;
    selected_upgrade_text = "[U] Upgrade: Need +" + string(missing_upgrade_coins) + " coins";
    selected_upgrade_colour = c_red;
  }

  draw_set_colour(selected_upgrade_colour);
  draw_text_shadow(selected_panel_x + panel_inner_pad, selected_panel_y + 12 + (panel_row_gap * 5), selected_upgrade_text);
  draw_set_colour(c_orange);
  /// @type {Real}
  var selected_delete_refund_hp = variable_instance_exists(global.selected_tower_id, "tower_placement_hp_cost") ? global.selected_tower_id.tower_placement_hp_cost : TOWER_PLACEMENT_HP_COST;
  draw_text_shadow(selected_panel_x + panel_inner_pad, selected_panel_y + 12 + (panel_row_gap * 6), "[X] Delete: +" + string(selected_delete_refund_hp) + " Life");

  if (global.confirm_action != "") {
    /// @type {Real}
    var confirm_flash = (sin(current_time * 0.02) + 1) * 0.5;
    draw_set_colour(merge_colour(c_yellow, c_red, confirm_flash));
    if (global.confirm_action == "upgrade") {
      draw_text_shadow(selected_panel_x + panel_inner_pad, selected_panel_y + 12 + (panel_row_gap * 7) + 2, "CONFIRM? Press [U] again");
    } else if (global.confirm_action == "delete") {
      draw_text_shadow(selected_panel_x + panel_inner_pad, selected_panel_y + 12 + (panel_row_gap * 7) + 2, "CONFIRM? Press [X] again");
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
  var continue_prompt = "Press [Space] to begin";

  if (global.intro_lock_timer_steps > 0) {
    continue_prompt = "Press [Space] in " + string(intro_seconds_remaining) + "s";
  }

  scr_draw_rounded_panel(0, 0, intro_gui_width, intro_gui_height, 0.72, 0);

  draw_set_halign(fa_center);
  draw_set_valign(fa_middle);
  draw_set_colour(c_white);
  draw_text_shadow(
    intro_center_x,
    intro_center_y - 110,
    "EQUIVALENT EXCHANGE"
  );

  draw_set_colour(c_yellow);
  draw_text_shadow(
    intro_center_x,
    intro_center_y - 24,
    "Life is your currency.\nSpend Life to place towers."
  );

  draw_set_colour(c_aqua);
  draw_text_shadow(
    intro_center_x,
    intro_center_y + 48,
    "Leaks also cost Life.\nKills grant Coins for upgrades ([U]).\nDelete selected tower with [X] for Life only (no coins)."
  );

  draw_set_colour(c_white);
  draw_text_shadow(intro_center_x, intro_center_y + 118, continue_prompt);
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
  draw_text_shadow(end_center_x, end_center_y - 142, "GAME OVER");

  draw_set_colour(c_white);
  draw_text_shadow(
    end_center_x,
    end_center_y - 104,
    "The exchange failed.\n\nWave Reached: " + string(global.wave_index) + "/" + string(TOTAL_WAVES) +
    "\nLife Left: " + string(global.player_hp) +
    "\nCoins Left: " + string(global.player_coins) +
    "\nRun Time: " + run_time_text
  );

  draw_set_colour(c_yellow);
  draw_text_shadow(end_center_x, end_center_y + 126, "Press [R] to restart");
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
  draw_text_shadow(victory_center_x, victory_center_y - 142, "VICTORY");

  draw_set_colour(c_white);
  draw_text_shadow(
    victory_center_x,
    victory_center_y - 104,
    "The balance is settled.\n\nWaves Cleared: " + string(TOTAL_WAVES) + "/" + string(TOTAL_WAVES) +
    "\nLife Left: " + string(global.player_hp) +
    "\nCoins Left: " + string(global.player_coins) +
    "\nRun Time: " + victory_run_time_text
  );

  draw_set_colour(c_yellow);
  draw_text_shadow(victory_center_x, victory_center_y + 126, "Press [R] to restart");
}

draw_set_colour(c_white);
draw_set_alpha(1);
