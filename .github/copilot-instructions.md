# GameMaker Studio 2 Project - Tower Defense (Equivalent Exchange)

## Project Overview

This project is a **GameMaker Studio 2 tower defense game** for a game jam.

Theme: **Equivalent Exchange**

Core mechanic: **The player spends life (HP) to place towers.**
If you over-build, you die. If you under-build, enemies leak and you die.

The design goal is a short, readable, strategic loop that can be completed in one jam session.

## Jam Constraint (Critical)

You have about **5 hours**. Favor speed and clarity over feature depth.

When generating code or suggestions, optimize for:

1. Fast implementation
2. Low bug risk
3. Easy balancing with a few constants
4. Reuse of simple patterns

Avoid proposing large systems that are hard to finish (save system, procedural map generation, complex status trees, etc.).

## Tech Stack

- **Engine:** GameMaker Studio 2
- **Language:** GML
- **Editor:** VSCode + Stitch
- **Runtime:** VM first (use YYC only for final performance checks)

## Core Gameplay Loop (Must Preserve)

1. Enemies spawn and walk along a path toward the base.
2. Player places towers by paying life cost immediately.
3. Towers kill enemies to prevent leaks.
4. Leaked enemies damage remaining life.
5. Survive waves as long as possible.

This economy is intentionally harsh: life is both your health bar and your build currency.

## MVP Scope (Do This First)

Implement these before anything else:

1. One playable map with one enemy path
2. One basic enemy type
3. One basic tower type
4. Tower placement with HP cost
5. Wave spawning that scales over time
6. Lose state when HP <= 0
7. Minimal UI: HP, wave, tower cost, placement preview

If time remains, add only small upgrades:

1. Second tower type
2. Tower upgrade OR sell (not both unless trivial)
3. One enemy variant (fast or tank)

## Recommended Architecture

Use simple object responsibilities:

- `obj_gameplay_manager`: wave logic, difficulty scaling, global state
- `obj_enemy_parent`: movement along path, base damage on leak
- `obj_tower_parent`: targeting, fire cooldown, projectile spawn or instant hit
- `obj_projectile_parent` (optional): movement and damage on contact
- `obj_build_cursor`: build mode, placement checks, confirmation/cancel
- `obj_ui_hud`: draw HP, wave, cost, game state

Keep behavior in parent objects when possible so new enemies/towers only override a few values.

## Data and Balance Conventions

Prefer constants/macros for rapid tuning:

```gml
#macro STARTING_HP 100
#macro TOWER_HP_COST 15
#macro LEAK_DAMAGE 10
#macro WAVE_BASE_COUNT 6
#macro WAVE_GROWTH 2
```

Use clear variable names:

- `player_hp`
- `tower_hp_cost`
- `wave_index`
- `enemy_max_hp`
- `enemy_reward` (if you add a second currency)

If adding a second resource, keep HP spending central. Example: kills grant `scrap`, but build still requires HP.

## Equivalent Exchange Design Rules

When suggesting mechanics, enforce these principles:

1. Every power gain should have a clear cost.
2. Costs should be visible before commitment.
3. Recovery should exist but be limited.
4. Failures should feel fair and legible.

Good examples:

- Spend 20 HP to place a high-DPS tower.
- Sell tower for only partial HP refund.
- Optional panic action: sacrifice HP for instant AoE clear.

Bad examples:

- Free tower placement.
- Unlimited healing loops.
- Hidden penalties the player cannot predict.

## GML and Stitch Conventions

Follow the repo instruction files:

- `.github/instructions/gml.instructions.md`
- `.github/instructions/yy.instructions.md`

Key reminders:

1. Use JSDoc type hints for ambiguous variables and all function params/returns.
2. Keep naming in `snake_case` and constants in `UPPER_SNAKE_CASE`.
3. For manual `.yy` edits, preserve field order and register assets in `.yyp`.

## Implementation Patterns

### Tower Placement Paid by HP

```gml
/// @description Attempts to place a tower if the player can afford HP cost.
/// @param {Real} build_x
/// @param {Real} build_y
/// @returns {Bool}
function try_place_tower(build_x, build_y) {
  if (global.player_hp < TOWER_HP_COST) return false;
  if (!position_meets_build_rules(build_x, build_y)) return false;

  instance_create_layer(build_x, build_y, "Instances", obj_tower_basic);
  global.player_hp -= TOWER_HP_COST;
  return true;
}
```

### Leak Damage

```gml
// On enemy reaching goal
global.player_hp -= LEAK_DAMAGE;
instance_destroy();

if (global.player_hp <= 0) {
  global.game_state = "game_over";
}
```

### Wave Scaling (Simple)

```gml
enemies_this_wave = WAVE_BASE_COUNT + (wave_index * WAVE_GROWTH);
enemy_hp_scale = 1 + (wave_index * 0.12);
enemy_speed_scale = 1 + (wave_index * 0.03);
```

## UI Priorities

Always show:

1. Current HP (large and readable)
2. Tower HP cost
3. Current wave index
4. Build validity feedback (valid/invalid tile)

The player should never wonder: "Can I afford this tower?" or "Why did I lose HP?"

## Debugging Checklist

When the build is unstable, validate in this order:

1. Tower placement deducts HP exactly once per placement
2. Enemy leak deducts HP exactly once per leak
3. Game over triggers reliably at `player_hp <= 0`
4. Wave does not stall due to spawn timer logic
5. Towers always acquire valid targets in range

Use `show_debug_message()` for quick wave and HP logging during jam iteration.

## Out-of-Scope for Jam

Unless explicitly requested, avoid implementing:

- Save/load profiles
- Complex skill trees
- Endless procedural paths
- Large numbers of tower/enemy archetypes
- Heavy shader/VFX work before gameplay is complete

## Definition of Done (Jam Build)

The game is done when:

1. You can start, place towers by spending HP, and survive at least one wave.
2. Losing all HP always ends the run.
3. Difficulty ramps in a noticeable but fair way over several waves.
4. A new player can understand the tradeoff within 30 seconds.

If a new feature risks breaking these conditions, skip it.