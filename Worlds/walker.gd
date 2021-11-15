extends Node
class_name Walker

const DIRECTIONS = [Vector2.RIGHT,Vector2.UP,Vector2.LEFT,Vector2.DOWN]

var position = Vector2.ZERO
var direction = Vector2.RIGHT
var borders = Rect2()
var step_history = []
var room_list = []	#contains cells inside rooms, avoid duplicates
var steps_since_turn = 0

func _init(starting_position, new_borders):
	assert(new_borders.has_point(starting_position))
	position = starting_position
	step_history.append(position)
	borders = new_borders
	
func walk(steps):
	create_room(position,4,true)
	for step in steps:
		if steps_since_turn >= 10:
			change_direction()
		if step():
			step_history.append(position)
		else:
			change_direction()
	print("roomlist length",len(room_list))
	return [step_history,room_list]
	
func step():
	var target_position = position + direction
	if borders.has_point(target_position):
		steps_since_turn += 1
		position = target_position
		widen(position)
		return true
	else:
		return false
	
func change_direction():
	var n = randi()%2 + 5
	create_room(position,n,false)
	steps_since_turn = 0
	var directions = DIRECTIONS.duplicate()
	directions.erase(direction)
	directions.shuffle()
	direction = directions.pop_front()
	while not borders.has_point(position + direction):
		direction = directions.pop_front()

func create_room(pos,n,start_pos):
	var room_exist = false
	var x_range = [INF,-INF]
	var y_range = [INF,-INF]
	for data in room_list:
		if data[4] == pos:
			room_exist = true
	if room_exist == false:
		var size = Vector2(randi() % 2 + n, randi() % 2 + n)
		var top_left_corner = (pos - size/2).ceil()
		var room_cells = []
		for y in size.y:
			for x in size.x:
				var new_step = top_left_corner + Vector2(x,y)
				if borders.has_point(new_step):
					step_history.append(new_step)
					#if does not exist in list
					room_cells.append(new_step)
					#getting min/max values for boundaries
					if new_step.x < x_range[0]:
						x_range[0] = new_step.x
					if new_step.x > x_range[1]:
						x_range[1] = new_step.x
					if new_step.y < y_range[0]:
						y_range[0] = new_step.y
					if new_step.y > y_range[1]:
						y_range[1] = new_step.y
		#remove room_cell borders,leaving available space for enemy spawn
		var room_cells_inside = []
		for cell in room_cells:
			if !(cell.x == x_range[0] or cell.x == x_range[1] or cell.y == y_range[0] or cell.y == y_range[1]):
				room_cells_inside.append(cell)
		room_list.append([top_left_corner,min(size.x,size.y),room_cells_inside,start_pos,pos])
				
func widen(pos):
	var size = Vector2(3, 3)
	var top_left_corner = (pos - size/2).ceil()
	for y in size.y:
		for x in size.x:
			var new_step = top_left_corner + Vector2(x,y)
			if borders.has_point(new_step):
				step_history.append(new_step)
