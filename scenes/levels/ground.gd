extends TileMapLayer

@export var grid_color : Color = Color(1, 1, 1, 1)
@export var hover_color: Color = Color(1, 1, 0, 0.5)
@export var terrain_set_id : int = 0
@export var terrain_id     : int = 0

@onready var grid_spacing : int = get_tile_set().get_tile_size().x
var hovered_cell: Vector2i = Vector2i(-1, -1)

# Dictionary mapping cell coordinates to the terrain (set, id) you placed there
var placed_cells: Dictionary = {}

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var local_mouse_pos: Vector2 = get_local_mouse_position()
		hovered_cell.x = int(local_mouse_pos.x / grid_spacing)
		hovered_cell.y = int(local_mouse_pos.y / grid_spacing)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if hovered_cell.x >= 0 and hovered_cell.y >= 0:
			# only place if we haven’t placed here yet
			if not placed_cells.has(hovered_cell):
				set_cells_terrain_connect([hovered_cell], terrain_set_id, terrain_id, false)
				placed_cells[hovered_cell] = Vector2i(terrain_set_id, terrain_id)
			else:
				print("Already have terrain at ", hovered_cell)

func _draw() -> void:
	var bounds: Rect2i = get_used_rect()
	for x in range(bounds.position.x, bounds.position.x + bounds.size.x + 1):
		var start = Vector2(x * grid_spacing, bounds.position.y * grid_spacing)
		var end   = Vector2(x * grid_spacing, (bounds.position.y + bounds.size.y) * grid_spacing)
		draw_line(start, end, grid_color)
	for y in range(bounds.position.y, bounds.position.y + bounds.size.y + 1):
		var start = Vector2(bounds.position.x * grid_spacing, y * grid_spacing)
		var end   = Vector2((bounds.position.x + bounds.size.x) * grid_spacing, y * grid_spacing)
		draw_line(start, end, grid_color)
	if hovered_cell.x >= 0 and hovered_cell.y >= 0:
		var rect = Rect2(hovered_cell.x * grid_spacing, hovered_cell.y * grid_spacing,
		grid_spacing, grid_spacing)
		draw_rect(rect, hover_color, true)

func _process(delta: float) -> void:
	queue_redraw()

func _ready() -> void:
	return