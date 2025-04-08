class_name PlayerHud extends PanelContainer

@export var player_level: int = 1
@export var player_exp_percentage: float = 100.0

@onready var health_bar: ExpBar = %HealthBar
@onready var level_label: Label = %PlayerLevel
@onready var exp_bar: ExpBar = %ExpBar
@onready var gm: Node = get_tree().root.get_node("GameManager")

func _ready() -> void:
	if not gm == null:
		var player_health = gm.get_player_health()

func _process(delta: float) -> void:
	if health_bar != null:
		health_bar.current_value = gm.get_player_health()
		health_bar.max_value = gm.get_player_max_health()
	
	if level_label != null:
		level_label.text = str(player_level)
