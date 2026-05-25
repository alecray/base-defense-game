# Base Defense Game

A top-down base building and defense game built with Godot 4.6 and GDScript. Expand your territory, build structures, assign workers, and defend your Core against waves of enemies.

## Gameplay

Place buildings on a purchasable 15x15 tile grid. Tile costs increase exponentially the further they are from your starting position. Your Core generates coins passively — use them to unlock tiles, construct buildings, hire workers, and build towers before the enemy waves overwhelm you.

Enemies spawn from outside the map in increasing numbers and attack any building they can reach, saving the Core for last. When the Core is destroyed, the game ends.

## Buildings

| Building | Cost | HP  | Description |
|----------|------|-----|-------------|
| Core | 100 | 500 | Required first. Generates 10 coins every 5 seconds. |
| Barracks | 50 | 150 | Increases worker cap by 5 per building. |
| Farm | 75 | 100 | Produces 3 food per worker every 5 seconds. Requires assigned workers. |
| Tower | 60 | 200 | Attacks enemies within 300px. Requires workers to fire. |

All buildings regenerate HP at 2% of their max per tick (every 3 seconds) after not taking damage for 30 seconds. Health bars are hidden at full HP and appear automatically when a building takes damage.

## Towers

Towers require workers assigned to operate. Assign up to 3 workers via the Tower Management menu (press E while standing on the tower). More workers means a faster fire rate:

| Workers | Fire Rate |
|---------|-----------|
| 0 | Inactive — does not fire |
| 1 | Slow (every 2.0s) |
| 2 | Medium (every 1.25s) |
| 3 | Fast (every 0.75s) |

Each shot deals 25 damage to the nearest enemy within range.

## Workers

Workers cost 20 coins and are hired from the Core menu (press E on the Core). Each Barracks built adds 5 to the worker cap. Workers roam near the Core when idle.

Assign workers to **Farms** to produce food, or to **Towers** to enable firing. All workers consume 1 food every 5 seconds regardless of assignment. If food runs out, workers keep functioning — but unstaffed farms means food will eventually deplete.

## Enemies

Enemies spawn from outside the map every 8 seconds at the start, ramping up to every 1.5 seconds over 5 minutes. Each enemy has 100 HP and moves at 45px/s.

Enemies prioritise non-Core buildings and only target the Core once all other buildings are destroyed. When close enough to a building they stop and deal 10 damage every 1.2 seconds. Killing an enemy drops 10 coins.

## Economy

- **Coins** — earned passively from the Core (+10 every 5s) and by killing enemies (+10 each). Spent on tiles, buildings, and workers.
- **Food** — produced by Farms with assigned workers. Consumed by all workers every 5 seconds. Starting supply: 100.

## Controls

| Key | Action |
|-----|--------|
| WASD | Move player |
| E | Interact — purchase tile / open build menu / manage building |
| Z | Manual save |
| U | Toggle developer menu |
| Escape | Close open menu |

## Saving

The game auto-saves every 5 minutes and on manual save (Z). Save data is written to `user://save.json` and restored automatically on next launch. The developer menu includes a Reset Game option to wipe the save and start fresh.

## Development

**Engine:** Godot 4.6  
**Language:** GDScript (strict typing throughout)  
**Art:** Aseprite sprites imported via the AsepriteWizard plugin

### Project Structure

```
scenes/      — Main scene and UI scenes
scripts/     — All GDScript source files
prefabs/     — Reusable node scenes (buildings, worker, enemy, bullet)
assets/      — Sprites and other assets
addons/      — Godot plugins (AsepriteWizard)
```

### Key Scripts

| Script | Role |
|--------|------|
| `game_state.gd` | Autoload singleton — economy, workers, buildings, signals |
| `tile_grid.gd` | Grid generation, tile purchasing, building placement |
| `building_base.gd` | Shared HP, health bar, regen, and destruction logic for all buildings |
| `player.gd` | Movement and E-key interaction routing |
| `enemy.gd` | Enemy AI — building priority targeting, movement, melee attack |
| `tower.gd` | Tower attack loop, worker-scaled fire rate, bullet spawning |
| `save_manager.gd` | JSON save/load and game reset |
