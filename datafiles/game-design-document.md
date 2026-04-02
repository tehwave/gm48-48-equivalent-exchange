# Equivalent Exchange - Game Design Document

## 1. High Concept

`Equivalent Exchange` is a tower defense game where the player must spend life to place towers.

- Every tower placement costs exactly `1 life`.
- Enemies that leak also remove life.
- The player must decide when to spend life for power and when to save life for survival.

This creates constant pressure: overbuilding kills you, underbuilding leaks kill you.

## 2. Scope

The game is a single self-contained tower defense run:

1. 1 level only
2. 48 waves total
3. 2 enemy types: basic + boss
4. 5 tower types: arrow, cannon, slow, freeze, flamer
5. HP cost for placement (1 HP)
6. Coins used for upgrades
7. Build only on predefined base platforms
8. Tower sell with partial life refund

Out of scope:

- Multiple maps or levels
- Skill trees or meta-progression
- Procedural generation
- Additional enemy/tower archetypes beyond the existing roster

## 3. Core Loop

1. Wave starts and enemies follow fixed path to goal.
2. Player places towers on platform tiles by paying `3 life` per tower.
3. Towers attack enemies and generate coins from kills.
4. Player spends coins to upgrade towers.
5. Leaks reduce life.
6. Survive all 48 waves.

Lose condition:

- `player_hp <= 0`

Win condition:

- Clear Wave 48.

## 4. Starting Values

Current implementation (all defined in `scr_game_constants`):

- Starting life: `48`
- Starting coins: `48`
- Tower placement life cost: `3`
- Normal enemy leak damage: `1 life`
- Boss leak damage: `5 life`
- Boss kill HP reward: `3 life`
- Time between waves: `2.5 seconds`
- Upgrade depth: `3 levels total` per tower (`L1 base, L2, L3`)

## 5. Player Economy

Two resources:

- `Life (HP)`: survival and placement currency
- `Coins`: upgrade currency

Resource rules:

1. Placing any tower costs `3 life`.
2. Upgrades never cost life, only coins.
3. Kills grant coins.
4. Boss kills grant coins AND restore `3 life`.

Coin rewards:

- Normal enemy kill: `+4 coins`
- Boss kill: `+20 coins` + `+3 life`

## 6. Tower Roster

All towers have 3 levels. Build cost is always 1 life regardless of type.

All stats are centralized in `scr_game_constants` and applied via `scr_tower_apply_level_stats()`.

### 6.1 Slow Tower (control)

Role: utility and lane control.

- L1: damage `4`, fire rate `1.1s`, range `150`, slow `30%` for `1.2s`
- L2: damage `7`, fire rate `1.0s`, range `165`, slow `40%` for `1.4s`
- L3: damage `10`, fire rate `0.85s`, range `180`, slow `50%` for `1.6s`

Upgrade costs: L2 `34`, L3 `59`

### 6.2 Arrow Tower (single target DPS)

Role: reliable sustained damage.

- L1: damage `8`, fire rate `0.75s`, range `165`
- L2: damage `13`, fire rate `0.65s`, range `180`
- L3: damage `20`, fire rate `0.55s`, range `200`

Upgrade costs: L2 `28`, L3 `54`

### 6.3 Cannon Tower (AoE)

Role: wave clear and crowd burst.

- L1: damage `12`, fire rate `1.35s`, range `190`, splash radius `55`
- L2: damage `18`, fire rate `1.2s`, range `210`, splash radius `70`
- L3: damage `27`, fire rate `1.05s`, range `230`, splash radius `88`

Upgrade costs: L2 `40`, L3 `70`

### 6.4 Freeze Tower (hard CC)

Role: area denial and burst lockdown.

- L1: damage `3`, fire rate `1.25s`, range `145`, freeze `0.8s`
- L2: damage `5`, fire rate `1.1s`, range `165`, freeze `1.0s`
- L3: damage `8`, fire rate `0.95s`, range `185`, freeze `1.2s`

Upgrade costs: L2 `45`, L3 `82`

### 6.5 Flamer Tower (DoT / cone AoE)

Role: sustained area damage with burn.

- L1: damage `3`, fire rate `0.28s`, range `130`, cone `70°`, burn `1.0/tick` for `1.1s`
- L2: damage `5`, fire rate `0.24s`, range `145`, cone `80°`, burn `1.5/tick` for `1.4s`
- L3: damage `7`, fire rate `0.20s`, range `160`, cone `90°`, burn `2.2/tick` for `1.8s`

Upgrade costs: L2 `42`, L3 `76`

Burn tick rate: `0.25s` (ENEMY_BURN_TICK_SECONDS)

## 7. Enemy Roster

### 7.1 Basic Enemy

Role: standard wave filler.

Base stats:

- HP: `25`
- Speed: `1.6`
- Leak damage: `1 life`
- Coin reward: `2`

Scaling:

- HP scaling per wave: `+8%`
- Speed scaling per wave: `+1.5%`

Formula idea:

`enemy_hp = round(25 * power(1.08, wave_index - 1))`

