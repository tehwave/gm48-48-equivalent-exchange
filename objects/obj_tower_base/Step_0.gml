/// @description Keeps occupancy in sync when towers are removed.

depth = -y - 1;

if (occupied && !instance_exists(tower_instance_id)) {
  occupied = false;
  tower_instance_id = noone;
}

if (base_failed_build_shake_steps_remaining > 0) {
  base_failed_build_shake_steps_remaining -= 1;
}