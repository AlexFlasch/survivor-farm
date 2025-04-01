extends Node

signal health_changed(health:int)

var player_health: int = 100

func _set_player_health(new_health: int) -> void:
	player_health = new_health
	emit_signal("health_changed", player_health)