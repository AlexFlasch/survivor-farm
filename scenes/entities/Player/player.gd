extends CharacterBody2D

enum DIRECTION { LEFT, RIGHT, UP, DOWN }

@onready var screen_size: Vector2     = get_viewport_rect().size
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var move_speed: int                   = 100
var move_vector: Vector2              = Vector2.ZERO
var move_direction: DIRECTION         = DIRECTION.DOWN

# New bounce variables
var bounce_velocity: Vector2 = Vector2.ZERO
var is_bouncing: bool = false
var bounce_timer: float = 0.0
const BOUNCE_DURATION: float = 0.2

var gm: Node = null

func _ready() -> void:
	gm = get_tree().root.get_node("GameManager")
	if not gm == null:
		gm.set_player(self)
		gm.connect("health_changed", Callable(self, "_on_health_changed"))

func _physics_process(delta: float) -> void:
	# If bouncing, override normal input movement
	if is_bouncing:
		self.velocity = bounce_velocity
		self.move_and_slide()
		bounce_timer -= delta
		bounce_velocity = bounce_velocity.slerp(Vector2.ZERO, delta * 5)
		if bounce_timer <= 0:
			is_bouncing = false
			bounce_velocity = Vector2.ZERO
		return
	
	# ...existing input processing code...
	var current_move_vector: Vector2 = Vector2.ZERO
	
	if not get_tree().root.get_node("GameManager").is_game_active():
		return
	
	if Input.is_action_pressed("move_left"):
		move_direction = DIRECTION.LEFT
		current_move_vector += Vector2.LEFT * Input.get_action_strength("move_left")
	
	if Input.is_action_pressed("move_right"):
		move_direction = DIRECTION.RIGHT
		current_move_vector += Vector2.RIGHT * Input.get_action_strength("move_right")
		
	if Input.is_action_pressed("move_up"):
		move_direction = DIRECTION.UP
		current_move_vector += Vector2.UP * Input.get_action_strength("move_up")
		
	if Input.is_action_pressed("move_down"):
		move_direction = DIRECTION.DOWN
		current_move_vector += Vector2.DOWN * Input.get_action_strength("move_down")
	
	if current_move_vector != Vector2.ZERO:
		move_vector = current_move_vector / current_move_vector.length()
	else:
		move_vector = Vector2.ZERO
	
	# Use the normal move
	self.velocity = move_vector * move_speed
	self.move_and_slide()

func _process(delta: float) -> void:
	if not get_tree().root.get_node("GameManager").is_game_active():
		return

	if move_vector == Vector2.ZERO:
		idle()
	else:
		move()


func idle() -> void:
	match move_direction:
		DIRECTION.UP:
			sprite.play('idle_up')
		DIRECTION.DOWN:
			sprite.play('idle_down')
		DIRECTION.LEFT:
			sprite.play('idle_left')
		DIRECTION.RIGHT:
			sprite.play('idle_right')


func move() -> void:
	match move_direction:
		DIRECTION.UP:
			sprite.play('walk_up')
		DIRECTION.DOWN:
			sprite.play('walk_down')
		DIRECTION.LEFT:
			sprite.play('walk_left')
		DIRECTION.RIGHT:
			sprite.play('walk_right')
	
	self.velocity = move_vector * move_speed
	self.move_and_slide()


func die() -> void:
	sprite.play("die")
	if not gm == null:
		gm.handle_player_death() 

func _on_health_changed(health: int) -> void:
	print("Player notified: Health changed to %d" % health)
	if health <= 0:
		die()

# New method to initiate bounce
func apply_bounce(bounce_force: Vector2) -> void:
	bounce_velocity = bounce_force
	is_bouncing = true
	bounce_timer = BOUNCE_DURATION
