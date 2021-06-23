extends Line2D

##################
#     PARAMS
##################

# axes position
var center = Vector2(280,280)
var box_width = 350
var box_height = 230
var conversion_index = 30.0

var center_ref_square = center + Vector2(10,255)
var ratio = 1.0
var length_diag_ref_sq = 5*conversion_index/ratio # shrink the imag by 3 times
var vert_up
var vert_down
var vert_left
var vert_right

var ref_sq_color = Color(64/255.0,64/255.0,64/255.0,0.5)

onready var label_x = get_node("Label_forx")
onready var label_y = get_node("Label_fory")

# efficiency improve
var pre_idx
var now_idx
var time_array = Array()
var time_start
var time_end

# link data
onready var data_node = get_node("../draw_and_control_thepoints")
var slider_current_idx
var slider_update
var slope_value
var slopes

var diamond_colr = Color(255/255.0,255/255.0,255/255.0,1)
var color1 = Color(0/255.0,0/255.0,0/255.0,1)
var color4 = Color(0/255.0,107/255.0,56/255.0,1)

var dia_locvec1
var dia_locvec2
var dia_locvec1_neg
var dia_locvec2_neg

var initial_update = true

# finger control
var events = {}
var point_moving_cont = false
var finger_loc
var touch_dist = 10
var movedpt = {}
var buff_region = 10
var diamond_vec = []

var slope_1x
var slope_2x
var slope_1y
var slope_2y

# control on the graph
var point_coord
var coord
var chosen_point
var pre_coord
var now_coord
var min_arrow_len = 15.0

var flag_corner_moving = false
var dragging_fixed_flag 

##############################

