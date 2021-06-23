extends Control

# button set-up
var pivot_loc = Vector2(470,65)
onready var node_param = get_node("../CanvasLayer/draw_and_control_thepoints")
var num_points

# button control
var button_add
var button_sub
var point_numb_tx


###########################

func _ready():
	num_points = node_param.numpoints
	
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 17

	button_add = get_node("Button_add")
	button_add.set_global_position(pivot_loc)
	button_add.text = " + "
	button_add.add_font_override("font",dynamic_font)
	
	point_numb_tx = get_node("Label_numberOfPoints")
	point_numb_tx.set_global_position(pivot_loc+Vector2(40,3))
	point_numb_tx.add_font_override("font",dynamic_font)
	point_numb_tx.text = "Num Fixed Points: "+str(num_points)
	
	button_sub = get_node("Button_subtract")
	button_sub.text = " - "
	button_sub.add_font_override("font",dynamic_font)
	button_sub.set_global_position(pivot_loc+Vector2(163,0))


func _on_Button_add_button_down():
	if node_param.numpoints + 1 < 3:
		node_param.numpoints = node_param.numpoints+1	
		num_points = node_param.numpoints
		point_numb_tx.text = "Num Fixed Points: "+str(num_points)

func _on_Button_subtract_button_down():
	if node_param.numpoints - 1 > 0:
		node_param.numpoints = node_param.numpoints-1
		num_points = node_param.numpoints
		point_numb_tx.text = "Num Fixed Points: "+str(num_points)
