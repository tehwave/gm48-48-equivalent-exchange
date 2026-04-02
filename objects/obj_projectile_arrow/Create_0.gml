/// @description Initialize arrow projectile flight data.

proj_target_x = variable_instance_exists(id, "proj_target_x") ? proj_target_x : x;
proj_target_y = variable_instance_exists(id, "proj_target_y") ? proj_target_y : y;
proj_target_id = variable_instance_exists(id, "proj_target_id") ? proj_target_id : noone;
proj_damage = variable_instance_exists(id, "proj_damage") ? proj_damage : 1;
proj_speed = variable_instance_exists(id, "proj_speed") ? proj_speed : 12;
proj_angle_offset = variable_instance_exists(id, "proj_angle_offset") ? proj_angle_offset : 0;
proj_source_tower_id = variable_instance_exists(id, "proj_source_tower_id") ? proj_source_tower_id : noone;
proj_has_impacted = false;
proj_impact_vfx_sprite = vfx_arrow_hit;

image_xscale = 0.07;
image_yscale = 0.07;
image_speed = 0;
image_angle = point_direction(x, y, proj_target_x, proj_target_y) + proj_angle_offset;
