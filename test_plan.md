# Test Plan

Covers all features built to date. Each case lists steps and the expected result.

---

## 1. HUD / Resource Bar

| # | Steps | Expected |
|---|-------|----------|
| 1.1 | Launch fresh game (no save file) | Top bar shows Coins: 200, Food: 50/200, Power: 0/120, Workers: 0/0, Soldiers: 0/0 |
| 1.2 | Spend coins on a building | Coins label decrements immediately |
| 1.3 | Wait 5 seconds with workers hired | Food label decrements by worker count |
| 1.4 | Place a Solar Farm, wait during daytime | Power label increments up to cap |
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
| 2.6 | Load game with workers assigned to mine/farm/tower/storehouse | Workers re-assigned correctly; worker count and label correct |
| 2.7 | Game over → Restart → verify fresh state | Coins 200, Day 1, no buildings, tutorial at step 0 |
| 2.8 | Autosave fires every 5 minutes | Toast appears; no manual input needed |
| 2.9 | Set a rally point, save (Z), reload | Cyan crosshair marker visible at the same position after reload |
| 2.10 | Set rally point, game over → Restart | Rally marker gone; soldiers revert to perimeter patrol |

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
| 3.12 | Place a Wall segment | → "Build a Library" |
| 3.13 | Place Library | → "Build 2 more Turrets" |
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
| 4.5 | Upgrade food cap from Core menu | Food cap increases by 100; label updates |
| 4.6 | Solar Farm present during daytime | Power increases by 6 every 4 seconds |
| 4.7 | Power at cap | Power stays at cap |
| 4.8 | Upgrade power cap from Core menu | Power cap increases by 60 |
| 4.9 | 3 Turrets active, Solar Farm producing | Power does not drain to zero during daytime |
| 4.10 | Kill an enemy | Coins increase by 10 (30 for Big, 20 for Flying, 25 for Burrower) |

---

## 5. Buildings

| # | Steps | Expected |
|---|-------|----------|
| 5.1 | Place each building type | Costs correct coins; placed on tile; HUD building count updates |
| 5.2 | Try placing a second Core or Library | Blocked; error message shown |
| 5.3 | Try placing building without Core first | Blocked |
| 5.4 | Fortify a building (any managed building — 75 coins) | Shield bar appears; first damage hits shield |
| 5.5 | Shield depleted | Shield bar gone; subsequent damage hits HP |
| 5.6 | Try to fortify an already-fortified building | Button disabled; no coins spent |
| 5.7 | Building HP regenerates after 30s of no damage | HP slowly climbs back at 2%/tick |
| 5.8 | Core destroyed | Game over screen appears; game paused |
| 5.9 | Non-Core building destroyed | Building removed; tile cleared; building count decrements |
| 5.10 | Building destroyed with workers assigned | Workers freed; assigned_workers decremented |
| 5.11 | Buy tile (unlock adjacent tile) | Tile border highlights; cost increases with distance |
| 5.12 | Try to unlock a tile not adjacent to any owned tile | "Need an adjacent tile!" error shown |
| 5.13 | Stand near a damaged building, hold R | Prompt shows repair cost (1 coin per 5 HP) |
| 5.14 | Hold R + left-click a damaged building with enough coins | Building restored to full HP; coins deducted |
| 5.15 | Hold R + left-click with insufficient coins | "Not enough coins!" error; no HP change |
| 5.16 | Hold R + left-click a full-HP building | "Already at full HP." message; no coins spent |

---

## 6. Walls

| # | Steps | Expected |
|---|-------|----------|
| 6.1 | Right-click tile edge near player | Wall appears; 25 coins deducted |
| 6.2 | Wall placed far from player (> 400px) | Placement blocked; error shown |
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
| 7.1 | Start fresh game; wait for first night | First wave spawns as a clumped burst |
| 7.2 | Wave clears; wait for next burst | Enemy count increases each burst |
| 7.3 | Enemies in a burst arrive from the same direction | All burst enemies spawn from a shared angle |
| 7.4 | Skip to dusk (U menu) | Night starts; enemies spawn sooner |
| 7.5 | Day 2 starts | Enemy HP and damage visibly higher than Day 1 |
| 7.6 | Building attacked off-screen | Directional arrow indicator appears at screen edge |
| 7.7 | Building attacked | Red vignette flashes; fades after 0.5 seconds |

---

## 8. Enemy Types

