extends Button

var attack_type: String
signal actionbar_button_pressed(action_type: String)

func _on_pressed(attack_type: String):
	actionbar_button_pressed.emit(attack_type)
