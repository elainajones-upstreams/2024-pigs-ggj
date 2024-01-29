extends Area2D

#var damage_delay_time = 0.3
#var linger_time = 2

@onready var player = $"../../Character"

var pickup : Pickup

#func _init(att):
	#attack = att

# Called when the node enters the scene tree for the first time.
func _ready():
	print("ITEM CREATED")
	$item_animation.play(pickup.animation)
	monitoring = true
	await body_entered
	picked_up()

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func picked_up():
	print("PICKED GORBO")
	$item_animation.play(pickup.animation)
	var targets = get_overlapping_bodies()
	for target in targets:
		target.on_pickup(pickup)
	queue_free()
	
func on_hit(atk):
	print("GORBO HIT")
	if pickup.hit_dmg > 0:
		player.on_pickup(pickup)
		queue_free()
