extends CharacterBody2D

@export var base_speed: float = 20.0
@export var base_damage: float = 10.0
@export var base_health: float = 1.0
@export var stop_distance: float = 0.0
@export var sprite_frames: SpriteFrames = preload("res://resources/enemies/sprite_frames/pink_bat.tres")

@onready var gm: Node = get_tree().root.get_node("GameManager")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# New variables for stunned state
var is_stunned: bool = false
var stun_duration: float = 1.0  # seconds
var stun_time_left: float = 0.0

var player

func set_player(p: CharacterBody2D) -> void:
	player = p

func set_speed(new_speed: float) -> void:
	base_speed = new_speed

func set_health(new_health: float) -> void:
	base_health = new_health
	
func get_health() -> float:
	return base_health
	
func set_damage(new_damage: float) -> void:
	base_damage = new_damage

func set_sprite_frames(new_sprite_frames: SpriteFrames) -> void:
	sprite_frames = new_sprite_frames

func _ready() -> void:
	# Connect game_reset signal to despawn this enemy
	if gm != null:
		gm.connect("game_reset", Callable(self, "_on_game_reset"))

func _on_game_reset() -> void:
	queue_free()

func _process(delta: float) -> void:
	if not get_tree().root.get_node("GameManager").is_game_active():
		return
		
	if get_health() <= 0:
		queue_free()

	# Skip movement if stunned
	if is_stunned:
		stun_time_left -= delta
		if stun_time_left <= 0:
			is_stunned = false
		return
	
	if player:
		var direction: Vector2 = (player.global_position - global_position).normalized()
		var distance_to_player: float = global_position.distance_to(player.global_position)
		
		# walking (mostly) right
		# Vector2.angle() returns difference between the called vector's angle and Vector2.RIGHT (1, 0)
		if abs(direction.angle()) <= PI / 2.0:
			sprite.play('walk_right')
		else:
			sprite.play('walk_left')
		
		if distance_to_player > stop_distance:
			var collision_info: KinematicCollision2D = move_and_collide(direction * base_speed * delta)
			if collision_info:
				var collider: Object = collision_info.get_collider()
				if collider == player:
					gm.set_player_health(gm.get_player_health() - base_damage)  # Use adjustable damage
					# Apply bounce to the player based on damage value
					if player.has_method("apply_bounce") and not player.is_bouncing:
						var bounce_vector: Vector2 = (player.global_position - global_position).normalized() * base_damage
						player.apply_bounce(bounce_vector)
					stun_time_left = stun_duration
					is_stunned = true
					return
			global_position += direction * base_speed * delta
			


func _on_hit_area_area_entered(area: Area2D) -> void:
	print_debug(area)
	set_health(get_health() - 2)
