/// @description Master audio settings helpers and bottom-left HUD layout.

/// @returns {Void}
function game_audio_settings_ensure_globals() {
  if (!variable_global_exists("audio_master_volume_gain")) {
    global.audio_master_volume_gain = clamp(AUDIO_MASTER_GAIN, AUDIO_MASTER_GAIN_MIN, AUDIO_MASTER_GAIN_MAX);
  }

  if (!variable_global_exists("audio_master_muted")) {
    global.audio_master_muted = false;
  }

  if (!variable_global_exists("audio_master_volume_previous_gain")) {
    global.audio_master_volume_previous_gain = max(AUDIO_MASTER_GAIN_STEP, clamp(AUDIO_MASTER_GAIN, AUDIO_MASTER_GAIN_MIN, AUDIO_MASTER_GAIN_MAX));
  }
}

/// @param {Real} gain
/// @returns {Real}
function game_audio_clamp_master_gain(gain) {
  return clamp(gain, AUDIO_MASTER_GAIN_MIN, AUDIO_MASTER_GAIN_MAX);
}

/// @returns {Void}
function game_audio_settings_apply_master_gain() {
  game_audio_settings_ensure_globals();

  /// @type {Real}
  var applied_gain = global.audio_master_muted ? 0 : game_audio_clamp_master_gain(global.audio_master_volume_gain);
  audio_master_gain(applied_gain);
}

/// @returns {Void}
function game_audio_settings_save() {
  game_audio_settings_ensure_globals();

  ini_open(AUDIO_SETTINGS_INI_FILE);
  ini_write_real("audio", "master_gain", game_audio_clamp_master_gain(global.audio_master_volume_gain));
  ini_write_real("audio", "master_muted", global.audio_master_muted ? 1 : 0);
  ini_write_real("audio", "master_previous_gain", game_audio_clamp_master_gain(global.audio_master_volume_previous_gain));
  ini_close();
}

/// @returns {Void}
function game_audio_settings_load() {
  game_audio_settings_ensure_globals();

  ini_open(AUDIO_SETTINGS_INI_FILE);

  /// @type {Real}
  var loaded_gain = ini_read_real("audio", "master_gain", AUDIO_MASTER_GAIN);
  /// @type {Bool}
  var loaded_muted = ini_read_real("audio", "master_muted", 0) >= 0.5;
  /// @type {Real}
  var loaded_previous_gain = ini_read_real("audio", "master_previous_gain", max(AUDIO_MASTER_GAIN_STEP, AUDIO_MASTER_GAIN));

  ini_close();

  global.audio_master_volume_gain = game_audio_clamp_master_gain(loaded_gain);
  global.audio_master_muted = loaded_muted;
  global.audio_master_volume_previous_gain = game_audio_clamp_master_gain(loaded_previous_gain);

  if (!global.audio_master_muted && global.audio_master_volume_gain > AUDIO_MASTER_GAIN_MIN) {
    global.audio_master_volume_previous_gain = global.audio_master_volume_gain;
  }

  if (global.audio_master_volume_previous_gain <= AUDIO_MASTER_GAIN_MIN) {
    global.audio_master_volume_previous_gain = max(AUDIO_MASTER_GAIN_STEP, game_audio_clamp_master_gain(AUDIO_MASTER_GAIN));
  }

  game_audio_settings_apply_master_gain();
}

/// @param {Real} gain
/// @param {Bool} unmute_if_positive
/// @param {Bool} save_immediately
/// @returns {Void}
function game_audio_set_master_gain(gain, unmute_if_positive, save_immediately) {
  game_audio_settings_ensure_globals();

  global.audio_master_volume_gain = game_audio_clamp_master_gain(gain);

  if (global.audio_master_volume_gain > AUDIO_MASTER_GAIN_MIN) {
    global.audio_master_volume_previous_gain = global.audio_master_volume_gain;
    if (unmute_if_positive) {
      global.audio_master_muted = false;
    }
  }

  game_audio_settings_apply_master_gain();

  if (save_immediately) {
    game_audio_settings_save();
  }
}

/// @param {Real} delta
/// @returns {Void}
function game_audio_adjust_master_gain(delta) {
  game_audio_settings_ensure_globals();
  game_audio_set_master_gain(global.audio_master_volume_gain + delta, true, true);
}

/// @returns {Void}
function game_audio_toggle_mute() {
  game_audio_settings_ensure_globals();

  if (global.audio_master_muted) {
    global.audio_master_muted = false;

    if (global.audio_master_volume_gain <= AUDIO_MASTER_GAIN_MIN) {
      global.audio_master_volume_gain = game_audio_clamp_master_gain(global.audio_master_volume_previous_gain);
    }

    if (global.audio_master_volume_gain <= AUDIO_MASTER_GAIN_MIN) {
      global.audio_master_volume_gain = max(AUDIO_MASTER_GAIN_STEP, game_audio_clamp_master_gain(AUDIO_MASTER_GAIN));
    }

    global.audio_master_volume_previous_gain = global.audio_master_volume_gain;
  } else {
    if (global.audio_master_volume_gain > AUDIO_MASTER_GAIN_MIN) {
      global.audio_master_volume_previous_gain = global.audio_master_volume_gain;
    }

    global.audio_master_muted = true;
  }

  game_audio_settings_apply_master_gain();
  game_audio_settings_save();
}

/// @param {Real} gui_width
/// @param {Real} gui_height
/// @returns {Struct}
function game_audio_ui_get_layout(gui_width, gui_height) {
  /// @type {Real}
  var panel_width = 304;
  /// @type {Real}
  var panel_height = 40;
  /// @type {Real}
  var panel_x = 16;
  /// @type {Real}
  var panel_y = gui_height - panel_height - 16;

  /// @type {Real}
  var mute_button_width = 108;
  /// @type {Real}
  var icon_button_width = 28;
  /// @type {Real}
  var value_width = 96;
  /// @type {Real}
  var inner_margin = 10;
  /// @type {Real}
  var item_gap = 8;

  /// @type {Real}
  var mute_x1 = panel_x + inner_margin;
  /// @type {Real}
  var mute_y1 = panel_y + 6;
  /// @type {Real}
  var mute_x2 = mute_x1 + mute_button_width;
  /// @type {Real}
  var mute_y2 = panel_y + panel_height - 6;

  /// @type {Real}
  var minus_x1 = mute_x2 + item_gap;
  /// @type {Real}
  var minus_x2 = minus_x1 + icon_button_width;

  /// @type {Real}
  var value_x1 = minus_x2 + item_gap;
  /// @type {Real}
  var value_x2 = value_x1 + value_width;

  /// @type {Real}
  var plus_x1 = value_x2 + item_gap;
  /// @type {Real}
  var plus_x2 = plus_x1 + icon_button_width;

  return {
    panel_x : panel_x,
    panel_y : panel_y,
    panel_width : panel_width,
    panel_height : panel_height,
    mute_x1 : mute_x1,
    mute_y1 : mute_y1,
    mute_x2 : mute_x2,
    mute_y2 : mute_y2,
    minus_x1 : minus_x1,
    minus_y1 : mute_y1,
    minus_x2 : minus_x2,
    minus_y2 : mute_y2,
    value_x1 : value_x1,
    value_y1 : mute_y1,
    value_x2 : value_x2,
    value_y2 : mute_y2,
    plus_x1 : plus_x1,
    plus_y1 : mute_y1,
    plus_x2 : plus_x2,
    plus_y2 : mute_y2
  };
}
