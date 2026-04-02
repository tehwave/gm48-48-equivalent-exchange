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
  var blur_surface_width = max(8, round(source_width / max(1, PANEL_BLUR_DOWNSAMPLE)));
  /// @type {Real}
  var blur_surface_height = max(8, round(source_height / max(1, PANEL_BLUR_DOWNSAMPLE)));

  if (!variable_global_exists("panel_blur_surface_a")) global.panel_blur_surface_a = -1;
  if (!variable_global_exists("panel_blur_surface_b")) global.panel_blur_surface_b = -1;
  if (!variable_global_exists("panel_blur_surface_w")) global.panel_blur_surface_w = 0;
  if (!variable_global_exists("panel_blur_surface_h")) global.panel_blur_surface_h = 0;

  /// Recreate pooled blur surfaces only when current panel needs a larger allocation.
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

  /// @type {Real}
  var blur_w = global.panel_blur_surface_w;
  /// @type {Real}
  var blur_h = global.panel_blur_surface_h;
  /// @type {Real}
  var capture_scale_x = blur_w / source_width;
  /// @type {Real}
  var capture_scale_y = blur_h / source_height;

  gpu_set_texfilter(true);

  surface_set_target(global.panel_blur_surface_a);
  draw_clear_alpha(c_black, 0);
  draw_set_alpha(1);
  draw_set_colour(c_white);
  draw_surface_part_ext(application_surface, source_x, source_y, source_width, source_height, 0, 0, capture_scale_x, capture_scale_y, c_white, 1);
  surface_reset_target();

  /// @type {Real}
  var surface_a = global.panel_blur_surface_a;
  /// @type {Real}
  var surface_b = global.panel_blur_surface_b;
  /// @type {Real}
  var blur_pass_count = max(1, round(PANEL_BLUR_PASSES));

  for (var blur_pass = 0; blur_pass < blur_pass_count; blur_pass += 1) {
    /// @type {Real}
    var blur_radius = (blur_pass + 1) * PANEL_BLUR_PASS_STEP;

    surface_set_target(surface_b);
    draw_clear_alpha(c_black, 0);
    draw_set_colour(c_white);

    draw_set_alpha(0.30);
    draw_surface_ext(surface_a, 0, 0, 1, 1, 0, c_white, 1);

    draw_set_alpha(0.12);
    draw_surface_ext(surface_a, -blur_radius, 0, 1, 1, 0, c_white, 1);
    draw_surface_ext(surface_a, blur_radius, 0, 1, 1, 0, c_white, 1);
    draw_surface_ext(surface_a, 0, -blur_radius, 1, 1, 0, c_white, 1);
    draw_surface_ext(surface_a, 0, blur_radius, 1, 1, 0, c_white, 1);

    draw_set_alpha(0.055);
    draw_surface_ext(surface_a, -blur_radius, -blur_radius, 1, 1, 0, c_white, 1);
    draw_surface_ext(surface_a, blur_radius, -blur_radius, 1, 1, 0, c_white, 1);
    draw_surface_ext(surface_a, -blur_radius, blur_radius, 1, 1, 0, c_white, 1);
    draw_surface_ext(surface_a, blur_radius, blur_radius, 1, 1, 0, c_white, 1);

    surface_reset_target();

    /// @type {Real}
    var surface_swap = surface_a;
    surface_a = surface_b;
    surface_b = surface_swap;
  }

  /// @type {Real}
  var blur_alpha = clamp(PANEL_BLUR_ALPHA, 0, 1);

  draw_set_alpha(blur_alpha);
  draw_set_colour(c_white);
  draw_surface_ext(surface_a, px, py, pw / blur_w, ph / blur_h, 0, c_white, 1);

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
  draw_set_alpha(clamp(bg_alpha, 0, 1));
  draw_set_colour(c_black);
  draw_roundrect_ext(px, py, px + pw, py + ph, corner_radius, corner_radius, false);
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

/// @param {Real} tower_type_index
/// @returns {Struct}
function scr_get_tower_description(tower_type_index) {
  /// @type {Struct}
  var tower_description = {
    name : "Unknown",
    damage_type : "-",
    special : "-",
    hp_cost : TOWER_PLACEMENT_HP_COST,
    range : 0
  };

  switch (tower_type_index) {
    case 0:
      tower_description.name = "Arrow";
      tower_description.damage_type = "Single target";
      tower_description.special = "Fast direct damage";
      tower_description.hp_cost = max(1, TOWER_PLACEMENT_HP_COST - 1);
      tower_description.range = ARROW_L1_RANGE;
      break;
    case 1:
      tower_description.name = "Slow";
      tower_description.damage_type = "Single target";
      tower_description.special = "Applies movement slow";
      tower_description.hp_cost = TOWER_PLACEMENT_HP_COST;
      tower_description.range = SLOW_L1_RANGE;
      break;
    case 2:
      tower_description.name = "Cannon";
      tower_description.damage_type = "Splash";
      tower_description.special = "Area explosion";
      tower_description.hp_cost = TOWER_PLACEMENT_HP_COST;
      tower_description.range = CANNON_L1_RANGE;
      break;
    case 3:
      tower_description.name = "Flamer";
      tower_description.damage_type = "Cone";
      tower_description.special = "Applies burn over time";
      tower_description.hp_cost = TOWER_PLACEMENT_HP_COST;
      tower_description.range = FLAMER_L1_RANGE;
      break;
    case 4:
      tower_description.name = "Freeze";
      tower_description.damage_type = "Single target";
      tower_description.special = "Temporarily freezes";
      tower_description.hp_cost = TOWER_PLACEMENT_HP_COST;
      tower_description.range = FREEZE_L1_RANGE;
      break;
  }

  return tower_description;
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
  var placement_refund_hp = variable_instance_exists(selected_tower_id, "tower_placement_hp_cost") ? selected_tower_id.tower_placement_hp_cost : TOWER_PLACEMENT_HP_COST;
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

  with (enemy_instance) {
    if (is_dead || has_leaked) return;

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