extends HBoxContainer

var buttons

func _ready():
	var button1 = get_node("button1")
	var button2 = get_node("button2")
	var button3 = get_node("button3")
	var button4 = get_node("button4")
	var button5 = get_node("button5")
	var button6 = get_node("button6")
	var button7 = get_node("button7")
	
	buttons = [button1,
			   button2,
			   button3,
			   button4,
			   button5,
			   button6,
			   button7, ]
	
	button1.token_placed.connect(place_token)
	button2.token_placed.connect(place_token)
	button3.token_placed.connect(place_token)
	button4.token_placed.connect(place_token)
	button5.token_placed.connect(place_token)
	button6.token_placed.connect(place_token)
	button7.token_placed.connect(place_token)
	
	button1.token_removed.connect(remove_token)
	button2.token_removed.connect(remove_token)
	button3.token_removed.connect(remove_token)
	button4.token_removed.connect(remove_token)
	button5.token_removed.connect(remove_token)
	button6.token_removed.connect(remove_token)
	button7.token_removed.connect(remove_token)

func place_token(index):
	print("placing token on index: " + str(index))
	buttons[index].text = " X "

func remove_token(index):
	print("removing token from index: " + str(index))
	buttons[index].text = " O "
	
