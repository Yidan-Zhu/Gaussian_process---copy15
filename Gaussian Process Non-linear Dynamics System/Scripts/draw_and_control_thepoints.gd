extends Line2D

##################
#     PARAMS
##################

# finger control points
var events = {}
var pointmoved = false
var point_moving_cont = false
var finger_loc
var touch_dist = 15
var movedpt = {}

# point drawing
var numpoints = 2
var pre_nump = 2
var point_coord = Array()
var rng = RandomNumberGenerator.new()
var overlapping_dist = 20
var margin_buff = 10

onready var dragging_corner_node = get_node("../diamond_illustration")
var dragging_corner_flag
var dragging_fixed_point = false

# axes position
var center = Vector2(280,280)
var box_width = 350
var box_height = 230

var axes_origin = center + Vector2(-box_width/2.0,box_height/2.0)

# slope
var slp_leg_loc = Vector2(590,130)
var spacingx = Vector2(-80,0)
var spacingy = Vector2(0,70)

onready var slider_title = get_node("slider_title")
onready var sprite_eqn = get_node("Sprite")
#onready var jacobian_eqn = get_node("Sprite2")
var slope_txt_1x_spacing = Vector2(40,-1)
var slope_txt_1y_spacing = Vector2(80,-1)
var slope_txt_2x_spacing = Vector2(40,25)
var slope_txt_2y_spacing = Vector2(80,25)
var dot_text_yspacing = Vector2(0,60)

var color1 = Color(0/255.0,0/255.0,0/255.0,1)
var color4 = Color(0/255.0,107/255.0,56/255.0,1)
var color3 = color1
var color2 = color4

var slope_value = Array()
var slider_current_idx = -1
var slider_initial = true
var slider_update = false

# efficiency
var slider_pre
var slider_now
var time_array = Array()
var time_start
var time_end

# decoration
var box_upleft = slp_leg_loc+spacingy*1.5+0.8*spacingx
var side_box_width = 215
var side_box_height = 205
var color_slope_text = Color(192/255.0,0/255.0,0/255.0,1.0)
var color_bracket = Color(192/255.0,0/255.0,0/255.0,0.5)

#########################

func _ready():
	slider_current_idx = numpoints-1
	dragging_corner_flag = dragging_corner_node.flag_corner_moving
	
	rng.randomize()
	# generate initial two fixed points
	for _i in range(numpoints):
		var add_point = Vector2(rng.randf_range(margin_buff, \
			box_width-margin_buff),\
			rng.randf_range(-box_height+margin_buff,-margin_buff))
		var test_flag = true	
		
		while add_point.x < 0 or add_point.x > box_width or \
			add_point.y > 0 or add_point.y < - box_height:
			add_point = Vector2(rng.randf_range(margin_buff, \
				box_width-margin_buff),\
				rng.randf_range(-box_height+margin_buff,-margin_buff))
		
		if _i == 1:
		#for the second point test, not too close:
			if dist_two_points(point_coord[0],add_point) < overlapping_dist:
				test_flag = false

			while test_flag == false:
				add_point = Vector2(rng.randf_range(0, box_width),\
					rng.randf_range(0,box_height))	
					
				while add_point.x < 0 or add_point.x > box_width or \
					add_point.y > 0 or add_point.y < - box_height:
					add_point = Vector2(rng.randf_range(margin_buff, \
						box_width-margin_buff),\
						rng.randf_range(-box_height+margin_buff,-margin_buff))
				
				test_flag = true
				#for item in point_coord:
				if dist_two_points(point_coord[0],add_point) < overlapping_dist:
					test_flag = false					
		
		point_coord.append(add_point)
		slope_value.append([1,1.2,0.5,-1])

	# title of sliders
	var dynamic_font2 = DynamicFont.new()
	dynamic_font2.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font2.size = 17

	slider_title.set_global_position(box_upleft)
	slider_title.text = "Linear dynamics approximation \nnear fixed points:"
	slider_title.add_color_override("font_color", \
		ColorN("Brown"))
	slider_title.add_font_override("font",dynamic_font2)
		
	slider_pre = slope_value
	
	# math equation
	sprite_eqn.set_global_position(\
		slp_leg_loc+spacingy*0.4-0.3*spacingx)
#	jacobian_eqn.set_global_position(\
#		box_upleft+spacingy*0.22-1.6*spacingx)

