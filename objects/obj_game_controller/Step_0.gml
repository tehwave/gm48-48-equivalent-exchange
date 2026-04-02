/// @description Handles wave state machine, inputs, and run end conditions.

game_decals_update();

if (global.game_state == GAME_STATE_RUNNING) {
  game_audio_start_ambience();
} else {
  game_audio_stop_ambience();
}

if (global.enemy_call_sfx_cooldown_steps_remaining > 0) {
  global.enemy_call_sfx_cooldown_steps_remaining -= 1;
}

if (global.leak_edge_flash_steps_remaining > 0) {
  global.leak_edge_flash_steps_remaining -= 1;
}

if (global.confirm_timer_steps > 0) {
  global.confirm_timer_steps -= 1;
  if (global.confirm_timer_steps <= 0) {
    global.confirm_action = "";
    global.confirm_timer_steps = 0;
  }
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

    if (keyboard_check(vk_space)) {
      global.intro_hold_skip_steps += 1;
      if (global.intro_hold_skip_steps >= global.intro_hold_skip_required_steps) {
        global.intro_lock_timer_steps = 0;
        global.intro_can_continue = true;
        global.game_state = GAME_STATE_RUNNING;
      }
    } else {
      global.intro_hold_skip_steps = 0;
    }
  } else {
    global.intro_lock_timer_steps = 0;
    global.intro_can_continue = true;
    global.intro_hold_skip_steps = 0;
  }

  // Hidden dev skip so jam iteration can bypass the intro wait.
  if (keyboard_check_pressed(vk_f8)) {
    global.intro_lock_timer_steps = 0;
    global.intro_can_continue = true;
    global.intro_hold_skip_steps = 0;
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
  global.build_mode = false;
  global.build_base_id = noone;
  global.build_click_lock = false;
  global.confirm_action = "";
  global.confirm_timer_steps = 0;
  exit;
}

/// @type {Bool}
var key_q = keyboard_check_pressed(ord("Q"));
/// @type {Bool}
var key_e = keyboard_check_pressed(ord("E"));
/// @type {Bool}
var key_1 = keyboard_check_pressed(ord("1"));
/// @type {Bool}
var key_2 = keyboard_check_pressed(ord("2"));
/// @type {Bool}
var key_3 = keyboard_check_pressed(ord("3"));
/// @type {Bool}
var key_4 = keyboard_check_pressed(ord("4"));
/// @type {Bool}
var key_5 = keyboard_check_pressed(ord("5"));
/// @type {Bool}
var key_u = keyboard_check_pressed(ord("U"));
/// @type {Bool}
var key_x = keyboard_check_pressed(ord("X"));
/// @type {Bool}
var key_enter = keyboard_check_pressed(vk_enter);
/// @type {Bool}
var key_b = keyboard_check_pressed(ord("B"));
/// @type {Bool}
var key_escape = keyboard_check_pressed(vk_escape);
/// @type {Bool}
var mouse_left = mouse_check_button_pressed(mb_left);
/// @type {Bool}
var mouse_right = mouse_check_button_pressed(mb_right);
/// @type {Bool}
var mouse_wheel_up_pressed = mouse_wheel_up();
/// @type {Bool}
var mouse_wheel_down_pressed = mouse_wheel_down();

if (global.build_mode && !instance_exists(global.build_base_id)) {
  global.build_mode = false;
  global.build_base_id = noone;
}

if (mouse_right) {
  if (global.build_mode) {
    global.build_mode = false;
    global.build_base_id = noone;
    global.build_click_lock = false;
  } else {
    global.selected_tower_id = noone;
  }
  global.confirm_action = "";
  global.confirm_timer_steps = 0;
}

