extends Object


class_name Attack

const plus = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -2), Vector2i(0, 2), Vector2i(2, 0), Vector2i(-2, 0)]
const vertical = [Vector2i(0, -5), Vector2i(0, -4), Vector2i(0, -3), Vector2i(0, -2), Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3), Vector2i(0, 4), Vector2i(0, 5)]
const horizontal = [Vector2i(-5, 0), Vector2i(-4, 0), Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0)]

const attack_shapes = {"Plus": plus, "Vertical": vertical, "Horizontal": horizontal}

var damage : int
var center : Vector2
var area : Array
var animation : String
var name: String


func _init(dmg, cntr, ar, nm):
	damage = dmg
	center = cntr
	area = ar
	name = nm
	
func copy():
	return new(damage, center, area, name)
	
func set_center(cnt):
	center = cnt
	
static func get_random():
	var rng = RandomNumberGenerator.new()
	var atkName = attack_shapes.keys()[rng.randi_range(0, attack_shapes.size() - 1)]
	var shape = attack_shapes.get(atkName)
	var roll = randi_range(10, 15)
	return new(roll, Vector2(), shape, atkName + " " + var_to_str(roll) )
	
static func draw_hand(player):
	var rng = RandomNumberGenerator.new()
	print("ATTACKGEN GENERATIN PLAYER HAND")
	player.hand.append(get_random())
	player.hand.append(get_random())
	if rng.randf() >= 0.0:
		player.hand.append(get_chaos_snake())
	else:
		player.hand.append(get_random)
	print("ATTACKGEN NEW PLAYER HAND " + var_to_str(player.hand))
	print("ATTACKGEN NEW PLAYER HAND SIZE " + var_to_str(player.hand.size()))
		
static func get_chaos_snake():
	var snake = [Vector2i(0,0)]
	return new(randi_range(20, 25), Vector2i(), do_chaos(snake[0], snake, 25), "CHAOS SNAKE")
	
static func do_chaos(head, body, length):
	var rng = RandomNumberGenerator.new()
	print("ATTACKGEN SNAKE CALL " + var_to_str(body))
	if length == 0:
		return body
	var roll = rng.randf()
	print("ATTACKGEN SNAKE ROLL " + var_to_str(roll))
	if roll <= 0.25:
		body.append(Vector2i(head.x + 1, head.y ))
		do_chaos(body[body.size() - 1], body, (length - 1))
	elif roll >= 0.25 && roll <= 0.5:
		body.append(Vector2i(head.x - 1, head.y ))
		do_chaos(body[body.size() - 1], body, (length - 1))
	elif roll >= 0.5 && roll <= 0.75:
		body.append(Vector2i(head.x, head.y + 1))
		do_chaos(body[body.size() - 1], body, (length - 1))
	elif roll >= 0.75 && roll <= 1.0:
		body.append(Vector2i(head.x + 1, head.y - 1))
		do_chaos(body[body.size() - 1], body, (length - 1))
	return body
	
	
