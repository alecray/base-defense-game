# Art To Do

## Buildings

### Storehouse
- [x] Sprite — `assets/sprites/buildings/storehouse.aseprite`
  - Static or 1–2 frame idle, ~64×64px — a large barrel/crate structure, warm brown/wood tones
  - Workers idle at the WorkPoint (offset y+44 from center)
  - Swap in by replacing placeholder data in `prefabs/storehouse.tscn`

### Market
- [x] Sprite — `assets/sprites/structures/market.aseprite`

### Siege Tower
- [x] Sprite — `assets/sprites/structures/siege_tower.aseprite`

### Armory
- [x] Sprite — `assets/sprites/structures/armory.aseprite`

## Enemies

### Runner
- [ ] Sprite sheet — `assets/sprites/npcs/runner.aseprite`
  - Animations: `Walk` (2–4 frames), `Attack` (optional), `Idle` (fallback)
  - ~24×24px — small, wiry, agile creature; reads as fast and fragile
  - Currently a yellow-tinted version of the ground enemy as placeholder
  - Swap in by updating `prefabs/runner.tscn` to point to the new sprite

### Armored Enemy
- [ ] Sprite sheet — `assets/sprites/npcs/armored_enemy.aseprite`
  - Animations: `Walk` (2–4 frames), `Attack` (optional wind-up), `Idle` (fallback)
  - ~48×48px — hulking, heavily plated unit; reads as slow and near-unkillable
  - Currently a blue-tinted, 1.4× scaled version of the ground enemy as placeholder
  - Swap in by updating `prefabs/armored_enemy.tscn` to point to the new sprite

### Burrower
- [x] Sprite sheet — `assets/sprites/npcs/burrower.aseprite`
  - Animations: `Idle` (surfaced idle, 2–4 frames)
  - ~32×32px, top-down perspective — compact, dirt-covered creature with visible claws
  - Tunneling phase is code-drawn (dirt ripple); only the surfaced form needs a sprite
  - Currently uses a brown-tinted version of the ground enemy as placeholder
  - Swap in by updating `prefabs/burrower.tscn` to point to the new sprite

### Enemy Camp
- [x] Sprite — `assets/sprites/structures/enemy-camp.aseprite`
  - Static (no animation needed), ~48×48px — fortified structure, dark red/bone aesthetic
  - Currently code-drawn (dark red circle with X pattern)
  - Swap in by removing `_draw()` from `scripts/enemy_camp.gd` and adding an AnimatedSprite2D

### Big Enemy
- [x] Sprite sheet — `assets/sprites/npcs/big_enemy.aseprite`
  - Animations: `Walk` (2–4 frames), `Attack` (optional wind-up), `Idle` (fallback)
  - ~48×48px, top-down perspective — large, hulking ground unit
  - `prefabs/big_enemy.tscn` has an empty SpriteFrames with no texture data — enemy is invisible in-game
  - Add PortableCompressedTexture2D frames to `big_enemy.tscn` the same way `enemy.tscn` is structured

### Flying Ranged Enemy
- [x] Sprite sheet — `assets/sprites/npcs/flying_enemy.aseprite`
  - Animations: `Idle` (hovering/flapping, 2–4 frames), `Attack` (optional wind-up)
  - ~32×32px, top-down perspective
  - Should read as airborne — wings, glowing, floating silhouette, etc.
  - Currently uses a cyan-tinted version of the ground enemy as placeholder
  - Swap in by updating `prefabs/flying_enemy.tscn` to point to the new sprite

## Projectiles

### Enemy Projectile (Flying Enemy attack)
- [ ] Sprite or particle — `assets/sprites/fx/enemy_projectile.aseprite`
  - Small (~8–12px) fiery or magical orb
  - Currently drawn in code as an orange circle (`enemy_projectile.gd`)
  - Replace `_draw()` in `scripts/enemy_projectile.gd` with an AnimatedSprite2D once ready

### Tower Bullet & Player Bullet
- [ ] Sprite — `assets/sprites/fx/bullet.aseprite` (can share one sheet)
  - Small (~6–8px) yellow/gold projectile — both tower and player bullets currently draw the same code circle
  - Tower bullet: `scripts/bullet.gd` `_draw()` — yellow circle + lighter trailing dot
  - Player bullet: `scripts/player_bullet.gd` `_draw()` — same style
  - Replace both `_draw()` methods with AnimatedSprite2D once ready

### Siege Boulder
- [ ] Sprite — `assets/sprites/fx/siege_projectile.aseprite`
  - Small dark boulder (~12–14px) — currently drawn as a brown circle in `scripts/siege_projectile.gd` `_draw()`
  - Explosion ring is code-drawn (expanding orange arc, fades over 0.4s) — can remain code-drawn or be replaced with a particle effect
  - Replace `_draw()` flight rendering with a Node2D + Sprite2D once art is ready
