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
| Farm | 75 | 100 | Produces food with assigned workers (3 food per worker every 5s). Upgradeable. |
| Tower | 60 | 200 | Attacks nearest enemy within 600px. Requires 1 worker and power. Upgradeable. |
| Barracks | 75 | 150 | Increases soldier cap by 5 per building. Allows purchasing soldiers. |
| Library | 150 | 200 | Research permanent upgrades using coins. Six research options available. |
| Solar Farm | 80 | 100 | Generates 6 power every 4 seconds during daytime only. |
| Gold Mine | — | — | Spawns automatically on map generation. Staff with workers to earn coins (5 per worker every 5s). Depletes over time. |
| Armory | 150 | 175 | Passively buffs all soldiers (+15 attack, new soldiers +25 HP per Armory built). Requires Armory Blueprint research. |
| Siege Tower | 120 | 250 | Fires AoE boulders at the densest enemy cluster in range. No worker needed. Drains 2 power every 4s. |
| Storehouse | 110 | 175 | Assign up to 5 workers to expand resource caps (+50 food cap and +30 power cap per worker). |
| Market | 100 | 175 | Passive. Converts excess food and power into coins automatically. |

All buildings regenerate HP at 2% of max per tick (every 3 seconds) after 30 seconds without taking damage. Health bars appear automatically when a building takes damage and hide at full HP.

## Building Upgrades

Press E on a Farm or Tower, then click the upgrade button (max 1 upgrade each).

| Building | Upgrade Cost | Effect |
|----------|-------------|--------|
| Farm | 100 coins | +2 food produced per worker per tick |
| Tower | 120 coins | −0.3s fire rate (min 0.4s cooldown) |

## Towers

Towers require exactly 1 assigned worker and available power to fire. Each shot deals 25 base damage (upgradable via the Library) to the nearest enemy within 600px range every 1 second. Towers drain 1 power every 4 seconds while staffed. If power reaches 0, towers stop firing even if staffed.

## Siege Towers

Siege Towers fire automatically without a worker whenever power is available. Every 4.5 seconds they launch a boulder at the densest enemy cluster within 750px, dealing 60 damage to all enemies within a 90px explosion radius on impact. They drain 2 power every 4 seconds continuously.

The targeting algorithm picks the enemy position with the most neighbors within the blast radius, making them naturally effective against tight groups and wave clusters.

## Storehouse

Open the Storehouse menu (press E) to assign or unassign workers. Each worker raises the food cap by 50 and the power cap by 30 (up to 5 workers). Caps drop immediately if a worker is unassigned or the Storehouse is destroyed.

## Market

The Market requires no interaction and operates passively. Whenever food exceeds 60% of the food cap, the surplus is sold at a rate of 1 coin per 8 food. Whenever power exceeds 60% of the power cap, the surplus is sold at 1 coin per 5 power. Build a Market when your resource caps consistently overflow to turn waste into income.

## Workers

Workers cost 20 coins and are hired from the Core menu (press E on the Core). Each Housing building adds 5 to the worker cap. Workers roam near the Core when idle.

Assign workers to **Farms** to produce food, **Towers** to enable firing, **Gold Mines** to generate coins, or **Storehouses** to raise resource caps. All workers consume food at a rate of 1 food per worker every 5 seconds.

## Soldiers

Soldiers are combat units purchased from the Barracks menu (press E on a Barracks) for 30 coins each. Each Barracks adds 5 to the soldier cap.

Soldiers automatically hunt enemies that come within range of any player building. When no threats are nearby they patrol either the perimeter of your unlocked territory or around a custom rally point (see **Rally Point** below). If an enemy camp is on the map and no regular enemies are threatening your base, soldiers will march to destroy it.

Each soldier has 80 HP (base) and deals 20 damage per second (base) in melee range. Both stats increase with Armory buildings and Library research.

## Rally Point

Middle-click anywhere on the map to set a soldier rally point. A cyan crosshair marker appears at the chosen location. While a rally point is active:

- Soldiers patrol a circle (80px radius) around it instead of the base perimeter
- Soldiers use the rally point as their chase leash center — they won't pursue enemies far beyond it
- All existing soldiers immediately update to the new patrol circuit

The rally point is saved with the game. Middle-click a new position to move it.

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

Power is produced by Solar Farms (daytime only) and consumed by Towers and Siege Towers. The base power cap is **120** and can be raised by upgrading from the Core menu (150 coins, +60 per upgrade) or by staffing a Storehouse (+30 per worker).

| Consumer | Drain |
|----------|-------|
| Tower (staffed) | 1 power / 4s |
| Siege Tower | 2 power / 4s (continuous) |

## Food

Food is produced by Farms with assigned workers. All workers consume food over time. The base food cap is **200** and can be raised by upgrading from the Core menu (100 coins, +100 per upgrade) or by staffing a Storehouse (+50 per worker). If food runs out workers continue functioning but food won't accumulate beyond zero.

## Day / Night Cycle

Each day and night lasts 150 seconds with a 15-second dusk/dawn transition. The current in-game time is displayed under the day counter (6:00 AM → 6:00 PM during the day, 6:00 PM → 6:00 AM during the night). Enemies only spawn at night, with spawn rate and clump size scaling with darkness intensity. Solar Farms produce no power at night.

## Library Research

