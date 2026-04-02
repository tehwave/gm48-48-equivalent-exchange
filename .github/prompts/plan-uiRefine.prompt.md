## Plan: UI Refine — HUD, Tower Selection, Confirmations, Kill Counts

Overhaul the HUD: move wave/boss info to top-left, life/coins to top-right with compact rounded panels, rework tower building to a click-base-then-pick-type flow, add upgrade/delete two-press confirmations, show contextual controls on selected towers, add level pips and kill counts, and replace all raw rectangles with a reusable rounded-rect helper.

---

### Phase 1: Foundation — Rounded-Rect Helper + New Globals

1. Add `scr_draw_rounded_panel(px, py, pw, ph, bg_alpha, corner_radius)` to `scr_game_state.gml` — uses GML built-in `draw_roundrect_ext()` for rounded corners, no shaders needed
2. Add `scr_get_tower_description(tower_type_index)` returning a struct `{ name, damage_type, special, hp_cost }` for each of the 5 tower types
3. In `obj_game_controller/Create_0.gml`, add: `global.confirm_action = ""`, `global.confirm_timer_steps = 0`, `global.build_mode = false`, `global.build_base_id = noone`
4. Add `#macro CONFIRM_TIMEOUT_SECONDS 3` in `scr_game_constants.gml`

### Phase 2: Tower Kill Tracking

5. Add `tower_kill_count = 0` in `obj_tower_parent/Create_0.gml`
6. Add `enemy_last_damage_source = noone` in `obj_enemy_parent/Create_0.gml`
7. Modify `enemy_take_damage()` in `scr_game_state.gml` to accept optional 3rd param `source_tower_id`, setting it on the enemy
8. In `obj_enemy_parent/Step_0.gml` death block, credit `tower_kill_count++` on the source tower
9. Add `proj_source_tower_id` to `obj_projectile_arrow/Create_0.gml` and `obj_projectile_cannon/Create_0.gml`; pass through to `enemy_take_damage()` in their Step events
10. Pass `id` as source in all attack calls in `obj_tower_parent/Step_0.gml` — *depends on 7*

### Phase 3: Build Flow — Click Base → Choose Tower → Build

11. Refactor `obj_tower_base/Mouse_0.gml`: clicking unoccupied base enters build mode (`global.build_mode = true`, `global.build_base_id = id`) instead of instant-placing — *parallel with Phase 2*
12. In `obj_game_controller/Step_0.gml`: in build mode, Q/E/1-5 cycle tower type, LMB on base or Enter confirms placement (reuses existing placement logic), RMB/Escape cancels — *depends on 11*
13. In `obj_gui/Draw_64.gml`: when `global.build_mode`, draw a panel near the base listing all 5 towers with name, damage type description, key shortcut, HP cost, and "Click/Enter to build | RMB cancel" — *depends on 11, 1*

### Phase 4: Selected Tower Info Panel + Level Pips

14. In `obj_gui/Draw_64.gml`: when a tower is selected (not build mode), draw context panel near it showing: tower name, level pips (●●○ for L2/L3), kill count, "[U] Upgrade: X coins", "[X] Delete: +3 Life" — *depends on 1, 5*
15. In `obj_tower_parent/Draw_0.gml`: draw level indicator pips above tower when selected; move range ring display out from behind `global.debug_mode` guard so it always shows when selected — *parallel with 14*

### Phase 5: Upgrade/Delete Two-Press Confirmations

16. In `obj_game_controller/Step_0.gml`: U key first press sets `global.confirm_action = "upgrade"`, second press executes; same for X/delete. Timer auto-cancels after 3s. Any other key or deselect resets — *depends on 3*
17. In `obj_gui/Draw_64.gml`: flash "CONFIRM?" text in the tower panel when confirm is pending — *depends on 14, 16*

### Phase 6: HUD Layout Reorganization

18. **Top-Left panel**: Wave X/48 + boss badge + enemies remaining — using `scr_draw_rounded_panel()` — *depends on 1*
19. **Top-Right panel**: Life (red) + Coins (yellow), compact two-line layout — *depends on 1*
20. **Remove** old 7-line info dump from top-right (Build:, Exchange Cost:, Upgrade:, Delete: lines, preview box)
21. **Context hint** below top-right: "Click a base to build" when idle; hidden when build mode or tower selected (those have their own panels) — *depends on 18, 19*

### Phase 7: Boss Banner + End-Screen Polish

22. Wrap boss banner and game-over/victory panels in `scr_draw_rounded_panel()` — *depends on 1*

---

### Relevant Files (16 files modified)

- `scr_game_state.gml` — add draw helper, tower description helper, modify `enemy_take_damage()`
- `scr_game_constants.gml` — add `CONFIRM_TIMEOUT_SECONDS`
- `obj_game_controller/Create_0.gml` — new globals
- `obj_game_controller/Step_0.gml` — build mode flow, confirm logic, input refactor
- `obj_gui/Draw_64.gml` — full HUD rewrite (biggest change)
- `obj_tower_parent/Create_0.gml` — `tower_kill_count`
- `obj_tower_parent/Draw_0.gml` — level pips, range ring always-on
- `obj_tower_parent/Step_0.gml` — pass tower id to damage calls
- `obj_tower_base/Mouse_0.gml` — enter build mode
- `obj_enemy_parent/Create_0.gml` — `enemy_last_damage_source`
- `obj_enemy_parent/Step_0.gml` — credit kills
- `obj_projectile_arrow/Create_0.gml` — `proj_source_tower_id`
- `obj_projectile_arrow/Step_0.gml` — pass source
- `obj_projectile_cannon/Create_0.gml` — `proj_source_tower_id`
- `obj_projectile_cannon/Step_0.gml` — pass source

### Verification

1. Top-left shows wave counter; top-right shows life + coins only
2. Click empty base → build menu appears with 5 tower options and descriptions
3. Q/E/1-5 in build mode highlights tower; Click/Enter places; RMB cancels
4. Click existing tower → info panel near it with name, level pips, kills, upgrade/delete controls
5. U pressed → "Confirm?" shown; U again → upgrades; wait 3s → auto-cancels
6. X pressed → "Confirm?" shown; X again → deletes; wait 3s → auto-cancels
7. Kill counts increment correctly for direct-hit and projectile towers
8. Rounded panels everywhere; boss banner and end screens polished

### Decisions

- **No blur background** — GML doesn't support native blur without shaders/surfaces, too complex for jam. Rounded semi-transparent black panels are the visual upgrade.
- **Kill credit = last hit** — simple, no damage contribution tracking needed.
- **Two-press confirmation** (not hold) — faster flow, no timing UI.
- **Tower type selection (Q/E/1-5) only active in build mode** — simplifies HUD. Easy to revert if unwanted.
- **Level pips visible only when tower is selected** — avoids clutter.
