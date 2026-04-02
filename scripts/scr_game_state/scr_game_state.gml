/// @description Shared state/economy/combat transaction helpers.

/// @returns {Bool}
function game_is_running() {
  return global.game_state == GAME_STATE_RUNNING;
}

/// @param {Real} px
/// @param {Real} py
/// @param {Real} pw
/// @param {Real} ph
/// @returns {Void}
function scr_draw_panel_blur_backdrop(px, py, pw, ph) {
  if (PANEL_BLUR_ENABLED != 1) return;
  if (pw <= 0 || ph <= 0) return;
  if (!surface_exists(application_surface)) return;

  /// Keep expensive blur passes off very large overlays.
  /// @type {Real}
  var gui_width = max(1, display_get_gui_width());
  /// @type {Real}
  var gui_height = max(1, display_get_gui_height());
  /// @type {Real}
  var panel_area_ratio = (pw * ph) / (gui_width * gui_height);
  if (panel_area_ratio > PANEL_BLUR_MAX_AREA_RATIO) return;

  /// @type {Real}
  var app_surface_width = max(1, surface_get_width(application_surface));
  /// @type {Real}
  var app_surface_height = max(1, surface_get_height(application_surface));
  /// @type {Real}
  var surface_scale_x = app_surface_width / gui_width;
  /// @type {Real}
  var surface_scale_y = app_surface_height / gui_height;

  /// @type {Real}
  var source_x = clamp(px * surface_scale_x, 0, app_surface_width - 1);
  /// @type {Real}
  var source_y = clamp(py * surface_scale_y, 0, app_surface_height - 1);
  /// @type {Real}
  var source_width = clamp(pw * surface_scale_x, 1, app_surface_width - source_x);
  /// @type {Real}
  var source_height = clamp(ph * surface_scale_y, 1, app_surface_height - source_y);

  /// @type {Real}
  var blur_pass_count = max(1, round(PANEL_BLUR_PASSES));
  /// @type {Real}
  var blur_alpha_total = clamp(PANEL_BLUR_ALPHA, 0, 1);
  /// @type {Real}
  var blur_alpha_per_pass = blur_alpha_total / blur_pass_count;
  /// @type {Real}
  var blur_tint_strength = clamp(PANEL_BLUR_TINT_STRENGTH, 0, 1);
  /// @type {Real}
  var blur_tint_colour = merge_colour(c_white, make_color_rgb(176, 210, 255), blur_tint_strength);

  /// Try shader path first when shader asset is available.
  /// @type {Asset.GMShader|Real}
  var panel_blur_shader = variable_global_exists("panel_blur_shader") ? global.panel_blur_shader : -1;
  if (panel_blur_shader == -1) {
    panel_blur_shader = asset_get_index("shd_panel_blur");
  }

  if (panel_blur_shader != -1) {
    if (!variable_global_exists("panel_blur_surface_a")) global.panel_blur_surface_a = -1;
    if (!variable_global_exists("panel_blur_surface_b")) global.panel_blur_surface_b = -1;
    if (!variable_global_exists("panel_blur_surface_w")) global.panel_blur_surface_w = 0;
    if (!variable_global_exists("panel_blur_surface_h")) global.panel_blur_surface_h = 0;

    /// @type {Real}
    var blur_surface_width = max(8, round(source_width / max(1, PANEL_BLUR_DOWNSAMPLE)));
    /// @type {Real}
    var blur_surface_height = max(8, round(source_height / max(1, PANEL_BLUR_DOWNSAMPLE)));

    if (
      !surface_exists(global.panel_blur_surface_a) ||
      !surface_exists(global.panel_blur_surface_b) ||
      global.panel_blur_surface_w < blur_surface_width ||
      global.panel_blur_surface_h < blur_surface_height
    ) {
      if (surface_exists(global.panel_blur_surface_a)) surface_free(global.panel_blur_surface_a);
      if (surface_exists(global.panel_blur_surface_b)) surface_free(global.panel_blur_surface_b);

      global.panel_blur_surface_w = blur_surface_width;
      global.panel_blur_surface_h = blur_surface_height;
      global.panel_blur_surface_a = surface_create(global.panel_blur_surface_w, global.panel_blur_surface_h);
      global.panel_blur_surface_b = surface_create(global.panel_blur_surface_w, global.panel_blur_surface_h);
    }

    if (surface_exists(global.panel_blur_surface_a) && surface_exists(global.panel_blur_surface_b)) {
      /// @type {Real}
      var blur_w = global.panel_blur_surface_w;
      /// @type {Real}
      var blur_h = global.panel_blur_surface_h;
      /// @type {Real}
      var capture_scale_x = blur_w / source_width;
      /// @type {Real}
      var capture_scale_y = blur_h / source_height;

      /// @type {Real}
      var uniform_blur_step = shader_get_uniform(panel_blur_shader, "u_blur_step");

      gpu_set_texfilter(true);

      surface_set_target(global.panel_blur_surface_a);
      draw_clear_alpha(c_black, 0);
      draw_set_alpha(1);
      draw_set_colour(c_white);
      draw_surface_part_ext(application_surface, source_x, source_y, source_width, source_height, 0, 0, capture_scale_x, capture_scale_y, c_white, 1);
      surface_reset_target();

      for (var blur_pass = 0; blur_pass < blur_pass_count; blur_pass += 1) {
        /// @type {Real}
        var blur_radius = max(0.5, PANEL_BLUR_SAMPLE_OFFSET + ((blur_pass + 1) * PANEL_BLUR_PASS_STEP));

        surface_set_target(global.panel_blur_surface_b);
        draw_clear_alpha(c_black, 0);
        draw_set_alpha(1);
        draw_set_colour(c_white);
        shader_set(panel_blur_shader);
        if (uniform_blur_step != -1) {
          shader_set_uniform_f(uniform_blur_step, blur_radius / blur_w, 0);
        }
        draw_surface_part_ext(global.panel_blur_surface_a, 0, 0, blur_w, blur_h, 0, 0, 1, 1, c_white, 1);
        shader_reset();
        surface_reset_target();

        surface_set_target(global.panel_blur_surface_a);
        draw_clear_alpha(c_black, 0);
        draw_set_alpha(1);
        draw_set_colour(c_white);
        shader_set(panel_blur_shader);
        if (uniform_blur_step != -1) {
          shader_set_uniform_f(uniform_blur_step, 0, blur_radius / blur_h);
        }
        draw_surface_part_ext(global.panel_blur_surface_b, 0, 0, blur_w, blur_h, 0, 0, 1, 1, c_white, 1);
        shader_reset();
        surface_reset_target();
      }

      draw_set_alpha(blur_alpha_total);
      draw_set_colour(blur_tint_colour);
      draw_surface_part_ext(global.panel_blur_surface_a, 0, 0, blur_w, blur_h, px, py, pw / blur_w, ph / blur_h, blur_tint_colour, 1);

      gpu_set_texfilter(false);
      draw_set_alpha(1);
      draw_set_colour(c_white);

      global.panel_blur_shader = panel_blur_shader;
      return;
    }
  }

  /// Fallback: stable multi-tap blur that samples application_surface directly.
  gpu_set_texfilter(true);
  draw_set_colour(blur_tint_colour);

  for (var blur_fallback_pass = 0; blur_fallback_pass < blur_pass_count; blur_fallback_pass += 1) {
    /// @type {Real}
    var blur_radius_x = (PANEL_BLUR_SAMPLE_OFFSET + ((blur_fallback_pass + 1) * PANEL_BLUR_PASS_STEP)) * surface_scale_x;
    /// @type {Real}
    var blur_radius_y = (PANEL_BLUR_SAMPLE_OFFSET + ((blur_fallback_pass + 1) * PANEL_BLUR_PASS_STEP)) * surface_scale_y;

    draw_set_alpha(blur_alpha_per_pass * 0.30);
    draw_surface_part_ext(application_surface, source_x, source_y, source_width, source_height, px, py, pw / source_width, ph / source_height, blur_tint_colour, 1);

    draw_set_alpha(blur_alpha_per_pass * 0.12);
    draw_surface_part_ext(application_surface, clamp(source_x - blur_radius_x, 0, app_surface_width - source_width), source_y, source_width, source_height, px, py, pw / source_width, ph / source_height, blur_tint_colour, 1);
    draw_surface_part_ext(application_surface, clamp(source_x + blur_radius_x, 0, app_surface_width - source_width), source_y, source_width, source_height, px, py, pw / source_width, ph / source_height, blur_tint_colour, 1);
    draw_surface_part_ext(application_surface, source_x, clamp(source_y - blur_radius_y, 0, app_surface_height - source_height), source_width, source_height, px, py, pw / source_width, ph / source_height, blur_tint_colour, 1);
    draw_surface_part_ext(application_surface, source_x, clamp(source_y + blur_radius_y, 0, app_surface_height - source_height), source_width, source_height, px, py, pw / source_width, ph / source_height, blur_tint_colour, 1);

    draw_set_alpha(blur_alpha_per_pass * 0.06);
    draw_surface_part_ext(application_surface, clamp(source_x - blur_radius_x, 0, app_surface_width - source_width), clamp(source_y - blur_radius_y, 0, app_surface_height - source_height), source_width, source_height, px, py, pw / source_width, ph / source_height, blur_tint_colour, 1);
    draw_surface_part_ext(application_surface, clamp(source_x + blur_radius_x, 0, app_surface_width - source_width), clamp(source_y - blur_radius_y, 0, app_surface_height - source_height), source_width, source_height, px, py, pw / source_width, ph / source_height, blur_tint_colour, 1);
    draw_surface_part_ext(application_surface, clamp(source_x - blur_radius_x, 0, app_surface_width - source_width), clamp(source_y + blur_radius_y, 0, app_surface_height - source_height), source_width, source_height, px, py, pw / source_width, ph / source_height, blur_tint_colour, 1);
    draw_surface_part_ext(application_surface, clamp(source_x + blur_radius_x, 0, app_surface_width - source_width), clamp(source_y + blur_radius_y, 0, app_surface_height - source_height), source_width, source_height, px, py, pw / source_width, ph / source_height, blur_tint_colour, 1);
  }

  gpu_set_texfilter(false);
  draw_set_alpha(1);
  draw_set_colour(c_white);
}

