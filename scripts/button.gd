extends Button

var column_index: int

var enabled: bool = false

signal token_placed(column_index)
signal token_removed(column_index)

func _on_pressed():
	if enabled == true:
		enabled = false
		token_removed.emit(column_index)
	elif enabled == false:
		enabled = true; 
		token_placed.emit(column_index)
