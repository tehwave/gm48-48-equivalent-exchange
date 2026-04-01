/// @description Handles wave state machine, inputs, and run end conditions.

if (global.game_state == GAME_STATE_RUNNING) {
  game_audio_start_ambience();
} else {
  game_audio_stop_ambience();
}

if (global.enemy_call_sfx_cooldown_steps_remaining > 0) {
  global.enemy_call_sfx_cooldown_steps_remaining -= 1;
}

if (global.game_state == GAME_STATE_RUNNING) {
  global.birdsong_steps_remaining -= 1;
  if (global.birdsong_steps_remaining <= 0) {
    audio_play_one_shot(WAV_SFX_Birdsong, AUDIO_GAIN_AMBIENCE * 1.15, 0.96, 1.06);
    global.birdsong_steps_remaining = irandom_range(
      max(1, round(room_speed * AUDIO_BIRDSONG_MIN_SECONDS)),
      max(1, round(room_speed * AUDIO_BIRDSONG_MAX_SECONDS))
    );
  }
}

if (global.game_state == GAME_STATE_INTRO) {
  if (global.intro_lock_timer_steps > 0) {
    global.intro_lock_timer_steps -= 1;
    global.intro_can_continue = false;
  } else {
    global.intro_lock_timer_steps = 0;
    global.intro_can_continue = true;
  }

  // Hidden dev skip so jam iteration can bypass the intro wait.
  if (keyboard_check_pressed(vk_f8)) {
    global.intro_lock_timer_steps = 0;
    global.intro_can_continue = true;
    global.game_state = GAME_STATE_RUNNING;
  }

  if (global.intro_can_continue && keyboard_check_pressed(vk_space)) {
    global.game_state = GAME_STATE_RUNNING;
  }

  if (global.game_state != GAME_STATE_RUNNING) {
    exit;
  }
}

if (keyboard_check_pressed(vk_f3)) {
  global.debug_mode = !global.debug_mode;
}

if (keyboard_check_pressed(ord("Q"))) {
  global.selected_tower_type = (global.selected_tower_type + 4) mod 5;
}

if (keyboard_check_pressed(ord("E"))) {
  global.selected_tower_type = (global.selected_tower_type + 1) mod 5;
}

if (keyboard_check_pressed(ord("1"))) global.selected_tower_type = 0;
if (keyboard_check_pressed(ord("2"))) global.selected_tower_type = 1;
if (keyboard_check_pressed(ord("3"))) global.selected_tower_type = 2;
if (keyboard_check_pressed(ord("4"))) global.selected_tower_type = 3;
if (keyboard_check_pressed(ord("5"))) global.selected_tower_type = 4;

if (mouse_check_button_pressed(mb_right)) {
  global.selected_tower_id = noone;
}

if (mouse_check_button_pressed(mb_left)) {
  /// @type {Id.Instance|Real}
  var clicked_tower_id = instance_position(mouse_x, mouse_y, obj_tower_parent);
  if (!instance_exists(clicked_tower_id)) {
    global.selected_tower_id = noone;
  }
}

if (keyboard_check_pressed(ord("U"))) {
  if (instance_exists(global.selected_tower_id)) {
    with (global.selected_tower_id) {
      event_user(0);
    }
  }
}

if (keyboard_check_pressed(ord("X"))) {
  if (game_delete_selected_tower_refund_life()) {
    audio_play_variation(WAV_Magical_Sparkle_Disappate_1, WAV_Magical_Sparkle_Disappate_2, AUDIO_GAIN_UI, 0.96, 1.06);
  } else if (game_is_running()) {
    audio_play_variation(WAV_Snake_Hiss_1, WAV_Snake_Hiss_2, AUDIO_GAIN_UI * 0.42, 0.95, 1.05);
  }
}

if (global.game_state == GAME_STATE_GAME_OVER || global.game_state == GAME_STATE_VICTORY) {
  if (global.run_end_time_ms < 0) {
    global.run_end_time_ms = current_time;
  }

  if (keyboard_check_pressed(ord("R"))) {
    room_restart();
    exit;
  }
}

if (!game_is_running()) {
  exit;
}

if (global.boss_banner_timer_steps > 0) {
  global.boss_banner_timer_steps -= 1;
}

if (wave_in_progress) {
  if (enemies_spawned >= enemies_to_spawn && global.enemies_alive <= 0) {
    wave_in_progress = false;

    if (global.wave_index >= TOTAL_WAVES) {
      global.game_state = GAME_STATE_VICTORY;
    } else {
      wave_transition_timer_steps = round(PRE_WAVE_DELAY_SECONDS * room_speed);
    }
  }

  exit;
}

if (global.wave_index >= TOTAL_WAVES) {
  if (global.enemies_alive <= 0) {
    global.game_state = GAME_STATE_VICTORY;
  }
  exit;
}

wave_transition_timer_steps -= 1;
if (wave_transition_timer_steps > 0) {
  exit;
}

global.wave_index += 1;
current_wave_has_boss = scr_wave_is_boss(global.wave_index);

/// @type {Real}
var normal_enemy_count = scr_wave_enemy_count(global.wave_index);
enemies_to_spawn = normal_enemy_count + (current_wave_has_boss ? 1 : 0);
enemies_spawned = 0;
wave_in_progress = true;

if (current_wave_has_boss) {
  global.boss_banner_timer_steps = round(BOSS_BANNER_SECONDS * room_speed);
}

alarm[0] = 1;