| # | Steps | Expected |
|---|-------|----------|
| 8.1 | First night — standard enemies | 100 HP, normal speed, target nearest building |
| 8.2 | After first full day/night cycle | Big Enemy spawns: larger sprite, 350 HP, slow, deals 35 damage, +30 coins on kill |
| 8.3 | Night 3 begins | Flying enemy spawns: orbits at range 280px, fires projectiles, ignores walls |
| 8.4 | Flying enemy killed | +20 coins awarded |
| 8.5 | Night 4 begins | Burrower spawns: tunnels underground, immune to damage while burrowing |
| 8.6 | Burrower reaches inside base | Warning flicker before surfacing; then attacks normally |
| 8.7 | Burrower surfaces inside walls | Can now take damage and be killed; +25 coins |
| 8.8 | Multiple enemy types active simultaneously | All behave independently; no targeting conflicts |

---

## 9. Enemy Camp

| # | Steps | Expected |
|---|-------|----------|
| 9.1 | Start night 2 | Enemy camp spawns roughly 900px from base |
| 9.2 | Wait 40 seconds near camp | Camp releases a burst of 3 enemies |
| 9.3 | No regular enemies threatening buildings | Soldiers march toward and attack the camp |
| 9.4 | Player shoots camp | Camp HP decreases |
| 9.5 | Camp HP reaches 0 | Camp removed; +150 coins awarded |
| 9.6 | Camp destroyed | Only one camp at a time; new camp may spawn on a later night |

---

## 10. Soldiers

| # | Steps | Expected |
|---|-------|----------|
| 10.1 | Buy soldier with no Barracks | Blocked |
| 10.2 | Buy soldier at soldier cap | Blocked; "Soldier cap reached!" shown |
| 10.3 | Buy soldier successfully | Soldier spawns at a wall exterior point (or tile perimeter if no walls) |
| 10.4 | No enemies — soldier patrol (no rally point) | Soldier walks the base perimeter in angular order |
| 10.5 | Enemy enters threat range of a building | Soldier switches to CHASE; moves toward enemy |
| 10.6 | Soldier reaches attack range | Stops moving; deals 20 damage per second |
| 10.7 | Enemy killed | Soldier returns to patrol; re-anchors to nearest patrol point |
| 10.8 | Enemy more than 900px from base center (no rally point) | Soldier stops chasing; returns to patrol |
| 10.9 | Walls added or removed | Patrol points update within 8 seconds |
| 10.10 | Soldier takes damage | HP bar shows; death removes from group and soldier count |
| 10.11 | Barracks destroyed | Soldier cap drops; excess soldiers remain alive |
| 10.12 | Load save with soldiers | Soldiers spawn at exterior positions, begin patrol |
| 10.13 | No regular threats — enemy camp on map | Soldiers march to and attack the camp |

---

## 11. Rally Point

| # | Steps | Expected |
|---|-------|----------|
| 11.1 | Middle-click a location on the map | Cyan crosshair marker appears at that position |
| 11.2 | After setting rally point — soldiers on patrol | Soldiers reroute to circle around the marker (80px radius, 8 waypoints) |
| 11.3 | Multiple soldiers active when rally set | All soldiers immediately update to new patrol circuit |
| 11.4 | Enemy appears near rally point | Soldiers chase within SOLDIER_CHASE_RADIUS of rally point, not base center |
| 11.5 | Enemy appears far from rally point (beyond chase radius) | Soldiers do not pursue; return to rally patrol |
| 11.6 | Middle-click a new position | Marker moves; soldiers reroute immediately |
| 11.7 | Save with rally active (Z); reload | Marker visible at same position; soldiers use that circuit |
| 11.8 | Game over → Restart | Marker gone; soldiers revert to perimeter patrol |

---

## 12. Storehouse

| # | Steps | Expected |
|---|-------|----------|
| 12.1 | Build Storehouse (110 coins) | Placed on tile; appears in building count |
| 12.2 | Press E on Storehouse | Storehouse UI opens; shows Workers: 0/5, cap bonuses, free workers, Fortify button |
| 12.3 | Assign first worker | Worker walks to Storehouse; food cap +50, power cap +30; HUD updates |
| 12.4 | Assign 5 workers | Workers: 5/5; food cap +250, power cap +150 total; assign button disabled |
| 12.5 | Try to assign 6th worker | Blocked; assign button disabled |
| 12.6 | Unassign one worker | Worker freed; food cap −50, power cap −30; food/power clamped if above new cap |
| 12.7 | Storehouse destroyed with 3 workers | All 3 workers freed; caps revert by 3× amounts; food/power clamped |
| 12.8 | Save with workers in Storehouse; reload | Correct number of workers re-assigned; caps restored |

---

## 13. Market

