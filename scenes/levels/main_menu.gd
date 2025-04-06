extends Control

var game_manager: Node = null

func _ready() -> void:
	game_manager = get_tree().root.get_node("GameManager")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/World.tscn")

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()
