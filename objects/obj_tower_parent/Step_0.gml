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
  tower_directional_display_angle = tower_facing_angle;
  if (tower_sprite_rotates_to_target) {
    image_angle = tower_facing_angle;
  } else {
    image_angle = 0;
  }

  if (tower_directional_sprite_enabled) {
    /// @type {Real}
    var normalized_angle = ((-tower_facing_angle) + tower_directional_sprite_angle_offset) mod 360;
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
      var directional_suffix = string(tower_directional_sprite_index);
      if (tower_directional_sprite_index < 10) {
        directional_suffix = "0" + directional_suffix;
      }
      var directional_sprite_name = tower_directional_sprite_prefix + "_" + directional_suffix;
      /// @type {Asset.GMSprite|Real}
      var directional_sprite_asset = asset_get_index(directional_sprite_name);

      if (directional_sprite_asset == -1) {
        directional_sprite_name = tower_directional_sprite_prefix + "_" + string(tower_directional_sprite_index);
        directional_sprite_asset = asset_get_index(directional_sprite_name);
      }

      if (directional_sprite_asset != -1) {
        sprite_index = directional_sprite_asset;
      }
    }

    /// Match VFX direction to the displayed directional sector.
    /// @type {Real}
    var displayed_normalized_angle = (tower_directional_sprite_index - 1) * sector_size;
    tower_directional_display_angle = tower_directional_sprite_angle_offset - displayed_normalized_angle;
  }
}

if (!tower_sprite_rotates_to_target) {
  image_angle = 0;
}

if (!instance_exists(target_id)) exit;
if (cooldown_steps_remaining > 0) exit;

tower_attack_vfx_angle = tower_facing_angle;
if (tower_directional_sprite_enabled) {
  tower_attack_vfx_angle = tower_directional_display_angle;
}

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
} else if (tower_is_flamer) {
  if (tower_flamer_sound_cooldown_steps_remaining <= 0) {
    audio_play_variation(WAV_Flame_Swoosh_1, WAV_Flame_Swoosh_2, AUDIO_GAIN_COMBAT, 0.97, 1.06);
    tower_flamer_sound_cooldown_steps_remaining = tower_flamer_sound_cooldown_steps_total;
  }

  /// @type {Real}
  var half_cone_angle = tower_cone_angle * 0.5;
  /// @type {Real}
  var cone_cos = dcos(half_cone_angle);
  /// @type {Real}
  var cone_cos_squared = cone_cos * cone_cos;
  /// @type {Real}
  var forward_x = lengthdir_x(1, tower_attack_vfx_angle);
  /// @type {Real}
  var forward_y = lengthdir_y(1, tower_attack_vfx_angle);
  /// @type {DS.List|Real}
  var hit_enemy_ids = tower_flamer_hit_enemy_ids;
  if (!ds_exists(hit_enemy_ids, ds_type_list)) {
    hit_enemy_ids = ds_list_create();
    tower_flamer_hit_enemy_ids = hit_enemy_ids;
  } else {
    ds_list_clear(hit_enemy_ids);
  }
  /// @type {Real}
  var hit_count = collision_circle_list(x, y, tower_range, obj_enemy_parent, false, false, hit_enemy_ids, false);

  for (var hit_index = 0; hit_index < hit_count; hit_index += 1) {
    /// @type {Id.Instance|Real}
    var enemy_id = hit_enemy_ids[| hit_index];
    if (!instance_exists(enemy_id)) continue;
    if (enemy_id.is_dead || enemy_id.has_leaked) continue;

    /// @type {Real}
    var delta_x = enemy_id.x - x;
    /// @type {Real}
    var delta_y = enemy_id.y - y;
    /// @type {Real}
    var dot = (delta_x * forward_x) + (delta_y * forward_y);
    if (dot <= 0) continue;

    /// @type {Real}
    var dist_squared = (delta_x * delta_x) + (delta_y * delta_y);
    if ((dot * dot) < (dist_squared * cone_cos_squared)) continue;

    enemy_take_damage(enemy_id, tower_damage, id);
    enemy_apply_burn(enemy_id, tower_burn_damage_per_tick, tower_burn_duration_steps);
  }
} else if (tower_is_freeze) {
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