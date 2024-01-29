extends Area2D

var damage_delay_time = 0.3
var linger_time = 2

var attack : Attack

#func _init(att):
	#attack = att

# Called when the node enters the scene tree for the first time.
func _ready():
	#position = attack.center
	aoe()

func _process(delta):
	pass

func aoe():
	$aoeAnimation.play(attack.animation)
	await get_tree().create_timer(damage_delay_time).timeout
	var targets = get_overlapping_bodies()
	for target in targets:
		target.on_hit(attack)
	var target_areas = get_overlapping_areas()
	for target_area in target_areas:
		target_area.on_hit(attack)
	await get_tree().create_timer(linger_time).timeout
	queue_free()