| # | Steps | Expected |
|---|-------|----------|
| 13.1 | Build Market (100 coins) | Placed on tile; no menu needed |
| 13.2 | Food above 60% of food cap | Excess food consumed; coins increase at +1 per 8 food; floating +N appears on Market |
| 13.3 | Food below 60% of food cap | No conversion; coins unchanged |
| 13.4 | Power above 60% of power cap | Excess power consumed; coins increase at +1 per 5 power |
| 13.5 | Power below 60% of power cap | No conversion |
| 13.6 | Market destroyed | Passive conversion stops |

---

## 14. Minimap

| # | Steps | Expected |
|---|-------|----------|
| 14.1 | Game loads | Minimap visible bottom-left; correct tile grid shown |
| 14.2 | Unlock a tile | New tile appears on minimap immediately |
| 14.3 | Place a building | Colored dot appears on minimap in correct position |
| 14.4 | Enemy spawns | Red dot appears on minimap |
| 14.5 | Player moves | Yellow dot moves on minimap |
| 14.6 | Soldier patrols | Blue dot moves along perimeter on minimap |
| 14.7 | Night overlay darkens screen | Minimap continues to update and remains readable |

---

## 15. Day/Night Cycle

| # | Steps | Expected |
|---|-------|----------|
| 15.1 | Game starts | 6:00 AM shown; no overlay |
| 15.2 | After 135 seconds (DAY_DURATION − transition) | Screen begins darkening |
| 15.3 | Full night (150s mark) | Overlay at max alpha (≈0.5) |
| 15.4 | After 285 seconds | Screen begins lightening; Day 2 declared |
| 15.5 | Towers staffed and powered | Active during night; power drains correctly |
| 15.6 | Solar Farm during night | No power generated; power only drains |

---

## 16. Library / Research

| # | Steps | Expected |
|---|-------|----------|
| 16.1 | Open Library UI (press E) | Research options listed; progress bar at 0 |
| 16.2 | Start Turret Damage research (100 coins) | Progress bar fills over 45 seconds |
| 16.3 | Research completes | Turret damage increases by 5 |
| 16.4 | Research again | Level increments; damage increases by another 5 |
| 16.5 | Research Armory Blueprint | Armory appears in build menu after completion |
| 16.6 | Save mid-research; reload | Research progress and level restored correctly |
| 16.7 | Research Combat Training | New soldiers deal +5 damage per level |
| 16.8 | Research Soldier Endurance | New soldiers spawn with +20 HP per level |

---

## 17. Siege Tower

| # | Steps | Expected |
|---|-------|----------|
| 17.1 | Build Siege Tower (120 coins) | Placed; press E shows Fortify panel (no workers needed) |
| 17.2 | Power available — Siege Tower fires | Boulder launched every 4.5s at densest enemy cluster within 750px |
| 17.3 | Boulder hits a cluster | AoE explosion; all enemies within 90px take 60 damage; ring effect plays |
| 17.4 | Power at 0 | Siege Tower stops firing |
| 17.5 | Continuous power drain | Power decreases by 2 every 4 seconds even between shots |
| 17.6 | Fortify the Siege Tower | Shield absorbs damage before HP |

---

## 18. Regression / Edge Cases

| # | Steps | Expected |
|---|-------|----------|
| 18.1 | Hire more workers than cap allows | Blocked; error shown |
| 18.2 | Spend all coins; try to place building | Blocked; insufficient coins message |
| 18.3 | Pause (game over screen) then Restart | Game unpauses; fresh state; no leftover enemies or soldiers |
| 18.4 | All walls removed | Soldier patrol falls back to tile perimeter cleanly |
| 18.5 | All Gold Mines depleted | No coin income from mines; game continues |
| 18.6 | Food at 0 for extended period | Workers remain; game does not crash; food label shows 0/cap |
| 18.7 | Power at 0 with active Turrets | Turrets stop firing until power restored |
| 18.8 | Press Z immediately on load | Save overwrites cleanly; no data corruption |
| 18.9 | Storehouse workers freed by destruction; food/power were at new cap | Food and power clamped to lower cap; no crash |
| 18.10 | Set rally point far off-map | Soldiers walk to the circuit; no crash; enemy leash distance uses rally origin |
| 18.11 | Flying enemy attacks while player is inside base | Projectile travels through walls; building takes damage |
| 18.12 | Burrower emerges inside a fortified building's tile | Building shield absorbs damage; Burrower takes return damage normally |
| 18.13 | Repair a building with exactly 1 missing HP | 1 coin spent; building at full HP |
