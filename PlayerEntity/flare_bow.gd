extends Node2D

var COOLDOWN = 0.5
var PROJ_SPEED = 600
var DAMAGE = 1
var TYPE = 0
var EFFECT = 1 #1 - for no effects default
var EVALUE = 100
var STACK_MAX = 1

var stack_count = 0
var can_attack = true
var cooldown_counter = 0

var projectile = preload("res://PlayerEntity/flare_arrow_normal.tscn")

func _ready():
	$AnimatedSprite.play("loading")

func _process(delta):
	
	look_at(get_global_mouse_position())
	
	if cooldown_counter < COOLDOWN:
		cooldown_counter += delta
	else:
		$AnimatedSprite.play("loaded")
		
	if Input.is_action_pressed("mouse_click") and cooldown_counter >= COOLDOWN:
		shoot()
		cooldown_counter = 0
		$AnimatedSprite.play("loading")

func shoot():
	var projectile_inst = projectile.instance()
	projectile_inst.position = $Bow_tip.get_global_position()
	projectile_inst.rotation = rotation
	projectile_inst.apply_impulse(Vector2(), Vector2(PROJ_SPEED,0).rotated(rotation))
	get_tree().get_root().add_child(projectile_inst)
