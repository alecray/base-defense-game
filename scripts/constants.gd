extends Node

## Economy
const STARTING_COINS: int = 200
const STARTING_FOOD: int = 100
const WORKER_COST: int = 20
const FORTIFY_COST: int = 75
const FOOD_DRAIN_INTERVAL: float = 5.0
const BUILDING_COSTS: Dictionary = {
	"Core": 100,
	"Housing": 50,
	"Barracks": 75,
	"Farm": 75,
	"Tower": 60,
	"Library": 150,
	"SolarFarm": 80,
	"Armory": 150,
	"SiegeTower": 120,
	"Market": 100,
	"Storehouse": 110,
}

## Housing
const HOUSING_WORKER_BONUS: int = 5

## Barracks
const BARRACKS_MAX_HP: int = 150
const BARRACKS_SOLDIER_BONUS: int = 5
const SOLDIER_COST: int = 30

## Soldier
const SOLDIER_HP: int = 80
const SOLDIER_SPEED: float = 75.0
const SOLDIER_ATTACK_RANGE: float = 60.0
const SOLDIER_ATTACK_DAMAGE: int = 20
const SOLDIER_ATTACK_INTERVAL: float = 1.0
const SOLDIER_RETARGET_INTERVAL: float = 1.5
const SOLDIER_THREAT_RANGE: float = 250.0
const SOLDIER_PATROL_OFFSET: float = 60.0
const SOLDIER_CHASE_RADIUS: float = 900.0
const SOLDIER_PATROL_REFRESH: float = 8.0
const SOLDIER_RALLY_PATROL_RADIUS: float = 80.0

## Building HP
const CORE_MAX_HP: int = 500
const HOUSING_MAX_HP: int = 150
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
const TOWER_MAX_WORKERS: int = 1
const TOWER_DAMAGE: int = 25
const TOWER_RANGE: float = 600.0
const TOWER_INTERVAL: float = 1.0
const TOWER_POWER_DRAIN_INTERVAL: float = 4.0
const TOWER_POWER_DRAIN_AMOUNT: int = 1

## Storehouse
const STOREHOUSE_MAX_HP: int = 175
const STOREHOUSE_MAX_WORKERS: int = 5
const STOREHOUSE_FOOD_CAP_PER_WORKER: int = 50
const STOREHOUSE_POWER_CAP_PER_WORKER: int = 30

## Market
const MARKET_MAX_HP: int = 175
const MARKET_FOOD_THRESHOLD_FRACTION: float = 0.6
const MARKET_POWER_THRESHOLD_FRACTION: float = 0.6
const MARKET_FOOD_PER_COIN: int = 8
const MARKET_POWER_PER_COIN: int = 5

## Solar Farm
const SOLAR_FARM_MAX_HP: int = 100
const SOLAR_FARM_POWER_INTERVAL: float = 4.0
const SOLAR_FARM_POWER_AMOUNT: int = 6

## Power
const STARTING_POWER: int = 0
const POWER_CAP_BASE: int = 120
const POWER_CAP_UPGRADE_COST: int = 150
const POWER_CAP_UPGRADE_AMOUNT: int = 60

## Food Cap
const FOOD_CAP_BASE: int = 200
const FOOD_CAP_UPGRADE_COST: int = 100
const FOOD_CAP_UPGRADE_AMOUNT: int = 100

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

## Flying Enemy
const FLYING_ENEMY_MAX_HP: int = 60
const FLYING_ENEMY_SPEED: float = 38.0
const FLYING_ENEMY_ATTACK_RANGE: float = 280.0
const FLYING_ENEMY_ATTACK_INTERVAL: float = 2.5
const FLYING_ENEMY_ATTACK_DAMAGE: int = 12
const FLYING_ENEMY_COIN_REWARD: int = 20
const FLYING_ENEMY_PROJECTILE_SPEED: float = 220.0
const FLYING_ENEMY_SPAWN_START_DAY: int = 3
const FLYING_ENEMY_SPAWN_INTERVAL: float = 22.0