func _input(event):
# take the most recent one finger-touch inputs
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
			#pointmoved = true
			point_moving_cont = true
		else:
			events.erase(event.index)	
			movedpt.erase(0)
			slider_initial = true
			#pointmoved = false
			point_moving_cont = false
			dragging_fixed_point = false

# use the touch in the axis region
	if event.position.x > axes_origin.x and \
		event.position.x < axes_origin.x+box_width \
		and event.position.y < axes_origin.y and \
		event.position.y > axes_origin.y-box_height and \
		dragging_corner_flag == false:
		if event is InputEventScreenDrag or \
			(event is InputEventScreenTouch and \
			event.is_pressed()):  # drag or touch input
			events[event.index] = event
			if events.size() == 1: # one finger input
				finger_loc = event.position - axes_origin
				if movedpt.size() == 1:
					point_coord[movedpt[0]] = finger_loc
					dragging_fixed_point = true
					update()
				else:
					for i in range(numpoints):			
						if dist_two_points(finger_loc,point_coord[i]) \
							< touch_dist:
							dragging_fixed_point = true
							#pointmoved = true
							movedpt[0] = i
							point_coord[i] = finger_loc	
							
							if slider_initial:
								slider_initial = false
								slider_current_idx = movedpt[0]	
								
							update()
							break
												
				finger_loc = event.position - axes_origin
				if movedpt.size() == 1:
					point_coord[movedpt[0]] = finger_loc
					dragging_fixed_point = true
					update()
				else:
					for i in range(numpoints):			
						if dist_two_points(finger_loc,point_coord[i]) \
							< touch_dist:
							dragging_fixed_point = true
							#pointmoved = true
							movedpt[0] = i
							point_coord[i] = finger_loc	
							
							if slider_initial:
								slider_initial = false
								slider_current_idx = movedpt[0]	
								slider_update = true
								
							update()
							break				


# use touch to switch to a text 
	else:
		if event is InputEventScreenDrag or \
			(event is InputEventScreenTouch and \
			event.is_pressed()):  # drag or touch input
			events[event.index] = event
			if events.size() == 1: # one finger input
				if event.position.x >= 562 and event.position.x <= 595:
					# point 1
					if event.position.y >=295 and event.position.y <= 309 \
						and numpoints >=1:
						slider_current_idx = 0
						update()
					# point 2
					elif event.position.y >=354 and event.position.y <= 370 \
						and numpoints >=2:
						slider_current_idx = 1
						update()

