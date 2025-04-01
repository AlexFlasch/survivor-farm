extends CharacterBody2D

func _ready() -> void:
	GameManager.connect("game_started", Callable(self, "_on_game_started"))

func _on_game_started() -> void:
	print("hello, world!")
