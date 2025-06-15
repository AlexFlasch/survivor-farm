extends CharacterBody2D

var animated_sprite: AnimatedSprite2D

func _ready():
	animated_sprite = $AnimatedSprite2D
	await get_tree().create_timer(10.0, false).timeout
	animated_sprite.play("sprout")
	await get_tree().create_timer(20.0, false).timeout
	animated_sprite.play("mature")
