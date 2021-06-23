extends Label

var color_title = Color(0,32.0/255.0,96.0/255.0,1)

func _ready():
	set_global_position(Vector2(110,60))
	text = "Gaussian Process\nDynamical System"
	
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 25
	
	add_color_override("font_color", color_title)
	add_font_override("font",dynamic_font)		
