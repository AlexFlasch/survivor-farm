extends Resource

class_name EnemyData

# --- Exported Variables ---
@export var enemy: Resource

# --- Enemy Spawn Variables ---
@export var time_start: int
@export var time_end: int
@export var enemy_num: int
@export var enemy_spawn_delay: int
@export var spawn_day: bool = true
@export var spawn_night: bool = true

# --- Enemy Variables ---
@export var base_health: float = 1.0
@export var base_damage: float = 1.0
@export var base_speed: float = 20.0
@export var stun_duration: float = 1.0
@export var stop_distance: float = 0.0

# --- Runtime Variables ---
var spawn_delay_counter: int = 0