## Burrower
const BURROWER_MAX_HP: int = 80
const BURROWER_TUNNEL_SPEED: float = 90.0
const BURROWER_SURFACE_SPEED: float = 55.0
const BURROWER_ATTACK_RANGE: float = 40.0
const BURROWER_ATTACK_INTERVAL: float = 1.8
const BURROWER_ATTACK_DAMAGE: int = 18
const BURROWER_COIN_REWARD: int = 25
const BURROWER_EMERGE_WARN_TIME: float = 2.0
const BURROWER_EMERGE_RADIUS: float = 120.0
const BURROWER_SPAWN_START_DAY: int = 4
const BURROWER_SPAWN_INTERVAL: float = 35.0

## Big Enemy
const BIG_ENEMY_MAX_HP: int = 350
const BIG_ENEMY_SPEED: float = 28.0
const BIG_ENEMY_ATTACK_RANGE: float = 80.0
const BIG_ENEMY_ATTACK_INTERVAL: float = 2.5
const BIG_ENEMY_ATTACK_DAMAGE: int = 35
const BIG_ENEMY_COIN_REWARD: int = 30
const BIG_ENEMY_SPAWN_INTERVAL: float = 35.0
const BIG_ENEMY_SPAWN_MIN_INTERVAL: float = 12.0

## Runner
const RUNNER_MAX_HP: int = 35
const RUNNER_SPEED: float = 105.0
const RUNNER_ATTACK_RANGE: float = 45.0
const RUNNER_ATTACK_INTERVAL: float = 0.9
const RUNNER_ATTACK_DAMAGE: int = 6
const RUNNER_COIN_REWARD: int = 6
const RUNNER_SPAWN_START_DAY: int = 5
const RUNNER_SPAWN_INTERVAL: float = 22.0
const RUNNER_BURST_SIZE: int = 4

## Armored Enemy
const ARMORED_MAX_HP: int = 450
const ARMORED_SPEED: float = 18.0
const ARMORED_ATTACK_RANGE: float = 80.0
const ARMORED_ATTACK_INTERVAL: float = 3.0
const ARMORED_ATTACK_DAMAGE: int = 50
const ARMORED_COIN_REWARD: int = 45
const ARMORED_SPAWN_START_DAY: int = 4
const ARMORED_SPAWN_INTERVAL: float = 55.0

## Day/Night Cycle
const DAY_DURATION: float = 150.0
const NIGHT_DURATION: float = 150.0
const DAY_NIGHT_TRANSITION: float = 15.0

## Library
const LIBRARY_MAX_HP: int = 200
const LIBRARY_RESEARCH_TURRET_DAMAGE_COST: int = 100
const LIBRARY_RESEARCH_TURRET_DAMAGE_DURATION: float = 45.0
const LIBRARY_TURRET_DAMAGE_UPGRADE_AMOUNT: int = 5

## Wall
const WALL_COST: int = 25
const WALL_MAX_HP: int = 200
const WALL_THICKNESS: float = 20.0
const WALL_SNAP_DISTANCE: float = 96.0
const WALL_PLAYER_RANGE: float = 400.0
const WALL_REPAIR_COST: int = 15
const WALL_REPAIR_RATE: float = 20.0
const BUILDING_REPAIR_HP_PER_COIN: int = 5

## Player
const PLAYER_BULLET_DAMAGE: int = 15
const PLAYER_BULLET_SPEED: float = 400.0
const PLAYER_SHOOT_COOLDOWN: float = 0.3
const PLAYER_BULLET_LIFETIME: float = 2.0

## Threat Scaling
const THREAT_SCALE_COINS: float = 800.0
const THREAT_HP_SCALE: float = 0.6
const THREAT_DAMAGE_SCALE: float = 0.3

## Building Upgrades
const FARM_UPGRADE_COST: int = 100
const FARM_UPGRADE_MAX: int = 1
const FARM_UPGRADE_FOOD_BONUS: int = 2
const TOWER_UPGRADE_COST: int = 120
const TOWER_UPGRADE_MAX: int = 1
const TOWER_UPGRADE_INTERVAL_REDUCTION: float = 0.3

