## One-Hour Theme Plan: Equivalent Exchange

Goal: Maximize theme score with minimal risk. Keep the current 48-wave loop and add only three quick, visible upgrades.

### What We Ship In 60 Minutes

1. End-screen restart prompt and key.
2. End-screen run stats: wave reached or cleared, HP left, coins left, run time.
3. Theme language pass in UI text so every screen says life is the currency.

No new systems, no new rooms, no wave-logic rewrite.

### Why This Works

1. Judges immediately see the theme in wording and outcomes.
2. Players understand the exchange loop from intro to death or victory.
3. Scope stays tiny and safe for final hour.

### Exact File Touches

1. [objects/obj_game_controller/Create_0.gml](objects/obj_game_controller/Create_0.gml)
2. [objects/obj_game_controller/Step_0.gml](objects/obj_game_controller/Step_0.gml)
3. [objects/obj_gui/Draw_64.gml](objects/obj_gui/Draw_64.gml)

### Implementation Checklist

1. Add run timer start value in controller create event.
2. Add restart input from game over and victory in controller step event.
3. Show run time on both end screens.
4. Change key HUD text from HP wording to life-exchange wording.
5. Add one strong final line per end screen.

Suggested lines:
- Game over: The exchange failed.
- Victory: The balance is settled.

### 60-Minute Timebox

1. 0 to 15 min: restart key and run timer storage.
2. 15 to 35 min: end-screen stats and copy.
3. 35 to 50 min: intro and HUD language pass.
4. 50 to 60 min: three test runs and tiny fixes only.

### Test Pass

1. Lose by placing too many towers. Confirm restart works.
2. Lose by leaks. Confirm same screen and timer display.
3. Clear to victory. Confirm stats and restart prompt.

### Hard Cut Rules

1. Do not add new mechanics now.
2. Do not touch enemy or tower balance unless something is broken.
3. If any change takes longer than 10 minutes, skip it and move on.
