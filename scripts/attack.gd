extends Object


class_name Attack

const plus = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -2), Vector2i(0, 2), Vector2i(2, 0), Vector2i(-2, 0)]
const vertical = [Vector2i(0, -5), Vector2i(0, -4), Vector2i(0, -3), Vector2i(0, -2), Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3), Vector2i(0, 4), Vector2i(0, 5)]

var attack_shapes = [plus, vertical]

var rng = RandomNumberGenerator.new()

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
	
func get_random():
	var shape = attack_shapes[rng.randi_range(0, attack_shapes.size() - 1)]
	return new(randi_range(5, 25), Vector2(), shape)
