# Base Defense Game

A top-down base building and defense game built with Godot 4.6 and GDScript. Expand your territory, build structures, assign workers, recruit soldiers, and defend your Core against waves of enemies.

## Gameplay

Place buildings on a purchasable 15×15 tile grid. Tile costs increase exponentially the further they are from your starting position. Earn coins from Gold Mines staffed by workers and from killing enemies. Use coins to unlock tiles, construct buildings, hire workers, buy soldiers, and build towers before the enemy waves overwhelm you.

The game is endless survival — enemies only spawn during the night, but they grow stronger the longer you last. Days survived is your score. When the Core is destroyed, the run ends.

## Buildings

| Building | Cost | HP | Description |
|----------|------|----|-------------|
| Core | 100 | 500 | Required first. Opens management menu for workers, fortification, and resource upgrades. |
| Housing | 50 | 150 | Increases worker cap by 5 per building. |
| Farm | 75 | 100 | Produces food with assigned workers (3 food per worker every 5s). Right-click to upgrade. |
| Tower | 60 | 200 | Attacks enemies within 600px. Requires 1 assigned worker and available power. Right-click to upgrade. |
| Barracks | 75 | 150 | Increases soldier cap by 5 per building. Allows purchasing soldiers. |
| Lab | 150 | 200 | Research upgrades using coins. Currently: Turret Damage. |
| Solar Farm | 80 | 100 | Generates 6 power every 4 seconds during daytime only. |
| Gold Mine | — | — | Spawns automatically on map generation. Staff with workers to earn coins (5 per worker every 5s). Depletes over time. |

All buildings regenerate HP at 2% of max per tick (every 3 seconds) after 30 seconds without taking damage. Health bars appear automatically when a building takes damage and hide at full HP.

## Building Upgrades

Right-click a Farm or Tower to open its upgrade option (max 1 upgrade each).

| Building | Upgrade Cost | Effect |
|----------|-------------|--------|
| Farm | 100 coins | +2 food produced per worker per tick |
| Tower | 120 coins | −0.3s fire rate (min 0.4s cooldown) |

## Towers

Towers require exactly 1 assigned worker and available power to fire. Each shot deals 25 base damage (upgradable via the Lab) to the nearest enemy within 600px range every 1 second. Towers drain 1 power every 4 seconds while staffed.

If power reaches 0, towers stop firing even if staffed.

## Workers

Workers cost 20 coins and are hired from the Core menu (press E on the Core). Each Housing building adds 5 to the worker cap. Workers roam near the Core when idle.

Assign workers to **Farms** to produce food, **Towers** to enable firing, or **Gold Mines** to generate coins. All workers consume food at a rate of 1 food per worker every 5 seconds.

## Soldiers

Soldiers are combat units purchased from the Barracks menu (press E on a Barracks) for 30 coins each. Each Barracks adds 5 to the soldier cap.

Soldiers automatically hunt enemies that come within range of any player building. When no threats are nearby they patrol the perimeter of your unlocked territory. If an enemy camp is on the map and no regular enemies are threatening your base, soldiers will march to destroy it.

Each soldier has 80 HP and deals 20 damage per second in melee range.

## Enemies

Enemies spawn from outside the map during nighttime only. They arrive in structured waves with cooldown windows between bursts. HP and damage scale with how many coins you have earned this run — the more coins you've accumulated, the more dangerous every enemy becomes.

| Enemy | HP (base) | Speed | Damage | Reward | Notes |
|-------|-----------|-------|--------|--------|-------|
| Standard | 100 | Normal | 10 / 1.2s | 10 coins | Basic ground attacker |
| Big | 350 | Slow | 35 / 2.5s | 30 coins | Spawns after the first full day/night cycle |
| Flying Ranged | 60 | Moderate | 12 / 2.5s | 20 coins | Ranged projectile attacker; ignores ground obstacles. Starts night 3. |
| Burrower | 80 | Fast (surface) | 18 / 1.8s | 25 coins | Tunnels underground through walls and surfaces inside your base. Immune to damage while tunneling. Starts night 4. |

Enemies attack any building they can reach, prioritising structures over the Core. When the Core falls the run ends.

### Threat Scaling

Enemy HP and damage increase based on total coins earned during the current run:

- **Every 800 coins earned** → +60% base HP and +30% base damage (cumulative)
- All enemy types scale together — waves that arrive late in a long run are significantly more dangerous

Coins from Legacy bonuses (see below) do **not** count toward threat scaling.

## Enemy Camp

Starting from night 2, an enemy camp spawns roughly 900px from your base. The camp periodically releases bursts of 3 enemies every 40 seconds. Destroying it rewards **150 coins**.

- The camp has 250 HP and can be damaged by the player, tower bullets, and soldiers
- Soldiers will automatically march to destroy the camp when no regular enemies are threatening buildings
- Only one camp exists at a time; a new one may spawn on subsequent nights

## Power

Power is produced by Solar Farms (daytime only) and consumed by staffed Towers. The power cap starts at **120** and can be upgraded from the Core menu for 150 coins (+60 per upgrade). Surplus power is capped — build more Solar Farms and upgrade the cap before expanding your tower network.

