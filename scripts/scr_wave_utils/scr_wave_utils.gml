/// @description Wave and tower utility helpers used across objects.

/// @param {Real} wave_index
/// @returns {Real}
function scr_wave_enemy_count(wave_index) {
  return WAVE_BASE_COUNT + ((wave_index - 1) * WAVE_GROWTH);
}

/// @param {Real} wave_index
/// @returns {Bool}
function scr_wave_is_boss(wave_index) {
  return (wave_index mod BOSS_WAVE_INTERVAL) == 0;
}

/// @param {Real} wave_index
/// @returns {Real}
function scr_wave_enemy_hp_scale(wave_index) {
  return 1 + ((wave_index - 1) * ENEMY_HP_SCALE_PER_WAVE);
}

/// @param {Real} wave_index
/// @returns {Real}
function scr_wave_enemy_speed_scale(wave_index) {
  return 1 + ((wave_index - 1) * ENEMY_SPEED_SCALE_PER_WAVE);
}

/// @param {Real} wave_index
/// @returns {Real}
function scr_wave_spawn_interval(wave_index) {
  /// @type {Real}
  var t = clamp((wave_index - 1) / max(1, TOTAL_WAVES - 1), 0, 1);
  return lerp(SPAWN_INTERVAL_START, SPAWN_INTERVAL_END, t);
}

/// @returns {Asset.GMObject|Real}
function scr_get_selected_tower_object() {
  /// @type {Asset.GMObject|Real}
  var flamer_object = asset_get_index("obj_tower_flamer");
  /// @type {Asset.GMObject|Real}
  var freeze_object = asset_get_index("obj_tower_freeze");

  switch (global.selected_tower_type) {
    case 0: return obj_tower_arrow;
    case 1: return obj_tower_slow;
    case 2: return obj_tower_cannon;
    case 3:
      if (flamer_object != -1) return flamer_object;
      return noone;
    case 4:
      if (freeze_object != -1) return freeze_object;
      return noone;
  }
  return noone;
}

/// @returns {String}
function scr_get_selected_tower_name() {
  switch (global.selected_tower_type) {
    case 0: return "Arrow";
    case 1: return "Slow";
    case 2: return "Cannon";
    case 3: return "Flamer";
    case 4: return "Freeze";
  }
  return "Unknown";
}

/// @param {Asset.GMObject|Real} tower_object
/// @param {Real} target_level
/// @returns {Real}
function scr_tower_upgrade_cost(tower_object, target_level) {
  /// @type {Asset.GMObject|Real}
  var flamer_object = asset_get_index("obj_tower_flamer");
  /// @type {Asset.GMObject|Real}
  var freeze_object = asset_get_index("obj_tower_freeze");

  if (target_level <= 1 || target_level > TOWER_MAX_LEVEL) return 0;

  if (tower_object == obj_tower_arrow) {
    if (target_level == 2) return UPGRADE_TO_L2_ARROW;
    if (target_level == 3) return UPGRADE_TO_L3_ARROW;
  }

  if (tower_object == obj_tower_slow) {
    if (target_level == 2) return UPGRADE_TO_L2_SLOW;
    if (target_level == 3) return UPGRADE_TO_L3_SLOW;
  }

  if (tower_object == obj_tower_cannon) {
    if (target_level == 2) return UPGRADE_TO_L2_CANNON;
    if (target_level == 3) return UPGRADE_TO_L3_CANNON;
  }

  if (flamer_object != -1 && tower_object == flamer_object) {
    if (target_level == 2) return UPGRADE_TO_L2_FLAMER;
    if (target_level == 3) return UPGRADE_TO_L3_FLAMER;
  }

  if (freeze_object != -1 && tower_object == freeze_object) {
    if (target_level == 2) return UPGRADE_TO_L2_FREEZE;
    if (target_level == 3) return UPGRADE_TO_L3_FREEZE;
  }

  return 0;
}

