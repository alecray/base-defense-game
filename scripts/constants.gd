extends Node

## Economy
const STARTING_COINS: int = 200
const STARTING_FOOD: int = 100
const WORKER_COST: int = 20
const FORTIFY_COST: int = 75
const FOOD_DRAIN_INTERVAL: float = 5.0
const BUILDING_COSTS: Dictionary = {
	"Core": 100,
	"Barracks": 50,
	"Farm": 75,
	"Tower": 60
}

## Barracks
const BARRACKS_WORKER_BONUS: int = 5

## Building HP
const CORE_MAX_HP: int = 500
const BARRACKS_MAX_HP: int = 150
const FARM_MAX_HP: int = 100
const TOWER_MAX_HP: int = 200

## Building Regen
const REGEN_COOLDOWN: float = 30.0
const REGEN_INTERVAL: float = 3.0
const REGEN_PERCENT: float = 0.02

## Fortification
const SHIELD_MAX_HP: int = 200

## Farm
const FARM_FOOD_INTERVAL: float = 5.0
const FARM_FOOD_PER_WORKER: int = 3

## Tower
const TOWER_MAX_WORKERS: int = 3
const TOWER_DAMAGE: int = 25
const TOWER_RANGE: float = 300.0
const TOWER_INTERVAL_1: float = 2.0
const TOWER_INTERVAL_2: float = 1.25
const TOWER_INTERVAL_3: float = 0.75

## Gold Mine
const MINE_MAX_WORKERS: int = 5
const MINE_MAX_RESERVES: int = 1000
const MINE_COINS_PER_WORKER: int = 5
const MINE_TICK_INTERVAL: float = 5.0

## Tile Grid
const TILE_SIZE: int = 128
const TILE_GAP: int = 2
const EXTRA_MINE_COUNT: int = 5
const TILE_COST_BASE: float = 10.0
const TILE_COST_SCALE: float = 1.5

## Worker
const WORKER_SPEED: float = 60.0
const WORKER_WORK_SPEED: float = 18.0
const WORKER_ROAM_RADIUS: float = 192.0
const WORKER_ARRIVAL_THRESHOLD: float = 12.0

## Enemy
const ENEMY_SPEED: float = 45.0
const ENEMY_MAX_HP: int = 100
const ENEMY_COIN_REWARD: int = 10
const ENEMY_RETARGET_INTERVAL: float = 2.0
const ENEMY_ATTACK_RANGE: float = 72.0
const ENEMY_ATTACK_INTERVAL: float = 1.2
const ENEMY_ATTACK_DAMAGE: int = 10

## Day/Night Cycle
const DAY_DURATION: float = 150.0
const NIGHT_DURATION: float = 150.0
const DAY_NIGHT_TRANSITION: float = 15.0
const NIGHT_SPAWN_INTERVAL_MULT: float = 0.6
const NIGHT_SPAWN_CLUMP_MAX: int = 10

## Enemy Spawner
const ENEMY_SPAWN_RADIUS: float = 1400.0
const ENEMY_SPAWN_START_DELAY: float = 60.0
const ENEMY_SPAWN_BASE_INTERVAL: float = 8.0
const ENEMY_SPAWN_MIN_INTERVAL: float = 1.5
const ENEMY_SPAWN_RAMP_DURATION: float = 300.0
const ENEMY_SPAWN_CLUMP_MAX: int = 5
const ENEMY_SPAWN_SCATTER: float = 48.0
