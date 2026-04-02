/// @description Initializes dropped coin pickup state and bounce launch.

sprite_index = spr_coin;
image_speed = 0;

depth = COIN_DROP_DEPTH;

/// @type {Real}
coin_value = max(1, round(variable_instance_exists(id, "coin_value") ? coin_value : 1));
/// @type {Real}
coin_ground_y = variable_instance_exists(id, "coin_ground_y") ? coin_ground_y : y;

/// @type {Real}
coin_life_steps = COIN_DROP_LIFETIME_STEPS;
/// @type {Bool}
coin_collected = false;
/// @type {Real}
coin_collect_vfx_total_steps = 20;
/// @type {Real}
coin_collect_vfx_steps = 0;
/// @type {Real}
coin_expire_warn_steps_remaining = 0;

/// @type {Real}
coin_velocity_x = random_range(-COIN_DROP_HORIZONTAL_SPEED, COIN_DROP_HORIZONTAL_SPEED);
/// @type {Real}
coin_velocity_y = -random_range(COIN_DROP_BOUNCE_MIN, COIN_DROP_BOUNCE_MAX);

/// @type {Real}
coin_rotation_speed = random_range(-9, 9);
image_angle = random_range(0, 359);