## Food

Food is produced by Farms with assigned workers. All workers consume food over time. The food cap starts at 200 and can be upgraded from the Core menu for 100 coins (+100 per upgrade). If food runs out workers continue functioning but food won't accumulate beyond zero.

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

Right-click near a tile edge to place a wall (25 coins, 200 HP). You must be within 200px of the target edge and at least one adjacent tile must be owned. Walls block enemies and can be destroyed by taking damage.

- **Right-click a full-HP wall** — demolish it and receive a full 25-coin refund
- **Right-click a damaged wall** — repair it for 15 coins, restoring HP over time. A damaged wall cannot be demolished until fully repaired.

Walls are saved and restored with the game.

## Legacy Points (Meta Progression)

When a run ends, you earn **10 Legacy Points per day survived**. A shop opens on the death screen where you can spend Legacy Points on permanent bonuses that carry into every future run.

| Upgrade | Cost | Effect | Max Level |
|---------|------|--------|-----------|
| Coin Cache | 30 LP | +75 starting coins per level | 5 |
| Food Reserve | 25 LP | +30 starting food per level | 3 |
| Power Grid | 40 LP | +20 starting power cap per level | 3 |
| Veteran Workforce | 50 LP | +1 worker at run start per level | 3 |

Legacy Point bonuses persist between runs and are stored separately from run save data.

## Economy

- **Coins** — earned from staffed Gold Mines and by killing enemies. Spent on tiles, buildings, workers, soldiers, research, and upgrades. Total coins earned this run drives enemy threat scaling.
- **Food** — produced by Farms. Consumed by all workers (1 per worker every 5s). Starting supply: 50 (increased by legacy upgrades). Cap upgradable from Core.
- **Power** — generated by Solar Farms (6 per tick) during daytime. Consumed by staffed Towers (1 per 4s). Starting cap: 120 (increased by legacy upgrades). Cap upgradable from Core.

## Controls

| Input | Action |
|-------|--------|
| WASD | Move player |
| Left click | Shoot toward cursor |
| Right click | Place wall on nearest tile edge (25 coins); right-click an existing wall to demolish or repair it |
| E | Interact — purchase tile / open build menu / manage building |
| Z | Manual save |
| U | Toggle developer menu |
| Escape | Close open menu |

### Player Shooting

Left-click fires a bullet toward the mouse cursor with a 0.3-second cooldown. Bullets deal 15 damage, travel at 400 px/s (plus inherited player velocity), and expire after 2 seconds.

### Developer Menu (U)

- **Add 100 / 1000 Coins** — instant coin injection for testing
- **Skip to Dusk** — jumps the day/night cycle to the start of the dusk transition, triggering nighttime and enemy spawns immediately
- **Reset Game** — wipes the run save and restarts from scratch (Legacy Points are kept)
- **Reset Legacy Data** — wipes all Legacy Points and permanent upgrades

## Saving

The game auto-saves every 5 minutes and on manual save (Z). Two save files are used:

- `user://save.json` — current run state (tiles, buildings, workers, soldiers, walls, resources, lab progress)
- `user://legacy.json` — persistent Legacy Point totals and purchased upgrades (survives run resets)

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
| `game_state.gd` | Autoload singleton — economy, workers, soldiers, buildings, research, signals, threat scaling |
| `legacy_state.gd` | Autoload singleton — Legacy Points persistence, upgrade bonuses, between-run shop data |
| `constants.gd` | Autoload — all game constants and tuning values |
| `tile_grid.gd` | Grid generation, tile purchasing, building placement, unit spawning, wall management |
| `building_base.gd` | Shared HP, health bar, regen, fortification, depth sorting, destruction, and upgrade level |
| `player.gd` | Movement, shooting, wall placement, and E-key interaction routing |
| `soldier.gd` | Soldier AI — patrol, chase, attack states; secondary targeting of enemy camps |
| `enemy.gd` | Enemy AI — building priority targeting, movement, melee attack, threat-scaled stats |
| `big_enemy.gd` | Slow heavy enemy with high HP and damage |
| `flying_enemy.gd` | Ranged flying enemy — orbits and fires projectiles, ignores ground obstacles |
| `burrower.gd` | Tunneling enemy — underground phase → emerge warning → surfaces and attacks |
| `enemy_camp.gd` | Destroyable enemy structure — periodically spawns enemy bursts |
| `tower.gd` | Tower attack loop, power drain, bullet spawning, upgrade-aware fire rate |
| `solar_farm.gd` | Power generation during daytime |
| `wall.gd` | Placeable wall segment with HP, repair mechanic, depth sorting, and save/load support |
| `day_night_cycle.gd` | Cycle timer, overlay alpha, time-of-day string, night intensity for spawning |
| `enemy_spawner.gd` | Structured wave system, all enemy type timers, enemy camp spawning |
| `save_manager.gd` | JSON save/load and game reset; applies Legacy bonuses on new run |
