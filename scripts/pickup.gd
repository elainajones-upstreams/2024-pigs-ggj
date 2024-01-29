extends Node

class_name Pickup

var energy : int
var hit_dmg : int
var animation : String
#var attack : Attack

func _init(eng, hd, an):
	energy = eng
	#attack = atk
	hit_dmg = hd
	animation = an
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
