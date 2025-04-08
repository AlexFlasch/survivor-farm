class_name ExpBar extends NinePatchRect

@export var show_value: bool = true
@export var current_value: int = 0
@export var max_value: int = 100
@export var percentage: float = 0.0
@export var bar_material: ShaderMaterial = preload("res://resources/materials/ProgressBar.material") as ShaderMaterial

@onready var progress_rect :TextureRect = %ProgressBar
@onready var value_label :Label = %ValueLabel
@onready var gm: Node = get_tree().root.get_node("GameManager")

func _ready() -> void:
	if not gm == null:
		current_value = gm.get_player_health()
		gm.connect("health_changed", Callable(self, "_on_health_changed"))
		gm.connect("max_health_changed", Callable(self, "_on_max_health_changed"))
	if not show_value:
		value_label.hide()

func _process(delta: float) -> void:
	if progress_rect != null:
		progress_rect.material = bar_material
		progress_rect.material.set('shader_parameter/progress', percentage)
	
	if value_label != null:
		value_label.text = '%s/%s' % [current_value, max_value]

func _on_health_changed(health: int) -> void:
	current_value = health

func _on_max_health_changed(new_max: int) -> void:
	max_value = new_max
