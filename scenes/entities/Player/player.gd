extends CharacterBody2D

enum DIRECTION { LEFT, RIGHT, UP, DOWN }

@onready var screen_size: Vector2     = get_viewport_rect().size
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var move_speed: int                   = 100
var move_vector: Vector2              = Vector2.ZERO
var move_direction: DIRECTION         = DIRECTION.DOWN

var bounce_velocity: Vector2 = Vector2.ZERO
var is_bouncing: bool = false
var bounce_timer: float = 0.0
const BOUNCE_DURATION: float = 0.2

@onready var gm: Node = get_tree().root.get_node("GameManager")

var original_position: Vector2

#Attacks
var magicProjectile = preload("res://scenes/entities/Player/Attack/magic_projectile.tscn")

#AttackNodes
@onready var magicProjectileTimer = get_node("%MagicProjectileTimer")
@onready var magicProjectileAttackTimer = get_node("%MagicProjectileAttackTimer")

#MagicProjectile
var magic_projectile_ammo = 0
var magic_projectile_base_ammo = 1
var magic_projectile_attack_speed = 1.5
var magic_projectile_level = 1

#Enemy Related
var enemy_close = []

func _ready() -> void:
	if not gm == null:
		gm.set_player(self)
		gm.connect("health_changed", Callable(self, "_on_health_changed"))
		gm.connect("game_reset", Callable(self, "_on_game_reset"))
	original_position = global_position

func _physics_process(delta: float) -> void:
	if not get_tree().root.get_node("GameManager").is_game_active():
		return

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
	
	var current_move_vector: Vector2 = Vector2.ZERO
	
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
	if health <= 0:
		die()

func apply_bounce(bounce_force: Vector2) -> void:
	bounce_velocity = bounce_force
	is_bouncing = true
	bounce_timer = BOUNCE_DURATION

func _on_game_reset() -> void:
	idle()

func reset_position() -> void:
	global_position = original_position  # reset player to original location
	
func attack() -> void:
	if (magic_projectile_level > 0):
		magicProjectileTimer.wait_time = magic_projectile_attack_speed
		if magicProjectileTimer.is_stopped():
			magicProjectileTimer.start()


func _on_magic_projectile_timer_timeout() -> void:
	magic_projectile_ammo += magic_projectile_base_ammo
	magicProjectileAttackTimer.start()


func _on_magic_projectile_attack_timer_timeout() -> void:
	if (magic_projectile_ammo > 0):
		var magic_projectile_attack = magicProjectile.instantiate()
		magic_projectile_attack.position = get_parent().position
		magic_projectile_attack.target = get_random_target()
		magic_projectile_attack.level = magic_projectile_level
		add_child(magic_projectile_attack)
		magic_projectile_ammo -= 1
		if (magic_projectile_ammo > 0):
			magicProjectileAttackTimer.start()
			# clear projectile of player as parent
			var new_parent = get_parent().get_parent()
			get_parent().remove_child(magic_projectile_attack)
			new_parent.add_child(magic_projectile_attack)
		else:
			magicProjectileAttackTimer.stop()
				
		
func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP



func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	attack() # todo clear this
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)
