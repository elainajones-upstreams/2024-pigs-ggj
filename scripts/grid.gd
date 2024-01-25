extends GridContainer

var rows: Array

@export var rows_per_grid: int = 7
@export var row = preload("res://scenes/row.tscn")

func _ready():
	for i in rows_per_grid:
		var new_row = row.instantiate()
		add_child(new_row)
		rows.append(new_row)
