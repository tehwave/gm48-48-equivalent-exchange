## Plan: Jam MVP Implementation Blueprint

Implement the full 48-wave Equivalent Exchange MVP by building a minimal, parent-driven GMS2 architecture: one central controller for economy/waves, parent enemy/tower behaviors with lightweight children for stats, platform-only placement that always costs 1 HP, and HUD-first readability. This approach prioritizes jam speed and low bug risk by reusing patterns from the reference project (path-based movement, path-progress targeting, alarm/cooldown timing) while keeping upgrade and wave data in constants/functions for quick balancing.

**Steps**
1. Phase 1 - Data and project wiring (foundation)
2. Define macros and shared helper scripts for economy, wave formulas, and tower stat lookup so balancing is centralized and fast to tweak. *blocks all later phases*
3. Create/register missing assets in `.yyp` and each object `eventList` exactly per existing field order rules (`.yy` safety-critical). *depends on 2*
4. Add a single path asset for the lane and set room bootstrap instances (`obj_game_controller`, `obj_gui`) plus 10-14 `obj_tower_base` placements. *parallel with 3 after asset names are decided*
5. Phase 2 - Core game loop (controller + enemies)
6. Implement `obj_game_controller` Create/Step/Alarm flow: starting HP/coins, wave index, pre-wave delay (2.5s), spawn scheduling, win/lose state, and boss insertion on every 12th wave. *depends on 2-4*
7. Implement `obj_enemy_parent` Create/Step/Destroy with path movement, leak handling, reward payout, and status handling (slow timer/effect); add children `obj_enemy_basic` and `obj_enemy_boss` for base stats/scaling hooks. *depends on 6*
8. Add defensive guards so each leak and kill transaction applies exactly once (`has_leaked`, `is_dead` flags or equivalent) to prevent double HP/coin mutations. *depends on 6-7*
9. Phase 3 - Building, towers, and upgrades
10. Implement platform-only placement interaction in `obj_tower_base` (mouse click on base), with selected tower type from keyboard cycling in controller, occupied-base checks, and exact 1 HP deduction once on successful placement. *depends on 6*
11. Implement `obj_tower_parent` targeting/cooldown/upgrade scaffolding using nearest-progress target priority (`path_position` style), then add `obj_tower_arrow`, `obj_tower_slow`, `obj_tower_cannon` stat overrides for L1-L3. *depends on 7 and 10*
12. Implement mixed attack model: instant-hit for arrow/slow (slow applies timed debuff on enemy), projectile splash object for cannon AoE. *depends on 11*
13. Implement coin-only upgrades (L1->L2->L3) through simple selected-tower interaction (no sell/refund in MVP) with per-tower upgrade costs from constants. *depends on 11-12*
14. Phase 4 - HUD, feedback, and end states
15. Implement `obj_gui` Draw GUI for always-visible: life, coins, current wave/48, selected tower type, placement cost (1 HP), selected tower upgrade cost, and temporary `BOSS WAVE` banner. *depends on 6 and 13*
16. Add placement validity color feedback (green/red) and selected tower highlight; keep visuals primitive-safe (no art dependency). *depends on 10 and 15*
17. Implement final victory flow on Wave 48 clear and defeat flow at `player_hp <= 0` with gameplay freeze and clear message overlay. *depends on 6 and 15*
18. Phase 5 - Balancing and validation
19. Run a short scripted balance pass using your locked formulas/values: enemy HP/speed scaling, spawn interval taper (0.65 to 0.35), boss multipliers, and coin economy so upgrades are reachable but tight. *depends on 6-17*
20. Execute acceptance checklist verification in one full playthrough and one accelerated debug run (with temporary `show_debug_message`) to validate 48-wave progression and no economy desync. *depends on 19*