/// @param {Id.Instance} tower_instance
/// @param {Asset.GMObject|Real} tower_object
/// @param {Real} tower_level
/// @returns {Void}
function scr_tower_apply_level_stats(tower_instance, tower_object, tower_level) {
  /// @type {Asset.GMObject|Real}
  var flamer_object = asset_get_index("obj_tower_flamer");
  /// @type {Asset.GMObject|Real}
  var freeze_object = asset_get_index("obj_tower_freeze");

  /// @type {Real}
  var range = 0;
  /// @type {Real}
  var damage = 0;
  /// @type {Real}
  var cooldown_seconds = 1;
  /// @type {Real}
  var slow_factor = 1;
  /// @type {Real}
  var slow_duration = 0;
  /// @type {Real}
  var splash_radius = 0;
  /// @type {Real}
  var cone_angle = 0;
  /// @type {Real}
  var burn_damage = 0;
  /// @type {Real}
  var burn_duration = 0;
  /// @type {Real}
  var freeze_duration = 0;

  if (tower_object == obj_tower_arrow) {
    if (tower_level == 1) {
      range = ARROW_L1_RANGE;
      damage = ARROW_L1_DAMAGE;
      cooldown_seconds = ARROW_L1_COOLDOWN;
    } else if (tower_level == 2) {
      range = ARROW_L2_RANGE;
      damage = ARROW_L2_DAMAGE;
      cooldown_seconds = ARROW_L2_COOLDOWN;
    } else {
      range = ARROW_L3_RANGE;
      damage = ARROW_L3_DAMAGE;
      cooldown_seconds = ARROW_L3_COOLDOWN;
    }
  } else if (tower_object == obj_tower_slow) {
    if (tower_level == 1) {
      range = SLOW_L1_RANGE;
      damage = SLOW_L1_DAMAGE;
      cooldown_seconds = SLOW_L1_COOLDOWN;
      slow_factor = SLOW_L1_FACTOR;
      slow_duration = SLOW_L1_DURATION;
    } else if (tower_level == 2) {
      range = SLOW_L2_RANGE;
      damage = SLOW_L2_DAMAGE;
      cooldown_seconds = SLOW_L2_COOLDOWN;
      slow_factor = SLOW_L2_FACTOR;
      slow_duration = SLOW_L2_DURATION;
    } else {
      range = SLOW_L3_RANGE;
      damage = SLOW_L3_DAMAGE;
      cooldown_seconds = SLOW_L3_COOLDOWN;
      slow_factor = SLOW_L3_FACTOR;
      slow_duration = SLOW_L3_DURATION;
    }
  } else if (tower_object == obj_tower_cannon) {
    if (tower_level == 1) {
      range = CANNON_L1_RANGE;
      damage = CANNON_L1_DAMAGE;
      cooldown_seconds = CANNON_L1_COOLDOWN;
      splash_radius = CANNON_L1_SPLASH;
    } else if (tower_level == 2) {
      range = CANNON_L2_RANGE;
      damage = CANNON_L2_DAMAGE;
      cooldown_seconds = CANNON_L2_COOLDOWN;
      splash_radius = CANNON_L2_SPLASH;
    } else {
      range = CANNON_L3_RANGE;
      damage = CANNON_L3_DAMAGE;
      cooldown_seconds = CANNON_L3_COOLDOWN;
      splash_radius = CANNON_L3_SPLASH;
    }
  } else if (flamer_object != -1 && tower_object == flamer_object) {
    if (tower_level == 1) {
      range = FLAMER_L1_RANGE;
      damage = FLAMER_L1_DAMAGE;
      cooldown_seconds = FLAMER_L1_COOLDOWN;
      cone_angle = FLAMER_L1_CONE_ANGLE;
      burn_damage = FLAMER_L1_BURN_DAMAGE;
      burn_duration = FLAMER_L1_BURN_DURATION;
    } else if (tower_level == 2) {
      range = FLAMER_L2_RANGE;
      damage = FLAMER_L2_DAMAGE;
      cooldown_seconds = FLAMER_L2_COOLDOWN;
      cone_angle = FLAMER_L2_CONE_ANGLE;
      burn_damage = FLAMER_L2_BURN_DAMAGE;
      burn_duration = FLAMER_L2_BURN_DURATION;
    } else {
      range = FLAMER_L3_RANGE;
      damage = FLAMER_L3_DAMAGE;
      cooldown_seconds = FLAMER_L3_COOLDOWN;
      cone_angle = FLAMER_L3_CONE_ANGLE;
      burn_damage = FLAMER_L3_BURN_DAMAGE;
      burn_duration = FLAMER_L3_BURN_DURATION;
    }
  } else if (freeze_object != -1 && tower_object == freeze_object) {
    if (tower_level == 1) {
      range = FREEZE_L1_RANGE;
      damage = FREEZE_L1_DAMAGE;
      cooldown_seconds = FREEZE_L1_COOLDOWN;
      freeze_duration = FREEZE_L1_DURATION;
    } else if (tower_level == 2) {
      range = FREEZE_L2_RANGE;
      damage = FREEZE_L2_DAMAGE;
      cooldown_seconds = FREEZE_L2_COOLDOWN;
      freeze_duration = FREEZE_L2_DURATION;
    } else {
      range = FREEZE_L3_RANGE;
      damage = FREEZE_L3_DAMAGE;
      cooldown_seconds = FREEZE_L3_COOLDOWN;
      freeze_duration = FREEZE_L3_DURATION;
    }
  }

  with (tower_instance) {
    tower_range = range;
    tower_damage = damage;
    tower_fire_cooldown_steps = max(1, round(cooldown_seconds * room_speed));
    tower_slow_factor = slow_factor;
    tower_slow_duration_steps = round(slow_duration * room_speed);
    tower_splash_radius = splash_radius;
    tower_cone_angle = cone_angle;
    tower_burn_damage_per_tick = burn_damage;
    tower_burn_duration_steps = round(burn_duration * room_speed);
    tower_freeze_duration_steps = round(freeze_duration * room_speed);
  }
}

/// @param {Id.Instance} tower_instance
/// @param {Real} tower_range
/// @returns {Id.Instance|Real}
function scr_find_tower_target(tower_instance, tower_range) {
  /// @type {Id.Instance|Real}
  var best_enemy = noone;
  /// @type {Real}
  var best_progress = -1;

  with (obj_enemy_parent) {
    if (is_dead || has_leaked) continue;
    if (point_distance(other.x, other.y, x, y) > tower_range) continue;

    if (path_position > best_progress) {
      best_enemy = id;
      best_progress = path_position;
    }
  }

  return best_enemy;
}