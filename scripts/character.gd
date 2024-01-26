extends Node2D

enum State { IDLE, FOLLOW }

const MASS = 5.0
const ARRIVE_DISTANCE = 10.0
const Attack = preload("res://scripts/attack.gd")


@export var speed: float = 200.0

var _state = State.IDLE
var _velocity = Vector2()

@onready var _tile_map = $"../TileMap"
@onready var animated_sprite = $charactersprite

var _click_position = Vector2()
var _path = PackedVector2Array()
var _next_point = Vector2()


func _ready():
	_change_state(State.IDLE)
	animated_sprite.animation_finished.connect(_return_to_idle)
	animated_sprite.play("idle")


func _process(_delta):
	if _state != State.FOLLOW:
		return
	var arrived_to_next_point = _move_to(_next_point)
	if arrived_to_next_point:
		_path.remove_at(0)
		if _path.is_empty():
			_change_state(State.IDLE)
			return
		_next_point = _path[0]


func _unhandled_input(event):
	_click_position = get_global_mouse_position()
	if _tile_map.is_point_walkable(_click_position):
		#if event.is_action_pressed(&"teleport_to", false, true):
			#_change_state(State.IDLE)
			#global_position = _tile_map.round_local_position(_click_position)
		if event.is_action_pressed(&"move_to"):
			_change_state(State.FOLLOW)
		elif event.is_action_pressed(&"attack"):
			_attack(_click_position)


func _move_to(local_position):
	var desired_velocity = (local_position - position).normalized() * speed
	var steering = desired_velocity - _velocity
	_velocity += steering / MASS
	
	position += _velocity * get_process_delta_time()
	#rotation = _velocity.angle()
	if Vector2.UP.angle() < _velocity.angle() && _velocity.angle() < Vector2.DOWN.angle():
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false
	
	return position.distance_to(local_position) < ARRIVE_DISTANCE


func _change_state(new_state):
	if new_state == State.IDLE:
		_tile_map.clear_path()
		animated_sprite.play("idle")
		_tile_map.emit_signal("turn_end")
	elif new_state == State.FOLLOW:
		_path = _tile_map.find_path(position, _click_position)
		animated_sprite.play("idle")
		if _path.size() < 2:
			_change_state(State.IDLE)
			return
		# The index 0 is the starting cell.
		# We don't want the character to move back to it in this example.
		_next_point = _path[1]
	_state = new_state
	
func _attack(click_position):
	animated_sprite.play("player_attack")
	_tile_map.execute_attack(Attack.new(10, _tile_map.get_tile_center(click_position)))
	
func _return_to_idle():
	animated_sprite.play("idle")

	

