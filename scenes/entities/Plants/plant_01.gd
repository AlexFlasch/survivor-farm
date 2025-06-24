extends CharacterBody2D

@export var collectible_scene: PackedScene

@export var min_collectible_distance: int = 20
@export var max_collectible_distance: int = 60
@export var pop_direction_x_range: Vector2 = Vector2(-20, 20)
@export var pop_direction_y_range: Vector2 = Vector2(-50, -80)
@export var pop_bounce_x_range: Vector2 = Vector2(-10, 10)
@export var pop_bounce_y_range: Vector2 = Vector2(5, 10)

var animated_sprite: AnimatedSprite2D
var rng = RandomNumberGenerator.new()

enum PlantState { SEED, SPROUT, MATURE }
var state: PlantState = PlantState.SEED

func spawn_collectible() -> void:
	if collectible_scene == null:
		return
	var collectible: Node2D = collectible_scene.instantiate() as Node2D
	add_child(collectible)

	# Spawn at a random distance and direction from the plant
	var angle = rng.randf_range(0, TAU)
	var distance = rng.randf_range(min_collectible_distance, max_collectible_distance)
	var offset = Vector2.RIGHT.rotated(angle) * distance
	collectible.position = offset

	# Pop animation
	var pop_direction: Vector2   = Vector2(rng.randf_range(pop_direction_x_range.x, pop_direction_x_range.y), rng.randf_range(pop_direction_y_range.x, pop_direction_y_range.y))
	var target_position: Vector2 = collectible.position + pop_direction
	var tween: Tween             = create_tween()
	tween.tween_property(collectible, "position", target_position, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(collectible, "position", collectible.position + Vector2(rng.randf_range(pop_bounce_x_range.x, pop_bounce_x_range.y), rng.randf_range(pop_bounce_y_range.x, pop_bounce_y_range.y)), 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_delay(0.3)
	collectible.scale = Vector2.ZERO
	tween.parallel().tween_property(collectible, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func set_state(new_state: PlantState) -> void:
	if state == new_state:
		return
	state = new_state
	match state:
		PlantState.SEED:
			animated_sprite.play("seed")
		PlantState.SPROUT:
			animated_sprite.play("sprout")
		PlantState.MATURE:
			animated_sprite.play("mature")
			spawn_collectible()
			spawn_collectible_loop()

func spawn_collectible_loop() -> void:
	# Spawns a collectible every 20 seconds indefinitely
	while true:
		await get_tree().create_timer(20.0, false).timeout
		spawn_collectible()

func _ready():
	animated_sprite = $AnimatedSprite2D
	set_state(PlantState.SEED)
	await get_tree().create_timer(10.0, false).timeout
	set_state(PlantState.SPROUT)
	await get_tree().create_timer(20.0, false).timeout
	set_state(PlantState.MATURE)
