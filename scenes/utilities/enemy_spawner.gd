extends Node2D

# Array of EnemyData objects that define the spawn parameters for each enemy type.
@export var spawns: Array[EnemyData] = []

# Reference to the player node, retrieved from the GameManager node.
@onready var player: Node2D = get_tree().root.get_node("GameManager").player
# Reference to the GameManager node, which manages game state and player health.
@onready var gm: Node = get_tree().root.get_node("GameManager")

var time: int = 0

func _on_timer_timeout() -> void:
	# Check if game is paused or not running; if so, do not spawn enemies.
	if not gm.game_running or gm.is_game_paused:
		return
		
	time += 1
	for spawn in spawns:
		if time >= spawn.time_start and time <= spawn.time_end:
			if not is_spawn_eligible(spawn):
				continue
			spawn.spawn_delay_counter += 1
			if spawn.spawn_delay_counter >= spawn.enemy_spawn_delay:
				spawn.spawn_delay_counter = 0
				var enemy_instance = load(str(spawn.enemy.resource_path))
				var counter: int = 0
				while counter < spawn.enemy_num:
					var enemy: Node2D = enemy_instance.instantiate()
					enemy.set_position(get_random_position())
					apply_enemy_setters(enemy, spawn)
					get_tree().root.add_child(enemy)
					counter += 1

func apply_enemy_setters(enemy, spawn) -> void:
	# Move enemy setters into this function
	if enemy.has_method("set_player"):
		enemy.set_player(player)
	if enemy.has_method("set_speed"):
		enemy.set_speed(spawn.base_speed)
	if enemy.has_method("set_health"):
		enemy.set_health(spawn.base_health)
	if enemy.has_method("set_damage"):
		enemy.set_damage(spawn.base_damage)
			
func get_random_position() -> Vector2:
	var viewport_rect: Rect2 = get_viewport_rect()
	var random_x: float = randf_range(1.1, 1.4)
	var random_y: float = randf_range(1.1, 1.4)
	viewport_rect.size.x *= random_x
	viewport_rect.size.y *= random_y
	var top_left: Vector2 = Vector2(player.global_position.x - viewport_rect.size.x / 2, player.global_position.y - viewport_rect.size.y / 2)
	var bottom_right: Vector2 = Vector2(player.global_position.x + viewport_rect.size.x / 2, player.global_position.y + viewport_rect.size.y / 2)
	var top_right: Vector2 = Vector2(player.global_position.x + viewport_rect.size.x / 2, player.global_position.y - viewport_rect.size.y / 2)
	var bottom_left: Vector2 = Vector2(player.global_position.x - viewport_rect.size.x / 2, player.global_position.y + viewport_rect.size.y / 2)
	var random_position: Vector2 = Vector2.ZERO
	var spawn_side = ["up", "down", "left", "right"].pick_random()
	if spawn_side == "up":
		random_position = Vector2(randf_range(top_left.x, top_right.x), top_left.y)
	elif spawn_side == "down":
		random_position = Vector2(randf_range(bottom_left.x, bottom_right.x), bottom_left.y)
	elif spawn_side == "left":
		random_position = Vector2(top_left.x, randf_range(top_left.y, bottom_left.y))
	elif spawn_side == "right":
		random_position = Vector2(top_right.x, randf_range(top_right.y, bottom_right.y))
	return random_position

func is_spawn_eligible(spawn) -> bool:
	if (gm.time_of_day == gm.TimeOfDay.DAY and not spawn.spawn_day) or (gm.time_of_day == gm.TimeOfDay.NIGHT and not spawn.spawn_night):
		return false
	return true