/// @param {Real} px
/// @param {Real} py
/// @param {Real} pw
/// @param {Real} ph
/// @param {Real} bg_alpha
/// @param {Real} corner_radius
/// @returns {Void}
function scr_draw_rounded_panel(px, py, pw, ph, bg_alpha, corner_radius) {
  scr_draw_panel_blur_backdrop(px, py, pw, ph);
  draw_set_alpha(clamp(bg_alpha * PANEL_BG_ALPHA_MULTIPLIER, 0, 1));
  draw_set_colour(c_black);
  draw_roundrect_ext(px, py, px + pw, py + ph, corner_radius, corner_radius, false);

  /// Add a subtle glass highlight at the top edge.
  /// @type {Real}
  var panel_highlight_alpha = clamp(PANEL_TOP_HIGHLIGHT_ALPHA, 0, 1);
  if (panel_highlight_alpha > 0) {
    /// @type {Real}
    var panel_line_margin = max(2, corner_radius * 0.45);
    draw_set_alpha(panel_highlight_alpha);
    draw_set_colour(make_color_rgb(226, 236, 255));
    draw_line(px + panel_line_margin, py + 1, px + pw - panel_line_margin, py + 1);
  }

  draw_set_alpha(1);
  draw_set_colour(c_white);
}

/// @description Draws text with an automatic shadow pass using the current draw colour for the main text.
/// @param {Real} x
/// @param {Real} y
/// @param {String} text
/// @param {Real} shadow_offset_x
/// @param {Real} shadow_offset_y
/// @returns {Void}
function draw_text_shadow(x, y, text, shadow_offset_x, shadow_offset_y) {
  if (is_undefined(shadow_offset_x)) shadow_offset_x = 1;
  if (is_undefined(shadow_offset_y)) shadow_offset_y = 1;

  /// @type {Real}
  var main_colour = draw_get_colour();

  draw_set_colour(c_black);
  draw_text(x + shadow_offset_x, y + shadow_offset_y, text);
  draw_set_colour(main_colour);
  draw_text(x, y, text);
}

/// @description Draws wrapped text with an automatic shadow pass using the current draw colour for the main text.
/// @param {Real} x
/// @param {Real} y
/// @param {String} text
/// @param {Real} sep
/// @param {Real} width
/// @param {Real} shadow_offset_x
/// @param {Real} shadow_offset_y
/// @returns {Void}
function draw_text_shadow_ext(x, y, text, sep, width, shadow_offset_x, shadow_offset_y) {
  if (is_undefined(shadow_offset_x)) shadow_offset_x = 1;
  if (is_undefined(shadow_offset_y)) shadow_offset_y = 1;

  /// @type {Real}
  var main_colour = draw_get_colour();

  draw_set_colour(c_black);
  draw_text_ext(x + shadow_offset_x, y + shadow_offset_y, text, sep, width);
  draw_set_colour(main_colour);
  draw_text_ext(x, y, text, sep, width);
}

/// @description Returns HUD-space anchor coordinates for value popups.
/// @param {Real} category
/// @returns {Struct}
function game_get_value_fx_hud_anchor(category) {
  /// @type {Real}
  var gui_width = display_get_gui_width();
  /// @type {Real}
  var top_right_width = 224;
  /// @type {Real}
  var top_right_x = gui_width - top_right_width - 16;
  /// @type {Real}
  var top_right_y = 16;
  /// @type {Real}
  var anchor_x = top_right_x + 14;
  /// @type {Real}
  var anchor_y = top_right_y + 10;

  if (category == VALUE_FX_CATEGORY_COIN_GAIN || category == VALUE_FX_CATEGORY_COIN_SPEND) {
    anchor_y = top_right_y + 42;
  }

  return {
    x : anchor_x,
    y : anchor_y
  };
}

/// @description Resolves default lifetime for a value popup category.
/// @param {Real} category
/// @returns {Real}
function game_value_fx_default_life_steps(category) {
  switch (category) {
    case VALUE_FX_CATEGORY_COIN_GAIN: return VALUE_FX_COIN_GAIN_LIFE_STEPS;
    case VALUE_FX_CATEGORY_COIN_SPEND: return VALUE_FX_COIN_SPEND_LIFE_STEPS;
    case VALUE_FX_CATEGORY_HP_GAIN: return VALUE_FX_HP_GAIN_LIFE_STEPS;
    case VALUE_FX_CATEGORY_HP_LOSS: return VALUE_FX_HP_LOSS_LIFE_STEPS;
    case VALUE_FX_CATEGORY_DAMAGE: return VALUE_FX_DAMAGE_LIFE_STEPS;
  }

  return VALUE_FX_DAMAGE_LIFE_STEPS;
}

/// @description Formats a numeric amount for readable popup text.
/// @param {Real} amount
/// @returns {String}
function game_value_fx_format_amount(amount) {
  /// @type {Real}
  var rounded_amount = round(amount);
  if (abs(amount - rounded_amount) < 0.01) {
    return string(rounded_amount);
  }

  return string_format(amount, 1, 1);
}

/// @description Enqueues a generic floating value popup.
/// @param {String} value_text
/// @param {Real} category
/// @param {Real} anchor_mode
/// @param {Real} anchor_x
/// @param {Real} anchor_y
/// @param {Real} lifetime_steps
/// @param {Real} x_spread
/// @param {Real} main_colour
/// @returns {Void}
function game_enqueue_value_fx(value_text, category, anchor_mode, anchor_x, anchor_y, lifetime_steps, x_spread, main_colour) {
  if (!variable_global_exists("value_fx_popups")) {
    /// @type {Array<Struct>}
    global.value_fx_popups = [];
  }

  if (string_length(value_text) <= 0) return;

  /// @type {Real}
  var popup_life_steps = (argument_count >= 6) ? max(1, round(lifetime_steps)) : game_value_fx_default_life_steps(category);
  /// @type {Real}
  var popup_x_spread = (argument_count >= 7) ? max(0, x_spread) : 0;
  /// @type {Real}
  var popup_main_colour = (argument_count >= 8) ? main_colour : -1;

  /// @type {Struct}
  var value_popup = {
    value_text : value_text,
    category : category,
    anchor_mode : anchor_mode,
    anchor_x : anchor_x,
    anchor_y : anchor_y,
    offset_x : (popup_x_spread > 0) ? random_range(-popup_x_spread, popup_x_spread) : 0,
    main_colour : popup_main_colour,
    life : popup_life_steps,
    max_life : popup_life_steps
  };

  array_push(global.value_fx_popups, value_popup);

  /// @type {Real}
  var popup_count = array_length(global.value_fx_popups);
  if (popup_count > VALUE_FX_MAX_ACTIVE) {
    /// @type {Array<Struct>}
    var trimmed_popups = [];
    /// @type {Real}
    var trim_start = popup_count - VALUE_FX_MAX_ACTIVE;

    for (var trim_index = trim_start; trim_index < popup_count; trim_index += 1) {
      array_push(trimmed_popups, global.value_fx_popups[trim_index]);
    }

    global.value_fx_popups = trimmed_popups;
  }
}

