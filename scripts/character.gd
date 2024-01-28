extends Node2D



const MASS = 5.0
const ARRIVE_DISTANCE = 10.0
const CHARACTER_MAX_HP = 50
const CHARACTER_ACTION_POINTS = 7
const ATTACK_COST = 2
const Attack = preload("res://scripts/attack.gd")
const Utils = preload("res://scripts/utils.gd")

signal turn_end

@export var speed: float = 200.0
var player_movement = 5

var _state = Utils.State.IDLE
var _velocity = Vector2()

@onready var _tile_map = $"../TileMap"
@onready var animated_sprite = $charactersprite
@onready var player_orig_position = position
var player_orig_color : Color

var _click_position = Vector2()
var _path = PackedVector2Array()
var _next_point = Vector2()

var hit_points : int
var action_points : int



func _ready():
	hit_points = CHARACTER_MAX_HP
	action_points = CHARACTER_ACTION_POINTS
	_change_state(Utils.State.IDLE)
	player_orig_color = animated_sprite.modulate
	animated_sprite.animation_finished.connect(_return_to_idle)
	_tile_map.player_turn.connect(_start_turn)


func _process(_delta):
	#if _state == Utils.State.NOT_MY_TURN:
		#return
	if hit_points <= 0 && _state != Utils.State.DYING:
		_change_state(Utils.State.DYING)
	if action_points <= 0 && _state == Utils.State.IDLE:
		_change_state(Utils.State.EXHAUSTED)
	if _state != Utils.State.FOLLOW:
		return
	var arrived_to_next_point = _move_to(_next_point)
	if arrived_to_next_point:
		_path.remove_at(0)
		if _path.is_empty():
			_change_state(Utils.State.IDLE)
			_tile_map.clear_all_paths()
			return
		_next_point = _path[0]


func _unhandled_input(event):
	if _state == Utils.State.IDLE:
		_click_position = get_global_mouse_position()
		if _tile_map.is_point_walkable(_click_position):
			#if event.is_action_pressed(&"teleport_to", false, true):
				#_change_state(State.IDLE)
				#global_position = _tile_map.round_local_position(_click_position)
			if event.is_action_pressed(&"move_to"):
				_change_state(Utils.State.FOLLOW)
		if event.is_action_pressed(&"attack"):
			_attack(_click_position)
			_tile_map.player_attack_squares()
		elif event.is_action_pressed(&"end_turn"):
			end_turn()
	if _state == Utils.State.EXHAUSTED:
		if event.is_action_pressed(&"end_turn"):
			end_turn()


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
	if new_state == Utils.State.IDLE:
		_tile_map.clear_all_paths()
		animated_sprite.play("idle")
	elif new_state == Utils.State.FOLLOW:
		_path = _tile_map.find_and_add_path(position, _click_position, action_points, true)
		animated_sprite.play("idle")
		if _path.size() < 2:
			_change_state(Utils.State.IDLE)
			return
		# The index 0 is the starting cell.
		# We don't want the character to move back to it in this example.
		action_points = action_points - (_path.size() - 1)
		print("ACTION POINTS: " + var_to_str(action_points))
		_next_point = _path[1]
	elif new_state == Utils.State.DYING:
		die()
	elif new_state == Utils.State.EXHAUSTED:
		animated_sprite.modulate = Color(0, 1, 0)
		animated_sprite.play("player_exhausted")
	elif new_state == Utils.State.NOT_MY_TURN:
		animated_sprite.modulate = player_orig_color
		animated_sprite.play("idle")
		print("I AM ENDING MY TURN")
	_state = new_state
	
func _attack(click_position):
	if action_points >= ATTACK_COST:
		_tile_map.execute_attack(Attack.new(10, _tile_map.get_tile_center(click_position)))
		animated_sprite.play("player_attack")
		await animated_sprite.animation_finished
		action_points = action_points - ATTACK_COST
		print("Action PPoint after attack: " + var_to_str(action_points))
		if action_points == 0:
			_change_state(Utils.State.EXHAUSTED)
	else:
		print("Not enough Action Points")
	
func _return_to_idle():
	animated_sprite.play("idle")
	
func on_hit(attack):
	print("THAT'S GOTTA HURT")
	hit_points = hit_points - attack.damage
	animated_sprite.play("player_take_damage")
	await animated_sprite.animation_finished
	animated_sprite.play("idle")

func die():
	print("AHHH AM DEAD")
	animated_sprite.play("player_death")
	await animated_sprite.animation_finished
	respawn()
	
func respawn():
	position = player_orig_position
	hit_points = CHARACTER_MAX_HP
	_change_state(Utils.State.IDLE)
	
func end_turn():
	_change_state(Utils.State.NOT_MY_TURN)
	emit_signal("turn_end")
	
func _start_turn():
	print("I AM STARTING MY TURN")
	action_points = CHARACTER_ACTION_POINTS
	print(animated_sprite.animation)
	if animated_sprite.animation == "player_take_damage":
		await animated_sprite.animation_finished
	_change_state(Utils.State.IDLE)
