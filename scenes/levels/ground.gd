extends TileMapLayer

@export var grid_color : Color = Color(1, 1, 1, 1)

@onready var grid_spacing : int = get_tile_set().get_tile_size().x
var borders_layer: TileMapLayer = null

func _draw() -> void:
	var bounds: Rect2i = get_used_rect()
	for x in range(bounds.position.x, bounds.position.x + bounds.size.x + 1):
		var start: Vector2 = Vector2(x * grid_spacing, bounds.position.y * grid_spacing)
		var end: Vector2   = Vector2(x * grid_spacing, (bounds.position.y + bounds.size.y) * grid_spacing)
		draw_line(start, end, grid_color)
	for y in range(bounds.position.y, bounds.position.y + bounds.size.y + 1):
		var start: Vector2 = Vector2(bounds.position.x * grid_spacing, y * grid_spacing)
		var end: Vector2   = Vector2((bounds.position.x + bounds.size.x) * grid_spacing, y * grid_spacing)
		draw_line(start, end, grid_color)

func _process(delta: float) -> void:
	queue_redraw()

func _ready() -> void:
	# Get reference to the borders layer from GameManager
	if GameManager.get_borders():
		borders_layer = GameManager.get_borders()
	else:
		# Find the borders layer in the parent TileMap node
		var parent: Node = get_parent()
		if parent:
			for child in parent.get_children():
				if child.get_script() and child.get_script().resource_path.ends_with("borders.gd"):
					borders_layer = child
					break
