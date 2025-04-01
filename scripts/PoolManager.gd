extends Node

var pools: Dictionary = {}
var scenes: Dictionary = {}

func register_pool(pool_name: String, pool_size: int, scene_path: PackedScene) -> void:
	if pool_name in pools:
		print("Pool already registered: ", pool_name)
		return
	var pool: Array = []
	for i in range(pool_size):
		var instance: Node = scene_path.instantiate()
		instance.visible = false
		pool.append(instance)
		add_child(instance)
	pools[pool_name] = pool
	scenes[pool_name] = scene_path

func _ready() -> void:
	pass
