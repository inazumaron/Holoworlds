extends Node2D

var COOLDOWN = 0.75
var SWING_DURATION = .3
var SWING_SPEED = 2.5
var SWING_ANGLE = 180
var DAMAGE = 1
var TYPE = 0
var EFFECT = 2 #1 - for no effects default
var EVALUE = 100
var STACK_MAX = 2
var ACTIVE = true

var swing_dir = 1 #left - right
var can_swing = true
var angle_offset = 90
var last_mouse_angle
var stack_count = 0

var can_damage = false
var on_cooldown = false

var swing_dur_counter = 0
var cooldown_counter = 0

signal EntityHit(damage,type, effect, evalue)

func _ready():
	visible = false

func _process(delta):
	
	if can_swing:
		rotation = global_position.angle_to_point(get_global_mouse_position()) + deg2rad(angle_offset)
	else:
		rotation = last_mouse_angle + deg2rad(angle_offset)
		
	if Input.is_action_pressed("mouse_click") and can_swing and stack_count>0:
		last_mouse_angle = global_position.angle_to_point(get_global_mouse_position())
		visible = true
		can_swing = false
		can_damage = true
		swing_dur_counter = 0
		cooldown_counter = 0
		stack_count -= 1
	
	if can_damage and swing_dur_counter < SWING_DURATION:
		swing_dur_counter += delta
		
	if can_damage and swing_dur_counter >= SWING_DURATION:
		visible = false
		can_swing = true
		can_damage = false
		swing_dir *= -1
		
	if cooldown_counter < COOLDOWN:
		cooldown_counter += delta
		
	if cooldown_counter >= COOLDOWN:
		cooldown_counter = 0
		stack_count = min(stack_count+1, STACK_MAX)
		
	if !can_swing:
		angle_offset += SWING_ANGLE*swing_dir*delta*SWING_SPEED

func _on_Area2D_body_entered(body):
	if body.has_method("take_damage") and body.is_in_group("enemy_list") and can_damage and ACTIVE:
		self.connect("EntityHit",body,"take_damage")
		emit_signal("EntityHit",DAMAGE, TYPE, EFFECT, EVALUE)
		self.disconnect("EntityHit",body,"take_damage")
