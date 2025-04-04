extends PointLight2D

var gm: Node = null

func _ready() -> void:
	gm = get_tree().root.get_node("GameManager")
	if not gm == null:
		gm.connect("player_died", Callable(self, "_on_player_died"))
	
func _on_player_died() -> void:
	# set light to red with full opacity
	self.color = Color(1, 0, 0, 1)
	# fade out light over 3 seconds
	var tween: Tween = create_tween()
	tween.tween_property(self, "color", Color(1, 0, 0, 0), 3.0)
