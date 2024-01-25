extends GridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	var texture_button = preload("res://scenes/tile.tscn")
	for i in range(4):
		var tile = texture_button.instantiate()
		add_child(tile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

