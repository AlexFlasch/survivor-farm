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
	
func get_from_pool(pool_name: String) -> Node:
	if not pool_name in pools:
		print("Pool not found: ", pool_name)
		return null
	var pool: Array = pools[pool_name]
	for instance in pool:
		if not instance.visible:
			instance.visible = true
			return instance
	print("No available instances in pool: ", pool_name)
	return null

func return_to_pool(instance: Node) -> void:
	if instance == null:
		print("Instance is null, cannot return to pool.")
		return
	for pool_name in pools.keys():
		var pool: Array = pools[pool_name]
		if instance in pool:
			instance.visible = false
			return
	print("Instance not found in any pool: ", instance)

func _ready() -> void:
	pass