/// @returns {Real}
function game_get_active_tower_count() {
  return max(0, instance_number(obj_tower_parent));
}

/// @param {Real} tower_type_index
/// @returns {Real}
function scr_get_tower_base_hp_cost(tower_type_index) {
  if (tower_type_index == 0) {
    return max(1, TOWER_PLACEMENT_HP_COST - 1);
  }

  return TOWER_PLACEMENT_HP_COST;
}

/// @param {Asset.GMObject|Real} tower_object
/// @returns {Real}
function scr_get_tower_type_index_from_object(tower_object) {
  /// @type {Asset.GMObject|Real}
  var flamer_object = asset_get_index("obj_tower_flamer");
  /// @type {Asset.GMObject|Real}
  var freeze_object = asset_get_index("obj_tower_freeze");

  if (tower_object == obj_tower_arrow) return 0;
  if (tower_object == obj_tower_slow) return 1;
  if (tower_object == obj_tower_cannon) return 2;
  if (flamer_object != -1 && tower_object == flamer_object) return 3;
  if (freeze_object != -1 && tower_object == freeze_object) return 4;

  return -1;
}

/// @param {Real} tower_type_index
/// @param {Real} active_tower_count
/// @returns {Real}
function game_get_tower_placement_hp_cost(tower_type_index, active_tower_count) {
  /// @type {Real}
  var resolved_tower_count = game_get_active_tower_count();
  if (argument_count >= 2 && !is_undefined(active_tower_count)) {
    resolved_tower_count = max(0, round(active_tower_count));
  }
  /// @type {Real}
  var placement_bonus = min(
    TOWER_PLACEMENT_COST_MAX_BONUS,
    floor(resolved_tower_count / max(1, TOWER_PLACEMENT_COST_STEP_TOWERS))
  );

  return max(1, scr_get_tower_base_hp_cost(tower_type_index) + placement_bonus);
}

/// @param {Real} tower_type_index
/// @param {Real} active_tower_count
/// @returns {Struct}
function scr_get_tower_description(tower_type_index, active_tower_count) {
  /// @type {Real}
  var resolved_tower_count = game_get_active_tower_count();
  if (argument_count >= 2 && !is_undefined(active_tower_count)) {
    resolved_tower_count = max(0, round(active_tower_count));
  }

  /// @type {Struct}
  var tower_description = {
    name : "Unknown",
    damage_type : "-",
    special : "-",
    hp_cost : game_get_tower_placement_hp_cost(tower_type_index, resolved_tower_count),
    base_hp_cost : scr_get_tower_base_hp_cost(tower_type_index),
    range : 0,
    name_colour : c_silver,
    range_colour : c_silver
  };

  switch (tower_type_index) {
    case 0:
      tower_description.name = "Arrow";
      tower_description.damage_type = "Single target";
      tower_description.special = "Fast direct damage";
      tower_description.range = ARROW_L1_RANGE;
      tower_description.name_colour = c_aqua;
      tower_description.range_colour = c_aqua;
      break;
    case 1:
      tower_description.name = "Slow";
      tower_description.damage_type = "Utility";
      tower_description.special = "Applies movement slow (no damage)";
      tower_description.range = SLOW_L1_RANGE;
      tower_description.name_colour = make_color_rgb(90, 195, 255);
      tower_description.range_colour = make_color_rgb(90, 195, 255);
      break;
    case 2:
      tower_description.name = "Cannon";
      tower_description.damage_type = "Splash";
      tower_description.special = "Area explosion";
      tower_description.range = CANNON_L1_RANGE;
      tower_description.name_colour = c_orange;
      tower_description.range_colour = c_orange;
      break;
    case 3:
      tower_description.name = "Flamer";
      tower_description.damage_type = "Cone";
      tower_description.special = "Applies burn over time";
      tower_description.range = FLAMER_L1_RANGE;
      tower_description.name_colour = c_red;
      tower_description.range_colour = c_red;
      break;
    case 4:
      tower_description.name = "Freeze";
      tower_description.damage_type = "Single target";
      tower_description.special = "Temporarily freezes";
      tower_description.range = FREEZE_L1_RANGE;
      tower_description.name_colour = make_color_rgb(128, 196, 255);
      tower_description.range_colour = make_color_rgb(128, 196, 255);
      break;
  }

  return tower_description;
}

/// @description Returns the gameplay tips used by the wave tips HUD panel.
/// @returns {Array<String>}
function game_get_wave_tip_pool() {
  return [
    "Life is your build currency. Leave buffer for leaks before overbuilding.",
    "Arrow towers are your cheapest stabilizer when pressure spikes.",
    "Place towers where they hit longer path segments, not just first contact.",
    "One leak hurts less than overspending life into a weak setup.",
    "Use coins for upgrades first when life is low and placement is risky.",
    "Build pressure rises with tower count, so each new base must earn value.",
    "Slow plus damage towers multiply each other. Pair control with DPS.",
    "Boss waves punish greedy life spending right before they arrive.",
    "Refunding a bad placement is often better than forcing more life spend.",
    "Cannon excels when enemies cluster. Cover choke points, not empty lanes.",
    "Freeze can buy time for every tower in range, even low-level ones.",
    "If enemies are reaching base, stabilize first and optimize later.",
    "Upgrade the tower doing the most work, not just the one nearest you.",
    "Keep at least one low-cost build option ready for emergency leaks.",
    "Wave transitions are planning windows. Decide your next spend before spawn.",
    "Do not stack identical towers blindly; diversify for control and burst.",
    "Sell and reposition when lane pressure shifts across the map.",
    "Flamer rewards sustained contact. Place it where enemies pass for longer.",
    "If you cannot afford mistakes, avoid speculative placements.",
    "Boss prep rule: enter with life buffer and at least one strong damage lane.",
    "A tower that never shoots is dead life. Prioritize uptime over theory.",
    "When in doubt, buy time: control effects reduce panic spending.",
    "Coins recover through kills; life recovery is limited, spend it carefully.",
    "Equivalent Exchange: every power gain needs a visible, intentional cost."
  ];
}

/// @description Resolves a deterministic wave tip by sequentially cycling through the tip pool.
/// @param {Real} wave_index
/// @returns {String}
function scr_get_wave_tip(wave_index) {
  /// @type {Array<String>}
  var tip_pool = game_get_wave_tip_pool();
  /// @type {Real}
  var tip_count = array_length(tip_pool);
  if (tip_count <= 0) return "Protect your life total and spend only with purpose.";

  /// @type {Real}
  var resolved_wave_index = max(1, round(wave_index));
  /// @type {Real}
  var tip_index = (resolved_wave_index - 1) mod tip_count;

  return tip_pool[tip_index];
}

/// @param {Real} amount
/// @param {Real} source_x
/// @param {Real} source_y
/// @returns {Bool}
function game_try_spend_hp(amount, source_x, source_y) {
  if (!game_is_running()) return false;
  if (amount <= 0) return true;
  if (global.player_hp < amount) return false;

  global.player_hp -= amount;
  /// @type {String}
  var hp_loss_text = "-" + game_value_fx_format_amount(amount);
  if (argument_count >= 3) {
    game_enqueue_value_fx(hp_loss_text, VALUE_FX_CATEGORY_HP_LOSS, VALUE_FX_ANCHOR_WORLD, source_x, source_y, VALUE_FX_HP_LOSS_LIFE_STEPS, 8);
  } else {
    /// @type {Struct}
    var hp_hud_anchor = game_get_value_fx_hud_anchor(VALUE_FX_CATEGORY_HP_LOSS);
    game_enqueue_value_fx(hp_loss_text, VALUE_FX_CATEGORY_HP_LOSS, VALUE_FX_ANCHOR_GUI, hp_hud_anchor.x, hp_hud_anchor.y, VALUE_FX_HP_LOSS_LIFE_STEPS, 5);
  }

  game_audio_play_life_lost(amount);
  if (global.player_hp <= 0) {
    global.player_hp = 0;
    global.game_state = GAME_STATE_GAME_OVER;
  }

  return true;
}

