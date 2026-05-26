# Test Plan

Covers all features built to date. Each case lists steps and the expected result.

---

## 1. HUD / Resource Bar

| # | Steps | Expected |
|---|-------|----------|
| 1.1 | Launch fresh game (no save file) | Top bar shows Coins: 200, Food: 50/200, Power: 0/120, Workers: 0/0, Soldiers: 0/0 |
| 1.2 | Spend coins on a building | Coins label decrements immediately |
| 1.3 | Wait 5 seconds with workers hired | Food label decrements by worker count |
| 1.4 | Place a Solar Farm with a worker assigned, wait | Power label increments up to cap |
| 1.5 | Buy workers until at cap | Workers label shows correct X/Y |
| 1.6 | Place Housing | Worker cap in label increases by 5 |
| 1.7 | Buy soldiers via Barracks UI | Soldiers label updates |
| 1.8 | Day counter increments after one full cycle | Day label reads "Day 2" |
| 1.9 | Time label cycles from 6:00 AM through PM and back | Time updates every frame, no freeze |

---

## 2. Save & Load

| # | Steps | Expected |
|---|-------|----------|
| 2.1 | Play for 2 minutes, press Z | "Game Saved" toast appears top-right |
| 2.2 | Close and reopen the game | All resources, buildings, workers, walls, soldiers, and day restored exactly |
| 2.3 | Load a save made before the power cap change (power_cap = 50) | power_cap loads as 120 (migrated up to base) |
| 2.4 | Load a save made before the food cap change | food_cap loads as at least 200 |
| 2.5 | Load game — verify map tiles match saved layout, no extra random mines | Tile layout identical to save; gold mines only where they were |
| 2.6 | Load game with workers assigned to mine/farm/tower | Workers re-assigned correctly; worker count and label correct |
| 2.7 | Game over → Restart → verify fresh state | Coins 200, Day 1, no buildings, tutorial at step 0 |
| 2.8 | Autosave fires every 5 minutes | Toast appears; no manual input needed |

---

## 3. Tutorial

| # | Steps | Expected |
|---|-------|----------|
| 3.1 | Fresh game — tutorial prompt visible | "Build a Core to start expanding" |
| 3.2 | Place Core | Prompt advances to "Build a Solar Farm for power" |
| 3.3 | Place Solar Farm | → "Build Housing to expand worker cap" |
| 3.4 | Place Housing | → "Buy workers and assign them to Gold" |
| 3.5 | Assign first worker to a Gold Mine | → "Buy a Farm" |
| 3.6 | Place Farm | → "Assign workers to the farm" |
| 3.7 | Assign worker to Farm | → "Build a Turret" |
| 3.8 | Place Turret | → "Assign a worker to the Turret" |
| 3.9 | Assign worker to Turret | → "Build a Barracks" |
| 3.10 | Place Barracks | → "Buy a Soldier" |
| 3.11 | Buy a Soldier | → "Build Walls to protect your base" |
| 3.12 | Place a Wall segment | → "Build a Arcanum" |
| 3.13 | Place Arcanum | → "Build 2 more Turrets" |
| 3.14 | Place 2 more Turrets (3 total) | Tutorial prompt disappears |
| 3.15 | Load a save with tutorial_step = 13 | No tutorial prompt shown |

---

## 4. Economy

| # | Steps | Expected |
|---|-------|----------|
| 4.1 | Assign workers to Gold Mine | Coins increase by workers × 5 every 5 seconds |
| 4.2 | Gold Mine reserves reach 0 | Mine disappears; workers unassigned; worker count unchanged |
| 4.3 | Assign workers to Farm | Food increases by workers × 3 every 5 seconds |
| 4.4 | Food at cap (200) with Farm producing | Food stays at cap; no overflow |
| 4.5 | Upgrade food cap | Food cap increases by 100; label updates |
| 4.6 | Solar Farm with worker assigned | Power increases by 6 every 4 seconds |
| 4.7 | Power at cap | Power stays at cap |
| 4.8 | Upgrade power cap | Power cap increases by 60 |
| 4.9 | 3 Turrets active, Solar Farm producing | Power does not drain to zero during daytime |
| 4.10 | Kill an enemy | Coins increase by 10 (30 for Big Enemy) |

---

## 5. Buildings

| # | Steps | Expected |
|---|-------|----------|
| 5.1 | Place each building type | Costs correct coins; placed on tile; HUD building count updates |
| 5.2 | Try placing a second Core or Arcanum | Blocked; error message shown |
| 5.3 | Try placing building without Core first | Blocked |
| 5.4 | Fortify a building (75 coins) | Shield bar appears; first damage hits shield |
| 5.5 | Shield depleted | Shield bar gone; subsequent damage hits HP |
| 5.6 | Building HP regenerates after 30s of no damage | HP slowly climbs back at 2%/tick |
| 5.7 | Core destroyed | Game over screen appears; game paused |
| 5.8 | Non-Core building destroyed | Building removed; tile cleared; building count decrements |
| 5.9 | Building destroyed with workers assigned | Workers freed; assigned_workers decremented |
| 5.10 | Buy tile (unlock adjacent tile) | Tile border highlights; cost increases with distance |

---

## 6. Walls

