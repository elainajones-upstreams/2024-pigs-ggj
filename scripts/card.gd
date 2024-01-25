extends Control

signal card_played(target_squares)

# array of rows
# each row is an array of columns/squares
@export var target_squares: Array[Array] = [[false, false, false, false, false, false, false], 
											[false, false, false, false, false, false, false],
											[false, false, false, false, false, false, false],
											[false, false, false, false, false, false, false],
											[false, false, false, false, false, false, false],
											[false, false, false, false, false, false, false],
											[false, false, false, false, false, false, false],
										   ]

func generate_random_targets_dice(die_faces: int):
	var row_count: int = 0 #debug purposes
	for row in target_squares:
		for square in row:
			square = false
		var square_index: int = randi() % die_faces
		row[square_index] = true
		row_count += 1
		print("setting row " + str(row_count) + ", square " + str(square_index) + " to true.")

func generate_random_targets_true():
	for row in target_squares:
		for square in row:
			if randi() % 2 == 0:
				print("setting row " + str(row) + " square " + str(square) + " to true.")
				square = true
			else:
				square = false
				print("setting row " + str(row) + " square " + str(square) + " to false.")

func create_new_card(die_faces: int = 0):
	if die_faces == 0:
		generate_random_targets_true()
	else:
		generate_random_targets_dice(die_faces)

func play_card():
	card_played.emit(target_squares)