/// @param {Real} amount
/// @param {Real} source_x
/// @param {Real} source_y
/// @returns {Bool}
function game_try_spend_coins(amount, source_x, source_y) {
  if (!game_is_running()) return false;
  if (amount <= 0) return true;
  if (global.player_coins < amount) return false;

  global.player_coins -= amount;

  /// @type {Bool}
  var has_world_source = argument_count >= 3;
  /// @type {Real}
  var spend_source_x = has_world_source ? source_x : 0;
  /// @type {Real}
  var spend_source_y = has_world_source ? source_y : 0;

  if (!has_world_source && instance_exists(global.selected_tower_id)) {
    spend_source_x = global.selected_tower_id.x;
    spend_source_y = global.selected_tower_id.y;
    has_world_source = true;
  }

  /// @type {String}
  var spend_text = "-" + game_value_fx_format_amount(amount);
  if (has_world_source) {
    game_enqueue_value_fx(spend_text, VALUE_FX_CATEGORY_COIN_SPEND, VALUE_FX_ANCHOR_WORLD, spend_source_x, spend_source_y, VALUE_FX_COIN_SPEND_LIFE_STEPS, 10);
  } else {
    /// @type {Struct}
    var spend_hud_anchor = game_get_value_fx_hud_anchor(VALUE_FX_CATEGORY_COIN_SPEND);
    game_enqueue_value_fx(spend_text, VALUE_FX_CATEGORY_COIN_SPEND, VALUE_FX_ANCHOR_GUI, spend_hud_anchor.x, spend_hud_anchor.y, VALUE_FX_COIN_SPEND_LIFE_STEPS, 7);
  }

  if (!variable_global_exists("coin_spend_vfx_bursts")) {
    /// @type {Array<Struct>}
    global.coin_spend_vfx_bursts = [];
  }

  /// @type {Real}
  var spend_vfx_budget = clamp(round(amount * 1.2), 3, 26);

  if (has_world_source) {
    /// @type {Struct}
    var spend_burst = {
      world_x : spend_source_x,
      world_y : spend_source_y - 10,
      particle_count : spend_vfx_budget
    };

    array_push(global.coin_spend_vfx_bursts, spend_burst);
  }

  return true;
}

/// @description Triggers a short shake on a tower for failed upgrade feedback.
/// @param {Id.Instance|Real} tower_id
/// @returns {Void}
function game_trigger_tower_upgrade_fail_feedback(tower_id) {
  if (!instance_exists(tower_id)) return;

  with (tower_id) {
    if (!variable_instance_exists(id, "tower_failed_upgrade_shake_steps_total")) exit;
    tower_failed_upgrade_shake_steps_remaining = tower_failed_upgrade_shake_steps_total;
    tower_failed_upgrade_shake_dir = choose(-1, 1);
  }
}

/// @description Triggers a short shake on a tower base for failed build feedback.
/// @param {Id.Instance|Real} base_id
/// @returns {Void}
function game_trigger_base_build_fail_feedback(base_id) {
  if (!instance_exists(base_id)) return;

  with (base_id) {
    if (!variable_instance_exists(id, "base_failed_build_shake_steps_total")) exit;
    base_failed_build_shake_steps_remaining = base_failed_build_shake_steps_total;
    base_failed_build_shake_dir = choose(-1, 1);
  }
}

/// @param {Real} amount
/// @param {Real} source_x
/// @param {Real} source_y
/// @returns {Void}
function game_add_coins(amount, source_x, source_y) {
  if (amount == 0) return;

  /// @type {Real}
  var coins_before = global.player_coins;
  global.player_coins = max(0, global.player_coins + amount);

  /// @type {Real}
  var coin_delta = global.player_coins - coins_before;
  if (coin_delta == 0) return;

  if (coin_delta > 0) {
    if (!variable_global_exists("coin_hud_pop_steps")) {
      global.coin_hud_pop_steps = 0;
    }

    global.coin_hud_pop_steps = max(global.coin_hud_pop_steps, 10);
  }

  /// @type {Real}
  var coin_fx_category = (coin_delta > 0) ? VALUE_FX_CATEGORY_COIN_GAIN : VALUE_FX_CATEGORY_COIN_SPEND;
  /// @type {String}
  var coin_delta_text = ((coin_delta > 0) ? "+" : "-") + game_value_fx_format_amount(abs(coin_delta));

  if (argument_count >= 3) {
    game_enqueue_value_fx(coin_delta_text, coin_fx_category, VALUE_FX_ANCHOR_WORLD, source_x, source_y, game_value_fx_default_life_steps(coin_fx_category), 14);
  } else {
    /// @type {Struct}
    var coin_hud_anchor = game_get_value_fx_hud_anchor(coin_fx_category);
    game_enqueue_value_fx(coin_delta_text, coin_fx_category, VALUE_FX_ANCHOR_GUI, coin_hud_anchor.x, coin_hud_anchor.y, game_value_fx_default_life_steps(coin_fx_category), 7);
  }
}

/// @param {Real} amount
/// @param {Real} source_x
/// @param {Real} source_y
/// @returns {Real}
function game_add_hp(amount, source_x, source_y) {
  if (!game_is_running()) return 0;
  if (amount <= 0) return 0;

  /// @type {Real}
  var hp_before = global.player_hp;
  global.player_hp += amount;

  /// @type {Real}
  var hp_gained = global.player_hp - hp_before;
  if (hp_gained <= 0) return 0;

  /// @type {String}
  var hp_gain_text = "+" + game_value_fx_format_amount(hp_gained);
  if (argument_count >= 3) {
    game_enqueue_value_fx(hp_gain_text, VALUE_FX_CATEGORY_HP_GAIN, VALUE_FX_ANCHOR_WORLD, source_x, source_y, VALUE_FX_HP_GAIN_LIFE_STEPS, 8);
  } else {
    /// @type {Struct}
    var hp_hud_anchor = game_get_value_fx_hud_anchor(VALUE_FX_CATEGORY_HP_GAIN);
    game_enqueue_value_fx(hp_gain_text, VALUE_FX_CATEGORY_HP_GAIN, VALUE_FX_ANCHOR_GUI, hp_hud_anchor.x, hp_hud_anchor.y, VALUE_FX_HP_GAIN_LIFE_STEPS, 5);
  }

  return hp_gained;
}

/// @description Deletes the selected tower and refunds life spent on placement.
/// @returns {Bool}
function game_delete_selected_tower_refund_life() {
  if (!game_is_running()) return false;

  /// @type {Id.Instance|Real}
  var selected_tower_id = global.selected_tower_id;
  if (!instance_exists(selected_tower_id)) {
    global.selected_tower_id = noone;
    return false;
  }

  /// @type {Asset.GMObject|Real}
  var selected_tower_object = selected_tower_id.object_index;
  if (!(selected_tower_object == obj_tower_parent || object_is_ancestor(selected_tower_object, obj_tower_parent))) {
    global.selected_tower_id = noone;
    return false;
  }

  /// @type {Id.Instance|Real}
  var base_owner_id = variable_instance_exists(selected_tower_id, "base_owner_id") ? selected_tower_id.base_owner_id : noone;

  /// @type {Real}
  var fallback_tower_type_index = scr_get_tower_type_index_from_object(selected_tower_object);
  /// @type {Real}
  var fallback_refund_hp = scr_get_tower_base_hp_cost(fallback_tower_type_index);
  /// @type {Real}
  var placement_refund_hp = variable_instance_exists(selected_tower_id, "tower_placement_hp_cost") ? selected_tower_id.tower_placement_hp_cost : fallback_refund_hp;
  game_add_hp(placement_refund_hp, selected_tower_id.x, selected_tower_id.y);
  if (instance_exists(base_owner_id)) {
    with (base_owner_id) {
      occupied = false;
      tower_instance_id = noone;
    }
  }

  with (selected_tower_id) {
    instance_destroy();
  }

  global.selected_tower_id = noone;
  return true;
}

