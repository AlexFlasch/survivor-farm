extends CharacterBody2D

@export var collectible_scene: PackedScene

var animated_sprite: AnimatedSprite2D
var rng = RandomNumberGenerator.new()

enum PlantState { SEED, SPROUT, MATURE }
var state: PlantState = PlantState.SEED

func spawn_collectible():
	if collectible_scene == null:
		return
	var collectible: Node = collectible_scene.instantiate()
	add_child(collectible)

	# Spawn at a random distance and direction from the plant
	var min_distance: int = 20
	var max_distance: int = 60
	var angle             = rng.randf_range(0, TAU)
	var distance = rng.randf_range(min_distance, max_distance)
	var offset = Vector2.RIGHT.rotated(angle) * distance
	collectible.position = offset

	# Pop animation
	var pop_direction: Vector2 = Vector2(rng.randf_range(-20, 20), rng.randf_range(-50, -80))
	var target_position        = collectible.position + pop_direction
	var tween: Tween           = create_tween()
	tween.tween_property(collectible, "position", target_position, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(collectible, "position", collectible.position + Vector2(rng.randf_range(-10,10), rng.randf_range(5,10)), 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_delay(0.3)
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
	await get_tree().create_timer(20.0, false).timeout
	spawn_collectible()
	spawn_collectible_loop()

func _ready():
	animated_sprite = $AnimatedSprite2D
	set_state(PlantState.SEED)
	await get_tree().create_timer(10.0, false).timeout
	set_state(PlantState.SPROUT)
	await get_tree().create_timer(20.0, false).timeout
	set_state(PlantState.MATURE)