func _ready():
	diamond_vec = [Vector2(0, 0),Vector2(0, 0)]

	# initialize link
	slider_current_idx = data_node.slider_current_idx
	slider_update = data_node.slider_update
	slope_value = data_node.slope_value
	point_coord = data_node.point_coord
	dragging_fixed_flag = data_node.dragging_fixed_point
	
	pre_idx = slider_current_idx
	
	slopes = slope_value # in prevention of array's simultaneous change
	coord = point_coord
	pre_coord = coord.duplicate()

	vert_up = coord[pre_idx] + center+Vector2(-box_width/2.0,box_height/2.0)+\
		Vector2(0,-length_diag_ref_sq)
	vert_down = coord[pre_idx] + center+Vector2(-box_width/2.0,box_height/2.0)+\
		Vector2(0, length_diag_ref_sq)
	vert_left = coord[pre_idx] + center+Vector2(-box_width/2.0,box_height/2.0)+\
		Vector2(-length_diag_ref_sq,0)
	vert_right = coord[pre_idx] + center+Vector2(-box_width/2.0,box_height/2.0)+\
		Vector2(length_diag_ref_sq,0)

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
			#slider_initial = true
			#pointmoved = true
			point_moving_cont = false
			flag_corner_moving = false

	if event.position.x > vert_left.x-buff_region and \
		event.position.x < vert_right.x+buff_region \
		and event.position.y < vert_down.y+buff_region and \
		event.position.y > vert_up.y-buff_region and \
		dragging_fixed_flag == false:
		if event is InputEventScreenDrag or \
			(event is InputEventScreenTouch and \
			event.is_pressed()):  # drag or touch input
			events[event.index] = event	
			if events.size() == 1: # one finger input
				finger_loc = event.position - coord[slider_current_idx]-\
					(center+Vector2(-box_width/2.0,box_height/2.0))
				if dist_two_points(finger_loc,Vector2(0,0))> min_arrow_len:
					if movedpt.size() == 1:
						if movedpt[0] <= 1:
							diamond_vec[movedpt[0]] = finger_loc
						elif movedpt[0]	<= 3:
							diamond_vec[movedpt[0]-2] = -finger_loc
							
						if movedpt[0] == 0:
							slope_1x = finger_loc.x*ratio/conversion_index
							slope_2x = -finger_loc.y*ratio/conversion_index
							slope_1x = stepify(slope_1x,0.01)
							slope_2x = stepify(slope_2x,0.01)
							data_node.slope_value[slider_current_idx][0]=slope_1x
							data_node.slope_value[slider_current_idx][2]=slope_2x
						elif movedpt[0] == 1: 	
							slope_1y = finger_loc.x*ratio/conversion_index
							slope_2y = -finger_loc.y*ratio/conversion_index	
							slope_1y = stepify(slope_1y,0.01)
							slope_2y = stepify(slope_2y,0.01)					
							data_node.slope_value[slider_current_idx][1]=slope_1y
							data_node.slope_value[slider_current_idx][3]=slope_2y
						elif movedpt[0] == 2:
							slope_1x = -finger_loc.x*ratio/conversion_index
							slope_2x = finger_loc.y*ratio/conversion_index
							slope_1x = stepify(slope_1x,0.01)
							slope_2x = stepify(slope_2x,0.01)
							data_node.slope_value[slider_current_idx][0]=slope_1x
							data_node.slope_value[slider_current_idx][2]=slope_2x
						elif movedpt[0] == 3: 	
							slope_1y = -finger_loc.x*ratio/conversion_index
							slope_2y = finger_loc.y*ratio/conversion_index	
							slope_1y = stepify(slope_1y,0.01)
							slope_2y = stepify(slope_2y,0.01)					
							data_node.slope_value[slider_current_idx][1]=slope_1y
							data_node.slope_value[slider_current_idx][3]=slope_2y
																								
						update()
					elif dist_two_points(finger_loc,diamond_vec[0]) \
						< touch_dist:
						flag_corner_moving = true
						#pointmoved = true
						movedpt[0] = 0
						diamond_vec[0] = finger_loc	
						update()	
						slope_1x = finger_loc.x*ratio/conversion_index
						slope_2x = -finger_loc.y*ratio/conversion_index
						slope_1x = stepify(slope_1x,0.01)
						slope_2x = stepify(slope_2x,0.01)
						data_node.slope_value[slider_current_idx][0]=slope_1x
						data_node.slope_value[slider_current_idx][2]=slope_2x
							
					elif dist_two_points(finger_loc,diamond_vec[1]) \
						< touch_dist:		
						flag_corner_moving = true									
						#pointmoved = true
						movedpt[0] = 1
						diamond_vec[1] = finger_loc	
						update()
						slope_1y = finger_loc.x*ratio/conversion_index
						slope_2y = -finger_loc.y*ratio/conversion_index						
						slope_1y = stepify(slope_1y,0.01)
						slope_2y = stepify(slope_2y,0.01)
						data_node.slope_value[slider_current_idx][1]=slope_1y
						data_node.slope_value[slider_current_idx][3]=slope_2y
	
					elif dist_two_points(finger_loc,-diamond_vec[0]) \
						< touch_dist:
						flag_corner_moving = true
						#pointmoved = true
						movedpt[0] = 2
						diamond_vec[0] = -finger_loc	
						update()	
						slope_1x = -finger_loc.x*ratio/conversion_index
						slope_2x = finger_loc.y*ratio/conversion_index
						slope_1x = stepify(slope_1x,0.01)
						slope_2x = stepify(slope_2x,0.01)
						data_node.slope_value[slider_current_idx][0]=slope_1x
						data_node.slope_value[slider_current_idx][2]=slope_2x
							
					elif dist_two_points(finger_loc,-diamond_vec[1]) \
						< touch_dist:	
						flag_corner_moving = true									
						#pointmoved = true
						movedpt[0] = 3
						diamond_vec[1] = -finger_loc	
						update()
						slope_1y = -finger_loc.x*ratio/conversion_index
						slope_2y = finger_loc.y*ratio/conversion_index						
						slope_1y = stepify(slope_1y,0.01)
						slope_2y = stepify(slope_2y,0.01)
						data_node.slope_value[slider_current_idx][1]=slope_1y
						data_node.slope_value[slider_current_idx][3]=slope_2y
						