/// @param {Real} spawn_x
/// @param {Real} spawn_y
/// @param {Real} coin_value
/// @returns {Bool}
function game_spawn_coin_drop(spawn_x, spawn_y, coin_value) {
  if (!game_is_running()) return false;
  if (coin_value <= 0) return false;

  /// @type {Id.Instance|Real}
  var coin_instance = instance_create_layer(spawn_x, spawn_y, "Instances", obj_coin_pickup, {
    coin_value : coin_value,
    coin_ground_y : spawn_y
  });

  return instance_exists(coin_instance);
}

/// @param {Real} leak_damage
/// @param {Real} source_x
/// @param {Real} source_y
/// @returns {Void}
function game_register_leak(leak_damage, source_x, source_y) {
  if (!game_is_running()) return;
  if (leak_damage <= 0) return;

  /// @type {Real}
  var hp_before = global.player_hp;
  global.player_hp = max(0, global.player_hp - leak_damage);
  /// @type {Real}
  var hp_lost = hp_before - global.player_hp;
  if (hp_lost > 0) {
    game_audio_play_life_lost(hp_lost);

    /// @type {Real}
    var leak_flash_steps = max(1, round(LEAK_EDGE_FLASH_SECONDS * room_speed));
    if (!variable_global_exists("leak_edge_flash_steps_remaining")) {
      global.leak_edge_flash_steps_remaining = 0;
    }
    if (!variable_global_exists("leak_edge_flash_intensity")) {
      global.leak_edge_flash_intensity = 0;
    }
    global.leak_edge_flash_steps_remaining = max(global.leak_edge_flash_steps_remaining, leak_flash_steps);
    global.leak_edge_flash_intensity = clamp(
      max(global.leak_edge_flash_intensity, 0.45) + (hp_lost * LEAK_EDGE_FLASH_STACK_PER_HP),
      0,
      1
    );

    /// @type {String}
    var hp_loss_text = "-" + game_value_fx_format_amount(hp_lost);
    if (argument_count >= 3) {
      game_enqueue_value_fx(hp_loss_text, VALUE_FX_CATEGORY_HP_LOSS, VALUE_FX_ANCHOR_WORLD, source_x, source_y, VALUE_FX_HP_LOSS_LIFE_STEPS, 8);
    } else {
      /// @type {Struct}
      var hp_hud_anchor = game_get_value_fx_hud_anchor(VALUE_FX_CATEGORY_HP_LOSS);
      game_enqueue_value_fx(hp_loss_text, VALUE_FX_CATEGORY_HP_LOSS, VALUE_FX_ANCHOR_GUI, hp_hud_anchor.x, hp_hud_anchor.y, VALUE_FX_HP_LOSS_LIFE_STEPS, 5);
    }
  }

  if (global.player_hp <= 0) {
    global.game_state = GAME_STATE_GAME_OVER;
  }
}

/// @param {Id.Instance} enemy_instance
/// @param {Real} damage
/// @param {Id.Instance|Real} source_tower_id
/// @returns {Bool}
function enemy_register_hit_feedback(enemy_instance, damage) {
  if (!instance_exists(enemy_instance)) return;
  if (enemy_instance.is_dead || enemy_instance.has_leaked) return;

  game_decals_stamp_blood(enemy_instance.x, enemy_instance.y, damage);

  with (enemy_instance) {
    enemy_hit_flash_steps_remaining = max(enemy_hit_flash_steps_remaining, enemy_hit_flash_steps_total);

    if (enemy_hit_audio_cooldown_steps_remaining <= 0) {
      /// @type {Real}
      var damage_gain_scale = clamp(0.85 + (damage * 0.03), 0.85, 1.15);

      audio_play_variation(
        WAV_Small_Spark_1,
        WAV_Small_Spark_2,
        (AUDIO_GAIN_COMBAT * ENEMY_HIT_AUDIO_GAIN_SCALE) * damage_gain_scale,
        ENEMY_HIT_AUDIO_PITCH_MIN,
        ENEMY_HIT_AUDIO_PITCH_MAX
      );

      enemy_hit_audio_cooldown_steps_remaining = enemy_hit_audio_cooldown_steps_total;
    }
  }
}

/// @description Resolves damage popup colour from source tower type.
/// @param {Id.Instance|Real} source_tower_id
/// @returns {Real}
function game_damage_popup_colour_from_source(source_tower_id) {
  if (!instance_exists(source_tower_id)) return -1;

  /// @type {Asset.GMObject|Real}
  var source_object = source_tower_id.object_index;

  if (source_object == obj_tower_arrow) return VALUE_FX_DAMAGE_COLOUR_ARROW;
  if (source_object == obj_tower_slow) return VALUE_FX_DAMAGE_COLOUR_SLOW;
  if (source_object == obj_tower_cannon) return VALUE_FX_DAMAGE_COLOUR_CANNON;
  if (source_object == obj_tower_flamer) return VALUE_FX_DAMAGE_COLOUR_FLAMER;
  if (source_object == obj_tower_freeze) return VALUE_FX_DAMAGE_COLOUR_FREEZE;

  return -1;
}

/// @param {Id.Instance} enemy_instance
/// @param {Real} damage
/// @param {Id.Instance|Real} source_tower_id
/// @returns {Bool}
function enemy_take_damage(enemy_instance, damage, source_tower_id) {
  if (!instance_exists(enemy_instance)) return false;
  if (damage <= 0) return false;

  if (argument_count < 3) {
    source_tower_id = noone;
  }

  /// @type {Bool}
  var source_is_valid = instance_exists(source_tower_id);
  if (source_is_valid) {
    /// @type {Asset.GMObject|Real}
    var source_object = source_tower_id.object_index;
    source_is_valid = (source_object == obj_tower_parent || object_is_ancestor(source_object, obj_tower_parent));
  }

  if (enemy_instance.is_dead || enemy_instance.has_leaked) return false;

  enemy_instance.enemy_hp -= damage;
  if (source_is_valid) {
    enemy_instance.enemy_last_damage_source = source_tower_id;
  }

  enemy_register_hit_feedback(enemy_instance, damage);
  game_enqueue_value_fx(
    game_value_fx_format_amount(damage),
    VALUE_FX_CATEGORY_DAMAGE,
    VALUE_FX_ANCHOR_WORLD,
    enemy_instance.x,
    enemy_instance.y,
    VALUE_FX_DAMAGE_LIFE_STEPS,
    12,
    game_damage_popup_colour_from_source(source_tower_id)
  );

  return true;
}

/// @param {Id.Instance} enemy_instance
/// @param {Real} slow_factor
/// @param {Real} duration_steps
/// @returns {Void}
function enemy_apply_slow(enemy_instance, slow_factor, duration_steps) {
  if (!instance_exists(enemy_instance)) return;

  with (enemy_instance) {
    if (is_dead || has_leaked) return;

    enemy_slow_factor = min(enemy_slow_factor, slow_factor);
    enemy_slow_timer_steps = max(enemy_slow_timer_steps, duration_steps);

    if (enemy_status_slow_decal_cooldown_steps_remaining <= 0) {
      game_decals_stamp_slow(x, y, 1 - slow_factor);
      enemy_status_slow_decal_cooldown_steps_remaining = max(1, round(room_speed * DECAL_STATUS_GROUND_COOLDOWN_SECONDS));
    }
  }
}

