extends CharacterBody2D

@export var follow_speed: float = 150.0
@export var stop_distance: float = 10.0
var player: Node2D

func _ready() -> void:
	player = get_parent().get_node("Player")

func _process(delta: float) -> void:
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
