extends CanvasItem

var fading_in = true
var fading_out = false

var texture_modulate: float = 0.0

func _unhandled_key_input(event):
	if Input.is_anything_pressed():
		print("tutorial is pressed")
		fading_out = true
		fading_in = false

func _process(delta):
	if (fading_in):
		self.modulate.a = texture_modulate
		texture_modulate += delta / 3
		if texture_modulate >= 1:
			fading_in = false
		
	if (fading_out):
		self.modulate.a = texture_modulate
		texture_modulate -= delta / 3
		if texture_modulate <= 0:
			fading_in = false
			fading_out = false
			switch_level()

func switch_level():
	get_tree().change_scene_to_file("scenes/game.tscn")
