/// @description Initialize cannon projectile flight data.

proj_target_x = variable_instance_exists(id, "proj_target_x") ? proj_target_x : x;
proj_target_y = variable_instance_exists(id, "proj_target_y") ? proj_target_y : y;
proj_target_id = variable_instance_exists(id, "proj_target_id") ? proj_target_id : noone;
proj_damage = variable_instance_exists(id, "proj_damage") ? proj_damage : 1;
proj_radius = variable_instance_exists(id, "proj_radius") ? proj_radius : 48;
proj_speed = variable_instance_exists(id, "proj_speed") ? proj_speed : 8;
proj_source_tower_id = variable_instance_exists(id, "proj_source_tower_id") ? proj_source_tower_id : noone;

image_xscale = 0.09;
image_yscale = 0.09;
image_speed = 0;