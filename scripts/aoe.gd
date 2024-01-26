extends Area2D

var damage_delay_time = 0.3

var attack : Attack

#func _init(att):
	#attack = att

# Called when the node enters the scene tree for the first time.
func _ready():
	print("AOE CREATED")
	position = attack.center
	aoe()

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func aoe():
	$aoeAnimation.play("aoe")
	await get_tree().create_timer(damage_delay_time).timeout
	var targets = get_overlapping_bodies()
	for target in targets:
		target.on_hit(attack)
	queue_free()
