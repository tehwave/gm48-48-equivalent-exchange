# Plan: Post-Feedback Balance & Bug Fix Pass

## TL;DR
All 8 players say the game is too easy — you can fill all 28 tower slots immediately for 28 HP from 48 starting HP, leaving plenty of buffer. Several players also reported tower rotation bugs, broken VFX, enemies sliding sideways, and awkward controls. This plan addresses balance (the #1 issue), visual bugs, and QoL in 4 phases.

## Verified Facts (from MCP export + room data)
- Room: rm_game, 1366x768, **30 FPS** (room_speed=30)
- Tower bases in room: **28** (confirmed via room YY)
- Starting HP: 48, Starting Coins: 48
- Tower cost: 1 HP each (can fill entire map for 28 HP, keeping 20 HP buffer)
- Enemy basic base HP: 16, Boss base HP: 60 (×2.3 = 138 effective at wave 12)
- HP scale: 12%/wave, Speed scale: 3%/wave
- Spawn interval: 0.75s→0.45s over 48 waves  
- obj_enemy_parent has NO image_angle update — enemies never rotate to face direction
- Tower directional sprite offset: 180° — likely causes backwards-facing bug
- Flamer/Freeze VFX angle offset: -90° — causes sideways VFX  
- Controls: Q/E cycle, U upgrade, X delete — scattered across keyboard
- Coins: click-to-collect only (Mouse_0 event on obj_coin_pickup)
- obj_enemy_parent has events: Create_0, Step_0, Destroy_0, Draw_0
- obj_tower_parent has events: Create_0, Step_0, Draw_0, Other_10 (User Event 0)
- obj_coin_pickup has events: Create_0, Step_0, Draw_0, Mouse_0
- All tower children (arrow, slow, cannon, flamer, freeze) are children of obj_tower_parent
- All enemy children (basic, boss) are children of obj_enemy_parent
- Boss death handling: in obj_enemy_parent/Step_0 with no boss-specific branch (just coin drop)
- game_delete_selected_tower_refund_life() in scr_game_state uses TOWER_PLACEMENT_HP_COST — auto-adjusts

---

## Phase 1: Balance Overhaul (Critical — every player mentioned this)

The root cause: 28 tower bases × 1 HP each = 28 HP total to fill the entire map. With 48 starting HP, the player keeps 20 HP and a full defense grid. There's zero tension.

### Steps

1. **Increase tower placement cost** — `TOWER_PLACEMENT_HP_COST` from `1` → `3`
   - File: `scripts/scr_game_constants/scr_game_constants.gml`, line ~7
   - Effect: filling all 28 slots costs 84 HP — impossible. Player must choose ~10 towers from 30 HP.

2. **Reduce starting HP** — `STARTING_HP` from `48` → `30`
   - Same file, line ~3
   - Max towers affordable: 10 (30/3). Just over 1/3 of slots. Creates real tradeoffs.

3. **Reduce starting coins** — `STARTING_COINS` from `48` → `10`
   - Same file, line ~4
   - Prevents immediate upgrading; forces earning coins through gameplay.

4. **Increase enemy base HP** — `ENEMY_BASIC_BASE_HP` from `16` → `24`
   - Same file, line ~21
   - Enemies survive longer, especially early when player has few towers.

5. **Increase enemy HP scaling** — `ENEMY_HP_SCALE_PER_WAVE` from `0.12` → `0.16`
   - Same file, line ~34
   - Late-game enemies become much tankier: wave 48 HP goes from ~7.5x to ~8.5x multiplier.

6. **Increase upgrade costs ~40%** — All `UPGRADE_TO_*` macros
   - Same file, lines ~110-120
   - Example: Arrow L2: 20→28, L3: 38→54. Cannon L2: 28→40, L3: 50→70. Etc.

7. **Add HP recovery on boss kill** — New constant `BOSS_KILL_HP_REWARD 3`
   - New macro in scr_game_constants
   - Implementation: in `obj_enemy_parent/Step_0.gml`, in the death block, if `object_index == obj_enemy_boss`, add `global.player_hp += BOSS_KILL_HP_REWARD`
   - Gives player a reason to survive to boss waves; creates recovery loop.

8. **Update tower delete refund** — `game_delete_selected_tower_refund_life()` already refunds `TOWER_PLACEMENT_HP_COST` (line ~67 of scr_game_state), so it auto-adjusts to 3. No change needed.

9. **Increase coin reward slightly** — `ENEMY_BASIC_BASE_REWARD` from `4` → `3` (actually reduce to compensate for more enemies surviving = more coins overall) OR keep at 4 and let upgrade costs gate it. Decision: keep at 4 since upgrade costs are rising.

### Revised Balance Math
- Starting HP: 30. Tower cost: 3. Max initial towers: 10 of 28 slots.
- Each boss kill grants +3 HP = can place 1 more tower per boss phase.
- 4 boss waves × 3 HP = 12 extra HP over the run → ~4 more towers → ~14 total.
- Player must still choose carefully; can never fill the whole map.
- If enemies leak (1 life each), tower budget shrinks further.

---

## Phase 2: Bug Fixes

### Step 1: Tower Rotation Fix
- **Issue**: Towers visually face wrong direction (reported by Villany)
- **Root cause**: `TOWER_DIRECTION_SPRITE_ANGLE_OFFSET = 180` in scr_game_constants. This rotates the sprite mapping by 180°, making towers face backwards from their target.
- **File**: `scripts/scr_game_constants/scr_game_constants.gml`, line ~12
- **Fix**: Change `TOWER_DIRECTION_SPRITE_ANGLE_OFFSET` from `180` → `0`. This requires manual testing — the correct value depends on how the sprite sheet angles are authored. If sprites face "down" at index 1, offset should be 0. If they face "up", offset should be 180. The current 180 is clearly wrong per player reports. Try `0` first; if still off, try `90` or `270`.
- **Verification**: Launch game, place a tower, observe it targets an enemy → sprite should face toward the target.

### Step 2: VFX Direction Fix
- **Issue**: Visual effects positioned wrong or going wrong direction (reported by Mimpy)
- **Root cause**: `tower_attack_vfx_angle_offset` is set to `-90` for Flamer and Freeze towers in `obj_tower_parent/Create_0.gml` (lines ~61, ~68). This offsets the VFX draw position and rotation 90° from the tower's actual facing.
- **File**: `objects/obj_tower_parent/Create_0.gml`
- **Fix**: Change Flamer and Freeze `tower_attack_vfx_angle_offset` from `-90` → `0`. Same caveat as rotation — depends on how VFX sprite is authored. `-90` likely was a guess and players confirm it's wrong.
- **Verification**: Place Flamer tower, observe flame VFX points toward the target (not sideways).

### Step 3: Enemy Facing Direction
- **Issue**: Enemies slide sideways (reported by Mager Trash)
- **Root cause**: `image_angle` is never set on enemies. They follow a path but the sprite doesn't rotate to face travel direction.
- **File**: `objects/obj_enemy_parent/Step_0.gml`
- **Fix**: After `path_speed = enemy_move_speed * move_factor;`, add:
  ```
  if (path_speed != 0) {
    image_angle = point_direction(xprevious, yprevious, x, y);
  }
  ```
  However, since enemies use path movement (not manual x/y), the position updates happen after the step event. Alternative: use `path_get_direction(path_main, path_position)` or track previous position with a variable. OR simpler: just flip `image_xscale` negative/positive based on horizontal direction (common in 2D sprite games with non-rotated sprites). Since these are top-down insect sprites, proper rotation is better.
- **Best approach**: Store `enemy_prev_x`/`enemy_prev_y` in Create, update `image_angle` from previous-to-current direction in Step, then update prev at end of step. 
- **Verification**: Watch enemies follow the path — they should face their movement direction, not slide sideways.

---

## Phase 3: Controls QoL

### Step 1: Remap keys closer together
- **Issue**: Q, E, U, X are spread across keyboard (reported by Skye Veran)
- **File**: `objects/obj_game_controller/Step_0.gml`
- **Fix**:
  - Keep Q/E for tower cycling (already good positions)
  - Change Upgrade from U → W (above Q/E, easy reach)
  - Change Delete from X → S or R... actually R is restart. Change Delete from X → D
  - Keep 1-5 for direct tower selection (standard for TD games)
- **Also update**: HUD text in `objects/obj_gui/Draw_64.gml` — change `[U]` → `[W]` and `[X]` → `[D]`
- **Also update**: Intro screen text mentioning controls

---

## Phase 4: Engagement QoL (Nice-to-have)

### Step 1: Auto-collect coins in radius
- **Issue**: After building, players just watch with nothing to do (reported by _gdev, Skye Veran)
- **File**: `objects/obj_coin_pickup/Step_0.gml`
- **Fix**: Instead of requiring click, auto-collect coins after they settle on the ground (e.g., 1.5s after spawn). Remove the Mouse_0 click requirement.
- **Alternative**: Keep click-to-collect but add a "collect all" hotkey (C key) that collects all coins at once.
- **Decision**: Auto-collect after settling is simpler and removes tedium without adding a new key.

### Step 2: Fast-forward toggle
- **Issue**: Late waves become boring to watch (_gdev, Skye Veran)
- This is more complex (changing room_speed). Skip for now unless player explicitly requests.

---

## Relevant Files

- `scripts/scr_game_constants/scr_game_constants.gml` — All balance constants (HP, costs, scaling, upgrade prices)
- `scripts/scr_game_state/scr_game_state.gml` — Economy transaction functions, `game_delete_selected_tower_refund_life()`
- `objects/obj_tower_parent/Create_0.gml` — VFX angle offsets per tower type
- `objects/obj_tower_parent/Step_0.gml` — Tower directional sprite rotation logic
- `objects/obj_enemy_parent/Step_0.gml` — Enemy movement, death (add boss HP reward + facing fix)
- `objects/obj_enemy_parent/Create_0.gml` — Add `enemy_prev_x`/`enemy_prev_y` init
- `objects/obj_game_controller/Step_0.gml` — Key binding remapping (U→W, X→D)
- `objects/obj_gui/Draw_64.gml` — HUD text updates for new keybinds
- `objects/obj_coin_pickup/Step_0.gml` — Auto-collect after settle

## Verification

1. Launch game. Confirm starting HP shows 30, coins shows 10.
2. Place a tower — confirm 3 HP deducted (27 remaining).
3. Try to place 11th tower — should be blocked (30 HP / 3 = 10 max).
4. Delete a tower with D key — confirm 3 HP refunded.
5. Upgrade a tower with W key — confirm new costs apply.
6. Kill a boss on wave 12 — confirm +3 HP recovered.
7. Observe towers face their targets correctly (no 180° flip).
8. Observe Flamer/Freeze VFX aim toward enemies (not sideways).
9. Watch enemies follow path — they should face their travel direction.
10. Run to wave 20+ — confirm difficulty feels challenging, not trivially easy.
11. Coins auto-collect after landing without needing clicks.

## Decisions

- HP cost of 3 is the sweet spot: meaningful sacrifice without being punishing. 2 still allows 24 towers from 48 HP. 4 might be too harsh (only 7 towers).
- Starting HP 30 with cost 3 = exactly 10 towers max early. With boss rewards (+12 over the run), up to ~14. This leaves 14 of 28 slots permanently empty = real strategic choices.
- Auto-collect coins removes the only active engagement mid-wave. But since the alternative is "boring clicking" per player feedback, it's the right call. If more engagement is needed later, add a speed toggle or active ability.
- Rotation fix (offset 0 vs 180) may need runtime testing. Start with 0, adjust if sprites visually face wrong.

## Further Considerations

1. **Coin auto-collect timing**: Should coins auto-collect instantly on ground settle, or after a 1-2 second delay? Recommend: 1.5s delay after settling so the bounce animation completes and player sees the reward before it flies away.
2. **Enemy speed scaling**: Currently 3% per wave. Consider bumping to 4-5% to increase late-game pressure. Optional — test after HP/damage changes first.
3. **Fast-forward**: Multiple players got bored late-game. A simple 2x speed toggle (Space or F key) would help a lot but is higher effort. Recommend as a follow-up if the balance changes still leave late-game slow.
