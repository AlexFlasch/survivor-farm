extends CharacterBody2D

var sprite: Sprite2D
var collision_shape: CollisionShape2D

func _ready():
	sprite = $Sprite2D
	collision_shape = $CollisionShape2D
