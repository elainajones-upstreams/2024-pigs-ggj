extends CharacterBody2D

#@export var actionbar: Control

const MASS = 5.0
const ARRIVE_DISTANCE = 10.0
const CHARACTER_MAX_HP = 50
const CHARACTER_ACTION_POINTS = 7
const ATTACK_COST = 2
const Attack = preload("res://scripts/attack.gd")
const Utils = preload("res://scripts/utils.gd")
const vertical = [Vector2i(0, -5), Vector2i(0, -4), Vector2i(0, -3), Vector2i(0, -2), Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3), Vector2i(0, 4), Vector2i(0, 5)]
const plus = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -2), Vector2i(0, 2), Vector2i(2, 0), Vector2i(-2, 0)]

signal turn_end

@export var speed: float = 200.0
var num_actions: int = 3
var player_movement = 5

var _state = Utils.State.IDLE
var _velocity = Vector2()

@onready var _tile_map = $"../TileMap"
@onready var game = $".."
@onready var animated_sprite = $charactersprite
@onready var pickup_sfx = $pickup_sfx
@onready var ground_attack = $ground_attack
var action_bar_container
#@onready var actionbar_container = $"../actionbar-container/HFlowContainer"
#@onready var actionbar_container = $"PanelContainer/HFlowContainer"
@onready var player_orig_position = position
@onready var basic_attack = Attack.new(10, position, [Vector2i(0, 0)], "Basic Attack")
#@onready var action_bar = $"../../actionbar-container/actionbar"

var actionbar_button = preload("res://scenes/actionbar_button.tscn")
var actionbar_scene = preload("res://scenes/actionbar.tscn")

var actionbar_container

var actionbar_buttons: Array
var actionbar_buttons_text: Array = ["vertical", "plus", "why"]

var player_orig_color : Color

var _click_position = Vector2()
var _path = PackedVector2Array()
var _next_point = Vector2()
#var attacks = {}

var hit_points : int
var action_points : int

var selected_ability = 0
var current_attack : Attack
var hand = []


func _ready():
	action_bar_container = $"../actionbar-container/HFlowContainer"
	#action_bar_container._ready()
	#actionbar_container.position = Vector2(463, 574)
	#actionbar_container.size = Vector2(251, 41)
	basic_attack.animation = "basic_attack"
	_change_state(Utils.State.RESPAWNING)
	player_orig_color = animated_sprite.modulate
	animated_sprite.animation_finished.connect(_return_to_idle)
	_tile_map.player_turn.connect(_start_turn)
	#attacks["basic"] = Attack.new(10, position, [Vector2i(0, 0)])
	#attacks["vertical"] = Attack.new(10, position, vertical)
	#attacks["plus"] = Attack.new(10, position, plus)
	#$"../".add_child(actionbar_container)
	for i in num_actions:
		var my_actionbar_button = actionbar_button.instantiate()
		my_actionbar_button._ready()
		action_bar_container.add_child(my_actionbar_button)
		my_actionbar_button.actionbar_button.action_type = actionbar_buttons_text[i]
		my_actionbar_button.actionbar_button.text = actionbar_buttons_text[i]
		actionbar_buttons.append(my_actionbar_button)
		my_actionbar_button.actionbar_button_pressed2.connect(select_attack)
	new_hand()
	#actionbar.actionbar_container_button_pressed.connect(select_attack)

func _process(_delta):
	#if _state == Utils.State.NOT_MY_TURN:
		#return
	if hit_points <= 0 && _state != Utils.State.DYING:
		_change_state(Utils.State.DYING)
	if action_points <= 0 && _state == Utils.State.IDLE:
		_change_state(Utils.State.EXHAUSTED)
	if _state == Utils.State.FOLLOW:
		character_follow()

func character_follow():
	var arrived_to_next_point = _move_to(_next_point)
	if arrived_to_next_point:
		_path.remove_at(0)
		if _path.is_empty():
			_change_state(Utils.State.IDLE)
			_tile_map.clear_all_paths()
			return
		_next_point = _path[0]

