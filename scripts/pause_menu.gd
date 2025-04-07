extends Control

var game_manager: Node = null

func _ready() -> void:
	hide()
	game_manager = get_tree().root.get_node("GameManager")
	# Connect signals from GameManager
	game_manager.connect("game_paused", Callable(self, "_on_pause"))
	game_manager.connect("game_unpaused", Callable(self, "_on_resume"))

func _on_resume():
	hide()
	game_manager.unpause_game()
	$AnimationPlayer.play_backwards("blur")
	
func _on_pause():
	show()
	$AnimationPlayer.play("blur")
	

func _on_resume_pressed() -> void:
	_on_resume()
	

func _on_options_pressed() -> void:
	pass # Replace with function body.
	
	
func _on_main_menu_pressed() -> void:
	hide()
	game_manager.unpause_game()
	get_tree().change_scene_to_file("res://scenes/levels/MainMenu.tscn")
