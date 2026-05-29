# Backlog

Ideas for future features, ordered roughly by impact within each category. Nothing here is committed — use this as a menu to pick from.

---

## Roguelite / Replayability

| Impact | Item |
|--------|------|
| ★★★★★ | **Night modifiers** — Each night rolls a random event: "Cursed Night" (enemies +30% speed), "Treasure Night" (2× coin drops), "Siege Night" (no flying/burrowers, massive ground wave), "Peaceful Night" (no enemies, double resource production). Adds enormous replayability with zero new content cost. |
| ★★★★☆ | **Boss enemies** — A unique boss spawns every 5 nights with a distinctive mechanic (shield that must be broken first, splits into runners on death, spawns a ring of enemy camps). Gives each run a landmark and escalating stakes. |
| ★★★★☆ | **Per-run relics** — Rare passive items dropped by bosses or bought from a merchant, each with a meaningful tradeoff (e.g. "Iron Heart: soldiers deal 2× damage but cost 2× to buy", "Plague Banner: enemies are slowed 20% but your workers consume 50% more food"). Roguelite layer on top of the Legacy system. |
| ★★★☆☆ | **Worker automation** — Workers auto-assign to nearby buildings they can reach, filling vacancies in priority order (Mine > Farm > Tower > Storehouse). Manual override still works. Reduces tedium once you have 10+ workers. |

---

## Tower Defense Depth

| Impact | Item |
|--------|------|
| ★★★★☆ | **Slow tower** — Fires a tar glob that reduces enemy speed by 50% for 3s within a radius. No damage. Cheap (50 coins), low HP. Combines with Tower/Siege Tower for burst-then-slow combos. Classic TD gap-filler that makes positioning matter more. |
| ★★★☆☆ | **Tower targeting priority** — Per-tower toggle in the Tower UI: Nearest / Strongest / Weakest / Fastest. Nearest is default (current behavior). Strongest for Siege Tower burst damage; Weakest for cleanup. Small UI addition, large tactical depth. |
| ★★★☆☆ | **Deployable traps** — Player places spike strips or tar patches on owned tiles (25–40 coins). Spike strips deal damage per second to any enemy on them. Tar patches halve enemy speed. Limited durability — disappear after absorbing enough traffic. |
| ★★☆☆☆ | **Chain tower** — Hits one enemy then arcs to up to 3 nearby enemies at reduced damage. Expensive (150 coins), requires 1 worker + power. Strong against dense ground waves, weak against spread-out flying enemies. |

---

## Bullet Hell / Player Feel

| Impact | Item |
|--------|------|
| ★★★★☆ | **Player dash** — Tap Shift to roll in the movement direction (short invincibility window, brief cooldown). Makes the player feel agile rather than passive. Adds skill expression and survivability without changing the macro game. |
| ★★★☆☆ | **Charged shot** — Hold LMB to charge; release for a piercing shot that travels through enemies and deals 3× damage. ~2s charge time, replaces the rapid-fire shot during charge. High-skill ceiling, rewards active play. |
| ★★★☆☆ | **Enemy attack patterns** — Give specific enemy types distinct projectile patterns. Flying enemy gains a 3-way spread shot at max level. Armored enemy does a telegraphed stomp that damages buildings in a radius on impact. More visual read-ability, more to dodge. |
| ★★☆☆☆ | **Player HP / death** — Player can take damage and has a small HP pool. Death knocks them to the Core to respawn (short cooldown). Adds stakes to being on the frontline. |

---

## RTS Depth

| Impact | Item |
|--------|------|
| ★★★☆☆ | **Merchant caravan** — A traveling merchant appears every 3 days at a random map edge. Spend coins to buy rare items (a one-time turret upgrade, a relic, extra workers, instant food). Adds decision moments and something to spend late-game coins on. |
| ★★★☆☆ | **Soldier squads** — Split soldiers into two groups (A and B). Each group has its own rally point. Lets you hold the base with one group and push the enemy camp with another. |
| ★★☆☆☆ | **Watchtower / fog of war** — Unexplored area at the map edge is fogged. Watchtower building (cheap, no worker) reveals a radius. Enemy camps and new mine spawns are hidden until scouted. Adds map tension and incentivises expansion. |
| ★★☆☆☆ | **Building priority flags** — Mark one building as "Defend Priority." Soldiers leash to that building's position instead of the rally point when an enemy is attacking it specifically. |

---

## Economy / Progression

| Impact | Item |
|--------|------|
| ★★★☆☆ | **Trade routes** — Connect two Gold Mines with a worker path; coins trickle passively along the route without depleting the mines. Expensive to set up, rewards long-term map planning. |
| ★★★☆☆ | **Prestige research** — After completing all 6 Library researches, unlock a 7th: a permanent Legacy Point multiplier for the current run's end reward. Gives late-game Library something to do. |
| ★★☆☆☆ | **Coin interest** — Holding large amounts of unspent coins generates small passive income (e.g. 1% of current coins every 30s). Rewards economic play styles and gives a reason to not immediately spend everything. |

---

## Polish / Feel

| Impact | Item |
|--------|------|
| ★★★★☆ | **Sound effects** — Attack, building placement, coin pickup, enemy death, alarm on building attacked. Pixel art games feel hollow without basic audio. Highest polish-per-effort ratio. |
| ★★★☆☆ | **Screen shake** — Camera shake on big enemy hits (Armored, Big Enemy attacks), Siege Tower impact, Core taking damage. Short duration, small amplitude. Makes impacts feel weighty. |
| ★★★☆☆ | **Music** — Two looping tracks: calm/ambient for daytime, tense/percussion-driven for night. Could be procedural (layer in drums as wave intensity rises). |
| ★★☆☆☆ | **Building construction animation** — Brief build-up effect (scaffold, scaffolding flash) when a building is first placed. Currently instant. |
| ★★☆☆☆ | **Enemy death variety** — Runners explode in a small coin burst. Armored crumples slowly. Burrowers sink back into the ground. Currently all enemies shrink and disappear the same way. |
| ★☆☆☆☆ | **Idle worker animation** — Workers bob or shuffle while idle near the Core instead of standing still. Pure vibe. |
