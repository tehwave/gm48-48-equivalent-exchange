/// @description Collects this coin on click and grants its value once.

if (coin_collected) exit;
if (!game_is_running()) exit;

coin_collected = true;
game_add_coins(coin_value);
audio_play_variation(WAV_Magical_Sparkle_Charge_Up_1, WAV_Magical_Sparkle_Charge_Up_2, AUDIO_GAIN_UI * 1.15, 1.04, 1.12);
audio_play_variation(WAV_Magical_Sparkle_Disappate_1, WAV_Magical_Sparkle_Disappate_2, AUDIO_GAIN_UI * 1.05, 1.08, 1.18);
coin_collect_vfx_steps = coin_collect_vfx_total_steps;

coin_velocity_x = 0;
coin_velocity_y = 0;
