/// @description Applies inherited enemy setup, then randomizes basic enemy variant sprite on spawn.

event_inherited();

/// @type {Array<Asset.GMSprite>}
var basic_enemy_sprite_pool = [
  spr_mantis_blue,
  spr_mantis_green,
  spr_mantis_yellow,
  spr_snail_green,
  spr_snail_pink,
  spr_snail_yellow,
  spr_spider_blue,
  spr_spider_green,
  spr_spider_purple
];

/// @type {Real}
var sprite_variant_index = irandom(array_length(basic_enemy_sprite_pool) - 1);
sprite_index = basic_enemy_sprite_pool[sprite_variant_index];

/// @type {Real}
var speed_multiplier = ENEMY_MANTIS_SPEED_MULTIPLIER;
/// @type {Real}
var hp_multiplier = ENEMY_MANTIS_HP_MULTIPLIER;
/// @type {String}
var enemy_family = "mantis";

if (sprite_variant_index >= 3 && sprite_variant_index <= 5) {
  enemy_family = "snail";
  speed_multiplier = ENEMY_SNAIL_SPEED_MULTIPLIER;
  hp_multiplier = ENEMY_SNAIL_HP_MULTIPLIER;
} else if (sprite_variant_index >= 6 && sprite_variant_index <= 8) {
  enemy_family = "spider";
  speed_multiplier = ENEMY_SPIDER_SPEED_MULTIPLIER;
  hp_multiplier = ENEMY_SPIDER_HP_MULTIPLIER;
}

enemy_move_speed *= speed_multiplier;
enemy_hp_max = max(1, round(enemy_hp_max * hp_multiplier));
enemy_hp = enemy_hp_max;
path_speed = enemy_move_speed;
