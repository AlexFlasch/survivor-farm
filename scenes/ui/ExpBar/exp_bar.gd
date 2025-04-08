class_name ExpBar extends NinePatchRect

@export var show_value: bool = true
@export var current_value: int = 0
@export var max_value: int = 100
@export var percentage: float = 0.0
@export var bar_material: ShaderMaterial = preload("res://resources/materials/ProgressBar.material")

@onready var progress_rect :TextureRect = %ProgressBar
@onready var value_label :Label = %ValueLabel

func _ready() -> void:
	if not show_value:
		value_label.hide()

func _process(delta: float) -> void:
	if progress_rect != null:
		progress_rect.material = bar_material
		progress_rect.material.set('shader_parameter/progress', percentage)
	
	if value_label != null:
		value_label.text = '%s/%s' % [current_value, max_value]
