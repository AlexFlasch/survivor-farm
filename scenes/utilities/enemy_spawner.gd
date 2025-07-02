extends Node2D

# Array of EnemyData objects that define the spawn parameters for each enemy type.
@export var spawns: Array[EnemyData] = []

# Reference to the player node, retrieved from the GameManager node.
@onready var player: Node2D = get_tree().root.get_node("GameManager").player
# Reference to the GameManager node, which manages game state and player health.
@onready var gm: Node = get_tree().root.get_node("GameManager")

var all_enemy_sprites = ResourceLoader.list_directory('res://resources/enemies/sprite_frames')
var time: int = 0

func _ready() -> void:
	gm.connect('time_of_day_changed', Callable(self, '_on_time_of_day_changed'))
	gm.connect('game_reset', Callable(self, '_on_game_reset'))  # Added game_reset connection

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
					if (time == 50):
						enemy.apply_scale((Vector2(5,5)))
						enemy.set_damage(30)
						enemy.set_health(25)
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
	if enemy.has_method("set_sprite_frames"):
		enemy.set_sprite_frames(spawn.sprite_frames)
			
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

func _on_time_of_day_changed() -> void:
	var random_sprite_index: int = randi_range(0, all_enemy_sprites.size() - 1)
	var random_sprite: SpriteFrames = all_enemy_sprites[random_sprite_index]
	
	spawns = spawns.map(func (spawn): spawn.sprite_frames = random_sprite)

func _on_game_reset() -> void:
	time = 0  # Reset the timer
	for spawn in spawns:
		spawn.spawn_delay_counter = 0
