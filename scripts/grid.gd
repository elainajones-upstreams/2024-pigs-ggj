extends GridContainer

var rows

func _ready():
	var row1 = get_node("row1")
	var row2 = get_node("row2")
	var row3 = get_node("row3")
	var row4 = get_node("row4")
	var row5 = get_node("row5")
	var row6 = get_node("row6")
	var row7 = get_node("row7")
	
	rows = [row1,
			row2,
			row3,
			row4,
			row5,
			row6,
			row7, ]
