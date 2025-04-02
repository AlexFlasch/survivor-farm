extends CharacterBody2D
@onready var screen_size: Vector2 = get_viewport_rect().size
var move_speed: int               = 7.5
var move_direction: Vector2       = Vector2.ZERO

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	var current_move_direction: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		current_move_direction += Vector2.LEFT * Input.get_action_strength("move_left")
	
	if Input.is_action_pressed("move_right"):
		current_move_direction += Vector2.RIGHT * Input.get_action_strength("move_right")
		
	if Input.is_action_pressed("move_up"):
		current_move_direction += Vector2.UP * Input.get_action_strength("move_up")
		
	if Input.is_action_pressed("move_down"):
		current_move_direction += Vector2.DOWN * Input.get_action_strength("move_down")
	
	move_direction = current_move_direction.normalized()


func _process(delta: float) -> void:
	move()


func move() -> void:
	self.global_position += move_direction * move_speed
