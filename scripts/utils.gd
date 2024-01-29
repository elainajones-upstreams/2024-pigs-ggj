extends Node
class_name Utils

enum State { IDLE, FOLLOW, DYING, ATTACKING, EXHAUSTED, NOT_MY_TURN }

#var x_distance : int
#var y_distance : int

static func is_adjacent(pos1, pos2, tile_map):
	print("ADJACENCY TIME! ")
	var x_distance = abs(tile_map.local_to_map(pos1).x - tile_map.local_to_map(pos2).x)
	var y_distance = abs(tile_map.local_to_map(pos1).y - tile_map.local_to_map(pos2).y)
	print("X DISTANCE " + var_to_str(x_distance))
	print("Y DISTANCE " + var_to_str(y_distance))
	if x_distance + y_distance <= 1:
		print("DISTANCE: ADjacent")
		return true
	return false