func _process(delta):
		
	slider_current_idx = data_node.slider_current_idx
	slider_update = data_node.slider_update
	slope_value = data_node.slope_value
	dragging_fixed_flag = data_node.dragging_fixed_point
	
	now_idx = slider_current_idx
	slopes = slope_value # in prevention of array's simultaneous change
	
	point_coord = data_node.point_coord
	coord = point_coord	# in prevention of array's simultaneous change
	now_coord = coord.duplicate()

	# when delete a point, the idx is not simultaneously updated in the same frame
	if len(now_coord) == 1:
		pre_idx = 0
		now_idx = 0
	
	if slider_update == true or \
		(pre_idx != now_idx) or \
		initial_update == true or \
		pre_coord != now_coord: # update the square by data of the chosen point

		initial_update = false
		pre_coord = now_coord
		pre_idx = now_idx
		#time_start = OS.get_ticks_msec()
		
		vert_up = coord[pre_idx] + center+Vector2(-box_width/2.0,box_height/2.0)+\
			Vector2(0,-length_diag_ref_sq)
		vert_down = coord[pre_idx] + center+Vector2(-box_width/2.0,box_height/2.0)+\
			Vector2(0, length_diag_ref_sq)
		vert_left = coord[pre_idx] + center+Vector2(-box_width/2.0,box_height/2.0)+\
			Vector2(-length_diag_ref_sq,0)
		vert_right = coord[pre_idx] + center+Vector2(-box_width/2.0,box_height/2.0)+\
			Vector2(length_diag_ref_sq,0)
		
		diamond_vec[0] = Vector2(slopes[pre_idx][0]*conversion_index/ratio,\
			-slopes[pre_idx][2]*conversion_index/ratio)
		diamond_vec[1] = Vector2(slopes[pre_idx][1]*conversion_index/ratio,\
			-slopes[pre_idx][3]*conversion_index/ratio)

		slider_update = false
		data_node.slider_update = false
		update()
		pre_idx = now_idx
		
#		time_end = OS.get_ticks_msec()
#		if time_array.size() < 1000:
#			time_array.append(time_end-time_start)
#			print(str(time_array.size())+": "+str(time_end-time_start))

func _draw():
	# draw the diamond
	chosen_point = center+Vector2(-box_width/2.0,box_height/2.0)+\
		coord[pre_idx]

	dia_locvec1 = chosen_point + diamond_vec[0]+diamond_vec[1]
	dia_locvec2 = chosen_point + diamond_vec[0]-diamond_vec[1]
	dia_locvec1_neg = chosen_point-diamond_vec[0]-diamond_vec[1]
	dia_locvec2_neg = chosen_point-diamond_vec[0]+diamond_vec[1]

	draw_line(dia_locvec1,dia_locvec2, diamond_colr, 1.5, true)
	draw_line(dia_locvec2,dia_locvec1_neg, diamond_colr, 1.5, true)
	draw_line(dia_locvec1_neg, dia_locvec2_neg, diamond_colr, 1.5, true)
	draw_line(dia_locvec2_neg, dia_locvec1, diamond_colr, 1.5, true)

	draw_circle(chosen_point + diamond_vec[0], 2, color1)
	draw_circle(chosen_point + diamond_vec[1], 2, color4)
	draw_circle(chosen_point - diamond_vec[0], 2, color1)
	draw_circle(chosen_point - diamond_vec[1], 2, color4)
	
#################################

func draw_small_arrow(location, direction, color):
	var len_dir = direction.x * direction.x + direction.y * direction.y
	len_dir = sqrt(len_dir)
	direction = direction/len_dir
	
	var b = location + direction.rotated(PI*4.0/5.0)*10
	draw_line(b, location, color, 1.5, true)
	var c = location + direction.rotated(-PI*4.0/5.0)*10
	draw_line(c, location, color, 1.5, true)


func dist_two_points(point1, point2):
	var square_dist 
	square_dist = (point1.x - point2.x)*(point1.x - point2.x) + \
		(point1.y - point2.y)*(point1.y - point2.y)
	return sqrt(square_dist)
