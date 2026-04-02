/// @description Shared state/economy/combat transaction helpers.

/// @returns {Bool}
function game_is_running() {
  return global.game_state == GAME_STATE_RUNNING;
}

/// @param {Real} px
/// @param {Real} py
/// @param {Real} pw
/// @param {Real} ph
/// @param {Real} bg_alpha
/// @param {Real} corner_radius
/// @returns {Void}
function scr_draw_rounded_panel(px, py, pw, ph, bg_alpha, corner_radius) {
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
  if (argument_count < 4) shadow_offset_x = 1;
  if (argument_count < 5) shadow_offset_y = 1;

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
  if (argument_count < 6) shadow_offset_x = 1;
  if (argument_count < 7) shadow_offset_y = 1;

  /// @type {Real}
  var main_colour = draw_get_colour();

  draw_set_colour(c_black);
  draw_text_ext(x + shadow_offset_x, y + shadow_offset_y, text, sep, width);
  draw_set_colour(main_colour);
  draw_text_ext(x, y, text, sep, width);
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
/// @returns {Bool}
function game_try_spend_hp(amount) {
  if (!game_is_running()) return false;
  if (amount <= 0) return true;
  if (global.player_hp < amount) return false;

  global.player_hp -= amount;
  game_audio_play_life_lost(amount);
  if (global.player_hp <= 0) {
    global.player_hp = 0;
    global.game_state = GAME_STATE_GAME_OVER;
  }

  return true;
}

/// @param {Real} amount
/// @returns {Bool}
function game_try_spend_coins(amount) {
  if (!game_is_running()) return false;
  if (amount <= 0) return true;
  if (global.player_coins < amount) return false;

  global.player_coins -= amount;

  if (!variable_global_exists("coin_spend_vfx_pending")) {
    global.coin_spend_vfx_pending = 0;
  }

  /// @type {Real}
  var spend_vfx_budget = clamp(round(amount), 1, 36);
  global.coin_spend_vfx_pending += spend_vfx_budget;

  return true;
}

/// @param {Real} amount
/// @returns {Void}
function game_add_coins(amount) {
  global.player_coins = max(0, global.player_coins + amount);
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
  global.player_hp += placement_refund_hp;
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
/// @returns {Void}
function game_register_leak(leak_damage) {
  if (!game_is_running()) return;
  if (leak_damage <= 0) return;

  /// @type {Real}
  var hp_before = global.player_hp;
  global.player_hp = max(0, global.player_hp - leak_damage);
  if (global.player_hp < hp_before) {
    game_audio_play_life_lost(hp_before - global.player_hp);
  }

  if (global.player_hp <= 0) {
    global.game_state = GAME_STATE_GAME_OVER;
  }
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

  /// @type {Bool}
  var source_is_valid_local = source_is_valid;
  /// @type {Id.Instance|Real}
  var source_tower_id_local = source_tower_id;

  with (enemy_instance) {
    if (is_dead || has_leaked) return false;
    enemy_hp -= damage;
    if (source_is_valid_local) {
      enemy_last_damage_source = source_tower_id_local;
    }
  }

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