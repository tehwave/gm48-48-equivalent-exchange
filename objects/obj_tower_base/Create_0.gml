/// @description Initializes platform occupancy tracking.

occupied = false;
tower_instance_id = noone;

base_failed_build_shake_steps_total = max(3, round(room_speed * 0.28));
base_failed_build_shake_steps_remaining = 0;
base_failed_build_shake_strength = 6;
base_failed_build_shake_dir = 1;

image_xscale = 1;
image_yscale = 1;
image_speed = 0;