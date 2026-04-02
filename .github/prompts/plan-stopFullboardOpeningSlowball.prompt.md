## Plan: Stop Full-Board Opening Snowball

Address the reported exploit directly: players can currently fill all 12 tower bases immediately because STARTING_HP is 48 and full-board placement costs only about 36 HP, then coast on upgrades. Keep core economy identity unchanged (HP buys towers, coins buy upgrades, sell returns HP only), but retune early liquidity and upgrade pacing so full-board openings are strategically risky, not dominant.

**Steps**
1. Phase 1 - Lock exploit-focused acceptance criteria
2. Define anti-exploit targets from the observed baseline: opening full-board should leave dangerously low survivability before stable coin income; early all-in builds should fail more often than mixed pacing builds by wave 12.
3. Add explicit acceptance thresholds: at wave 6 and wave 12, expected HP and coin bands for three openers (greedy full-board, balanced, conservative). Depends on step 2.
4. Phase 2 - Primary anti-fill levers (your selected direction)
5. Reduce immediate placement budget pressure by lowering starting HP from current 48 to a target test band and evaluate resulting opening board size ceilings. Depends on step 3.
6. Add escalating HP placement cost by active tower count so each additional tower has higher life commitment, while preserving HP-only purchase semantics and full HP sell refund semantics. Depends on step 3.
7. Slow post-fill snowball by lowering early coin inflow and or raising early upgrade costs, especially level-2 breakpoints that currently enable safe stabilization after board fill. Parallel with steps 5 and 6.
8. Phase 3 - Economy integrity and fairness checks
9. Preserve hard economy invariants while implementing anti-exploit pressure: no coin use for placement, no HP use for upgrades, no coin refund on sell.
10. Ensure sell-refund behavior remains readable and fair under escalating costs: define whether refund is based on original paid placement HP per tower instance and verify consistency in UI messaging.
11. Review boss HP reward and early Arrow placement discount as secondary liquidity amplifiers; tune only if exploit still survives after primary levers. Depends on steps 5 to 7.
12. Phase 4 - Refit wave pacing around harsher openings
13. Retune waves 1-12 with the new economy pressure so balanced early pressure remains true: leaks matter and overbuilding opportunity cost also matters.
14. Recheck waves 13-24 transition pressure so players cannot recover from reckless full-board starts through passive coin drift alone.
15. Revalidate boss checkpoints at 12, 24, 36, and 48 to ensure the full 48-wave arc remains very punishing but beatable.
16. Phase 5 - Verify exploit is neutralized
17. Run targeted scenario matrix: full-board rush, full-board rush plus slow upgrades, mixed placement timing, upgrade-first economy, and frequent sell-churn.
18. Confirm desired outcome: full-board rush is no longer the dominant strategy and usually underperforms balanced play by wave 12 to 24.
19. Finalize tuned constants and economy formulas with a short rationale map tying each change to exploit suppression.

**Relevant files**
- c:\Users\tehwa\webdev\gm48-48-equivalent-exchange\scripts\scr_game_constants\scr_game_constants.gml - Starting HP, base placement cost, enemy rewards, upgrade costs, and wave constants.
- c:\Users\tehwa\webdev\gm48-48-equivalent-exchange\scripts\scr_game_state\scr_game_state.gml - HP spend/add, coin spend/add, tower delete refund life path, and tower-description placement cost values.
- c:\Users\tehwa\webdev\gm48-48-equivalent-exchange\scripts\scr_wave_utils\scr_wave_utils.gml - Enemy count and spawn interval scaling functions used to reinforce early pressure.
- c:\Users\tehwa\webdev\gm48-48-equivalent-exchange\objects\obj_game_controller\Step_0.gml - Tower placement confirmation flow and upgrade trigger logic where cost hooks may be applied.
- c:\Users\tehwa\webdev\gm48-48-equivalent-exchange\objects\obj_tower_parent\Create_0.gml - Tower instance fields to persist actual paid placement HP if escalating cost is introduced.
- c:\Users\tehwa\webdev\gm48-48-equivalent-exchange\objects\obj_tower_parent\Other_10.gml - Upgrade purchase execution.
- c:\Users\tehwa\webdev\gm48-48-equivalent-exchange\objects\obj_enemy_parent\Create_0.gml - Per-wave enemy reward and stat setup affecting early coin tempo.
- c:\Users\tehwa\webdev\gm48-48-equivalent-exchange\objects\obj_enemy_parent\Step_0.gml - Coin drops, leaks, and boss HP reward on death.
- c:\Users\tehwa\webdev\gm48-48-equivalent-exchange\objects\obj_gui\Draw_64.gml - Cost and refund communication in HUD.
- c:\Users\tehwa\webdev\gm48-48-equivalent-exchange\rooms\rm_game\rm_game.yy - Fixed tower-base capacity context (12 base instances).

**Verification**
1. Rule invariants still pass: placement HP only, upgrade coins only, sell HP only, 48 total waves, boss every 12.
2. Early exploit test: from fresh start, attempt immediate all-base placement and track HP risk and wave-12 survival rate against target bands.
3. Compare opening archetypes over repeated runs and confirm full-board opening is no longer highest-consistency path.
4. Validate refund correctness for towers bought at different effective HP costs if escalating pricing is active.
5. Confirm wave-48 victory remains possible but rare with strong decision quality.

**Decisions**
- Keep full HP sell refunds.
- Keep very punishing target difficulty.
- Keep early pressure balanced between leaks and opportunity cost.
- Prioritize these anti-exploit levers: lower early coin tempo or higher early upgrade cost, reduce starting HP, add escalating HP placement cost by active tower count.
- Included scope: balance and economy formula tuning within current game pillars only.
- Excluded scope: new maps, new meta systems, new currencies, and any change to the 48-wave structure.

**Further Considerations**
1. Escalating placement cost is the strongest anti-fill control, but requires careful refund bookkeeping per tower instance to avoid perceived unfairness.
2. If reducing starting HP alone causes brittle early losses, keep HP higher and shift pressure into escalating placement costs plus tighter early coin tempo.
3. If exploit persists after economy changes, tune wave-1 to wave-12 spawn pressure as a secondary counter, not as the primary fix.
