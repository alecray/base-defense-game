# Art To Do

## Enemies

### Flying Ranged Enemy
- [ ] Sprite sheet — `assets/sprites/npcs/flying_enemy.aseprite`
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
