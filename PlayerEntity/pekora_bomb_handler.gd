extends AnimatedSprite

var COOLDOWN = 0.5
var PROJ_SPEED = 600
var DAMAGE = 1
var TYPE = 0
var EFFECT = 1 #1 - for no effects default
var EVALUE = 100
var STACK_MAX = 3
var MIN_DIST = 100
var MAX_DIST = 200

var stack_count = 0
var can_attack = true
var cooldown_counter = 0

var projectile = preload("res://PlayerEntity/pekora_bomb.tscn")

func _ready():
	pass

func _process(delta):
	
	look_at(get_global_mouse_position())
	
	if cooldown_counter < COOLDOWN:
		cooldown_counter += delta
		visible = false
	else:
		visible = true
		
	if Input.is_action_pressed("mouse_click") and cooldown_counter >= COOLDOWN:
		throw()
		cooldown_counter = 0

func throw():
	var projectile_inst = projectile.instance()
	projectile_inst.position = get_global_position()
	projectile_inst.rotation = rotation
	projectile_inst.MIN_DIST = MIN_DIST
	projectile_inst.MAX_DIST = MAX_DIST
	get_tree().get_root().add_child(projectile_inst)
