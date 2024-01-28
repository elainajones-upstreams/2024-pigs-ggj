extends Node
class_name Utils

enum State { IDLE, FOLLOW, DYING, ATTACKING, EXHAUSTED, NOT_MY_TURN }
	
#var x_distance : int
#var y_distance : int

static func is_adjacent(pos1, pos2, tile_map):
	var x_distance = abs(tile_map.local_to_map(pos1).x - tile_map.local_to_map(pos2).x)
	var y_distance = abs(tile_map.local_to_map(pos1).y - tile_map.local_to_map(pos2).y)
	if x_distance + y_distance <= 1:
		return true
