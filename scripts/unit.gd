extends CharacterBody2D

@onready var _animated_sprite = $sprite
@export var max_health: int = 3
var current_health: int

func _ready():
	_animated_sprite.play("idle")
	current_health = max_health