func _process(_delta):
	#time_start = OS.get_ticks_msec()
	# efficiency unit
	slider_now = slope_value
	
	if slider_pre != slider_now:
		update()
		slider_pre = slider_now
	
	# separate two controls on the screen
	dragging_corner_flag = dragging_corner_node.flag_corner_moving
	
	
	if pre_nump < numpoints:
		pointmoved = true
		# generate more points
		for _i in range(pre_nump,numpoints):
			var add_point = Vector2(rng.randf_range(margin_buff, \
				box_width-margin_buff),\
				rng.randf_range(-box_height+margin_buff,-margin_buff))
			var test_flag = true	
			
			while add_point.x < 0 or add_point.x > box_width or \
				add_point.y > 0 or add_point.y < - box_height:
				# guarantee the points are in
				add_point = Vector2(rng.randf_range(margin_buff, \
					box_width-margin_buff),\
					rng.randf_range(-box_height+margin_buff,-margin_buff))
			
			for item in point_coord:
				if dist_two_points(item,add_point) < overlapping_dist:
					test_flag = false
	
			while test_flag == false:
				add_point = Vector2(rng.randf_range(margin_buff, \
					box_width-margin_buff),\
					rng.randf_range(-box_height+margin_buff,-margin_buff))	
					
				while add_point.x < 0 or add_point.x > box_width or \
					add_point.y > 0 or add_point.y < - box_height:
					# guarantee the points are in
					add_point = Vector2(rng.randf_range(margin_buff, \
						box_width-margin_buff),\
						rng.randf_range(-box_height+margin_buff,-margin_buff))

				test_flag = true
				for item in point_coord:
					if dist_two_points(item,add_point) < overlapping_dist:
						test_flag = false					
			
			point_coord.append(add_point)
			slope_value.append([1,1.2,0.5,-1])
			
		pre_nump = numpoints
		update()
	
	elif pre_nump > numpoints:
		pointmoved = true
		# delete the point chosen
		point_coord.remove(slider_current_idx)
		slope_value.remove(slider_current_idx)
			
		pre_nump = numpoints
		slider_current_idx = numpoints-1
		
		update()		
	
	# update the slope value and text
	if numpoints>=0:
		for _i in range(numpoints):
			# slope text
			if !get_node_or_null("val_slope"+str(_i)):
				var node = Label.new()
				node.name = "val_slope"+str(_i)
				add_child(node)		
				node.set_global_position(box_upleft-spacingy*1.4+\
					_i*dot_text_yspacing+dot_text_yspacing*2.59-0.5*spacingx)
				
			get_node("val_slope"+str(_i)).text = \
				"x* : "

			var dynamic_font3 = DynamicFont.new()
			dynamic_font3.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
			dynamic_font3.size = 12

			if !get_node_or_null("val_slope"+str(_i)+"low_idx"):
				var node = Label.new()
				node.name = "val_slope"+str(_i)+"low_idx"
				add_child(node)		
				node.set_global_position(box_upleft-spacingy*1.4+\
					_i*dot_text_yspacing+dot_text_yspacing*2.73-0.62*spacingx)
				node.add_font_override("font",dynamic_font3)
				
			get_node("val_slope"+str(_i)+"low_idx").text = str(_i+1)
						
			# slope 1x
			if !get_node_or_null("val_slope1x"+str(_i)):
				var node = Label.new()
				node.name = "val_slope1x"+str(_i)
				add_child(node)		
				node.set_global_position(box_upleft-spacingy*1.4+\
					_i*dot_text_yspacing+\
					dot_text_yspacing*2.6+slope_txt_1x_spacing-0.7*spacingx)
				node.text = str(slope_value[_i][0])	
					
			# slope 1y
			if !get_node_or_null("val_slope1y"+str(_i)):
				var node = Label.new()
				node.name = "val_slope1y"+str(_i)
				add_child(node)		
				node.set_global_position(box_upleft-spacingy*1.4+\
					_i*dot_text_yspacing+\
					dot_text_yspacing*2.6+slope_txt_1y_spacing-0.7*spacingx)
				node.text = str(slope_value[_i][1])	
	
			# slope 2x
			if !get_node_or_null("val_slope2x"+str(_i)):
				var node = Label.new()
				node.name = "val_slope2x"+str(_i)
				add_child(node)		
				node.set_global_position(box_upleft-spacingy*1.4+\
					_i*dot_text_yspacing+\
					dot_text_yspacing*2.6++slope_txt_2x_spacing-0.7*spacingx)
				node.text = str(slope_value[_i][2])	
			
			# slope 2y
			if !get_node_or_null("val_slope2y"+str(_i)):
				var node = Label.new()
				node.name = "val_slope2y"+str(_i)
				add_child(node)		
				node.set_global_position(box_upleft-spacingy*1.4+\
					_i*dot_text_yspacing+\
					dot_text_yspacing*2.6++slope_txt_2y_spacing-0.7*spacingx)
				node.text = str(slope_value[_i][3])	
			
			# bracket

			if !get_node_or_null("Sprite_left_brac"+str(_i)):
				var node = Sprite.new()
				node.name = "Sprite_left_brac"+str(_i)
				var texture_pic = preload("res://left_bracket.png")
				node.set_texture(texture_pic)	
				
				node.set_scale(Vector2(0.6,0.8))
				
				if _i == 0:
					var mat = preload("res://new_shadermaterial2.tres")
					node.set_material(mat)
				elif _i == 1:
					var mat = preload("res://new_shadermaterial3.tres")
					node.set_material(mat)	
				
				node.set_global_position(\
					box_upleft-spacingy*1.4+\
					_i*dot_text_yspacing+\
					dot_text_yspacing*2.9+slope_txt_1y_spacing-0.05*spacingx)				
				add_child(node)
						
			if !get_node_or_null("Sprite_right_brac"+str(_i)):
				var node = Sprite.new()
				node.name = "Sprite_right_brac"+str(_i)
				var texture_pic = preload("res://right_bracket.png")
				node.set_texture(texture_pic)	
				
				node.set_scale(Vector2(0.6,0.8))
				if _i == 0:
					var mat = preload("res://new_shadermaterial2.tres")
					node.set_material(mat)
				elif _i == 1:
					var mat = preload("res://new_shadermaterial3.tres")
					node.set_material(mat)					
				
				node.set_global_position(\
					box_upleft-spacingy*1.4+\
					_i*dot_text_yspacing+\
					dot_text_yspacing*2.9+slope_txt_1y_spacing-1.2*spacingx)				
				add_child(node)
					
	# choose the values by sliders if choosen
			if slider_current_idx == _i:
				get_node("val_slope1x"+str(_i)).text = str(slope_value[_i][0])
				get_node("val_slope1y"+str(_i)).text = str(slope_value[_i][1])
				get_node("val_slope2x"+str(_i)).text = str(slope_value[_i][2])
				get_node("val_slope2y"+str(_i)).text = str(slope_value[_i][3])
				
	# slope value text set to black when choosen
			if slider_current_idx == _i:
				
				get_node("val_slope"+str(_i)).add_color_override(\
					"font_color", color_slope_text)		
				get_node("val_slope1x"+str(_i)).add_color_override(\
					"font_color", color1)	
				get_node("val_slope1y"+str(_i)).add_color_override(\
					"font_color", color2)	
				get_node("val_slope2x"+str(_i)).add_color_override(\
					"font_color", color3)	
				get_node("val_slope2y"+str(_i)).add_color_override(\
					"font_color", color4)	
				get_node("Sprite_right_brac"+str(_i)).material.\
					set_shader_param("to_color2", color_bracket)
				get_node("Sprite_right_brac"+str(_i)).material.\
					set_shader_param("to_color2", color_bracket)				
				get_node("val_slope"+str(_i)+"low_idx").add_color_override(\
					"font_color", color_slope_text)	
																					
			else:	
				get_node("val_slope"+str(_i)).add_color_override(\
					"font_color", ColorN("White"))	
				get_node("val_slope1x"+str(_i)).add_color_override(\
					"font_color", ColorN("White"))	
				get_node("val_slope1y"+str(_i)).add_color_override(\
					"font_color", ColorN("White"))	
				get_node("val_slope2x"+str(_i)).add_color_override(\
					"font_color", ColorN("White"))	
				get_node("val_slope2y"+str(_i)).add_color_override(\
					"font_color", ColorN("White"))	
				get_node("Sprite_right_brac"+str(_i)).material.\
					set_shader_param("to_color2",ColorN("White"))
				get_node("Sprite_right_brac"+str(_i)).material.\
					set_shader_param("to_color2",ColorN("White"))
				get_node("val_slope"+str(_i)+"low_idx").add_color_override(\
					"font_color", ColorN("White"))	

	# remove the text when some points are removed
	for i in range(len(point_coord),2):
		if get_node_or_null("val_slope"+str(i)):
			get_node_or_null("val_slope"+str(i)).queue_free()
			get_node_or_null("val_slope1x"+str(i)).queue_free()
			get_node_or_null("val_slope1y"+str(i)).queue_free()
			get_node_or_null("val_slope2x"+str(i)).queue_free()
			get_node_or_null("val_slope2y"+str(i)).queue_free()
			get_node("Sprite_right_brac"+str(i)).queue_free()
			get_node("Sprite_left_brac"+str(i)).queue_free()
			get_node_or_null("val_slope"+str(i)+"low_idx").queue_free()

