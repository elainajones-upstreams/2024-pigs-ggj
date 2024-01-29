extends Control

@export var num_actions: int = 2

@onready var actionbar_container = $PanelContainer/HFlowContainer
var actionbar_button = preload("res://scenes/actionbar_button.tscn")

var actionbar_buttons: Array
var actionbar_buttons_text: Array = ["vertical", "plus"]

signal actionbar_container_button_pressed(action_type: String)

func _ready():
	for i in num_actions:
		var my_actionbar_button = actionbar_button.instantiate()
		actionbar_container.add_child(my_actionbar_button)
		my_actionbar_button.actionbar_button.action_type = actionbar_buttons_text[i]
		my_actionbar_button.actionbar_button.text = actionbar_buttons_text[i]
		actionbar_buttons.append(my_actionbar_button)
		my_actionbar_button.actionbar_button_pressed2.connect(actionbar_button_pressed)

func actionbar_button_pressed(action_type: String):
	actionbar_container_button_pressed.emit(action_type)
