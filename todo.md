# Todo

| Impact | Item |
|--------|------|
| ★★★★★ | **Tutorial polish** — add visual highlights/arrows pointing at the target building for each step; skip button; cover food drain, fortification, and the rally point in prompts |
| ★★★★★ | **Enemy pathfinding** — replace straight-line movement with NavigationAgent2D so enemies route around walls instead of stopping against them |
| ★★★★★ | **Night modifiers** — each night rolls a random event: "Cursed Night" (enemies +30% speed), "Treasure Night" (2× coin drops), "Siege Night" (massive ground wave), "Peaceful Night" (double resource production) |
| ★★★★☆ | **Main menu + pause** — title screen with Play/Continue/Legacy Shop; in-run pause menu |
| ★★★★☆ | **Player dash** — tap Shift to roll in movement direction with a short invincibility window and cooldown; adds skill expression and a reason to play aggressively |
| ★★★☆☆ | **Deeper legacy shop** — 2–3 more upgrades that change *how you play*, not just starting numbers (e.g. unlock a building type, start with a relic slot) |
| ★★★☆☆ | **Boss announcement** — screen message and visual warning when a boss night begins so it lands as a moment rather than a surprise |

---

## Completed

- [x] Minimap (tile colors + enemy dots overlay)
- [x] Walls (cheap placeable barriers that block/slow enemies, low HP)
- [x] Wall repairing (right-click a damaged wall to repair it for coins, enabling removal again)
- [x] Building attack alerts (screen flash or sound when a building is under attack off-screen)
- [x] Structured waves (discrete enemy waves with cooldown windows instead of a pure spawn ramp)
- [x] Win condition (endless survival — days survived as the core metric)
- [x] Meta progression (Legacy Points earned per run, spent in a between-run shop)
- [x] Enemy variety — Flying ranged enemy (starts night 3), Burrower (tunnels inside walls, starts night 4)
- [x] Threat scaling (enemy HP/damage scales with total coins earned this run)
- [x] Building upgrades (Farm: +food/worker, Tower: faster fire rate — right-click to upgrade)
- [x] Enemy camp (spawns night 2+, periodically releases enemy bursts, soldiers march to destroy it, 150 coin reward)
- [x] Balance the food drain (starting food 50→100, real-time net rate indicator in HUD)
- [x] Tech gates (Armory Blueprint research in Arcanum unlocks Armory building)
- [x] More Arcanum research (Combat Training, Soldier Endurance, Efficient Workers, Agricultural Methods)
- [x] Siege Tower (AoE boulder, cluster targeting, no worker, 2 power/4s drain, 60 dmg / 90px radius / 750px range)
- [x] Repair (hold R + LMB on any damaged building to restore full HP; 1 coin per 5 HP missing)
- [x] Market (passive, no worker — instantly sells food/power when they exceed 60% cap; 8:1 food, 5:1 power; shows floating +N coins)
- [x] Storehouse (worker-staffed; each worker adds +50 food cap and +30 power cap; up to 5 workers; 110 coins)
- [x] Soldier rally point (middle-click to direct soldiers to patrol a location)
- [x] More enemy variety — Runner (fast/fragile, packs of 4, night 5+), Armored (tanky, solo, night 4+)
- [x] Lights that come on at night (firefly GPU particles, additive blend, fade with day/night cycle)
- [x] Boss enemy — unique boss every 5 nights; phase shield that must be broken first, splits into runners on death, large coin reward
