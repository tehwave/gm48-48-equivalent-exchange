---
applyTo: "**/*.gml"
---

# GML Code Style & Type Annotations

This file applies to all GameMaker Language (GML) files in the project.

## Type Annotations (Required)

**Always annotate function parameters, return types, and ambiguous variable declarations** using JSDoc tags. Stitch uses these at declaration time to infer types.

### Function Signatures

```gml
/// @description Brief description of what the function does.
/// @param {Real} param_name - Description of this parameter
/// @param {String} text - Description
/// @returns {Bool} True if successful, false otherwise
function my_function(param_name, text) {
  return true;
}
```

### Explicit Variable Types

```gml
/// @type {Real}
var damage = 10;

/// @type {Array<String>}
var inventory = [];

/// @type {Struct}
var player_data = {};

/// @type {Id.Instance.player}
var player = noone;

/// @type {Asset.GMSprite}
var my_sprite = sp_player;
```

### Union Types

When a variable can be multiple types:

```gml
/// @type {String|Real}
var value = "text"; // or could be a number

/// @type {Bool|Void}
function maybe_return() {
  if (some_condition) {
    return true;
  }
  // implicitly returns undefined
}
```

## JSDoc Tags Used with Stitch

### Essential Tags

| Tag | Usage |
|-----|-------|
| `@param {Type} name` | Function parameter |
| `@returns {Type}` | Function return type |
| `@type {Type}` | Variable declaration type |
| `@description` | What the function/variable does |

### Advanced Tags

| Tag | Usage | Example |
|-----|-------|---------|
| `@self {Type}` | Specify `with` statement context | `/// @self {Struct.Player}` |
| `@mixin` | Function adds variables to caller | `/// @mixin` on constructor |
| `@template T` | Generic type parameter | `/// @template T` for generic functions |
| `@globalvar {Type} NAME` | Declare global variables | `/// @globalvar {Real} GAME_SPEED` |
| `@instancevar {Type} name` | Declare instance variables | `/// @instancevar {Bool} can_jump` |
| `@localvar {Type} NAME` | Declare local variables | `/// @localvar {Array} temp_array` |

## Common Type Patterns

### Asset Types

```gml
/// @type {Asset.GMObject}
var obj_reference = player;

/// @type {Asset.GMSprite}
var sprite_reference = sp_player;

/// @type {Asset.GMSound}
var sound_reference = snd_jump;

/// @type {Asset.GMRoom}
var room_reference = Room1;
```

### Instance Types

```gml
/// @type {Id.Instance}
var any_instance = noone;

/// @type {Id.Instance.player}
var player_inst = noone;

/// @type {Id.Instance.obstacles}
var obstacle = noone;
```

### Built-in Array and Struct Types

```gml
/// @type {Array<Real>}
var numbers = [1, 2, 3];

/// @type {Array<Array<String>>}
var grid = [["a", "b"], ["c", "d"]];

/// @type {Struct}
var generic_struct = {};

/// @type {Struct.Point}
var point = { x: 0, y: 0 };
```

## Context-Aware Code with `@self`

### In `with` Statements

When Stitch can't infer the context of a `with` statement, explicitly declare it:

```gml
/// @self {Struct.Player}
with (player_inst) {
  speed += 1; // Stitch now knows about player-specific variables
  play_sound = true;
}
```

### In Constructor Functions

Mark constructor functions that add instance variables:

```gml
/// @self {Function.create_player}
function initialize() {
  x = 100;
  y = 100;
  speed = 5;
}

initialize(); // Stitch tracks these variables on the caller
```

## Code Organization

### Order Within Functions

1. Parameter validation (if needed)
2. Variable declarations
3. Main logic
4. Return statement (if applicable)

```gml
/// @param {Real} damage
/// @returns {Bool}
function take_damage(damage) {
  // 1. Validate
  if (damage <= 0) return false;
  
  // 2. Declare
  var new_health = health - damage;
  
  // 3. Main logic
  health = new_health;
  if (health <= 0) {
    state = "dying";
  }
  
  // 4. Return
  return true;
}
```

