extends TileMapLayer

@onready var gm: Node = get_tree().root.get_node("GameManager")

# Function to check if a cell position has a border tile
func has_border_at(cell_position: Vector2i) -> bool:
	var source_id: int = get_cell_source_id(cell_position)
	return source_id != -1  # If there's any tile at this position, consider it a border
