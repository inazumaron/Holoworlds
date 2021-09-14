extends Node2D

var CHAR_VALUE = 0 

var active = false
var click = false
var click_timer = 0

var clicked = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_pressed("mouse_click") and active and click:
		GameHandler.main_char = CHAR_VALUE
		clicked = true
	
	if !click:
		click_timer += delta
	
	if click_timer > 1:
		click = true

func change_texture(path):
	$Sprite.set_texture(path)

func _on_Area2D_mouse_entered():
	active = true

func _on_Area2D_mouse_exited():
	active = false
