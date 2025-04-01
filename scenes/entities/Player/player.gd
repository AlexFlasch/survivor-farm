extends CharacterBody2D
@onready var screen_size: Vector2 = get_viewport_rect().size
var move_speed: int               = 300

func _ready() -> void:
	GameManager.connect("game_started", Callable(self, "_on_game_started"))
	GameManager.start_game()

func _on_game_started() -> void:
	# Calculate target position at right edge and tween movement
	var target_x: float = screen_size.x
	var distance: float = target_x - position.x
	var duration: float = distance / move_speed if distance > 0 else 0.0
	var tween: Tween    = create_tween()
	tween.tween_property(self, "position:x", target_x, duration)
	tween.connect("finished", Callable(self, "_on_tween_finished"))

func _on_tween_finished() -> void:
	if position.x >= screen_size.x:
		GameManager.stop_game()
