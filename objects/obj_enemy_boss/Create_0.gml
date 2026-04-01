/// @description Applies inherited enemy setup, then randomizes boss centipede variant sprite on spawn.

event_inherited();

/// @type {Array<Asset.GMSprite>}
var boss_sprite_pool = [
  spr_centipede_blue,
  spr_centipede_pink,
  spr_centipede_red
];

/// @type {Real}
var sprite_variant_index = irandom(array_length(boss_sprite_pool) - 1);
sprite_index = boss_sprite_pool[sprite_variant_index];
