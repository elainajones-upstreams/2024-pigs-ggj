extends CanvasItem

var fading_in = true
var fading_out = false

enum NEXT_LEVEL { GAME, CREDITS, EXIT, OPTIONS }
var next_level = NEXT_LEVEL.EXIT

var texture_modulate: float = 0.0

func _unhandled_key_input(event):
	if Input.is_anything_pressed():
		print("main-menu is pressed")
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
			start_game()

func start_game():
	get_tree().change_scene_to_file("scenes/tutorial.tscn")

func show_credits():
	get_tree().change_scene_to_file("scenes/credits.tscn")
	
func quit_game():
	get_tree().quit()

func options():
	pass

func _on_startgame_pressed():
	next_level = NEXT_LEVEL.GAME
	start_game()

func _on_credits_pressed():
	next_level = NEXT_LEVEL.CREDITS
	show_credits()

func _on_options_pressed():
	next_level = NEXT_LEVEL.OPTIONS
	options()

func _on_quit_pressed():
	next_level = NEXT_LEVEL.EXIT
	quit_game()