/// @param {Id.Instance} enemy_instance
/// @param {Real} damage_per_tick
/// @param {Real} duration_steps
/// @returns {Void}
function enemy_apply_burn(enemy_instance, damage_per_tick, duration_steps) {
  if (!instance_exists(enemy_instance)) return;
  if (damage_per_tick <= 0) return;
  if (duration_steps <= 0) return;

  with (enemy_instance) {
    if (is_dead || has_leaked) return;

    enemy_burn_damage_per_tick = max(enemy_burn_damage_per_tick, damage_per_tick);
    enemy_burn_timer_steps = max(enemy_burn_timer_steps, duration_steps);

    if (enemy_burn_tick_steps_remaining <= 0) {
      enemy_burn_tick_steps_remaining = max(1, round(ENEMY_BURN_TICK_SECONDS * room_speed));
    }

    if (enemy_status_burn_decal_cooldown_steps_remaining <= 0) {
      game_decals_stamp_flame(x, y, damage_per_tick);
      enemy_status_burn_decal_cooldown_steps_remaining = max(1, round(room_speed * DECAL_STATUS_GROUND_COOLDOWN_SECONDS));
    }
  }
}

/// @param {Id.Instance} enemy_instance
/// @param {Real} duration_steps
/// @returns {Void}
function enemy_apply_freeze(enemy_instance, duration_steps) {
  if (!instance_exists(enemy_instance)) return;
  if (duration_steps <= 0) return;

  with (enemy_instance) {
    if (is_dead || has_leaked) return;

    // Refresh freeze by extending to the strongest remaining timer.
    enemy_freeze_timer_steps = max(enemy_freeze_timer_steps, duration_steps);

    if (enemy_status_freeze_decal_cooldown_steps_remaining <= 0) {
      game_decals_stamp_ice(x, y, duration_steps);
      enemy_status_freeze_decal_cooldown_steps_remaining = max(1, round(room_speed * DECAL_STATUS_GROUND_COOLDOWN_SECONDS));
    }
  }
}

/// @param {Asset.GMSound|Real} sound_a
/// @param {Asset.GMSound|Real} sound_b
/// @returns {Asset.GMSound|Real}
function audio_pick(sound_a, sound_b) {
  if (sound_a == -1) return sound_b;
  if (sound_b == -1) return sound_a;
  return choose(sound_a, sound_b);
}

/// @param {Asset.GMSound|Real} sound_id
/// @param {Real} gain
/// @param {Real} pitch_min
/// @param {Real} pitch_max
/// @returns {Real}
function audio_play_one_shot(sound_id, gain, pitch_min, pitch_max) {
  if (sound_id == -1) return -1;

  /// @type {Real}
  var pitch_low = min(pitch_min, pitch_max);
  /// @type {Real}
  var pitch_high = max(pitch_min, pitch_max);
  /// @type {Real}
  var sound_instance = audio_play_sound(sound_id, 0, false);

  if (sound_instance != -1) {
    audio_sound_gain(sound_instance, max(0, gain), 0);
    audio_sound_pitch(sound_instance, random_range(pitch_low, pitch_high));
  }

  return sound_instance;
}

/// @param {Asset.GMSound|Real} sound_a
/// @param {Asset.GMSound|Real} sound_b
/// @param {Real} gain
/// @param {Real} pitch_min
/// @param {Real} pitch_max
/// @returns {Real}
function audio_play_variation(sound_a, sound_b, gain, pitch_min, pitch_max) {
  /// @type {Asset.GMSound|Real}
  var picked_sound = audio_pick(sound_a, sound_b);
  return audio_play_one_shot(picked_sound, gain, pitch_min, pitch_max);
}

/// @returns {Void}
function game_audio_start_ambience() {
  if (!variable_global_exists("ambient_sound_instance")) {
    global.ambient_sound_instance = -1;
  }

  if (global.ambient_sound_instance != -1 && audio_is_playing(global.ambient_sound_instance)) {
    audio_sound_gain(global.ambient_sound_instance, AUDIO_GAIN_AMBIENCE, 0);
    return;
  }

  global.ambient_sound_instance = audio_play_sound(WAV_SND_Grasslands, 0, true);
  if (global.ambient_sound_instance != -1) {
    audio_sound_gain(global.ambient_sound_instance, AUDIO_GAIN_AMBIENCE, 0);
  }
}

/// @returns {Void}
function game_audio_stop_ambience() {
  if (!variable_global_exists("ambient_sound_instance")) return;
  if (global.ambient_sound_instance == -1) return;

  audio_stop_sound(global.ambient_sound_instance);
  global.ambient_sound_instance = -1;
}

/// @param {String} enemy_family
/// @returns {Void}
function game_audio_play_enemy_call(enemy_family) {
  if (!game_is_running()) return;
  if (!variable_global_exists("enemy_call_sfx_cooldown_steps_remaining")) return;
  if (global.enemy_call_sfx_cooldown_steps_remaining > 0) return;

  audio_play_one_shot(WAV_Hoof_sounds_on_grass, AUDIO_GAIN_ENEMY_CALL, 0.95, 1.04);

  if (!variable_global_exists("enemy_call_sfx_cooldown_steps_total")) {
    global.enemy_call_sfx_cooldown_steps_total = max(1, round(room_speed * AUDIO_ENEMY_CALL_COOLDOWN_SECONDS));
  }

  global.enemy_call_sfx_cooldown_steps_remaining = global.enemy_call_sfx_cooldown_steps_total;
}

/// @param {Real} hp_lost
/// @returns {Void}
function game_audio_play_life_lost(hp_lost) {
  if (hp_lost <= 0) return;

  /// @type {Real}
  var gain_scale = clamp(0.85 + (hp_lost * 0.05), 0.85, 1.2);
  audio_play_variation(
    WAV_Badger_Hiss_1,
    WAV_Badger_Hiss_2,
    AUDIO_GAIN_LIFE_LOST * gain_scale,
    0.92,
    1.02
  );
}

/// @returns {Void}
function game_decals_init() {
  global.decal_surface_static = -1;
  global.decal_surface_dynamic = -1;
  global.decal_surface_w = max(1, room_width);
  global.decal_surface_h = max(1, room_height);
  global.decal_static_marks = [];
  global.decal_dynamic_marks = [];

  game_decals_ensure_surfaces();
  game_decals_rebuild_static_surface();
  game_decals_rebuild_dynamic_surface();
}

/// @returns {Void}
function game_decals_shutdown() {
  if (surface_exists(global.decal_surface_static)) {
    surface_free(global.decal_surface_static);
  }

  if (surface_exists(global.decal_surface_dynamic)) {
    surface_free(global.decal_surface_dynamic);
  }

  global.decal_surface_static = -1;
  global.decal_surface_dynamic = -1;
  global.decal_static_marks = [];
  global.decal_dynamic_marks = [];
}

/// @returns {Void}
function game_decals_ensure_surfaces() {
  if (!variable_global_exists("decal_surface_static")) global.decal_surface_static = -1;
  if (!variable_global_exists("decal_surface_dynamic")) global.decal_surface_dynamic = -1;
  if (!variable_global_exists("decal_surface_w")) global.decal_surface_w = max(1, room_width);
  if (!variable_global_exists("decal_surface_h")) global.decal_surface_h = max(1, room_height);
  if (!variable_global_exists("decal_static_marks")) global.decal_static_marks = [];
  if (!variable_global_exists("decal_dynamic_marks")) global.decal_dynamic_marks = [];

  /// @type {Real}
  var target_w = max(1, room_width);
  /// @type {Real}
  var target_h = max(1, room_height);
  /// @type {Bool}
  var needs_rebuild_static = false;
  /// @type {Bool}
  var needs_rebuild_dynamic = false;

  if (global.decal_surface_w != target_w || global.decal_surface_h != target_h) {
    global.decal_surface_w = target_w;
    global.decal_surface_h = target_h;
    needs_rebuild_static = true;
    needs_rebuild_dynamic = true;
  }

  if (!surface_exists(global.decal_surface_static)) {
    global.decal_surface_static = surface_create(global.decal_surface_w, global.decal_surface_h);
    needs_rebuild_static = true;
  }

  if (!surface_exists(global.decal_surface_dynamic)) {
    global.decal_surface_dynamic = surface_create(global.decal_surface_w, global.decal_surface_h);
    needs_rebuild_dynamic = true;
  }

  if (needs_rebuild_static) {
    game_decals_rebuild_static_surface();
  }

  if (needs_rebuild_dynamic) {
    game_decals_rebuild_dynamic_surface();
  }
}