### Comments

Avoid obvious comments. Write WHY, not WHAT:

```gml
// Good: explains design decision
/// Only allow jumping if grounded (prevents air-jumping)
if (is_grounded) {
  velocity_y = -jump_force;
}

// Bad: restates the code
// Subtract gravity from velocity
velocity_y += gravity;
```

## Naming Conventions

### Variables and Functions

- Use `snake_case` for all variables and functions
- Prefix instance variables with the object name: `player_speed`, `enemy_health`
- Use clear, descriptive names: `max_jump_height` instead of `mjh`

```gml
/// Good
var player_speed = 5;
function handle_player_input() { }

/// Bad
var ps = 5;
function hpi() { }
```

### Constants and Macros

Use `UPPER_SNAKE_CASE` for constants and macros:

```gml
#macro GRAVITY 0.5
#macro MAX_SPEED 10
#macro PLAYER_WIDTH 32
```

### Asset Names

Follow these prefixes in the Stitch config:

- Sprites: `sp_*` → `sp_player`, `sp_bullet`, `sp_effect_explosion`
- Objects: `obj_*` (or no prefix) → `player`, `obj_enemy`, `spawner`
- Sounds: `snd_*`, `mus_*`, `amb_*` → `snd_jump`, `mus_theme`, `amb_wind`
- Scripts: `fn_*` (optional) → `fn_vector_normalize`

## Avoid These Patterns

### Avoid Extraneous Braces

The Stitch parser doesn't support random curly braces:

```gml
// Bad: parser error
{
  var x = 10;
  show_debug_message(x);
}

// Good: use if/for/while or inline
if (true) {
  var x = 10;
  show_debug_message(x);
}
```

### Avoid IIFEs

Immediately-invoked function expressions are not supported:

```gml
// Bad: parser error
(function() {
  show_debug_message("hello");
})();

// Good: define then call
function say_hello() {
  show_debug_message("hello");
}
say_hello();
```

### Avoid Complex Macro Usage

Only use simple, complete expressions in macros:

```gml
// Good
#macro PLAYER_SPEED 5
#macro MAX_HEALTH 100

// Risky: avoid complex expressions or multi-statements
#macro COMPLEX_CALC x + y * 2 + z / 3
```

## Refactoring with Stitch

### Renaming Symbols

Use **F2** to rename any symbol. Stitch will update:
- All references in code
- Asset names (via tree view)
- References in JSDoc comments

**Example workflow:**
1. Click on `player_speed`
2. Press **F2**
3. Type `player_velocity`
4. Stitch updates everywhere (code + comments)

### Go to Definition

Press **F12** or **Ctrl+Click** on a symbol to jump to its definition. Great for:
- Understanding how built-in functions work
- Navigating to custom function definitions
- Exploring asset dependencies

### Find References

Press **Shift+F12** to find all usages of a symbol throughout the project.

## Type Inference Examples

These examples show how Stitch infers types. **Ambiguous declarations need explicit `@type` tags:**

```gml
// Stitch infers: Real
var speed = 5;

// Stitch infers: String
var name = "Player";

// AMBIGUOUS: needs @type tag
/// @type {Array<Real>}
var values = [];

// AMBIGUOUS: could be different types
/// @type {String|Real}
var data = get_data(); // function with unclear return

// Clear: function signature hints the return type
var result = move_player(5, 10); // Stitch uses the function's @returns type
```

## Testing Your Types

To verify Stitch understands your types:

1. **Hover over a variable** → See the inferred type in the tooltip
2. **Use autocomplete** → Type a symbol and press **Ctrl+Space** to see options
3. **Check errors** → Stitch will highlight type mismatches in the Problems panel
4. **View logs** → Open Output → "Stitch" dropdown for detailed parsing info

