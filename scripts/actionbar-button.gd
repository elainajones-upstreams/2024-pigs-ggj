extends Button

var action_type: String
signal actionbar_button_pressed(action_type: String)

func _on_pressed():
	actionbar_button_pressed.emit(action_type)
