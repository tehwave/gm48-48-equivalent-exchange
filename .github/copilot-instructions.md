# GameMaker Studio 2 Project - Tower Defense (Equivalent Exchange)

## Project Overview

This project is a **GameMaker Studio 2 tower defense game** originally built for the gm(48) game jam and now being developed as a polished post-jam release.

Theme: **Equivalent Exchange**

Core mechanic: **The player spends life (HP) to place towers.**
If you over-build, you die. If you under-build, enemies leak and you die.

The design goal is a tight, readable, strategic loop within a deliberately small scope.

## Project Phase

This is the **post-jam polish version**. The jam build was submitted successfully. There are no deadline constraints — prioritize quality, correctness, and polish over speed.

When generating code or suggestions, optimize for:

1. Clean, maintainable implementation
2. Correct behavior and edge-case handling
3. Good game feel and polish
4. Easy balancing with centralized constants
5. Reuse of simple patterns

The scope of the game is intentionally small. Do not propose systems that expand it beyond what it already is (no new maps, no meta-progression, no procedural generation, no skill trees). Improve what exists rather than adding new pillars.

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

## Game Scope

The game is one self-contained tower defense run on a single map:

1. One playable map with one enemy path
2. Two enemy types (basic + boss)
3. Five tower types (arrow, cannon, slow, freeze, flamer)
4. Tower placement with HP cost
5. Coin economy for upgrades
6. 48 waves with boss waves every 12
7. Win state at wave 48, lose state at HP <= 0
8. Full UI: HP, coins, wave counter, tower selection, upgrade/sell, placement preview

Polish priorities (now that the jam is over):

1. Balancing and tuning across all 48 waves
2. Visual and audio feedback (hit effects, tower animations, sound cues)
3. Game feel improvements (camera, UI transitions, readability)
4. Bug fixes and edge-case handling
5. Quality-of-life features within existing scope

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

## MCP Workflow (Context First)

When non-trivial gameplay/system tasks come up (multi-file changes, behavior refactors, debugging unknown interactions), prefer gathering whole-project context first using:

- `mcp_gms2-mcp_export_project_data`

Then use targeted MCP tools for detail-level inspection:

- `mcp_gms2-mcp_get_object_info` for object/event/inheritance details
- `mcp_gms2-mcp_get_gml_file_content` for exact script or event code
- `mcp_gms2-mcp_list_project_assets` for asset discovery and naming validation

This order reduces hallucinated assumptions about object relationships and speeds up safe jam-time edits.

## Out of Scope

Unless explicitly requested, avoid implementing:

- Additional maps or levels
- Save/load profiles or meta-progression
- Complex skill trees or talent systems
- Procedural paths or map generation
- Large numbers of new tower/enemy archetypes beyond the existing roster
- Narrative systems or cutscenes

The game is one map, one path, 48 waves. Improve what's there — don't add new pillars.

## Definition of Done (Post-Jam Release)

The game is done when:

1. All 48 waves are completable with a well-tuned difficulty curve.
2. Every tower type, enemy type, and upgrade level is balanced and functional.
3. Losing all HP always ends the run.
4. The HUD clearly communicates HP, coins, wave, costs, and game state.
5. Visual and audio feedback makes the game feel polished and responsive.
6. A new player can understand the core tradeoff within 30 seconds.
7. No known bugs or stalls in wave logic, targeting, or placement.

If a new feature risks breaking these conditions, skip it.