/// @returns {Void}
function game_decals_rebuild_static_surface() {
  if (!surface_exists(global.decal_surface_static)) return;

  surface_set_target(global.decal_surface_static);
  draw_clear_alpha(c_black, 0);

  /// @type {Real}
  var static_count = array_length(global.decal_static_marks);
  for (var i = 0; i < static_count; i += 1) {
    game_decals_draw_mark(global.decal_static_marks[i], global.decal_static_marks[i].alpha);
  }

  surface_reset_target();
}

/// @returns {Void}
function game_decals_rebuild_dynamic_surface() {
  if (!surface_exists(global.decal_surface_dynamic)) return;

  surface_set_target(global.decal_surface_dynamic);
  draw_clear_alpha(c_black, 0);

  /// @type {Real}
  var dynamic_count = array_length(global.decal_dynamic_marks);
  for (var i = 0; i < dynamic_count; i += 1) {
    /// @type {Struct}
    var mark = global.decal_dynamic_marks[i];
    /// @type {Real}
    var fade = clamp(mark.life / max(1, mark.max_life), 0, 1);
    game_decals_draw_mark(mark, mark.alpha * fade);
  }

  surface_reset_target();
}

/// @param {Struct} mark
/// @param {Real} alpha_override
/// @returns {Void}
function game_decals_noise(seed, channel) {
  /// @type {Real}
  var n = sin((seed * 12.9898) + (channel * 78.233)) * 43758.5453;
  return n - floor(n);
}

/// @param {Struct} mark
/// @param {Real} draw_alpha
/// @param {Real} outer_colour
/// @param {Real} inner_colour
/// @param {Real} lobe_count
/// @returns {Void}
function game_decals_draw_blob(mark, draw_alpha, outer_colour, inner_colour, lobe_count) {
  /// @type {Real}
  var seed = variable_struct_exists(mark, "seed") ? mark.seed : ((mark.x * 17) + (mark.y * 11) + (mark.size * 9));

  draw_set_alpha(clamp(draw_alpha * 0.92, 0, 1));
  draw_set_colour(outer_colour);
  draw_circle(mark.x, mark.y, max(1.2, mark.size * 0.62), false);

  for (var i = 0; i < lobe_count + 2; i += 1) {
    /// @type {Real}
    var angle = game_decals_noise(seed, i + 1) * 360;
    /// @type {Real}
    var dist = mark.size * (0.12 + (game_decals_noise(seed, 40 + i) * 0.78));
    /// @type {Real}
    var radius = max(1, mark.size * (0.20 + (game_decals_noise(seed, 80 + i) * 0.36)));

    draw_circle(
      mark.x + lengthdir_x(dist, angle),
      mark.y + lengthdir_y(dist, angle),
      radius,
      false
    );
  }

  draw_set_alpha(clamp(draw_alpha * 0.72, 0, 1));
  draw_set_colour(inner_colour);

  for (var j = 0; j < max(3, floor(lobe_count * 0.82)); j += 1) {
    /// @type {Real}
    var inner_angle = game_decals_noise(seed, 140 + j) * 360;
    /// @type {Real}
    var inner_dist = mark.size * (0.08 + (game_decals_noise(seed, 170 + j) * 0.38));
    /// @type {Real}
    var inner_radius = max(0.9, mark.size * (0.16 + (game_decals_noise(seed, 200 + j) * 0.24)));

    draw_circle(
      mark.x + lengthdir_x(inner_dist, inner_angle),
      mark.y + lengthdir_y(inner_dist, inner_angle),
      inner_radius,
      false
    );
  }
}

/// @param {Struct} mark
/// @param {Real} draw_alpha
/// @returns {Void}
function game_decals_draw_track(mark, draw_alpha) {
  /// @type {Real}
  var seed = variable_struct_exists(mark, "seed") ? mark.seed : ((mark.x * 19) + (mark.y * 13) + (mark.angle * 0.7));
  /// @type {Real}
  var pair_offset = DECAL_TRACK_PAIR_OFFSET * mark.size;
  /// @type {Real}
  var track_colour = make_color_rgb(98, 72, 48);
  /// @type {Real}
  var track_inner_colour = make_color_rgb(138, 106, 74);
  /// @type {Real}
  var wheel_spacing = mark.size * 2.1;
  /// @type {Array<Real>}
  var wheel_offsets = [-1.5, -0.5, 0.5, 1.5];

  draw_set_alpha(clamp(draw_alpha * 0.96, 0, 1));
  draw_set_colour(track_colour);

  for (var side = 0; side < 2; side += 1) {
    /// @type {Real}
    var side_sign = (side == 0) ? 1 : -1;
    /// @type {Real}
    var side_seed_offset = side * 31;
    /// @type {Real}
    var side_x = mark.x + lengthdir_x(pair_offset, mark.angle + (90 * side_sign));
    /// @type {Real}
    var side_y = mark.y + lengthdir_y(pair_offset, mark.angle + (90 * side_sign));

    for (var wheel = 0; wheel < array_length(wheel_offsets); wheel += 1) {
      /// @type {Real}
      var seg_dist = wheel_offsets[wheel] * wheel_spacing;
      /// @type {Real}
      var seg_jitter = (game_decals_noise(seed, 240 + side_seed_offset + wheel) * 2 - 1) * (mark.size * 0.32);
      /// @type {Real}
      var wheel_x = side_x + lengthdir_x(seg_dist, mark.angle) + lengthdir_x(seg_jitter, mark.angle + 90);
      /// @type {Real}
      var wheel_y = side_y + lengthdir_y(seg_dist, mark.angle) + lengthdir_y(seg_jitter, mark.angle + 90);

      /// @type {Real}
      var line_len = max(2.4, mark.size * (2.2 + (game_decals_noise(seed, 280 + side_seed_offset + wheel) * 0.8)));
      /// @type {Real}
      var half_len = line_len * 0.5;
      /// @type {Real}
      var line_x1 = wheel_x + lengthdir_x(-half_len, mark.angle);
      /// @type {Real}
      var line_y1 = wheel_y + lengthdir_y(-half_len, mark.angle);
      /// @type {Real}
      var line_x2 = wheel_x + lengthdir_x(half_len, mark.angle);
      /// @type {Real}
      var line_y2 = wheel_y + lengthdir_y(half_len, mark.angle);

      // Per-wheel tread segment oriented to movement direction.
      draw_line(line_x1, line_y1, line_x2, line_y2);
      draw_line(
        line_x1 + lengthdir_x(0.9, mark.angle + 90),
        line_y1 + lengthdir_y(0.9, mark.angle + 90),
        line_x2 + lengthdir_x(0.9, mark.angle + 90),
        line_y2 + lengthdir_y(0.9, mark.angle + 90)
      );

      draw_set_alpha(clamp(draw_alpha * 0.48, 0, 1));
      draw_set_colour(track_inner_colour);
      draw_line(
        wheel_x + lengthdir_x(-(half_len * 0.72), mark.angle),
        wheel_y + lengthdir_y(-(half_len * 0.72), mark.angle),
        wheel_x + lengthdir_x((half_len * 0.72), mark.angle),
        wheel_y + lengthdir_y((half_len * 0.72), mark.angle)
      );
      draw_set_alpha(clamp(draw_alpha * 0.96, 0, 1));
      draw_set_colour(track_colour);
    }
  }
}

/// @param {Struct} mark
/// @param {Real} alpha_override
/// @returns {Void}
function game_decals_draw_mark(mark, alpha_override) {
  /// @type {Real}
  var draw_alpha = clamp(alpha_override, 0, 1);
  if (draw_alpha <= 0) return;

  draw_set_alpha(draw_alpha);

  switch (mark.type) {
    case DECAL_TYPE_BLOOD:
      game_decals_draw_blob(mark, draw_alpha, make_color_rgb(132, 24, 20), make_color_rgb(82, 10, 8), 6);
      break;

    case DECAL_TYPE_ICE:
      game_decals_draw_blob(mark, draw_alpha, make_color_rgb(150, 215, 255), make_color_rgb(218, 246, 255), 6);
      break;

    case DECAL_TYPE_QUAKE:
      game_decals_draw_blob(mark, draw_alpha, make_color_rgb(122, 104, 90), make_color_rgb(78, 66, 58), 7);
      break;

    case DECAL_TYPE_FLAME:
      game_decals_draw_blob(mark, draw_alpha, make_color_rgb(255, 116, 34), make_color_rgb(120, 24, 8), 6);
      break;

    case DECAL_TYPE_SLOW:
      game_decals_draw_blob(mark, draw_alpha, make_color_rgb(122, 136, 58), make_color_rgb(64, 78, 29), 6);
      break;

    case DECAL_TYPE_TRACK:
      game_decals_draw_track(mark, draw_alpha);
      break;
  }

  draw_set_alpha(1);
  draw_set_colour(c_white);
}

