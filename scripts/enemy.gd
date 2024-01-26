extends CharacterBody2D

enum State { IDLE, FOLLOW, DYING }

const MASS = 5.0
const ARRIVE_DISTANCE = 10.0
const death_delay = 5.0

@export var speed: float = 200.0

var _state = State.IDLE
var _velocity = Vector2()

@onready var _tile_map = $"../TileMap"
@onready var player = $"../Character"
@onready var baddie_sprite = $baddiesprite

var _path = PackedVector2Array()
var _next_point = Vector2()
var hit_points : int

# Called when the node enters the scene tree for the first time.
func _ready():
	hit_points = 10
	_tile_map.turn_end.connect(_on_turn_end)
	baddie_sprite.animation_finished.connect(_return_to_idle)
	_change_state(State.IDLE)

func _process(_delta):
	if _state != State.FOLLOW:
		return
	if hit_points <= 0:
		die()
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
		baddie_sprite.flip_h = false
	else:
		baddie_sprite.flip_h = true
	
	return position.distance_to(local_position) < ARRIVE_DISTANCE
	
func _change_state(new_state):
	if new_state == State.IDLE:
		_tile_map.clear_path()
		baddie_sprite.play("baddie_idle")
	elif new_state == State.FOLLOW:
		_path = _tile_map.find_path(position, player.position)
		baddie_sprite.play("baddie_move")
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

func _return_to_idle():
	baddie_sprite.play("baddie_idle")

func on_hit(attack):
	print("DIRECT HIT")
	hit_points = hit_points - attack.damage
	
func die():
	_change_state(State.DYING)
	baddie_sprite.play("baddie_die")
	#await get_tree().create_timer(death_delay).timeout
	await baddie_sprite.animation_finished
	position.x = 1125
	position.y = 31
	hit_points = 10
	_change_state(State.IDLE)