## Enemy Camp
const ENEMY_CAMP_HP: int = 250
const ENEMY_CAMP_SPAWN_RADIUS: float = 900.0
const ENEMY_CAMP_REWARD: int = 150
const ENEMY_CAMP_SPAWN_INTERVAL: float = 40.0
const ENEMY_CAMP_BURST_SIZE: int = 3
const ENEMY_CAMP_MAX_COUNT: int = 1
const ENEMY_CAMP_START_NIGHT: int = 2
const SOLDIER_CAMP_CHASE_RADIUS: float = 1100.0

## Siege Tower
const SIEGE_TOWER_MAX_HP: int = 250
const SIEGE_TOWER_DAMAGE: int = 60
const SIEGE_TOWER_RANGE: float = 750.0
const SIEGE_TOWER_INTERVAL: float = 4.5
const SIEGE_TOWER_AOE_RADIUS: float = 90.0
const SIEGE_TOWER_POWER_DRAIN_INTERVAL: float = 4.0
const SIEGE_TOWER_POWER_DRAIN_AMOUNT: int = 2
const SIEGE_PROJECTILE_SPEED: float = 280.0

## Armory
const ARMORY_MAX_HP: int = 175
const ARMORY_DAMAGE_BONUS: int = 15
const ARMORY_HP_BONUS: int = 25

## Library — Armory Blueprint research
const LIBRARY_RESEARCH_ARMORY_COST: int = 175
const LIBRARY_RESEARCH_ARMORY_DURATION: float = 75.0

## Library — Combat Training (soldier damage)
const LIBRARY_RESEARCH_SOLDIER_DAMAGE_COST: int = 120
const LIBRARY_RESEARCH_SOLDIER_DAMAGE_DURATION: float = 50.0
const LIBRARY_SOLDIER_DAMAGE_UPGRADE_AMOUNT: int = 5

## Library — Soldier Endurance (soldier HP)
const LIBRARY_RESEARCH_SOLDIER_HP_COST: int = 130
const LIBRARY_RESEARCH_SOLDIER_HP_DURATION: float = 55.0
const LIBRARY_SOLDIER_HP_UPGRADE_AMOUNT: int = 20

## Library — Efficient Workers (worker speed)
const LIBRARY_RESEARCH_WORKER_SPEED_COST: int = 100
const LIBRARY_RESEARCH_WORKER_SPEED_DURATION: float = 40.0
const LIBRARY_WORKER_SPEED_UPGRADE_AMOUNT: float = 10.0

## Library — Agricultural Methods (farm yield)
const LIBRARY_RESEARCH_FARM_YIELD_COST: int = 110
const LIBRARY_RESEARCH_FARM_YIELD_DURATION: float = 45.0
const LIBRARY_FARM_YIELD_UPGRADE_AMOUNT: int = 1

## Legacy System
const LEGACY_POINTS_PER_DAY: int = 10

## Boss Enemy
const BOSS_SHIELD_HP: int = 400
const BOSS_MAX_HP: int = 1200
const BOSS_SPEED: float = 22.0
const BOSS_ATTACK_RANGE: float = 90.0
const BOSS_ATTACK_INTERVAL: float = 2.0
const BOSS_ATTACK_DAMAGE: int = 40
const BOSS_COIN_REWARD: int = 150
const BOSS_SPLIT_COUNT: int = 4
const BOSS_SPAWN_EVERY_N_NIGHTS: int = 5

## Enemy Spawner
const ENEMY_SPAWN_RADIUS: float = 1400.0
const ENEMY_SPAWN_SCATTER: float = 48.0
const ENEMY_SPAWN_RAMP_DAYS: int = 5
const WAVE_INITIAL_DELAY: float = 20.0
const WAVE_COOLDOWN: float = 30.0
const WAVE_BASE_COUNT: int = 3
const WAVE_COUNT_PER_WAVE: int = 2
const WAVE_COUNT_PER_DAY: int = 2
const WAVE_BURST_INTERVAL: float = 0.4
