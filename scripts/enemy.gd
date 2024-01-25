extends Marker2D

enum State { IDLE, FOLLOW }

const MASS = 5.0
const ARRIVE_DISTANCE = 10.0

@export var speed: float = 200.0

var _state = State.IDLE
var _velocity = Vector2()

@onready var _tile_map = $"../TileMap"
@onready var player = $"../Character"
@onready var baddie_sprite = $baddiesprite
@onready var move_sprite = $movingbaddie

var _path = PackedVector2Array()
var _next_point = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	_tile_map.turn_end.connect(_on_turn_end)
	_change_state(State.IDLE)
	baddie_sprite.show()
	move_sprite.hide()

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

func _move_to(local_position):
	var desired_velocity = (local_position - position).normalized() * speed
	var steering = desired_velocity - _velocity
	_velocity += steering / MASS
	
	position += _velocity * get_process_delta_time()
	#rotation = _velocity.angle()
	if Vector2.UP.angle() < _velocity.angle() && _velocity.angle() < Vector2.DOWN.angle():
		move_sprite.flip_h = false
	else:
		move_sprite.flip_h = true
	
	return position.distance_to(local_position) < ARRIVE_DISTANCE
	
func _change_state(new_state):
	if new_state == State.IDLE:
		_tile_map.clear_path()
		baddie_sprite.show()
		move_sprite.hide()
		baddie_sprite.flip_h = move_sprite.flip_h
	elif new_state == State.FOLLOW:
		_path = _tile_map.find_path(position, player.position)
		baddie_sprite.hide()
		move_sprite.show()
		if _path.size() < 2:
			_change_state(State.IDLE)
			return
		# The index 0 is the starting cell.
		# We don't want the character to move back to it in this example.
		_next_point = _path[1]
	_state = new_state

func _on_turn_end():
	if _tile_map.is_point_walkable(player.position):
		_change_state(State.FOLLOW)

