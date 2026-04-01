# Tower Tax

Tower Tax is a slow, low-pressure tower defense game submitted to the (48th gm(48) GameMaker game jam)[https://gm48.net/game-jams/equivalent-exchange/games/tower-tax].

The twist is simple: your Life is both your health bar and your build currency.

Every tower placement costs Life. If you overbuild, you die. If you underbuild, leaks kill you.

## Core Idea

- Place towers by spending Life.
- Kill enemies to earn Coins.
- Spend Coins to upgrade towers.
- Survive all 48 waves.

## How to Play

### Objective

- Survive through Wave 48.
- Do not let your Life reach 0.

### Controls

- Space: Start the run from the intro screen.
- Q / E: Cycle selected tower type.
- 1-5: Directly select a tower type slot.
- Left Click on an empty build platform: Place selected tower (costs 1 Life).
- Left Click on an existing tower: Select that tower.
- Right Click: Clear selected tower.
- U: Upgrade selected tower (costs Coins).
- X: Delete selected tower (returns Life only, no Coin refund).
- R: Restart after Game Over or Victory.

### HUD Guide

The HUD shows:

- Life
- Coins
- Current wave out of 48
- Current build selection
- Exchange Cost (placement Life cost)
- Upgrade cost for selected tower

### Rules That Matter

- You can only build on tower base platforms.
- Each placement costs exactly 1 Life.
- Leaked enemies also remove Life.
- Boss waves happen every 12 waves.

## How It Was Made

Tower Tax was made in 5 hours and was submitted a few minutes before the deadline.

This project was intentionally scoped as a small experiment: can a complete, playable tower defense game be built in 5 hours using AI-assisted coding and pre-made asset bundles? 

Because of that constraint, this is a lean MVP with limited balancing and minimal extra mechanics.

- Engine: GameMaker Studio 2
- Graphics and SFX: Official GameMaker asset bundles
- Bundle source: https://gamemaker.io/en/bundles
- Background art: Generated using Google Gemini
- Code: Every line of gameplay code was written using GPT-5.3-Codex
