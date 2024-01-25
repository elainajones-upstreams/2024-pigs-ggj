extends HBoxContainer

var squares: Array

@export var squares_per_row: int = 7
@export var square = preload("res://scenes/square.tscn")

func _ready():
	for i in squares_per_row:
		var new_square = square.instantiate()
		new_square.column_index = i
		add_child(new_square)
		squares.append(new_square)
		squares[i].token_placed.connect(place_token)
		squares[i].token_removed.connect(remove_token)

func place_token(index):
	print("placing token on index: " + str(index))
	squares[index].text = " X "

func remove_token(index):
	print("removing token from index: " + str(index))
	squares[index].text = " O "
	
