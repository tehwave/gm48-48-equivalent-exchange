/// @description Draws essential HUD and end-state overlays.

/// @type {Real}
var gui_width = display_get_gui_width();
/// @type {Real}
var gui_height = display_get_gui_height();
/// @type {Bool}
var is_intro_screen = global.game_state == GAME_STATE_INTRO;

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(fnt_body);

/// @type {Real}
var top_left_x = 16;
/// @type {Real}
var top_left_y = 16;
/// @type {Real}
var top_left_width = 318;
/// @type {Real}
var top_left_height = 86;

if (!is_intro_screen) {
  scr_draw_rounded_panel(top_left_x, top_left_y, top_left_width, top_left_height, 0.58, 14);

  draw_set_font(fnt_heading);
  draw_set_colour(c_white);
  draw_text_shadow(top_left_x + 14, top_left_y + 10, "Wave " + string(global.wave_index) + "/" + string(TOTAL_WAVES));

  /// @type {String}
  var enemies_text = "Enemies: " + string(global.enemies_alive);
  draw_set_font(fnt_body);
  draw_set_colour(c_ltgray);
  draw_text_shadow(top_left_x + 14, top_left_y + 40, enemies_text);

  if (global.wave_index > 0 && scr_wave_is_boss(global.wave_index)) {
    draw_set_font(fnt_heading);
    draw_set_colour(c_orange);
    draw_text_shadow(top_left_x + top_left_width - 120, top_left_y + 10, "BOSS WAVE");
    draw_set_font(fnt_body);
  }
}

/// @type {Real}
var top_right_width = 224;
/// @type {Real}
var top_right_height = 82;
/// @type {Real}
var top_right_x = gui_width - top_right_width - 16;
/// @type {Real}
var top_right_y = 16;

if (!is_intro_screen) {
  scr_draw_rounded_panel(top_right_x, top_right_y, top_right_width, top_right_height, 0.58, 14);

  /// @type {Real}
  var life_text_x = top_right_x + 14;
  /// @type {Real}
  var life_text_y = top_right_y + 10;

  draw_set_font(fnt_heading);
  draw_set_colour(make_color_rgb(255, 134, 198));
  draw_text_shadow(life_text_x, life_text_y, "Life: " + string(global.player_hp));
  draw_set_font(fnt_body);
}

if (!variable_global_exists("coin_hud_pop_steps")) {
  global.coin_hud_pop_steps = 0;
}

if (!variable_global_exists("value_fx_popups")) {
  /// @type {Array<Struct>}
  global.value_fx_popups = [];
}

if (!variable_global_exists("coin_spend_particles")) {
  /// @type {Array<Struct>}
  global.coin_spend_particles = [];
}