| # | Steps | Expected |
|---|-------|----------|
| 6.1 | Right-click tile edge near player | Wall appears; 25 coins deducted |
| 6.2 | Wall placed far from player (> WALL_PLAYER_RANGE) | Placement blocked; error shown |
| 6.3 | Right-click existing undamaged wall | Wall removed; 25 coins refunded |
| 6.4 | Damage a wall, then right-click it | Repair starts (costs 15 coins); HP slowly rises |
| 6.5 | Wall HP reaches max after repair | Repair stops; subsequent right-click removes wall |
| 6.6 | Right-click damaged wall with insufficient coins | "Not enough coins!" shown; no repair starts |
| 6.7 | Wall destroyed by enemies | Wall removed from grid; enemies can pass |
| 6.8 | Wall attacked by enemy | Red vignette flashes; directional arrow if off-screen |

---

## 7. Enemy Waves

| # | Steps | Expected |
|---|-------|----------|
| 7.1 | Start fresh game; wait 20 seconds | First wave spawns (3 enemies in a burst) |
| 7.2 | Wave clears; wait 30 seconds | Second wave spawns (5 enemies — base 3 + 2 per wave) |
| 7.3 | Enemies in a wave arrive from the same direction | All burst enemies spawn from a shared angle |
| 7.4 | Night begins | Next wave spawns sooner (night spawn trigger) |
| 7.5 | Day 2 starts | Wave enemy count higher than Day 1 |
| 7.6 | Big Enemy appears after ~35 seconds (first spawn) | Larger sprite, higher HP, slower, 30-coin reward |
| 7.7 | Building attacked off-screen | Directional arrow indicator appears at screen edge |
| 7.8 | Building attacked | Red vignette flashes; fades after 0.5 seconds |

---

## 8. Soldiers

| # | Steps | Expected |
|---|-------|----------|
| 8.1 | Buy soldier with no Barracks | Blocked |
| 8.2 | Buy soldier at soldier cap | Blocked; "Soldier cap reached!" shown |
| 8.3 | Buy soldier successfully | Soldier spawns at a wall exterior point, not inside walls |
| 8.4 | No walls placed — soldier spawns | Spawns outside the tile perimeter |
| 8.5 | Walls placed in a ring — soldier spawns | Spawns outside the wall ring |
| 8.6 | No enemies — soldier patrol | Soldier walks the wall perimeter in angular order (clockwise or counterclockwise) |
| 8.7 | Enemy enters threat range of a building | Soldier switches to CHASE; moves toward enemy |
| 8.8 | Soldier reaches attack range | Stops moving; deals 20 damage per second |
| 8.9 | Enemy killed | Soldier returns to patrol; re-anchors to nearest patrol point |
| 8.10 | Enemy more than 900px from base center | Soldier stops chasing; returns to patrol |
| 8.11 | Walls added/removed | Patrol points update within 8 seconds |
| 8.12 | Soldier takes damage | HP bar shows; death removes from group and count |
| 8.13 | Barracks destroyed | Soldier cap drops; excess soldiers count still live (no insta-kill) |
| 8.14 | Load save with soldiers | Soldiers spawn at exterior positions, begin patrol |

---

## 9. Minimap

| # | Steps | Expected |
|---|-------|----------|
| 9.1 | Game loads | Minimap visible bottom-left; correct tile grid shown |
| 9.2 | Unlock a tile | New tile appears on minimap immediately |
| 9.3 | Place a building | Colored dot appears on minimap in correct position |
| 9.4 | Enemy spawns | Red dot appears on minimap |
| 9.5 | Player moves | Yellow dot moves on minimap |
| 9.6 | Soldier patrols | Blue dot moves along perimeter on minimap |
| 9.7 | Night overlay darkens screen | Minimap continues to update and remains readable |

---

## 10. Day/Night Cycle

| # | Steps | Expected |
|---|-------|----------|
| 10.1 | Game starts | 6:00 AM shown; no overlay |
| 10.2 | After 135 seconds (DAY_DURATION − transition) | Screen begins darkening |
| 10.3 | Full night (150s mark) | Overlay at max alpha (≈0.5) |
| 10.4 | After 285 seconds | Screen begins lightening; Day 2 declared |
| 10.5 | Towers with workers | Active during night; power drains correctly |

---

## 11. Arcanum / Research

| # | Steps | Expected |
|---|-------|----------|
| 11.1 | Open Arcanum UI | Research option shown; progress bar at 0 |
| 11.2 | Start Turret Damage research (100 coins) | Progress bar fills over 45 seconds |
| 11.3 | Research completes | Turret damage increases by 5; toast/signal fires |
| 11.4 | Research again | Level increments; damage increases by another 5 |
| 11.5 | Save mid-research; reload | Research progress and level restored |

---

## 12. Regression / Edge Cases

| # | Steps | Expected |
|---|-------|----------|
| 12.1 | Hire more workers than cap allows | Blocked; error shown |
| 12.2 | Spend all coins; try to place building | Blocked; insufficient coins message |
| 12.3 | Pause (game over screen) then Restart | Game unpauses; fresh state; no leftover enemies or soldiers |
| 12.4 | Many walls placed then all removed | Soldier patrol falls back to tile perimeter cleanly |
| 12.5 | All Gold Mines depleted | No coin income from mines; game continues |
| 12.6 | Food at 0 for extended period | Workers remain; game does not crash; food label shows 0/200 |
| 12.7 | Power at 0 with active turrets | Turrets stop firing until power restored |
| 12.8 | Press Z immediately on load | Save overwrites cleanly; no data corruption |
