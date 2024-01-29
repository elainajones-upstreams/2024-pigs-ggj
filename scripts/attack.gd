extends Object


class_name Attack

const plus = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -2), Vector2i(0, 2), Vector2i(2, 0), Vector2i(-2, 0)]
const vertical = [Vector2i(0, -5), Vector2i(0, -4), Vector2i(0, -3), Vector2i(0, -2), Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3), Vector2i(0, 4), Vector2i(0, 5)]
const horizontal = [Vector2i(-5, 0), Vector2i(-4, 0), Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0)]

const attack_shapes = [plus, vertical, horizontal]



var damage : int
var center : Vector2
var area : Array
var animation : String


func _init(dmg, cntr, ar):
	damage = dmg
	center = cntr
	area = ar
	
func copy():
	return new(damage, center, area)
	
func set_center(cnt):
	center = cnt
	
static func get_random():
	var rng = RandomNumberGenerator.new()
	var shape = attack_shapes[rng.randi_range(0, attack_shapes.size() - 1)]
	return new(randi_range(10, 15), Vector2(), shape)
	
static func draw_hand(player):
	var rng = RandomNumberGenerator.new()
	player.hand.append(get_random())
	player.hand.append(get_random())
	#if rng.randf() >= 0.0:
		#player.hand.append(get_chaos_snake())
	#else:
		#player.hand.append(get_random)
		#
#static func get_chaos_snake():
	#snake = [Vector2i(0,0)]
	#pass
	
static func do_chaos(head, body, length):
	var rng = RandomNumberGenerator.new()
	if length == 0:
		return
	var roll = rng.randf()
		
	if roll <= 0.25:
		body.append(Vector2(head.x + 1, head.y ))
		#do_chaos()
	elif roll >= 0.25 && roll <= 0.5:
		pass
	#elif roll >= 0.5 && roll <= 0.75:
		#
	#elif roll >= 0.75 && roll <= 1.0:
	#
	
	
