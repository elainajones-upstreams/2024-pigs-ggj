extends CanvasItem

var fading_in = true
var fading_out = false

var next_level = 0
enum NEXT_LEVEL { GAME    = 1, 
				  CREDITS = 2, 
				  QUIT    = 3, 
				  OPTIONS = 4 }

var texture_modulate: float

func _ready():
	fading_in = true
	fading_out = false
	next_level = 0
	texture_modulate = 0.0
	self.modulate.a = texture_modulate
	visible = true
	
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
			switch_scene()

func switch_scene():
	if next_level == NEXT_LEVEL.GAME:
		get_tree().change_scene_to_file("scenes/tutorial.tscn")
	if next_level == NEXT_LEVEL.CREDITS:
		get_tree().change_scene_to_file("scenes/credits.tscn")
	if next_level == NEXT_LEVEL.OPTIONS:
		pass
	if next_level == NEXT_LEVEL.QUIT:
		get_tree().quit()

func _on_startgame_pressed():
	next_level = NEXT_LEVEL.GAME
	fading_in = false
	fading_out = true

func _on_credits_pressed():
	next_level = NEXT_LEVEL.CREDITS
	fading_in = false
	fading_out = true

func _on_options_pressed():
	next_level = NEXT_LEVEL.OPTIONS
	#FIXME TODO
	#fading_in = false
	#fading_out = true #uncomment when options screen added

func _on_quit_pressed():
	next_level = NEXT_LEVEL.QUIT
	fading_in = false
	fading_out = true
