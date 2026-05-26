# Base Defense Game

A top-down base building and defense game built with Godot 4.6 and GDScript. Expand your territory, build structures, assign workers, recruit soldiers, and defend your Core against waves of enemies.

## Gameplay

Place buildings on a purchasable 15×15 tile grid. Tile costs increase exponentially the further they are from your starting position. Earn coins from Gold Mines staffed by workers and from killing enemies. Use coins to unlock tiles, construct buildings, hire workers, buy soldiers, and build towers before the enemy waves overwhelm you.

Enemies only spawn during the night, ramping up as darkness deepens and stopping as dawn breaks. When the Core is destroyed, the game ends.

## Buildings

| Building | Cost | HP | Description |
|----------|------|----|-------------|
| Core | 100 | 500 | Required first. Opens management menu for workers, fortification, and resource upgrades. |
| Housing | 50 | 150 | Increases worker cap by 5 per building. |
| Farm | 75 | 100 | Produces food with assigned workers (3 food per worker every 5s). |
| Tower | 60 | 200 | Attacks enemies within 600px. Requires 1 assigned worker and available power. |
| Barracks | 75 | 150 | Increases soldier cap by 5 per building. Allows purchasing soldiers. |
| Lab | 150 | 200 | Research upgrades using coins. Currently: Turret Damage. |
| Solar Farm | 80 | 100 | Generates 1 power every 4 seconds during daytime only. |
| Gold Mine | — | — | Spawns automatically on map generation. Staff with workers to earn coins (5 per worker every 5s). Depletes over time. |

All buildings regenerate HP at 2% of max per tick (every 3 seconds) after 30 seconds without taking damage. Health bars appear automatically when a building takes damage and hide at full HP.

## Towers

Towers require exactly 1 assigned worker and available power to fire. Each shot deals 25 base damage (upgradable via the Lab) to the nearest enemy within 600px range every 1 second. Towers drain 1 power every 4 seconds while staffed.

If power reaches 0, towers stop firing even if staffed.

## Workers

Workers cost 20 coins and are hired from the Core menu (press E on the Core). Each Housing building adds 5 to the worker cap. Workers roam near the Core when idle.

Assign workers to **Farms** to produce food, **Towers** to enable firing, or **Gold Mines** to generate coins. All workers consume food at a rate of 1 food per worker every 5 seconds.

## Soldiers

Soldiers are combat units purchased from the Barracks menu (press E on a Barracks) for 30 coins each. Each Barracks adds 5 to the soldier cap.

Soldiers automatically hunt enemies that come within range of any player building. When no threats are nearby they patrol the perimeter of your unlocked territory. Each soldier has 80 HP and deals 20 damage per second in melee range.

## Enemies

Enemies spawn from outside the map during nighttime only. Spawn rate ramps up as the night deepens and accelerates further over time. At night, enemies arrive in clumps of up to 10.

| Enemy | HP | Speed | Damage | Reward | Notes |
|-------|----|-------|--------|--------|-------|
| Standard | 100 | Normal | 10 / 1.2s | 10 coins | Basic attacker |
| Big | 350 | Slow | 35 / 2.5s | 30 coins | Spawns after the first full day |

Enemies attack any building they can reach, prioritising structures over the Core. When the Core falls the game ends.

## Power

Power is produced by Solar Farms (daytime only) and consumed by staffed Towers. The power cap starts at 50 and can be upgraded from the Core menu for 150 coins (+50 per upgrade). Surplus power is capped — build more Solar Farms and upgrade the cap before expanding your tower network.

## Food

Food is produced by Farms with assigned workers. All workers consume food over time. The food cap starts at 200 and can be upgraded from the Core menu for 100 coins (+100 per upgrade). If food runs out workers continue functioning but new food won't accumulate beyond zero.

## Day / Night Cycle

Each day and night lasts 150 seconds with a 15-second dusk/dawn transition. The current in-game time is displayed under the day counter (6:00 AM → 6:00 PM during the day, 6:00 PM → 6:00 AM during the night). Enemies only spawn at night, with spawn rate and clump size scaling with darkness intensity. Solar Farms produce no power at night.

