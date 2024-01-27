extends TileMap

enum Tile { OBSTACLE, START_POINT, END_POINT }

enum Turn_State { PLAYER_TURN, ENEMY_TURN }

signal enemy_turn
signal player_turn

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
var all_enemy_turns_finished = false
var enemies : Array[Node]
#var composite_signal = CompositeSignal.new()

func _ready():
	player.turn_end.connect(_on_player_turn_end)
	composite_signal.finished.connect(begin_player_turn)
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
	if _path.is_empty():
		return

	var last_point = _path[0]
	for index in range(1, len(_path)):
		var current_point = _path[index]
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
		queue_redraw()


func find_path(local_start_point, local_end_point, move_distance, should_draw):
	clear_path()

	_start_point = local_to_map(local_start_point)
	_end_point = local_to_map(local_end_point)
	_path = _astar.get_point_path(_start_point, _end_point)

	if not _path.is_empty():
		if move_distance > 0 && (_path.size()-1) > move_distance:
			_path.resize(move_distance + 1)
			if _path.size() >= 2:
				_end_point = local_to_map(_path[_path.size() - 1])
			
		if should_draw:
			pass
			#set_cell(0, _start_point, Tile.START_POINT, Vector2i())
			#set_cell(0, _end_point, Tile.END_POINT, Vector2i())

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
	emit_signal("enemy_turn")
	enemies = get_tree().get_nodes_in_group("Enemies")
	print("ENEMY COUNT: " + var_to_str(enemies.size()))
	#all_enemy_turns_finished = true
	for enemy in enemies:
		print("ENEMY STATE: " + var_to_str(enemy._state))
		composite_signal.add_signal(enemy.exhaust)
	await composite_signal.finished
	begin_player_turn()
		#if enemy._state != Utils.State.EXHAUSTED:
			#all_enemy_turns_finished = false
	#if all_enemy_turns_finished:
		#begin_player_turn()
		#return

func begin_player_turn():
	print("PLAYER TURN STARTING")
	_turn_state = Turn_State.PLAYER_TURN
	emit_signal("player_turn")
