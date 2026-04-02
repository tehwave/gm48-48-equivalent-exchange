/// @description Initializes run state and wave scheduling.

audio_master_gain(AUDIO_MASTER_GAIN);

global.player_hp = STARTING_HP;
global.player_coins = STARTING_COINS;
global.wave_index = 0;
global.enemies_alive = 0;
global.game_state = GAME_STATE_INTRO;

global.intro_lock_timer_steps = round(INTRO_LOCK_SECONDS * room_speed);
global.intro_can_continue = false;

global.selected_tower_type = 0;
global.selected_tower_id = noone;
global.confirm_action = "";
global.confirm_timer_steps = 0;
global.build_mode = false;
global.build_base_id = noone;
global.debug_mode = false;
global.ambient_sound_instance = -1;
global.enemy_call_sfx_cooldown_steps_total = max(1, round(room_speed * AUDIO_ENEMY_CALL_COOLDOWN_SECONDS));
global.enemy_call_sfx_cooldown_steps_remaining = 0;
global.birdsong_steps_remaining = irandom_range(
	max(1, round(room_speed * AUDIO_BIRDSONG_MIN_SECONDS)),
	max(1, round(room_speed * AUDIO_BIRDSONG_MAX_SECONDS))
);
global.run_start_time_ms = current_time;
global.run_end_time_ms = -1;

wave_in_progress = false;
current_wave_has_boss = false;
enemies_to_spawn = 0;
enemies_spawned = 0;

wave_transition_timer_steps = round(PRE_WAVE_DELAY_SECONDS * room_speed);
global.boss_banner_timer_steps = 0;

alarm[0] = -1;