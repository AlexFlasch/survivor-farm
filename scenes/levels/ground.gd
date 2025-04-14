extends TileMapLayer

@onready var game_manager: Node = get_tree().root.get_node("GameManager") 

var cell_position: Vector2

func _ready() -> void:
	game_manager.set_ground(self)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_position: Vector2 = get_global_mouse_position()
		var local_position: Vector2 = map_to_local(mouse_position)
		cell_position = local_to_map(local_position)
		
func _draw() -> void:
	if cell_position:
		var rect_position: Vector2i = local_to_map(cell_position)
		var rect_size: Vector2      = Vector2(16, 16)
		draw_rect(Rect2(rect_position, rect_size), Color(1, 1, 0), false)

func _process(delta: float) -> void:
	queue_redraw()
