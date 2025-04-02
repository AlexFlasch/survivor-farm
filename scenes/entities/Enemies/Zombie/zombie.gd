extends CharacterBody2D

@export var follow_speed: float = 150.0
@export var stop_distance: float = 10.0
@export var bounce_distance: float = 20.0  # New variable for bounce distance

# New variables for stunned state
var is_stunned: bool = false
var stun_duration: float = 1.0  # seconds
var stun_time_left: float = 0.0

var player: Node2D

func _ready() -> void:
	player = get_parent().get_node("Player")

func _process(delta: float) -> void:
	# Skip movement if stunned
	if is_stunned:
		stun_time_left -= delta
		if stun_time_left <= 0:
			is_stunned = false
		return
	
	if not get_tree().root.get_node("GameManager").is_game_active():
		return
	
	if player:
		var direction: Vector2 = (player.global_position - global_position).normalized()
		var distance_to_player: float = global_position.distance_to(player.global_position)
		if distance_to_player > stop_distance:
			var collision_info: KinematicCollision2D = move_and_collide(direction * follow_speed * delta)
			if collision_info:
				var collider: Object = collision_info.get_collider()
				if collider == player:
					return
			global_position += direction * follow_speed * delta
