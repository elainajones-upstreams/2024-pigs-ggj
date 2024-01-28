extends TileMap

enum Tile { OBSTACLE, START_POINT, END_POINT }

enum Turn_State { PLAYER_TURN, ENEMY_TURN }

signal enemy_turn
signal player_turn
signal enemy_pathing_calculated

const CELL_SIZE = Vector2(64, 64)
const BASE_LINE_WIDTH = 1.5
const DRAW_COLOR = Color.WHITE
const AOE = preload("res://scenes/aoe.tscn")
const Utils = preload("res://scripts/utils.gd")
const CompositeSignal = preload("res://scripts/compositesignal.gd")


@onready var player = $"../Character"
@onready var composite_signal = $"../CompositeSignal"

var _turn_state = Turn_State.PLAYER_TURN

# The object for pathfinding on 2D grids.
var _astar = AStarGrid2D.new()

var _start_point = Vector2i()
var _end_point = Vector2i()
var _path = PackedVector2Array()
var _all_paths : Array[PackedVector2Array]
var enemy_path = PackedVector2Array()
var blocked_points = PackedVector2Array()
var all_enemy_turns_finished = false
var enemies : Array[Node]
#var composite_signal = CompositeSignal.new()

func _ready():
	enemies = get_tree().get_nodes_in_group("Enemies")
	player.turn_end.connect(_on_player_turn_end)
	#composite_signal.finished.connect(begin_player_turn)
	_astar.region = get_used_rect()
	_astar.cell_size = CELL_SIZE
	_astar.offset = CELL_SIZE * 0.5
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()

	for i in range(_astar.region.position.x, _astar.region.end.x):
		for j in range(_astar.region.position.y, _astar.region.end.y):
			var pos = Vector2i(i, j)
			if get_cell_source_id(0, pos) == Tile.OBSTACLE:
				_astar.set_point_solid(pos)


func _draw():
	if _all_paths.size() == 0:
		return
	
	for path in _all_paths:
		var last_point = path[0]
		for index in range(1, len(path)):
			var current_point = path[index]
			draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
			draw_circle(current_point, BASE_LINE_WIDTH * 2.0, DRAW_COLOR)
			last_point = current_point


func round_local_position(local_position):
	return map_to_local(local_to_map(local_position))


func is_point_walkable(local_position):
	var map_position = local_to_map(local_position)
	if _astar.is_in_boundsv(map_position):
		return not _astar.is_point_solid(map_position)
	return false


func clear_path():
	if not _path.is_empty():
		_path.clear()
		#erase_cell(0, _start_point)
		#erase_cell(0, _end_point)
		# Queue redraw to clear the lines and circles.
		path.clear()
		queue_redraw()

func find_and_add_path(local_start_point, local_end_point, move_distance, should_draw):
	find_path(local_start_point, local_end_point, move_distance, should_draw)

func find_path(local_start_point, local_end_point, move_distance, should_draw):

	_start_point = local_to_map(local_start_point)
	_end_point = local_to_map(local_end_point)
	print("STAART POINT " + var_to_str(local_start_point))
	print("END POINT " + var_to_str(local_end_point))
	_path = _astar.get_point_path(_start_point, _end_point)
	print("PATH_LENGTH " + var_to_str(_path))

	if not _path.is_empty():
		if move_distance > 0 && (_path.size()-1) > move_distance:
			_path.resize(move_distance + 1)
			if _path.size() >= 2:
				_end_point = local_to_map(_path[_path.size() - 1])
			
		if should_draw:
			pass
			#set_cell(0, _start_point, Tile.START_POINT, Vector2i())
			#set_cell(0, _end_point, Tile.END_POINT, Vector2i())

	_all_paths.append(_path)
	# Redraw the lines and circles from the start to the end point.
	if should_draw:
		queue_redraw()

	return _path.duplicate()

func execute_attack(attack):
	#var targetTile = get_cell_atlas_coords(1, local_to_map(attack.center))
	var aoe_instance = AOE.instantiate()
	aoe_instance.attack = attack
	add_child(aoe_instance)
	
func get_tile_center(vector):
	return map_to_local(local_to_map(vector))
	
func _on_player_turn_end():
	_turn_state = Turn_State.ENEMY_TURN
	play_enemy_turn()

func play_enemy_turn():
	
	print("ENEMY COUNT: " + var_to_str(enemies.size()))
	#all_enemy_turns_finished = true
	for enemy in enemies:
		enemy.prepare_for_pathing()
	#await composite_signal.finished
	calculate_enemy_pathing(enemies)
	for enemy in enemies:
		print("ENEMY STATE: " + var_to_str(enemy._state))
		composite_signal.add_signal(enemy.exhaust)
	emit_signal("enemy_turn")
	await composite_signal.finished
	clear_all_paths()
	begin_player_turn()
		#if enemy._state != Utils.State.EXHAUSTED:
			#all_enemy_turns_finished = false
	#if all_enemy_turns_finished:s
		#begin_player_turn()
		#return

func begin_player_turn():
	print("PLAYER TURN STARTING")
	for enemy in enemies:
		enemy._state = Utils.State.NOT_MY_TURN
	_turn_state = Turn_State.PLAYER_TURN
	emit_signal("player_turn")
	
func calculate_enemy_pathing(enemies):
	#_astar.set_point_solid(local_to_map(player.position))
	#blocked_points.append(local_to_map(player.position))
	#_path = _tile_map.find_path(position, player.position, enemy_move_distance, true)
	for enemy in enemies:
		if enemy.needs_pathing:
			enemy_path = find_path(enemy.position, enemy.target, enemy.enemy_move_distance, true)
			prune_path(enemy_path)
			enemy._path = enemy_path
			if enemy_path.size() == 0:
				enemy.cant_move == true
			#_astar.set_point_solid(enemy_path[enemy_path.size() - 1])
			#blocked_points.append(enemy_path[enemy_path.size() - 1])
	#for point in blocked_points:
		#_astar.set_point_solid(point, false)
	#blocked_points.resize(0)
	#emit_signal("enemy_pathing_calculated")
	

func prune_path(path):
	print("POSITION " + var_to_str(local_to_map(player.position)))
	print("PATH " + var_to_str(path[path.size() - 1]))
	if path.size() == 0:
		return
	if local_to_map(path[path.size() - 1]) == local_to_map(player.position):
		path.resize(path.size() - 1)
		prune_path(path)
	for other_path in _all_paths:
		if other_path != path && path[path.size() - 1] == other_path[other_path.size() - 1]:
			path.resize(path.size() - 1)
			prune_path(path)
	for enemy in enemies:
		if enemy.needs_pathing == false:
			if local_to_map(path[path.size() - 1]) == local_to_map(enemy.position):
				path.resize(path.size() - 1)
				prune_path(path)
	
