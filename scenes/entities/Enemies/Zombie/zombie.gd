extends CharacterBody2D

@export var follow_speed: float = 20.0
@export var stop_distance: float = 0.0
@export var damage: int = 10  # New editable damage value

# New variables for stunned state
var is_stunned: bool = false
var stun_duration: float = 1.0  # seconds
var stun_time_left: float = 0.0

var player: CharacterBody2D
@onready var gm: Node = get_tree().root.get_node("GameManager")

func set_player(p: CharacterBody2D) -> void:
	player = p

func _process(delta: float) -> void:
	if not get_tree().root.get_node("GameManager").is_game_active():
		return

	# Skip movement if stunned
	if is_stunned:
		stun_time_left -= delta
		if stun_time_left <= 0:
			is_stunned = false
		return
	
	if player:
		var direction: Vector2 = (player.global_position - global_position).normalized()
		var distance_to_player: float = global_position.distance_to(player.global_position)
		if distance_to_player > stop_distance:
			var collision_info: KinematicCollision2D = move_and_collide(direction * follow_speed * delta)
			if collision_info:
				var collider: Object = collision_info.get_collider()
				if collider == player:
					print("Zombie collided with player!")
					gm.set_player_health(gm.get_player_health() - damage)  # Use adjustable damage
					# Apply bounce to the player based on damage value
					if player.has_method("apply_bounce"):
						var bounce_vector: Vector2 = (player.global_position - global_position).normalized() * damage
						player.apply_bounce(bounce_vector)
					stun_time_left = stun_duration
					is_stunned = true
					return
			global_position += direction * follow_speed * delta
