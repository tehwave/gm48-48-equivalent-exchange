/// @description Releases dynamic resources owned by this tower instance.

if (ds_exists(tower_flamer_hit_enemy_ids, ds_type_list)) {
  ds_list_destroy(tower_flamer_hit_enemy_ids);
}
