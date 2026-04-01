# Equivalent Exchange - Game Design Document (Jam MVP)

## 1. High Concept

`Equivalent Exchange` is a short-session tower defense game where the player must spend life to place towers.

- Every tower placement costs exactly `1 life`.
- Enemies that leak also remove life.
- The player must decide when to spend life for power and when to save life for survival.

This creates constant pressure: overbuilding kills you, underbuilding leaks kill you.

## 2. Jam Constraints and Scope

Target build time: `5 hours`

Scope locked for MVP:

1. 1 level only
2. 48 waves total (required)
3. 1 normal enemy + 1 boss enemy
4. 3 tower types: slow, arrow, cannon (AoE)
5. HP cost for placement (1 HP)
6. Coins used for upgrades
7. Build only on predefined base platforms

Out of scope for jam:

- Multiple maps
- Skill trees
- Meta progression
- Complicated status systems

## 3. Core Loop

1. Wave starts and enemies follow fixed path to goal.
2. Player places towers on platform tiles by paying `1 life` per tower.
3. Towers attack enemies and generate coins from kills.
4. Player spends coins to upgrade towers.
5. Leaks reduce life.
6. Survive all 48 waves.

Lose condition:

- `player_hp <= 0`

Win condition:

- Clear Wave 48.

## 4. Starting Values (Locked)

Based on current design decisions:

- Starting life: `50`
- Tower placement life cost: `1`
- Starting coins: `25`
- Normal enemy leak damage: `1 life`
- Boss leak damage: `5 life`
- Time between waves: `2.5 seconds`
- Upgrade depth: `3 levels total` per tower (`L1 base, L2, L3`)

## 5. Player Economy

Two resources:

- `Life (HP)`: survival and placement currency
- `Coins`: upgrade currency

Resource rules:

1. Placing any tower always costs `1 life`.
2. Upgrades never cost life, only coins.
3. Kills grant coins.
4. Boss kills grant large coin payout ("fat coins").

Suggested coin rewards:

- Normal enemy kill: `+2 coins`
- Boss kill: `+30 coins`

## 6. Tower Roster

All towers have 3 levels. Build cost is always 1 life regardless of type.

### 6.1 Slow Tower (control)

Role: utility and lane control.

- L1: low damage, applies slow
- L2: better slow and slight damage boost
- L3: strong slow aura on hit

Suggested stats:

- L1: damage `2`, fire rate `1.0/s`, range `160`, slow `20%` for `1.2s`
- L2: damage `3`, fire rate `1.1/s`, range `170`, slow `30%` for `1.4s`
- L3: damage `4`, fire rate `1.2/s`, range `180`, slow `40%` for `1.6s`

Upgrade coin costs:

- L1 -> L2: `20`
- L2 -> L3: `35`

### 6.2 Arrow Tower (single target DPS)

Role: reliable sustained damage.

- L1: fast single-target
- L2: better rate and damage
- L3: strong single-target finisher

Suggested stats:

- L1: damage `7`, fire rate `1.2/s`, range `220`
- L2: damage `10`, fire rate `1.35/s`, range `230`
- L3: damage `14`, fire rate `1.5/s`, range `240`

Upgrade coin costs:

- L1 -> L2: `25`
- L2 -> L3: `40`

### 6.3 Cannon Tower (AoE)

Role: wave clear and crowd burst.

- L1: slow reload, splash damage
- L2: stronger blast
- L3: high-impact wave control

Suggested stats:

- L1: impact damage `14`, splash radius `48`, fire rate `0.55/s`, range `190`
- L2: impact damage `20`, splash radius `56`, fire rate `0.60/s`, range `200`
- L3: impact damage `28`, splash radius `64`, fire rate `0.65/s`, range `210`

Upgrade coin costs:

- L1 -> L2: `30`
- L2 -> L3: `50`

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
3. Cannot place if `player_hp < 1`.

Placement transaction:

1. Player confirms placement.
2. Tower instance is created.
3. `player_hp -= 1` exactly once.

No refund in MVP (to keep rules simple and punish overbuilding).

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

## 14. 5-Hour Execution Plan

### Hour 1: Foundation

1. Global state in `obj_game_controller`
2. Path-following enemy base logic in `obj_enemy_parent`
3. Basic wave spawn loop

### Hour 2: Towers

1. Targeting and cooldown in `obj_tower_parent`
2. Implement arrow tower first
3. Implement placement on `obj_tower_base` with 1-life cost

### Hour 3: Remaining Combat

1. Add slow tower behavior
2. Add cannon AoE behavior
3. Add boss enemy variant

### Hour 4: Economy + UI

1. Coin rewards and upgrades
2. HUD values in `obj_gui`
3. Wave/boss banners and lose/win screens

### Hour 5: Balance + Polish

1. Tune wave pacing and stats
2. Verify all 48 waves run
3. Fix edge cases and do one full playtest pass

## 15. Acceptance Checklist (Definition of Done)

MVP is complete when all are true:

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

## 16. Open Questions for Next Iteration

These are optional post-MVP choices:

1. Add tower sell with partial life refund?
2. Add wave skip button for experienced players?
3. Add one elite enemy between bosses?

For jam safety, do not implement these unless MVP is already stable.
