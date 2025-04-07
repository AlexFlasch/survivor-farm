class_name PlayerHud extends PanelContainer

@export var player_health_percentage: float = 100.0
@export var player_level: int = 1
@export var player_exp_percentage: float = 100.0

@onready var health_bar: ExpBar = %HealthBar
@onready var level_label: Label = %PlayerLevel
@onready var exp_bar: ExpBar = %ExpBar

func _process(delta: float) -> void:
	if health_bar != null:
		health_bar.percentage = player_health_percentage
	
	if level_label != null:
		level_label.text = str(player_level)
	
	if exp_bar != null:
		exp_bar.percentage = player_exp_percentage
