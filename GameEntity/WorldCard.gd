extends Node2D

var WORLD_VALUE = 0 
var ORIG_SIZE = 1
var SIZE_INCR = 0.1

var active = false
var mouse_over = false
var click = false
var click_timer = 0
var spr_text = ""
var next_step = "none"
var scene_change = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_pressed("mouse_click") and active and click and mouse_over:
		GameHandler.level += 1
		GameHandler.next_step = next_step
		scene_change = true;
	
	if !click:
		click_timer += delta
		
	if click_timer > 1 and active:
		click = true
		click_timer = 0
		print("ready")
		print(self)
			
func change_texture(path):
	$Sprite.set_texture(path)

func _on_Area2D_mouse_entered():
	if active and click:
		self.scale.x = ORIG_SIZE + SIZE_INCR
		self.scale.y = ORIG_SIZE + SIZE_INCR
		mouse_over = true

func _on_Area2D_mouse_exited():
	if active and click:
		self.scale.x = ORIG_SIZE
		self.scale.y = ORIG_SIZE
		mouse_over = false