if (global.build_mode) {
  if (key_q) global.selected_tower_type = (global.selected_tower_type + 4) mod 5;
  if (key_e) global.selected_tower_type = (global.selected_tower_type + 1) mod 5;
  if (mouse_wheel_up_pressed) global.selected_tower_type = (global.selected_tower_type + 4) mod 5;
  if (mouse_wheel_down_pressed) global.selected_tower_type = (global.selected_tower_type + 1) mod 5;
  if (key_1) global.selected_tower_type = 0;
  if (key_2) global.selected_tower_type = 1;
  if (key_3) global.selected_tower_type = 2;
  if (key_4) global.selected_tower_type = 3;
  if (key_5) global.selected_tower_type = 4;

  if (key_escape) {
    global.build_mode = false;
    global.build_base_id = noone;
    global.build_click_lock = false;
  }

  if (global.build_click_lock && !mouse_check_button(mb_left)) {
    global.build_click_lock = false;
  }

  /// @type {Id.Instance|Real}
  var target_base_id = global.build_base_id;

  if (mouse_left && !global.build_click_lock) {
    /// @type {Id.Instance|Real}
    var clicked_base_id = instance_position(mouse_x, mouse_y, obj_tower_base);
    if (instance_exists(clicked_base_id) && !clicked_base_id.occupied) {
      target_base_id = clicked_base_id;
      global.build_base_id = clicked_base_id;
    } else if (!instance_exists(clicked_base_id)) {
      // Clicking empty space while the build panel is open cancels build mode.
      global.build_mode = false;
      global.build_base_id = noone;
      global.build_click_lock = false;
    }
  }

  /// @type {Bool}
  var build_confirmed = key_enter || key_b;

  if (build_confirmed && instance_exists(target_base_id) && !target_base_id.occupied) {
    /// @type {Asset.GMObject|Real}
    var tower_object = scr_get_selected_tower_object();
    /// @type {Real}
    var active_tower_count = game_get_active_tower_count();
    /// @type {Real}
    var placement_hp_cost = game_get_tower_placement_hp_cost(global.selected_tower_type, active_tower_count);

    if (tower_object == noone) {
      game_trigger_base_build_fail_feedback(target_base_id);
      audio_play_variation(WAV_Snake_Hiss_1, WAV_Snake_Hiss_2, AUDIO_GAIN_UI * 0.42, 0.95, 1.05);
    } else if (!game_try_spend_hp(placement_hp_cost, target_base_id.x, target_base_id.y)) {
      game_trigger_base_build_fail_feedback(target_base_id);
      audio_play_variation(WAV_Snake_Hiss_1, WAV_Snake_Hiss_2, AUDIO_GAIN_UI * 0.42, 0.95, 1.05);
    } else {
      target_base_id.tower_instance_id = instance_create_layer(target_base_id.x, target_base_id.y, "Instances", tower_object, {
        base_owner_id : target_base_id.id,
        tower_placement_hp_cost : placement_hp_cost
      });
      target_base_id.occupied = true;
      global.selected_tower_id = target_base_id.tower_instance_id;
      global.build_mode = false;
      global.build_base_id = noone;
      global.build_click_lock = false;
      audio_play_variation(WAV_Small_Spark_1, WAV_Small_Spark_2, AUDIO_GAIN_UI, 0.97, 1.06);
    }
  }

  global.confirm_action = "";
  global.confirm_timer_steps = 0;
} else {
  if (mouse_left) {
    /// @type {Id.Instance|Real}
    var clicked_tower_id = instance_position(mouse_x, mouse_y, obj_tower_parent);
    if (!instance_exists(clicked_tower_id)) {
      global.selected_tower_id = noone;
      global.confirm_action = "";
      global.confirm_timer_steps = 0;
    }
  }

  if (key_u) {
    if (!instance_exists(global.selected_tower_id)) {
      audio_play_variation(WAV_Snake_Hiss_1, WAV_Snake_Hiss_2, AUDIO_GAIN_UI * 0.42, 0.95, 1.05);
      global.confirm_action = "";
      global.confirm_timer_steps = 0;
    } else if (global.confirm_action == "upgrade") {
      /// @type {Real}
      var confirm_target_level = global.selected_tower_id.tower_level + 1;
      /// @type {Real}
      var confirm_upgrade_cost = scr_tower_upgrade_cost(global.selected_tower_id.object_index, confirm_target_level);

      if (confirm_upgrade_cost <= 0 || global.player_coins < confirm_upgrade_cost) {
        game_trigger_tower_upgrade_fail_feedback(global.selected_tower_id);
        audio_play_variation(WAV_Snake_Hiss_1, WAV_Snake_Hiss_2, AUDIO_GAIN_UI * 0.42, 0.95, 1.05);
        global.confirm_action = "";
        global.confirm_timer_steps = 0;
      } else {
        with (global.selected_tower_id) {
          event_user(0);
        }
        global.confirm_action = "";
        global.confirm_timer_steps = 0;
      }
    } else {
      /// @type {Real}
      var target_level = global.selected_tower_id.tower_level + 1;
      /// @type {Real}
      var upgrade_cost = scr_tower_upgrade_cost(global.selected_tower_id.object_index, target_level);

      if (upgrade_cost <= 0 || global.player_coins < upgrade_cost) {
        game_trigger_tower_upgrade_fail_feedback(global.selected_tower_id);
        audio_play_variation(WAV_Snake_Hiss_1, WAV_Snake_Hiss_2, AUDIO_GAIN_UI * 0.42, 0.95, 1.05);
        global.confirm_action = "";
        global.confirm_timer_steps = 0;
      } else {
        global.confirm_action = "upgrade";
        global.confirm_timer_steps = round(CONFIRM_TIMEOUT_SECONDS * room_speed);
      }
    }
  }

  if (key_x) {
    if (!instance_exists(global.selected_tower_id)) {
      audio_play_variation(WAV_Snake_Hiss_1, WAV_Snake_Hiss_2, AUDIO_GAIN_UI * 0.42, 0.95, 1.05);
      global.confirm_action = "";
      global.confirm_timer_steps = 0;
    } else if (global.confirm_action == "delete") {
      if (game_delete_selected_tower_refund_life()) {
        audio_play_variation(WAV_Magical_Sparkle_Disappate_1, WAV_Magical_Sparkle_Disappate_2, AUDIO_GAIN_UI, 0.96, 1.06);
      } else {
        audio_play_variation(WAV_Snake_Hiss_1, WAV_Snake_Hiss_2, AUDIO_GAIN_UI * 0.42, 0.95, 1.05);
      }
      global.confirm_action = "";
      global.confirm_timer_steps = 0;
    } else {
      global.confirm_action = "delete";
      global.confirm_timer_steps = round(CONFIRM_TIMEOUT_SECONDS * room_speed);
    }
  }

  if (global.confirm_action != "" && !instance_exists(global.selected_tower_id)) {
    global.confirm_action = "";
    global.confirm_timer_steps = 0;
  }

  // Any non-confirm key press clears pending confirmation state.
  if (
    global.confirm_action != "" &&
    keyboard_check_pressed(vk_anykey) &&
    !key_u &&
    !key_x
  ) {
    global.confirm_action = "";
    global.confirm_timer_steps = 0;
  }
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