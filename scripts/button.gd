extends Button

@export var index: int

var enabled: bool = false

signal token_placed(index)
signal token_removed(index)

func _on_pressed():
	if enabled == true:
		enabled = false
		token_removed.emit(index)
	elif enabled == false:
		enabled = true; 
		token_placed.emit(index)