func _unhandled_input(event):
	if event.is_action_pressed(&"quit"):
		get_tree().quit()
	if _state == Utils.State.IDLE:
		_click_position = get_global_mouse_position()
		if _tile_map.is_point_walkable(_click_position):
			#if event.is_action_pressed(&"teleport_to", false, true):
				#_change_state(State.IDLE)
				#global_position = _tile_map.round_local_position(_click_position)
			if event.is_action_pressed(&"move_to"):
				_change_state(Utils.State.FOLLOW)
		if event.is_action_pressed(&"attack"):
			_attack(_click_position, true)
			_tile_map.player_attack_squares()
		if event.is_action_pressed(&"aoe_attack"):
			_attack(_click_position, false)
			_tile_map.player_attack_squares()
		if event.is_action_pressed(&"cycle_attacks"):
			cycle_attacks()
		#TODO: Player should not be able to do this while an enemy is dying, that breaks it
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
		_path = _tile_map.find_player_path(position, _click_position, action_points)
		animated_sprite.play("move")
		if _path.size() < 2:
			_change_state(Utils.State.IDLE)
			return
		# The index 0 is the starting cell.
		# We don't want the character to move back to it in this example.
		action_points = action_points - (_path.size() - 1)
		_next_point = _path[1]
	elif new_state == Utils.State.DYING:
		_state = new_state
		die()
		return
	elif new_state == Utils.State.RESPAWNING:
		_state = new_state
		respawn()
		return
	elif new_state == Utils.State.EXHAUSTED:
		animated_sprite.modulate = Color(0, 1, 0)
		animated_sprite.play("player_exhausted")
	elif new_state == Utils.State.NOT_MY_TURN:
		animated_sprite.modulate = player_orig_color
		animated_sprite.play("idle")
	_state = new_state

	
func _attack(click_position, basic):
	if basic && action_points >= ATTACK_COST || !basic && action_points >= ATTACK_COST * 2:
		if basic:
			basic_attack.center = _tile_map.get_tile_center(click_position)
			current_attack = basic_attack
			action_points = action_points - ATTACK_COST
		else:
			current_attack = hand[selected_ability]
			current_attack.center = _tile_map.get_tile_center(click_position)
			action_points = action_points - (ATTACK_COST * 2)
		_tile_map.execute_attack(current_attack)
		animated_sprite.play("player_attack")
		ground_attack.play(0.0)
		await animated_sprite.animation_finished
		
		if action_points == 0:
			_change_state(Utils.State.EXHAUSTED)
	else:
		pass
	
func _return_to_idle():
	animated_sprite.play("idle")

func on_hit(attack):
	hit_points = hit_points - attack.damage
	animated_sprite.play("player_take_damage")
	await animated_sprite.animation_finished
	animated_sprite.play("idle")

func die():
	animated_sprite.play("player_death")
	await animated_sprite.animation_finished
	respawn()
	
func respawn():
	position = player_orig_position
	hit_points = CHARACTER_MAX_HP
	action_points = CHARACTER_ACTION_POINTS
	animated_sprite.play("player_respawn")
	await animated_sprite.animation_finished
	_state = Utils.State.IDLE
	animated_sprite.play("idle")
	
func end_turn():
	_change_state(Utils.State.NOT_MY_TURN)
	emit_signal("turn_end")
	
func _start_turn():
	action_points = CHARACTER_ACTION_POINTS
	new_hand()
	if (animated_sprite.animation == "player_take_damage" or 
		animated_sprite.animation == "player_death"):
		await animated_sprite.animation_finished
	_change_state(Utils.State.IDLE)

func cycle_attacks():
	selected_ability = selected_ability + 1
	if selected_ability > hand.size() - 1:
		selected_ability = 0

func on_pickup(pickup):
	pickup_sfx.play(0.0)
	action_points += pickup.energy
	hit_points -= pickup.hit_dmg

func select_attack(action_type: String):
	if hand[0].name == action_type:
		selected_ability = 0
	elif hand[1].name == action_type:
		selected_ability = 1
	elif hand[2].name == action_type:
		selected_ability = 2

func new_hand():
	hand = []
	Attack.draw_hand(self)
	actionbar_buttons_text.clear()
	for atk in hand:
		actionbar_buttons_text.append(atk.name)
	refresh_action_bar()

func refresh_action_bar():
	for n in action_bar_container.get_children():
		action_bar_container.remove_child(n)
	for i in num_actions:
		var my_actionbar_button = actionbar_button.instantiate()
		my_actionbar_button._ready()
		action_bar_container.add_child(my_actionbar_button)
		my_actionbar_button.actionbar_button.action_type = actionbar_buttons_text[i]
		my_actionbar_button.actionbar_button.text = actionbar_buttons_text[i]
		actionbar_buttons.append(my_actionbar_button)
		my_actionbar_button.actionbar_button_pressed2.connect(select_attack)
	