## Lab Research

Open the Lab menu (press E on the Lab) to start research. Research costs coins and takes real time to complete.

| Upgrade | Cost | Time | Effect |
|---------|------|------|--------|
| Turret Damage | 100 | 45s | +5 damage per Tower shot per level |

## Fortification

Fortify the Core from the Core menu for 75 coins. This adds a 200 HP shield layer that absorbs damage before the Core's own HP. The shield does not regenerate.

## Walls

Right-click near a tile edge to place a wall (25 coins, 200 HP). You must be within 200px of the target edge and at least one adjacent tile must be owned. Walls block enemies and can be destroyed by taking damage. Right-click an existing wall to demolish it and receive a full refund. Walls are saved and restored with the game.

## Economy

- **Coins** — earned from staffed Gold Mines and by killing enemies (+10 standard, +30 big). Spent on tiles, buildings, workers, soldiers, research, and upgrades.
- **Food** — produced by Farms. Consumed by all workers (1 per worker every 5s). Starting supply: 50. Cap upgradable from Core.
- **Power** — generated by Solar Farms during daytime. Consumed by staffed Towers. Starting cap: 50. Cap upgradable from Core.

## Controls

| Input | Action |
|-------|--------|
| WASD | Move player |
| Left click | Shoot toward cursor |
| Right click | Place wall on nearest tile edge (25 coins); right-click an existing wall to demolish |
| E | Interact — purchase tile / open build menu / manage building |
| Z | Manual save |
| U | Toggle developer menu |
| Escape | Close open menu |

### Player Shooting

Left-click fires a bullet toward the mouse cursor with a 0.3-second cooldown. Bullets deal 15 damage, travel at 400 px/s (plus inherited player velocity), and expire after 2 seconds.

### Developer Menu (U)

- **Add 100 / 1000 Coins** — instant coin injection for testing
- **Skip to Dusk** — jumps the day/night cycle to the start of the dusk transition, triggering nighttime and enemy spawns immediately
- **Reset Game** — wipes the save and restarts from scratch

## Saving

The game auto-saves every 5 minutes and on manual save (Z). Save data is written to `user://save.json` and restored automatically on next launch. The save includes tile ownership, buildings (with shield HP), workers, farm/tower assignments, gold mine reserves, walls, soldiers, lab progress, and resource caps.

## Development

**Engine:** Godot 4.6  
**Language:** GDScript (strict typing throughout)  
**Art:** Aseprite sprites imported via the AsepriteWizard plugin

### Project Structure

```
scenes/      — Main scene
scripts/     — All GDScript source files
prefabs/     — Reusable node scenes (buildings, units, bullets, UI)
assets/      — Sprites and other assets
addons/      — Godot plugins (AsepriteWizard)
```

### Key Scripts

| Script | Role |
|--------|------|
| `game_state.gd` | Autoload singleton — economy, workers, soldiers, buildings, research, signals |
| `constants.gd` | Autoload — all game constants and tuning values |
| `tile_grid.gd` | Grid generation, tile purchasing, building placement, unit spawning, wall management |
| `building_base.gd` | Shared HP, health bar, regen, fortification, depth sorting, and destruction logic |
| `player.gd` | Movement, shooting, wall placement, and E-key interaction routing |
| `soldier.gd` | Soldier AI — patrol, chase, and attack states |
| `enemy.gd` | Enemy AI — building priority targeting, movement, melee attack |
| `big_enemy.gd` | Slow heavy enemy with high HP and damage |
| `tower.gd` | Tower attack loop, power drain, bullet spawning |
| `solar_farm.gd` | Power generation during daytime |
| `wall.gd` | Placeable wall segment with HP, depth sorting, and save/load support |
| `day_night_cycle.gd` | Cycle timer, overlay alpha, time-of-day string, night intensity for spawning |
| `save_manager.gd` | JSON save/load and game reset |
