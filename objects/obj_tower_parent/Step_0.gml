/// @description Acquires highest-progress target and attacks on cooldown.

if (!game_is_running()) exit;

// Y-sort towers so lower-on-screen towers render in front.
depth = -y;

if (tower_attack_vfx_steps_remaining > 0) {
  tower_attack_vfx_steps_remaining -= 1;
}

if (tower_upgrade_shine_steps_remaining > 0) {
  tower_upgrade_shine_steps_remaining -= 1;
}

if (tower_failed_upgrade_shake_steps_remaining > 0) {
  tower_failed_upgrade_shake_steps_remaining -= 1;
}

if (abs(tower_scale_current - tower_scale_target) > 0.003) {
  tower_scale_current = lerp(tower_scale_current, tower_scale_target, 0.22);
} else {
  tower_scale_current = tower_scale_target;
}

image_xscale = tower_scale_current;
image_yscale = tower_scale_current;

if (tower_spawn_anim_steps_remaining > 0) {
  tower_spawn_anim_steps_remaining -= 1;
}

if (tower_fire_recoil_steps_remaining > 0) {
  tower_fire_recoil_steps_remaining -= 1;
}

if (cooldown_steps_remaining > 0) {
  cooldown_steps_remaining -= 1;
}

if (tower_flamer_sound_cooldown_steps_remaining > 0) {
  tower_flamer_sound_cooldown_steps_remaining -= 1;
}

target_id = scr_find_tower_target(id, tower_range);

if (instance_exists(target_id)) {
  tower_facing_angle = point_direction(x, y, target_id.x, target_id.y);

  if (tower_directional_sprite_enabled) {
    /// @type {Real}
    var normalized_angle = (tower_facing_angle + tower_directional_sprite_angle_offset) mod 360;
    if (normalized_angle < 0) normalized_angle += 360;

    /// @type {Real}
    var sector_size = 360 / TOWER_DIRECTION_SPRITE_COUNT;
    /// @type {Real}
    var direction_index = 1 + floor((normalized_angle + (sector_size * 0.5)) / sector_size);
    if (direction_index > TOWER_DIRECTION_SPRITE_COUNT) {
      direction_index -= TOWER_DIRECTION_SPRITE_COUNT;
    }

    if (direction_index != tower_directional_sprite_index) {
      tower_directional_sprite_index = direction_index;

      /// @type {String}
      var directional_sprite_name = tower_directional_sprite_prefix + "_" + string(tower_directional_sprite_index);
      /// @type {Asset.GMSprite|Real}
      var directional_sprite_asset = asset_get_index(directional_sprite_name);

      if (directional_sprite_asset != -1) {
        sprite_index = directional_sprite_asset;
      }
    }
  }
}

if (!instance_exists(target_id)) exit;
if (cooldown_steps_remaining > 0) exit;

tower_attack_vfx_angle = tower_facing_angle;
/// @type {Asset.GMObject|Real}
var flamer_object = asset_get_index("obj_tower_flamer");
/// @type {Asset.GMObject|Real}
var freeze_object = asset_get_index("obj_tower_freeze");

if (object_index == obj_tower_arrow) {
  /// @type {Real}
  var tx_arrow = target_id.x;
  /// @type {Real}
  var ty_arrow = target_id.y;

  audio_play_variation(WAV_Fireball_Launch_1, WAV_Fireball_Launch_2, AUDIO_GAIN_COMBAT, 0.95, 1.06);

  instance_create_layer(x, y, "Instances", obj_projectile_arrow, {
    proj_target_x : tx_arrow,
    proj_target_y : ty_arrow,
    proj_target_id : target_id,
    proj_damage : tower_damage,
    proj_speed : 12,
    proj_source_tower_id : id
  });
} else if (object_index == obj_tower_slow) {
  audio_play_variation(WAV_Water_Swoosh_1, WAV_Water_Swoosh_2, AUDIO_GAIN_COMBAT, 0.95, 1.05);
  enemy_take_damage(target_id, tower_damage, id);

  with (obj_enemy_parent) {
    if (is_dead || has_leaked) continue;
    if (point_distance(other.x, other.y, x, y) > other.tower_slow_splash_radius) continue;

    enemy_apply_slow(id, other.tower_slow_factor, other.tower_slow_duration_steps);
  }
} else if (object_index == obj_tower_cannon) {
  /// @type {Real}
  var tx = target_id.x;
  /// @type {Real}
  var ty = target_id.y;

  audio_play_variation(WAV_Bomb_Explosion_Small_1, WAV_Bomb_Explosion_Small_2, 0.62 * AUDIO_GAIN_COMBAT, 0.93, 1.04);

  instance_create_layer(x, y, "Instances", obj_projectile_cannon, {
    proj_target_x : tx,
    proj_target_y : ty,
    proj_target_id : target_id,
    proj_damage : tower_damage,
    proj_radius : tower_splash_radius,
    proj_speed : 9,
    proj_source_tower_id : id
  });
} else if (flamer_object != -1 && object_index == flamer_object) {
  if (tower_flamer_sound_cooldown_steps_remaining <= 0) {
    audio_play_variation(WAV_Flame_Swoosh_1, WAV_Flame_Swoosh_2, AUDIO_GAIN_COMBAT, 0.97, 1.06);
    tower_flamer_sound_cooldown_steps_remaining = tower_flamer_sound_cooldown_steps_total;
  }

  /// @type {Real}
  var half_cone_angle = tower_cone_angle * 0.5;

  with (obj_enemy_parent) {
    if (is_dead || has_leaked) continue;

    /// @type {Real}
    var dist = point_distance(other.x, other.y, x, y);
    if (dist > other.tower_range) continue;

    /// @type {Real}
    var enemy_angle = point_direction(other.x, other.y, x, y);
    if (abs(angle_difference(enemy_angle, other.tower_attack_vfx_angle)) > half_cone_angle) continue;

    enemy_take_damage(id, other.tower_damage, other.id);
    enemy_apply_burn(id, other.tower_burn_damage_per_tick, other.tower_burn_duration_steps);
  }
} else if (freeze_object != -1 && object_index == freeze_object) {
  audio_play_one_shot(WAV_Lightning_Swoosh_1, AUDIO_GAIN_COMBAT, 0.98, 1.02);
  enemy_take_damage(target_id, tower_damage, id);
  enemy_apply_freeze(target_id, tower_freeze_duration_steps);
}

if (tower_attack_vfx_sprite != -1) {
  tower_attack_vfx_steps_remaining = max(1, sprite_get_number(tower_attack_vfx_sprite));
}

tower_fire_recoil_steps_remaining = tower_fire_recoil_steps_total;
tower_fire_wiggle_dir = choose(-1, 1);

cooldown_steps_remaining = tower_fire_cooldown_steps;