Open the Library menu (press E on the Library) to start research. Only one research can run at a time.

| Research | Cost | Time | Effect |
|----------|------|------|--------|
| Turret Damage | 100 | 45s | +5 Tower damage per level. No cap. |
| Armory Blueprint | 175 | 75s | **One-time unlock.** Adds Armory to the build menu. |
| Combat Training | 120 | 50s | +5 soldier attack damage per level. No cap. |
| Soldier Endurance | 130 | 55s | +20 soldier max HP per level (new soldiers). No cap. |
| Efficient Workers | 100 | 40s | +10 worker travel speed per level. No cap. |
| Agricultural Methods | 110 | 45s | +1 food per farm worker per harvest tick per level. No cap. |

## Fortification

Any building with a management menu can be fortified for **75 coins**. This adds a 200 HP shield layer that absorbs damage before the building's own HP. The shield does not regenerate.

Open a building's menu (press E) and click Fortify. The button shows the current shield HP once a fortification is active.

## Building Repair

While standing near a building, hold **R** and **left-click** to repair it. Repair costs **1 coin per 5 HP** restored (rounded up) and restores the building to full HP in one action. The prompt on the building label updates to show the repair cost while R is held.

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

- **Coins** — earned from staffed Gold Mines, enemy kills, and the Market. Spent on tiles, buildings, workers, soldiers, research, and upgrades. Total coins earned this run drives enemy threat scaling.
- **Food** — produced by Farms. Consumed by all workers (1 per worker every 5s). Starting supply: 100 (increased by legacy upgrades). Cap raised from Core menu or Storehouse.
- **Power** — generated by Solar Farms (6 per tick) during daytime. Consumed by Towers (1/4s) and Siege Towers (2/4s). Starting cap: 120 (increased by legacy upgrades). Cap raised from Core menu or Storehouse.

## Controls

| Input | Action |
|-------|--------|
| WASD | Move player |
| Left click | Shoot toward cursor |
| Right click | Place wall on nearest tile edge (25 coins); right-click an existing wall to demolish or repair it |
| Middle click | Set soldier rally point at cursor position |
| E | Interact — purchase tile / open build menu / manage building |
| R + Left click | Repair the nearest building (costs coins) |
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

- `user://save.json` — current run state (tiles, buildings, workers, soldiers, walls, resources, library research, rally point)
- `user://legacy.json` — persistent Legacy Point totals and purchased upgrades (survives run resets)

## Development

**Engine:** Godot 4.6  
**Language:** GDScript (strict typing throughout)  
**Art:** Aseprite sprites imported via the AsepriteWizard plugin

### Project Structure

```
scenes/      — Main scene and UI scenes
scripts/     — All GDScript source files
prefabs/     — Reusable node scenes (buildings, units, bullets, UI)
assets/      — Sprites and other assets
addons/      — Godot plugins (AsepriteWizard)
```

### Key Scripts

| Script | Role |
|--------|------|
| `game_state.gd` | Autoload singleton — economy, workers, soldiers, buildings, research, signals, threat scaling, rally point |
| `legacy_state.gd` | Autoload singleton — Legacy Points persistence, upgrade bonuses, between-run shop data |
| `constants.gd` | Autoload — all game constants and tuning values |
| `tile_grid.gd` | Grid generation, tile purchasing, building placement, unit spawning, wall management |
| `building_base.gd` | Shared HP, health bar, regen, fortification, repair, destruction, and upgrade level |
| `player.gd` | Movement, shooting, wall placement, rally point input, and E-key interaction routing |
| `soldier.gd` | Soldier AI — patrol/rally circuit, chase, attack states; secondary targeting of enemy camps |
| `rally_marker.gd` | Visual crosshair drawn at the active soldier rally point |
| `enemy.gd` | Enemy AI — building priority targeting, movement, melee attack, threat-scaled stats |
| `big_enemy.gd` | Slow heavy enemy with high HP and damage |
| `flying_enemy.gd` | Ranged flying enemy — orbits and fires projectiles, ignores ground obstacles |
| `burrower.gd` | Tunneling enemy — underground phase → emerge warning → surfaces and attacks |
| `enemy_camp.gd` | Destroyable enemy structure — periodically spawns enemy bursts |
| `tower.gd` | Tower attack loop, power drain, bullet spawning, upgrade-aware fire rate |
| `siege_tower.gd` | AoE tower — cluster targeting, boulder fire, power drain |
| `siege_projectile.gd` | Boulder projectile — flies to target position, AoE damage on impact, explosion ring visual |
| `armory.gd` | Passive buff building — stats read by soldiers at spawn and attack time |
| `storehouse.gd` | Worker-staffed cap expander — adds food/power cap per assigned worker |
| `market.gd` | Passive economy building — converts excess food and power to coins |
| `solar_farm.gd` | Power generation during daytime |
| `library.gd` | Research building — drives the Library research queue and upgrade levels |
| `wall.gd` | Placeable wall segment with HP, repair mechanic, and save/load support |
| `day_night_cycle.gd` | Cycle timer, overlay alpha, time-of-day string, night intensity for spawning |
| `enemy_spawner.gd` | Structured wave system, all enemy type timers, enemy camp spawning |
| `save_manager.gd` | JSON save/load and game reset; applies Legacy bonuses on new run |
