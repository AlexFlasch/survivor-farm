extends Resource

class_name EnemyData

@export var time_start: int
@export var time_end: int
@export var enemy: Resource
@export var enemy_num: int
@export var enemy_spawn_delay: int
@export var spawn_day: bool = true
@export var spawn_night: bool = true

var spawn_delay_counter: int = 0