**Relevant files**
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/gm48-48-equivalent-exchange.yyp` - Register all new objects/scripts/path assets alphabetically in `resources`.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/rooms/rm_game/rm_game.yy` - Add startup instances and platform layout; keep single-map MVP composition.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_game_controller/obj_game_controller.yy` - Register Create/Step/Alarm events for state/wave control.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_game_controller/Create_0.gml` - Initialize global run state, selection state, wave timers.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_game_controller/Step_0.gml` - Wave state machine and game-over/win transitions.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_game_controller/Alarm_0.gml` - Spawn cadence and boss insertion timing.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_enemy_parent/obj_enemy_parent.yy` - Register Create/Step/Destroy (and optional Draw) events.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_enemy_parent/Create_0.gml` - Base HP/speed/reward/leak setup and path start.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_enemy_parent/Step_0.gml` - Path progress, leak check, slow-effect update.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_tower_parent/obj_tower_parent.yy` - Register Create/Step/User events for generic tower behavior.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_tower_parent/Create_0.gml` - Common level/range/cooldown fields.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_tower_parent/Step_0.gml` - Target acquisition and firing/attack dispatch.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_tower_parent/Other_10.gml` - Upgrade hook (level stat application).
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_tower_base/obj_tower_base.yy` - Register click/step events for placement checks.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_tower_base/Mouse_0.gml` - Placement confirm and affordability/occupancy validation.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_gui/obj_gui.yy` - Register Draw GUI event.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_gui/Draw_64.gml` - HUD and boss banner draw.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/scripts/scr_game_constants/scr_game_constants.gml` - Locked design macros and upgrade costs.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/scripts/scr_wave_utils/scr_wave_utils.gml` - Enemy count/scaling formulas and boss-wave helpers.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/scripts/scr_game_state/scr_game_state.gml` - Getter/setter transaction helpers for HP/coins.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_enemy_basic/obj_enemy_basic.yy` - Basic enemy child.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_enemy_boss/obj_enemy_boss.yy` - Boss enemy child.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_tower_arrow/obj_tower_arrow.yy` - Arrow tower child.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_tower_slow/obj_tower_slow.yy` - Slow tower child.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_tower_cannon/obj_tower_cannon.yy` - Cannon tower child.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/objects/obj_projectile_cannon/obj_projectile_cannon.yy` - Cannon splash projectile object.
- `c:/Users/tehwa/gamedev/gm48-48-equivalent-exchange/paths/path_main/path_main.yy` - Main enemy lane path.

**Verification**
1. Asset integrity check: project opens cleanly in GameMaker after all new `.yy`/event files are registered (no missing assets or parser errors).
2. Economy transaction test: place 5 towers and verify HP decreases by exactly 5; attempt placement at 0 HP and verify rejection with no side effects.
3. Leak transaction test: spawn one basic and one boss directly near path end; confirm leak damage is exactly 1 and 5 once each.
4. Wave progression test: run to Wave 13 and confirm boss appears only on Wave 12, with post-wave transition still functioning.
5. Upgrade test: for each tower type, buy L2 and L3 with coins and verify stat changes + no HP cost during upgrades.
6. Combat behavior test: slow debuff visibly alters enemy movement temporarily; cannon projectile applies AoE to clustered enemies.
7. Full-run smoke test: simulate/fast-run all 48 waves and verify win only after Wave 48 clear and no enemies remaining.
8. HUD readability check at all states: in-wave, between waves, boss wave, game over, and win overlay.

**Decisions**
- Confirmed pathing approach: use a GMS2 path asset and `path_start`-driven movement.
- Confirmed placement UX: keyboard tower-type cycling + click on `obj_tower_base` for fastest MVP.
- Confirmed combat model: instant-hit for Arrow/Slow and projectile AoE for Cannon.
- Included scope: all checklist-critical MVP features from your GDD through Wave 48 win/lose states.
- Excluded scope: sell/refunds, wave skip, elite enemies, meta systems, advanced VFX/UI polish.

**Further Considerations**
1. Optional debug macro toggle (`DEBUG_FAST_WAVES`) can safely accelerate late-wave testing without changing release balance values.
2. If path readability becomes an issue without art, add simple draw primitives for lane and platform outlines before adding any sprite polish.