#	time_end = OS.get_ticks_msec()
#	if time_array.size() < 1000:
#		time_array.append(time_end-time_start)
#		print(str(time_array.size())+": "+str(time_end-time_start))
		

func _draw():
	# draw all fixed points
	for i in range(numpoints):
		draw_circle(axes_origin+point_coord[i],
			5.0, Color(16/255.0,21/255.0,102/255.0,1))			
	
	# draw a decoration box
	var start_corner = box_upleft+Vector2(-10,-23)
	draw_line(start_corner, start_corner+Vector2(side_box_width,0),\
		ColorN("Black"),1.0,true)
	draw_line(start_corner, start_corner+Vector2(0,side_box_height),\
		ColorN("Black"),1.0,true)
	draw_line(start_corner+Vector2(side_box_width,0),\
		start_corner+Vector2(side_box_width,side_box_height),\
		ColorN("Black"),1.0,true)
	draw_line(start_corner+Vector2(side_box_width,side_box_height),\
		start_corner+Vector2(0,side_box_height),\
		ColorN("Black"),1.0,true)
			
##############################

func dist_two_points(point1, point2):
	var square_dist 
	square_dist = (point1.x - point2.x)*(point1.x - point2.x) + \
		(point1.y - point2.y)*(point1.y - point2.y)
	return sqrt(square_dist)
