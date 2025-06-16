extends TileMapLayer

@export var hover_color: Color = Color(1, 1, 0, 0.5)
@export var hover_invalid_color: Color = Color(1, 0, 0, 0.5) # Red color for invalid placement
@export var terrain_set_id : int = 0
@export var terrain_id     : int = 0

@onready var grid_spacing : int = get_tile_set().get_tile_size().x
var hovered_cell: Vector2i = Vector2i(-1, -1)

# Dictionary mapping cell coordinates to the terrain (set, id) you placed there
var placed_cells: Dictionary = {}
# Dictionary mapping cell coordinates to the plant instance
var planted_cells: Dictionary = {}
var borders_layer: TileMapLayer = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var local_mouse_pos: Vector2 = get_local_mouse_position()
		hovered_cell.x = int(local_mouse_pos.x / grid_spacing)
		hovered_cell.y = int(local_mouse_pos.y / grid_spacing)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if hovered_cell.x >= 0 and hovered_cell.y >= 0:
			if is_not_border(hovered_cell):
				# Step 1: If not tilled yet, till the soil
				if not placed_cells.has(hovered_cell):
					set_cells_terrain_connect([hovered_cell], terrain_set_id, terrain_id, false)
					placed_cells[hovered_cell] = Vector2i(terrain_set_id, terrain_id)
					print("Tilled soil at ", hovered_cell)
				# Step 2: If already tilled but not planted, plant a seed
				elif not planted_cells.has(hovered_cell):
					var selected_plant_key = GameManager.selected_plant
					if GameManager.plant_scenes.has(selected_plant_key):
						var plant_scene = GameManager.plant_scenes[selected_plant_key]
						var plant = plant_scene.instantiate()
						var cell_center = map_to_local(hovered_cell) + Vector2(grid_spacing, grid_spacing) * 0.5
						plant.position = cell_center
						plant.z_index = 0
						get_parent().add_child(plant)
						planted_cells[hovered_cell] = plant
						print("Planted ", selected_plant_key, " at ", hovered_cell)
					else:
						print("Selected plant scene not found: ", selected_plant_key)
				else:
					print("Already have plant at ", hovered_cell)
			else:
				print("Cannot place tile on border at ", hovered_cell)

func is_not_border(cell: Vector2i) -> bool:
	# Check if there's a border at this position
	if borders_layer and borders_layer.get_cell_source_id(cell) < 0:
		return true
	return false

func can_plant(cell: Vector2i) -> bool:
	# Check if cell is tilled and has no plant already
	return placed_cells.has(cell) and not planted_cells.has(cell)

func _draw() -> void:
	# Only draw the hover indicator, no grid
	if hovered_cell.x >= 0 and hovered_cell.y >= 0:
		var can_place: bool = is_not_border(hovered_cell)
		var hover_col: Color = hover_color if can_place else hover_invalid_color
		var rect: Rect2 = Rect2(hovered_cell.x * grid_spacing, hovered_cell.y * grid_spacing,
		grid_spacing, grid_spacing)
		draw_rect(rect, hover_col, true)

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
