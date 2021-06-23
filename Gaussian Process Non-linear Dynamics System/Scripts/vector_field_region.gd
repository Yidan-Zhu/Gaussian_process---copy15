extends Line2D

#######################

var center = Vector2(280,280)
var box_width = 350
var box_height = 230

var axes_origin = center + Vector2(-box_width/2.0,box_height/2.0)
var axes_buff = 10
var tick_space = 30  # 30 pix = 1 number

#######################

func _ready():
	pass
	

func _draw():
	draw_rect(Rect2(center.x-box_width/2.0, \
	center.y-box_height/2.0,box_width,box_height), \
	Color(255/255.0,204/255.0,169/255.0,1), 1.0, true)

# draw the bar graph axes
	# x
	draw_line(Vector2(axes_origin.x, axes_origin.y), \
		Vector2(axes_origin.x + box_width+axes_buff,axes_origin.y),\
		Color(81/255.0,18/255.0,82/255.0,1.0),1.5,true)
	draw_triangle(Vector2(axes_origin.x + box_width+axes_buff,\
		axes_origin.y), Vector2(1,0), 5, \
		Color(81/255.0,18/255.0,82/255.0,1.0))
	# y
	draw_line(axes_origin, Vector2(axes_origin.x, \
		axes_origin.y - box_height-axes_buff),\
		Color(81/255.0,18/255.0,82/255.0,1.0),1.5,true)
	draw_triangle(Vector2(axes_origin.x, \
		axes_origin.y - box_height-axes_buff),Vector2(0,-1),5,\
		Color(81/255.0,18/255.0,82/255.0,1.0))
	
	# set a font
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 18	

	# ticks
	for i in range(1+box_width/tick_space):
		# x ticks
		if i!=0:
			draw_line(Vector2(axes_origin.x+i*tick_space,axes_origin.y),\
				Vector2(axes_origin.x+i*tick_space,axes_origin.y+5),\
				Color(0.25,0.25,0.25,1.0),1.0,true)
		# x tick labels	
		if i%2 == 0:
			if !get_node_or_null("Label_(" + str(i)+",0)"):
				var node = Label.new()
				node.name = "Label_(" + str(i)+",0)"
				add_child(node)	
			if i == 0:
				get_node("Label_(" + str(i)+",0)").set_global_position(\
					Vector2(axes_origin.x-22,axes_origin.y+10))
			elif i!=10 and i!=11:
				get_node("Label_(" + str(i)+",0)").set_global_position(\
					Vector2(axes_origin.x+i*tick_space-4,axes_origin.y+12))
			else: # i = 10, 11 text line up
				get_node("Label_(" + str(i)+",0)").set_global_position(\
					Vector2(axes_origin.x+i*tick_space-7.5,axes_origin.y+12))	
			get_node("Label_(" + str(i)+",0)").text = str(i)
			get_node("Label_(" + str(i)+",0)").add_color_override("font_color", \
				Color(0,0,0,1))	
			get_node("Label_(" + str(i)+",0)").add_font_override("font",\
				dynamic_font)

	for i in range(1, 1+box_height/tick_space):
		# y ticks
		draw_line(Vector2(axes_origin.x,-i*tick_space+axes_origin.y),\
			Vector2(axes_origin.x-5,-i*tick_space+axes_origin.y),\
			Color(0.25,0.25,0.25,1.0),1.0,true)
			
		# y tick labels	
		if i%2 == 0:
			if !get_node_or_null("Labely_(" + str(i)+",0)"):
				var node = Label.new()
				node.name = "Labely_(" + str(i)+",0)"
				add_child(node)	
	
			if i == 1 or i == 2 or i == 3:
				get_node("Labely_(" + str(i)+",0)").set_global_position(\
					Vector2(axes_origin.x-25, -i*tick_space+axes_origin.y-6))
			else:
				get_node("Labely_(" + str(i)+",0)").set_global_position(\
					Vector2(axes_origin.x-25, -i*tick_space+axes_origin.y-6))	
			get_node("Labely_(" + str(i)+",0)").text = str(i)
			get_node("Labely_(" + str(i)+",0)").add_color_override("font_color", \
				Color(0,0,0,1))			
			get_node("Labely_(" + str(i)+",0)").add_font_override("font",\
				dynamic_font)


	# x-axis label
	if !get_node_or_null("Label_x_axis"):
		var node = Label.new()
		node.name = "Label_x_axis"
		add_child(node)		
	get_node("Label_x_axis").set_global_position( \
		Vector2(axes_origin.x + box_width+10,axes_origin.y+12))		
	get_node("Label_x_axis").text = "X"
	get_node("Label_x_axis").add_font_override("font",dynamic_font)
	get_node("Label_x_axis").add_color_override("font_color", Color(0,0,0,1))

	# y-axis label
	if !get_node_or_null("Label_y_axis"):
		var node = Label.new()
		node.name = "Label_y_axis"
		add_child(node)		
	get_node("Label_y_axis").set_global_position( \
		Vector2(axes_origin.x - 23, axes_origin.y - box_height- 21))		
	get_node("Label_y_axis").text = "Y"
	get_node("Label_y_axis").add_font_override("font",dynamic_font)
	get_node("Label_y_axis").add_color_override("font_color", Color(0,0,0,1))

####################################################
# draw a triangle on the 2d canvas
func draw_triangle(pos:Vector2, dir:Vector2, size, color):
	dir = dir.normalized()
	var a = pos + dir*size
	var b = pos + dir.rotated(2*PI/3)*size
	var c = pos + dir.rotated(4*PI/3)*size
	var points = PoolVector2Array([a,b,c])
	draw_polygon(points, PoolColorArray([color]))	