If something seems wrong:
- Add explicit `@type` tags to variables
- Add `@param` and `@returns` to functions
- Check for unsupported patterns (extraneous braces, IIFEs)
- Restart VSCode if Stitch seems out of sync

## ⚠️ CRITICAL: Asset Registration for Manual Asset Creation

**If you manually create `.yy` files and event files, your assets will NOT appear in GameMaker unless you complete asset registration.**

See [yy.instructions.md](./yy.instructions.md) for **MANDATORY** steps:

1. Register the asset in `bootleg-gm48-2.yyp` `resources` array
2. Register events in the object's `eventList` array (for objects only)
3. Reload GameMaker IDE

**This is extremely necessary.** Skipping any of these steps will result in invisible assets that cannot be used in the editor.

**Preferred approach:** Use **Stitch UI** to create assets (right-click in tree → "New Object", etc). Stitch handles all registration automatically.
## ⚠️ CRITICAL: Use Alarms for Timed Events, NOT Frame Counting

**NEVER use manual frame counting for time-based delays.** Frame counting assumes a fixed frame rate (e.g., 60fps) which GameMaker does NOT guarantee. Games can run at different speeds on different hardware, and manual counters will be inaccurate.

### ❌ WRONG: Manual Frame Counting

```gml
// Create Event
timer = 300;  // Assumes 60fps (5 seconds)

// Step Event
timer -= 1;
if (timer <= 0) {
    // Do something after 5 seconds
}
```

**Problems:**
- Assumes game runs at exactly 60fps
- Will be wrong if game runs at 30fps, 120fps, or variable fps
- No built-in support in GameMaker
- Hard to debug and maintain

### ✅ CORRECT: Use Alarms

```gml
// Create Event
// Set alarm for 5 seconds using actual game speed
alarm[0] = game_get_speed(gamespeed_fps) * 5;

// Alarm 0 Event (create Alarm_0.gml)
// This automatically fires when alarm reaches 0
// Do something after 5 seconds
```

**Benefits:**
- Frame-rate independent
- Automatically accounts for actual game speed
- Built into GameMaker engine
- More reliable and maintainable

### Pattern: Invincibility with Alarm

```gml
// Create Event
/// @type {Bool}
is_invincible = false;

// Collision Event - take damage
lives -= 1;
is_invincible = true;
alarm[0] = game_get_speed(gamespeed_fps) * 3;  // 3 seconds invincibility

// Alarm 0 Event (Alarm_0.gml)
// Invincibility ends
is_invincible = false;
```

### Pattern: Delayed Action with Alarm

```gml
// Create Event
/// @type {Bool}
can_act = false;
alarm[0] = game_get_speed(gamespeed_fps) * 2;  // 2 second delay

// Alarm 0 Event (Alarm_0.gml)
can_act = true;

// Step Event
if (can_act && keyboard_check_pressed(vk_space)) {
    // Action only available after delay
}
```

### Multiple Alarms

GameMaker provides 12 alarm slots (alarm[0] through alarm[11]). Use different slots for different timers:

```gml
// Create Event
alarm[0] = game_get_speed(gamespeed_fps) * 5;   // Invincibility timer
alarm[1] = game_get_speed(gamespeed_fps) * 10;  // Power-up duration
alarm[2] = game_get_speed(gamespeed_fps) * 1;   // Cooldown timer

// Alarm_0.gml
is_invincible = false;

// Alarm_1.gml
has_power_up = false;

// Alarm_2.gml
can_shoot = true;
```

### When Frame Counting IS Acceptable

Frame counting is acceptable for **purely visual effects** that don't affect gameplay:

```gml
// OK: Animation frame counter
blink_timer += 1;
if (blink_timer >= 5) {
    is_visible = !is_visible;  // Blink every 5 frames (visual only)
    blink_timer = 0;
}
```

**Rule of thumb:** If the timing affects gameplay logic, use alarms. If it's just for visuals, frame counting is acceptable.