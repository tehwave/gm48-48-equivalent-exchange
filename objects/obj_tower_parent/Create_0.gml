/// @description Initializes shared tower fields and applies level 1 stats.

tower_level = 1;
target_id = noone;
cooldown_steps_remaining = 0;

tower_range = 0;
tower_damage = 0;
tower_fire_cooldown_steps = room_speed;
tower_slow_factor = 1;
tower_slow_duration_steps = 0;
tower_splash_radius = 0;
tower_cone_angle = 0;
tower_burn_damage_per_tick = 0;
tower_burn_duration_steps = 0;
tower_freeze_duration_steps = 0;
tower_flamer_sound_cooldown_steps_total = max(1, round(room_speed * AUDIO_FLAMER_MIN_INTERVAL_SECONDS));
tower_flamer_sound_cooldown_steps_remaining = 0;

tower_attack_vfx_sprite = -1;
tower_attack_vfx_steps_remaining = 0;
tower_attack_vfx_scale = 0.24;
tower_attack_vfx_angle = 0;
tower_attack_vfx_angle_offset = 0;
tower_attack_vfx_distance = 0;

tower_spawn_anim_steps_total = max(1, round(room_speed * 0.30));
tower_facing_angle = 0;
tower_directional_sprite_enabled = false;
tower_directional_sprite_prefix = "";
tower_directional_sprite_index = 1;
tower_directional_sprite_angle_offset = TOWER_DIRECTION_SPRITE_ANGLE_OFFSET;
tower_spawn_anim_steps_remaining = tower_spawn_anim_steps_total;
tower_fire_recoil_steps_total = max(2, round(room_speed * 0.16));
tower_fire_recoil_steps_remaining = 0;
tower_fire_wiggle_dir = choose(-1, 1);

base_owner_id = variable_instance_exists(id, "base_owner_id") ? base_owner_id : noone;

/// @type {Real}
var tower_sprite_scale = 0.8;
/// @type {Asset.GMObject|Real}
var flamer_object = asset_get_index("obj_tower_flamer");
/// @type {Asset.GMObject|Real}
var freeze_object = asset_get_index("obj_tower_freeze");

if (object_index == obj_tower_arrow) {
	tower_directional_sprite_enabled = true;
	tower_directional_sprite_prefix = "SPR_Cannon";
	tower_attack_vfx_sprite = SPR_Cannon_VFX;
	tower_attack_vfx_scale = 0.22;
	tower_attack_vfx_distance = 22;
} else if (object_index == obj_tower_slow) {
	tower_directional_sprite_enabled = true;
	tower_directional_sprite_prefix = "SPR_Slow";
	tower_attack_vfx_sprite = SPR_Slow_VFX;
	tower_attack_vfx_scale = 1;
} else if (object_index == obj_tower_cannon) {
	tower_directional_sprite_enabled = true;
	tower_directional_sprite_prefix = "SPR_Explosive";
	tower_attack_vfx_sprite = SPR_Explosive_VFX;
	tower_attack_vfx_scale = 0.24;
	tower_sprite_scale = 0.82;
} else if (flamer_object != -1 && object_index == flamer_object) {
	tower_directional_sprite_enabled = true;
	tower_directional_sprite_prefix = "SPR_Flamer";
	tower_attack_vfx_sprite = SPR_Flamer_VFX;
	tower_attack_vfx_scale = 0.7;
	tower_attack_vfx_angle_offset = -90;
	tower_attack_vfx_distance = 14;
	tower_sprite_scale = 0.84;
} else if (freeze_object != -1 && object_index == freeze_object) {
	tower_directional_sprite_enabled = true;
	tower_directional_sprite_prefix = "SPR_Freeze";
	tower_attack_vfx_sprite = SPR_Freeze_VFX;
	tower_attack_vfx_scale = 0.72;
	tower_attack_vfx_angle_offset = -90;
	tower_attack_vfx_distance = 12;
	tower_sprite_scale = 0.84;
}

tower_base_scale = tower_sprite_scale;
tower_scale_target = tower_base_scale;
tower_scale_current = tower_base_scale;

tower_upgrade_shine_steps_total = max(1, round(room_speed * 0.42));
tower_upgrade_shine_steps_remaining = 0;

image_xscale = tower_scale_current;
image_yscale = tower_scale_current;
image_speed = 0;

scr_tower_apply_level_stats(id, object_index, tower_level);