### 7.2 Boss Enemy

Role: periodic threat every 12th wave.

Base stats (Wave 12 boss):

- HP: `500`
- Speed: `1.0`
- Leak damage: `5 life`
- Coin reward: `30`

Boss scaling by boss number (`wave / 12`):

- HP multiplier: `x1.55` per boss tier
- Speed multiplier: `x1.05` per boss tier

Boss waves:

- Wave 12
- Wave 24
- Wave 36
- Wave 48

## 8. Wave Structure (48 Total)

Design goal: short wave gaps and constant pressure.

- Pre-wave delay: `2.5s`
- In-wave spawn interval starts at `0.65s`
- Spawn interval gradually lowers to `0.35s` by late waves

Wave composition blocks:

1. Waves 1-11: basic enemies only
2. Wave 12: basic enemies + boss
3. Waves 13-23: stronger basics (higher count/scaling)
4. Wave 24: stronger basics + boss
5. Waves 25-35: high-pressure basics
6. Wave 36: high-pressure basics + boss
7. Waves 37-47: final pressure block
8. Wave 48: final boss wave

Suggested enemy count curve for basics:

`base_count = 6 + floor((wave_index - 1) * 1.2)`

Boss wave composition:

- Spawn `70%` of calculated basic count
- Then spawn 1 boss after a short delay (for dramatic readability)

## 9. Build Rules

Placement constraints:

1. Tower can only be placed on instances of `obj_tower_base`.
2. Cannot place if occupied by an existing tower.
3. Cannot place if `player_hp < 3`.

Placement transaction:

1. Player confirms placement.
2. Tower instance is created.
3. `player_hp -= 3` exactly once.

Selling a tower returns 1 life (partial refund).

## 10. One-Level Layout Plan

Single map requirements:

1. One clearly readable enemy path from spawn to goal.
2. Multiple tower platforms near corners/turns.
3. At least 10-14 build platforms for meaningful decisions.

Recommended room entities:

- `obj_game_controller` (one instance)
- `obj_gui` (one instance)
- Path marker or path-follow system instances
- Multiple `obj_tower_base` instances placed by hand

## 11. UI / UX Requirements

Always visible HUD values:

1. Life (large and obvious)
2. Coins
3. Current wave / 48
4. Selected tower type
5. Placement cost (`1 life`)
6. Upgrade cost for selected tower

Placement preview feedback:

- Green: valid placement
- Red: invalid placement

Boss readability:

- Wave banner text: `BOSS WAVE`

## 12. Game Objects and Responsibilities

Use existing object names as core skeleton:

- `obj_game_controller`
	- Owns global state: life, coins, wave index, spawn logic, game state
- `obj_enemy_parent`
	- Handles path movement, HP, leak behavior, reward payout
- `obj_obstacle_parent`
	- Can remain reserved/unused unless needed for map blockers
- `obj_tower_parent`
	- Shared targeting, cooldown, attack API
- `obj_tower_base`
	- Buildable platform marker
- `obj_gui`
	- Draw HUD, wave banners, lose/win state overlays

Suggested child objects to add:

- `obj_enemy_basic` (child of `obj_enemy_parent`)
- `obj_enemy_boss` (child of `obj_enemy_parent`)
- `obj_tower_slow` (child of `obj_tower_parent`)
- `obj_tower_arrow` (child of `obj_tower_parent`)
- `obj_tower_cannon` (child of `obj_tower_parent`)
- Optional projectile objects if not using instant-hit

## 13. Tuning Targets

Desired run duration:

- Approximately `12-18 minutes` if player is doing reasonably well.

Difficulty shape:

1. Waves 1-8: tutorial pressure
2. Waves 9-20: first real tradeoff pressure
3. Waves 21-35: sustained strain
4. Waves 36-48: high risk, high payout, narrow margins

Equivalent exchange feel checks:

- If player builds too much early, they become fragile.
- If player greedily saves life, leaks punish them.
- Winning should feel like balancing on edge, not brute force.

## 14. Polish Priorities

1. Balance and tune the full 48-wave difficulty curve
2. Visual and audio feedback (hit effects, tower animations, sound cues)
3. Game feel improvements (UI transitions, placement readability)
4. Bug fixes and edge-case handling
5. Quality-of-life features within existing scope

## 15. Acceptance Checklist (Definition of Done)

The game is complete when all are true:

1. Player can place towers only on base platforms.
2. Every placement costs exactly 1 life.
3. Enemies follow path and leak correctly.
4. Normal leak does 1 life damage.
5. Boss leak does 5 life damage.
6. There are 48 waves.
7. Every 12th wave includes a boss.
8. Boss kill grants fat coins.
9. Coins can upgrade towers to level 3.
10. HUD clearly shows life, coins, and wave.
11. Game ends at life <= 0.
12. Wave 48 is beatable but difficult.

## 16. Open Questions

1. Add wave skip button for experienced players?
2. Add one elite enemy type between bosses?
3. Additional visual polish passes (particles, screen shake, etc.)?
