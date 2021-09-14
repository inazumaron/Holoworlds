extends Node2D

var play_selected = false
var resume_selected = false
var archives_selected = false
var settings_selected = false
var quit_selected = false

func _ready():
	pass # Replace with function body.
	
func _process(delta):
	if Input.is_action_pressed("mouse_click"):
		if play_selected:
			get_tree().change_scene("res://GameEntity/CharSelect.tscn")
		if resume_selected:
			pass
		if archives_selected:
			pass
		if settings_selected:
			pass
		if quit_selected:
			get_tree().quit()

func _on_Area_Play_mouse_entered():
	play_selected = true

func _on_Area_Play_mouse_exited():
	play_selected = false

func _on_Area_Resume_mouse_entered():
	resume_selected = true

func _on_Area_Resume_mouse_exited():
	resume_selected = false

func _on_Area_Archives_mouse_entered():
	archives_selected = true

func _on_Area_Archives_mouse_exited():
	archives_selected = false

func _on_Area_Settings_mouse_entered():
	settings_selected = true

func _on_Area_Settings_mouse_exited():
	settings_selected = false

func _on_Area_Quit_mouse_entered():
	quit_selected = true

func _on_Area_Quit_mouse_exited():
	quit_selected = false
