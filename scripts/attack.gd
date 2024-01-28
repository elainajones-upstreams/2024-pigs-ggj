extends Object


class_name Attack

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
