extends Node2D

var MIN_D = 50
var MAX_D = 200
var parent
var counter = 1

func distance(parent_pos):
	return parent_pos.distance_to(get_global_mouse_position())

func _process(delta):
	var parent_pos = parent.global_position
	look_at(get_global_mouse_position())
	
	if distance(parent_pos) < MIN_D:
		$target.global_position = parent_pos + Vector2(MIN_D,0).rotated(rotation)
	if distance(parent_pos) >= MIN_D and distance(parent_pos) <= MAX_D:
		$target.global_position = get_global_mouse_position()
	if distance(parent_pos) > MAX_D:
		$target.global_position = parent_pos + Vector2(MAX_D,0).rotated(rotation)