if (!variable_global_exists("coin_spend_vfx_bursts")) {
  /// @type {Array<Struct>}
  global.coin_spend_vfx_bursts = [];
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

draw_set_font(fnt_heading);
draw_set_colour(c_black);
if (!is_intro_screen) {
  draw_text_transformed(coin_text_x + 1, coin_text_y + 1, coin_text, pop_scale, pop_scale, 0);
  draw_set_colour(c_yellow);
  draw_set_alpha(pop_alpha);
  draw_text_transformed(coin_text_x, coin_text_y, coin_text, pop_scale, pop_scale, 0);
  draw_set_alpha(1);
}

if (global.coin_hud_pop_steps > 0) {
  global.coin_hud_pop_steps -= 1;
}

/// Draw all floating value effects through one generic world/gui renderer.
/// @type {Array<Struct>}
var active_value_fx_popups = [];
/// @type {Real}
var value_fx_popup_count = array_length(global.value_fx_popups);
/// @type {Real}
var value_fx_camera_id = view_camera[0];
/// @type {Real}
var value_fx_view_x = (value_fx_camera_id != -1) ? camera_get_view_x(value_fx_camera_id) : 0;
/// @type {Real}
var value_fx_view_y = (value_fx_camera_id != -1) ? camera_get_view_y(value_fx_camera_id) : 0;
/// @type {Real}
var value_fx_view_w = (value_fx_camera_id != -1) ? camera_get_view_width(value_fx_camera_id) : room_width;
/// @type {Real}
var value_fx_view_h = (value_fx_camera_id != -1) ? camera_get_view_height(value_fx_camera_id) : room_height;
/// @type {Real}
var value_fx_safe_view_w = max(1, value_fx_view_w);
/// @type {Real}
var value_fx_safe_view_h = max(1, value_fx_view_h);
/// @type {Real}
var value_fx_safe_gui_w = max(1, gui_width);
/// @type {Real}
var value_fx_safe_gui_h = max(1, gui_height);

draw_set_font(fnt_body);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
for (var value_fx_index = 0; value_fx_index < value_fx_popup_count; value_fx_index += 1) {
  /// @type {Struct}
  var value_fx = global.value_fx_popups[value_fx_index];
  value_fx.life -= 1;

  if (value_fx.life > 0) {
    /// @type {Real}
    var value_fx_t = 1 - (value_fx.life / max(1, value_fx.max_life));
    /// @type {Real}
    var value_fx_rise_distance = VALUE_FX_DAMAGE_RISE_DISTANCE;
    /// @type {Real}
    var value_fx_scale = VALUE_FX_DAMAGE_SCALE_START + (VALUE_FX_DAMAGE_SCALE_GROWTH * value_fx_t);
    /// @type {Real}
    var value_fx_main_colour = make_color_rgb(255, 200, 120);

    switch (value_fx.category) {
      case VALUE_FX_CATEGORY_COIN_GAIN:
        value_fx_rise_distance = VALUE_FX_COIN_GAIN_RISE_DISTANCE;
        value_fx_scale = VALUE_FX_COIN_GAIN_SCALE_START + (VALUE_FX_COIN_GAIN_SCALE_GROWTH * value_fx_t);
        value_fx_main_colour = c_yellow;
        break;
      case VALUE_FX_CATEGORY_COIN_SPEND:
        value_fx_rise_distance = VALUE_FX_COIN_SPEND_RISE_DISTANCE;
        value_fx_scale = VALUE_FX_COIN_SPEND_SCALE_START + (VALUE_FX_COIN_SPEND_SCALE_GROWTH * value_fx_t);
        value_fx_main_colour = make_color_rgb(255, 178, 74);
        break;
      case VALUE_FX_CATEGORY_HP_GAIN:
        value_fx_rise_distance = VALUE_FX_HP_GAIN_RISE_DISTANCE;
        value_fx_scale = VALUE_FX_HP_GAIN_SCALE_START + (VALUE_FX_HP_GAIN_SCALE_GROWTH * value_fx_t);
        value_fx_main_colour = make_color_rgb(130, 255, 162);
        break;
      case VALUE_FX_CATEGORY_HP_LOSS:
        value_fx_rise_distance = VALUE_FX_HP_LOSS_RISE_DISTANCE;
        value_fx_scale = VALUE_FX_HP_LOSS_SCALE_START + (VALUE_FX_HP_LOSS_SCALE_GROWTH * value_fx_t);
        value_fx_main_colour = make_color_rgb(255, 134, 198);
        break;
      case VALUE_FX_CATEGORY_DAMAGE:
        value_fx_rise_distance = VALUE_FX_DAMAGE_RISE_DISTANCE;
        value_fx_scale = VALUE_FX_DAMAGE_SCALE_START + (VALUE_FX_DAMAGE_SCALE_GROWTH * value_fx_t);
        value_fx_main_colour = make_color_rgb(255, 200, 120);
        break;
    }

    if (value_fx.category == VALUE_FX_CATEGORY_DAMAGE && variable_struct_exists(value_fx, "main_colour") && value_fx.main_colour != -1) {
      value_fx_main_colour = value_fx.main_colour;
    }

    /// @type {Real}
    var value_fx_fade_t = clamp((value_fx_t - 0.88) / 0.12, 0, 1);
    /// @type {Real}
    var value_fx_alpha = 1 - value_fx_fade_t;
    /// @type {Real}
    var value_fx_base_x = value_fx.anchor_x + value_fx.offset_x;
    /// @type {Real}
    var value_fx_base_y = value_fx.anchor_y - VALUE_FX_BASE_WORLD_Y_OFFSET - (value_fx_rise_distance * value_fx_t);
    /// @type {Real}
    var value_fx_gui_x = value_fx_base_x;
    /// @type {Real}
    var value_fx_gui_y = value_fx_base_y;

    if (value_fx.anchor_mode == VALUE_FX_ANCHOR_WORLD) {
      value_fx_gui_x = ((value_fx_base_x - value_fx_view_x) / value_fx_safe_view_w) * value_fx_safe_gui_w;
      value_fx_gui_y = ((value_fx_base_y - value_fx_view_y) / value_fx_safe_view_h) * value_fx_safe_gui_h;
    }

    draw_set_alpha(value_fx_alpha);
    draw_set_colour(c_black);
    draw_text_transformed(value_fx_gui_x + 2, value_fx_gui_y + 2, value_fx.value_text, value_fx_scale, value_fx_scale, 0);
    draw_set_colour(value_fx_main_colour);
    draw_text_transformed(value_fx_gui_x, value_fx_gui_y, value_fx.value_text, value_fx_scale, value_fx_scale, 0);

    array_push(active_value_fx_popups, value_fx);
  }
}

draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
global.value_fx_popups = active_value_fx_popups;

/// Convert queued spend bursts into immediate exploding coin particles.
/// @type {Real}
var spend_burst_count = array_length(global.coin_spend_vfx_bursts);
for (var burst_index = 0; burst_index < spend_burst_count; burst_index += 1) {
  /// @type {Struct}
  var spend_burst = global.coin_spend_vfx_bursts[burst_index];

  for (var burst_particle_index = 0; burst_particle_index < spend_burst.particle_count; burst_particle_index += 1) {
    /// @type {Real}
    var burst_angle = random_range(0, 359);
    /// @type {Real}
    var burst_speed = random_range(COIN_SPEND_UI_PARTICLE_SPEED_MIN, COIN_SPEND_UI_PARTICLE_SPEED_MAX);
    /// @type {Real}
    var burst_life = irandom_range(COIN_SPEND_UI_PARTICLE_LIFE_MIN, COIN_SPEND_UI_PARTICLE_LIFE_MAX);

    /// @type {Struct}
    var spend_particle = {
      world_x : spend_burst.world_x,
      world_y : spend_burst.world_y,
      vx : lengthdir_x(burst_speed, burst_angle),
      vy : lengthdir_y(burst_speed, burst_angle),
      life : burst_life,
      max_life : burst_life,
      angle : random_range(0, 359),
      angle_speed : random_range(-COIN_SPEND_UI_PARTICLE_SPIN_MAX, COIN_SPEND_UI_PARTICLE_SPIN_MAX)
    };

    array_push(global.coin_spend_particles, spend_particle);
  }
}

global.coin_spend_vfx_bursts = [];

/// @type {Array<Struct>}
var active_spend_particles = [];
/// @type {Real}
var spend_particle_count = array_length(global.coin_spend_particles);

/// @type {Real}
var spend_camera_id = view_camera[0];
/// @type {Real}
var spend_view_x = (spend_camera_id != -1) ? camera_get_view_x(spend_camera_id) : 0;
/// @type {Real}
var spend_view_y = (spend_camera_id != -1) ? camera_get_view_y(spend_camera_id) : 0;
/// @type {Real}
var spend_view_w = (spend_camera_id != -1) ? camera_get_view_width(spend_camera_id) : room_width;
/// @type {Real}
var spend_view_h = (spend_camera_id != -1) ? camera_get_view_height(spend_camera_id) : room_height;
/// @type {Real}
var spend_safe_view_w = max(1, spend_view_w);
/// @type {Real}
var spend_safe_view_h = max(1, spend_view_h);
/// @type {Real}
var spend_safe_gui_w = max(1, gui_width);
/// @type {Real}
var spend_safe_gui_h = max(1, gui_height);

for (var particle_index = 0; particle_index < spend_particle_count; particle_index += 1) {
  /// @type {Struct}
  var spend_particle_state = global.coin_spend_particles[particle_index];
  spend_particle_state.life -= 1;

  if (spend_particle_state.life > 0) {
    spend_particle_state.vx *= COIN_SPEND_UI_PARTICLE_DRAG;
    spend_particle_state.vy += COIN_SPEND_UI_PARTICLE_GRAVITY;
    spend_particle_state.world_x += spend_particle_state.vx;
    spend_particle_state.world_y += spend_particle_state.vy;
    spend_particle_state.angle += spend_particle_state.angle_speed;

    /// @type {Real}
    var spend_life_t = spend_particle_state.life / max(1, spend_particle_state.max_life);
    /// @type {Real}
    var spend_fade_t = clamp((spend_life_t - 0.05) / 0.95, 0, 1);
    /// @type {Real}
    var spend_alpha = spend_fade_t;
    /// @type {Real}
    var spend_gui_x = ((spend_particle_state.world_x - spend_view_x) / spend_safe_view_w) * spend_safe_gui_w;
    /// @type {Real}
    var spend_gui_y = ((spend_particle_state.world_y - spend_view_y) / spend_safe_view_h) * spend_safe_gui_h;

    draw_set_alpha(spend_alpha);
    draw_set_colour(c_white);
    draw_sprite_ext(
      spr_coin,
      0,
      spend_gui_x,
      spend_gui_y,
      COIN_SPEND_UI_PARTICLE_SCALE,
      COIN_SPEND_UI_PARTICLE_SCALE,
      spend_particle_state.angle,
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
  draw_set_font(fnt_body);
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
  var build_panel_x = clamp(base_gui_x + 110, 10, gui_width - build_panel_width - 10);
  /// @type {Real}
  var build_panel_y = clamp(base_gui_y - 132, 10, gui_height - build_panel_height - 10);

  scr_draw_rounded_panel(build_panel_x, build_panel_y, build_panel_width, build_panel_height, 0.86, 14);

  draw_set_halign(fa_left);
  draw_set_valign(fa_top);
  draw_set_font(fnt_heading);
  draw_set_colour(c_black);
  draw_text_transformed(build_panel_x + 16 + 2, build_panel_y - 22 + 2, "BUILD TOWER", 2.4, 2.4, 0);
  draw_set_colour(c_white);
  draw_text_transformed(build_panel_x + 16, build_panel_y - 22, "BUILD TOWER", 2.4, 2.4, 0);

  draw_set_font(fnt_body);
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
    var preview_scale = 1.275 + (0.06 * sin(current_time * 0.008));

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
      scr_draw_rounded_panel(build_panel_x + 8, row_y - 8, build_panel_width - 16, 50, PANEL_SELECTED_ROW_BG_ALPHA, 8);
      draw_set_colour(c_white);
      draw_set_alpha(PANEL_SELECTED_ROW_BORDER_ALPHA);
      draw_roundrect_ext(build_panel_x + 8, row_y - 8, build_panel_x + build_panel_width - 8, row_y + 42, 8, 8, true);

      draw_set_colour(c_black);
      draw_set_alpha(PANEL_SELECTED_ROW_INNER_SHADOW_ALPHA);
      draw_roundrect_ext(build_panel_x + 10, row_y - 6, build_panel_x + build_panel_width - 10, row_y + 40, 6, 6, true);

      draw_set_alpha(1);
    }

    draw_set_font(fnt_body);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

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

  draw_set_font(fnt_heading);
  draw_set_halign(fa_left);
  draw_set_valign(fa_top);
  draw_set_colour(c_black);
  draw_text_transformed(selected_panel_x + panel_inner_pad + 2, selected_panel_y - 22 + 2, selected_description.name, 2.1, 2.1, 0);
  draw_set_colour(c_white);
  draw_text_transformed(selected_panel_x + panel_inner_pad, selected_panel_y - 22, selected_description.name, 2.1, 2.1, 0);
  draw_set_font(fnt_body);
  draw_set_colour(c_ltgray);
  draw_text_shadow(selected_panel_x + panel_inner_pad, selected_panel_y + 12 + panel_row_gap, "Lvl " + string(selected_level) + " / " + string(TOWER_MAX_LEVEL));

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
  draw_set_font(fnt_heading);
  draw_set_colour(c_black);
  draw_text_transformed(boss_center_x + 4, boss_center_y + 4, "BOSS WAVE", boss_pulse * 1.6, boss_pulse * 1.6, 0);
  draw_set_colour(c_orange);
  draw_text_transformed(boss_center_x, boss_center_y, "BOSS WAVE", boss_pulse * 1.6, boss_pulse * 1.6, 0);
  draw_set_font(fnt_body);
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
  /// @type {Real}
  var intro_anim_t = current_time * 0.008;
  /// @type {Real}
  var intro_panel_width = min(intro_gui_width - 56, 1140);
  /// @type {Real}
  var intro_panel_height = min(intro_gui_height - 118, 560);
  /// @type {Real}
  var intro_panel_x = (intro_gui_width - intro_panel_width) * 0.5;
  /// @type {Real}
  var intro_panel_y = (intro_gui_height - intro_panel_height) * 0.5;
  /// @type {Bool}
  var intro_use_vertical_cards = intro_panel_width < 900;
  /// @type {Real}
  var intro_card_outer_margin = 20;
  /// @type {Real}
  var intro_card_gap = 14;
  /// @type {Real}
  var intro_cards_top = intro_panel_y + 156;
  /// @type {Real}
  var intro_cards_bottom = intro_panel_y + intro_panel_height - 94;
  /// @type {Real}
  var intro_cards_area_height = max(180, intro_cards_bottom - intro_cards_top);
  /// @type {Real}
  var intro_card_width = intro_use_vertical_cards
    ? (intro_panel_width - (intro_card_outer_margin * 2))
    : ((intro_panel_width - (intro_card_outer_margin * 2) - (intro_card_gap * 2)) / 3);
  /// @type {Real}
  var intro_card_height = intro_use_vertical_cards
    ? ((intro_cards_area_height - (intro_card_gap * 2)) / 3)
    : intro_cards_area_height;
  /// @type {Asset.GMSprite|Real}
  var intro_tower_sprite = object_get_sprite(obj_tower_arrow);
  /// @type {Asset.GMSprite|Real}
  var intro_upgrade_sprite = object_get_sprite(obj_tower_cannon);

  if (intro_tower_sprite == -1) intro_tower_sprite = spr_tower_base;
  if (intro_upgrade_sprite == -1) intro_upgrade_sprite = spr_tower_base;

  if (global.intro_lock_timer_steps > 0) {
    continue_prompt = "Press [Space] in " + string(intro_seconds_remaining) + "s";
  }

  draw_set_alpha(0.62);
  draw_set_colour(c_black);
  draw_rectangle(0, 0, intro_gui_width, intro_gui_height, false);

  draw_set_alpha(0.74);
  draw_roundrect_ext(intro_panel_x, intro_panel_y, intro_panel_x + intro_panel_width, intro_panel_y + intro_panel_height, 24, 24, false);
  draw_set_alpha(1);
  draw_set_colour(c_white);
  draw_set_alpha(0.2);
  draw_roundrect_ext(intro_panel_x + 1, intro_panel_y + 1, intro_panel_x + intro_panel_width - 1, intro_panel_y + intro_panel_height - 1, 24, 24, true);
  draw_set_alpha(1);
  draw_set_colour(c_white);

  draw_set_halign(fa_center);
  draw_set_valign(fa_top);
  draw_set_font(fnt_heading);
  draw_set_colour(c_white);
  draw_set_colour(c_black);
  draw_text_transformed(intro_center_x + 2, intro_panel_y - 26 + 2, "TOWER TAX", 3.2, 3.2, 0);
  draw_set_colour(c_white);
  draw_text_transformed(intro_center_x, intro_panel_y - 26, "TOWER TAX", 3.2, 3.2, 0);

  draw_set_font(fnt_body);
  draw_set_colour(c_yellow);
  draw_text_shadow(intro_center_x, intro_panel_y + 56, "Every gain has a cost. Every cost is visible.");

  draw_set_colour(make_color_rgb(255, 146, 140));
  draw_text_shadow(intro_center_x, intro_panel_y + 84, "Overbuild and you bleed Life. Underbuild and leaks bleed it anyway.");

  for (var intro_step_index = 0; intro_step_index < 3; intro_step_index += 1) {
    /// @type {Real}
    var intro_card_x = intro_panel_x + intro_card_outer_margin;
    /// @type {Real}
    var intro_card_y = intro_cards_top;

    if (intro_use_vertical_cards) {
      intro_card_y += intro_step_index * (intro_card_height + intro_card_gap);
    } else {
      intro_card_x += intro_step_index * (intro_card_width + intro_card_gap);
    }

    /// @type {Real}
    var intro_icon_pulse = 0.94 + (0.06 * sin(intro_anim_t + (intro_step_index * 0.85)));
    /// @type {Real}
    var intro_icon_spin = sin((intro_anim_t * 0.85) + (intro_step_index * 0.8)) * 4;
    /// @type {Real}
    var intro_card_center_x = intro_card_x + (intro_card_width * 0.5);
    /// @type {Real}
    var intro_title_y = intro_card_y + 12;
    /// @type {Real}
    var intro_icon_y = intro_card_y + (intro_card_height * 0.5);
    /// @type {Real}
    var intro_subline_y = intro_card_y + 44;
    /// @type {Real}
    var intro_body_bottom_y = intro_card_y + intro_card_height - 24;
    /// @type {String}
    var intro_step_title = "";
    /// @type {String}
    var intro_step_line_top = "";
    /// @type {String}
    var intro_step_line_bottom = "";
    /// @type {Real}
    var intro_step_colour = c_white;

    switch (intro_step_index) {
      case 0:
        intro_step_title = "1) Spend Life";
        intro_step_line_top = "Place towers by paying Life upfront.";
        intro_step_line_bottom = "No Life left means no new defenses.";
        intro_step_colour = make_color_rgb(255, 134, 198);
        break;
      case 1:
        intro_step_title = "2) Hold The Path";
        intro_step_line_top = "Leaks cost Life.";
        intro_step_line_bottom = "Kills grant Coins for upgrades.";
        intro_step_colour = c_aqua;
        break;
      case 2:
        intro_step_title = "3) Reinvest Or Recover";
        intro_step_line_top = "Spend Coins with [U] to scale power.";
        intro_step_line_bottom = "Delete with [X] to reclaim Life only.";
        intro_step_colour = c_yellow;
        break;
    }

    draw_set_alpha(0.54);
    draw_set_colour(c_black);
    draw_roundrect_ext(intro_card_x, intro_card_y, intro_card_x + intro_card_width, intro_card_y + intro_card_height, 16, 16, false);
    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_alpha(0.16);
    draw_roundrect_ext(intro_card_x + 1, intro_card_y + 1, intro_card_x + intro_card_width - 1, intro_card_y + intro_card_height - 1, 16, 16, true);
    draw_set_alpha(1);
    draw_set_colour(c_white);

    switch (intro_step_index) {
      case 0:
        draw_set_alpha(0.26);
        draw_set_colour(make_color_rgb(255, 134, 198));
        draw_circle(intro_card_center_x, intro_icon_y + 6, 30, false);
        draw_set_alpha(1);
        draw_sprite_ext(intro_tower_sprite, 0, intro_card_center_x, intro_icon_y, intro_icon_pulse, intro_icon_pulse, intro_icon_spin, c_white, 1);
        break;

      case 1:
        draw_sprite_ext(spr_mantis_blue, 0, intro_card_center_x - 30, intro_icon_y, intro_icon_pulse, intro_icon_pulse, 0, c_white, 1);
        draw_sprite_ext(spr_coin, 0, intro_card_center_x + 32, intro_icon_y + 2, 0.8 + (0.08 * sin(intro_anim_t * 1.3)), 0.8 + (0.08 * sin(intro_anim_t * 1.3)), intro_icon_spin * 2.4, c_white, 1);
        break;

      case 2:
        draw_sprite_ext(spr_coin, 0, intro_card_center_x - 44, intro_icon_y - 14, 0.82, 0.82, -intro_icon_spin * 2, c_white, 1);
        draw_sprite_ext(spr_coin, 0, intro_card_center_x - 26, intro_icon_y - 2, 0.9, 0.9, intro_icon_spin * 2.2, c_white, 1);
        draw_sprite_ext(spr_coin, 0, intro_card_center_x - 50, intro_icon_y + 8, 0.76, 0.76, -intro_icon_spin * 1.7, c_white, 1);
        draw_sprite_ext(intro_upgrade_sprite, 0, intro_card_center_x + 24, intro_icon_y, intro_icon_pulse, intro_icon_pulse, intro_icon_spin, c_white, 1);
        break;
    }

    draw_set_font(fnt_body);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_colour(intro_step_colour);
    draw_text_shadow(intro_card_center_x, intro_title_y, intro_step_title);

    draw_set_colour(c_ltgray);
    switch (intro_step_index) {
      case 0:
        draw_text_shadow(intro_card_center_x, intro_subline_y, "-" + string(TOWER_PLACEMENT_HP_COST) + " Life");
        break;
      case 1:
        draw_text_shadow(intro_card_center_x, intro_subline_y, "Enemy leak <-> coin reward");
        break;
      case 2:
        draw_text_shadow(intro_card_center_x, intro_subline_y, "[U] upgrades | [X] returns Life");
        break;
    }

    draw_set_colour(c_white);
      draw_set_halign(fa_center);
      draw_set_valign(fa_bottom);
      draw_text_shadow(intro_card_center_x, intro_body_bottom_y - 32, intro_step_line_top);
      draw_text_shadow(intro_card_center_x, intro_body_bottom_y, intro_step_line_bottom);
      draw_set_valign(fa_top);
    draw_set_halign(fa_center);
  }

  draw_set_halign(fa_center);
  draw_set_valign(fa_middle);
  draw_set_font(fnt_body);
  draw_set_colour(c_white);
  draw_text_shadow(intro_center_x, intro_panel_y + intro_panel_height - 56, continue_prompt);
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
  draw_set_font(fnt_heading);
  draw_set_colour(c_red);
  draw_text_shadow(end_center_x, end_center_y - 142, "GAME OVER");

  draw_set_font(fnt_body);
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
  draw_set_font(fnt_heading);
  draw_set_colour(c_lime);
  draw_text_shadow(victory_center_x, victory_center_y - 142, "VICTORY");

  draw_set_font(fnt_body);
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
draw_set_font(-1);