/// @param {Real} mark_type
/// @param {Real} px
/// @param {Real} py
/// @param {Real} size
/// @param {Real} alpha
/// @param {Real} angle
/// @returns {Void}
function game_decals_add_static_mark(mark_type, px, py, size, alpha, angle) {
  game_decals_ensure_surfaces();

  /// @type {Struct}
  var mark = {
    type : mark_type,
    x : px,
    y : py,
    size : size,
    alpha : alpha,
    angle : angle,
    seed : random(1000000),
    life : 1,
    max_life : 1
  };

  array_push(global.decal_static_marks, mark);

  /// @type {Bool}
  var exceeded = array_length(global.decal_static_marks) > DECAL_STATIC_MAX_MARKS;
  if (exceeded) {
    array_delete(global.decal_static_marks, 0, 1);
    game_decals_rebuild_static_surface();
    return;
  }

  if (!surface_exists(global.decal_surface_static)) return;

  surface_set_target(global.decal_surface_static);
  game_decals_draw_mark(mark, mark.alpha);
  surface_reset_target();
}

/// @param {Real} mark_type
/// @param {Real} px
/// @param {Real} py
/// @param {Real} size
/// @param {Real} alpha
/// @param {Real} angle
/// @param {Real} life_steps
/// @returns {Void}
function game_decals_add_dynamic_mark(mark_type, px, py, size, alpha, angle, life_steps) {
  game_decals_ensure_surfaces();

  /// @type {Struct}
  var mark = {
    type : mark_type,
    x : px,
    y : py,
    size : size,
    alpha : alpha,
    angle : angle,
    seed : random(1000000),
    life : max(1, life_steps),
    max_life : max(1, life_steps)
  };

  array_push(global.decal_dynamic_marks, mark);

  if (array_length(global.decal_dynamic_marks) > DECAL_DYNAMIC_MAX_MARKS) {
    array_delete(global.decal_dynamic_marks, 0, 1);
  }
}

/// @returns {Void}
function game_decals_update() {
  game_decals_ensure_surfaces();

  /// @type {Array<Struct>}
  var next_marks = [];
  /// @type {Real}
  var mark_count = array_length(global.decal_dynamic_marks);

  for (var i = 0; i < mark_count; i += 1) {
    /// @type {Struct}
    var mark = global.decal_dynamic_marks[i];
    mark.life -= 1;
    if (mark.life > 0) {
      array_push(next_marks, mark);
    }
  }

  global.decal_dynamic_marks = next_marks;
  game_decals_rebuild_dynamic_surface();
}

/// @returns {Void}
function game_decals_draw() {
  game_decals_ensure_surfaces();

  if (surface_exists(global.decal_surface_static)) {
    draw_surface(global.decal_surface_static, 0, 0);
  }

  if (surface_exists(global.decal_surface_dynamic)) {
    draw_surface(global.decal_surface_dynamic, 0, 0);
  }
}

/// @param {Real} px
/// @param {Real} py
/// @param {Real} damage
/// @returns {Void}
function game_decals_stamp_blood(px, py, damage) {
  /// @type {Real}
  var intensity = clamp(damage * 0.35, 0, DECAL_BLOOD_SIZE_MAX - DECAL_BLOOD_SIZE_MIN);
  /// @type {Real}
  var size = clamp(DECAL_BLOOD_SIZE_MIN + intensity, DECAL_BLOOD_SIZE_MIN, DECAL_BLOOD_SIZE_MAX);
  /// @type {Real}
  var alpha = random_range(DECAL_BLOOD_ALPHA_MIN, DECAL_BLOOD_ALPHA_MAX);

  game_decals_add_static_mark(
    DECAL_TYPE_BLOOD,
    px + random_range(-2.2, 2.2),
    py + random_range(-2.2, 2.2),
    size,
    alpha,
    random(360)
  );
}

/// @param {Real} px
/// @param {Real} py
/// @param {Real} duration_steps
/// @returns {Void}
function game_decals_stamp_ice(px, py, duration_steps) {
  /// @type {Real}
  var size_bonus = clamp(duration_steps / max(1, room_speed), 0, 3.5);
  /// @type {Real}
  var size = clamp(DECAL_ICE_SIZE_MIN + size_bonus, DECAL_ICE_SIZE_MIN, DECAL_ICE_SIZE_MAX);

  game_decals_add_static_mark(
    DECAL_TYPE_ICE,
    px + random_range(-1.2, 1.2),
    py + random_range(-1.2, 1.2),
    size,
    DECAL_ICE_ALPHA,
    random(360)
  );
}

/// @param {Real} px
/// @param {Real} py
/// @param {Real} burn_strength
/// @returns {Void}
function game_decals_stamp_flame(px, py, burn_strength) {
  /// @type {Real}
  var size_bonus = clamp(burn_strength * 1.8, 0, DECAL_FLAME_SIZE_MAX - DECAL_FLAME_SIZE_MIN);
  /// @type {Real}
  var size = clamp(DECAL_FLAME_SIZE_MIN + size_bonus, DECAL_FLAME_SIZE_MIN, DECAL_FLAME_SIZE_MAX);

  game_decals_add_static_mark(
    DECAL_TYPE_FLAME,
    px + random_range(-1.6, 1.6),
    py + random_range(-1.6, 1.6),
    size,
    DECAL_FLAME_ALPHA,
    random(360)
  );
}

/// @param {Real} px
/// @param {Real} py
/// @param {Real} slow_strength
/// @returns {Void}
function game_decals_stamp_slow(px, py, slow_strength) {
  /// @type {Real}
  var size_bonus = clamp(slow_strength * 8, 0, DECAL_SLOW_SIZE_MAX - DECAL_SLOW_SIZE_MIN);
  /// @type {Real}
  var size = clamp(DECAL_SLOW_SIZE_MIN + size_bonus, DECAL_SLOW_SIZE_MIN, DECAL_SLOW_SIZE_MAX);

  game_decals_add_static_mark(
    DECAL_TYPE_SLOW,
    px + random_range(-1.4, 1.4),
    py + random_range(-1.4, 1.4),
    size,
    DECAL_SLOW_ALPHA,
    random(360)
  );
}

/// @param {Real} px
/// @param {Real} py
/// @param {Real} splash_radius
/// @returns {Void}
function game_decals_stamp_quake(px, py, splash_radius) {
  /// @type {Real}
  var base_size = clamp((splash_radius * 0.2) + DECAL_QUAKE_SIZE_MIN, DECAL_QUAKE_SIZE_MIN, DECAL_QUAKE_SIZE_MAX);

  game_decals_add_static_mark(
    DECAL_TYPE_QUAKE,
    px,
    py,
    base_size,
    DECAL_QUAKE_ALPHA,
    random(360)
  );

  for (var i = 0; i < 2; i += 1) {
    game_decals_add_static_mark(
      DECAL_TYPE_QUAKE,
      px + random_range(-6, 6),
      py + random_range(-6, 6),
      max(3, base_size * random_range(0.45, 0.72)),
      DECAL_QUAKE_ALPHA * 0.75,
      random(360)
    );
  }
}

/// @param {Real} px
/// @param {Real} py
/// @param {Real} move_angle
/// @param {Real} speed_factor
/// @returns {Void}
function game_decals_stamp_track(px, py, move_angle, speed_factor) {
  /// @type {Real}
  var alpha = lerp(DECAL_TRACK_ALPHA_MIN, DECAL_TRACK_ALPHA_MAX, clamp(speed_factor, 0, 1));
  /// @type {Real}
  var size = random_range(DECAL_TRACK_SIZE_MIN, DECAL_TRACK_SIZE_MAX);
  /// @type {Real}
  var life_steps = max(1, round(room_speed * DECAL_TRACK_LIFETIME_SECONDS));

  game_decals_add_dynamic_mark(DECAL_TYPE_TRACK, px, py, size, alpha, move_angle, life_steps);
}