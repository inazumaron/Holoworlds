extends KinematicBody2D

#--------------------stats related
var MAX_SPEED = 300
var ACCELERATION = 1000
var POS_UPDATE_TIMER = .1
var MAX_HP = 10
var HP = 10
var DEF = 0 #0 by default, reduces damage by a flat amount. 

var ATTACK_COOLDOWN = 0.5
var ATTACK_STACK_COUNT = 1
var ATTACK_DAMAGE = 1
var ATTACK_TYPE = 0
var ATTACK_EFFECT = 0

var SPECIAL_COOLDOWN = 1
var SPECIAL_REGEN_TYPE = 0 #0 - auto, 1 - offensive, 2 - defensive

var DAMAGE_ANIM_DUR = 0.2
#---------------------------------
var motion = Vector2.ZERO
var pos_timer = 0
var last_anim_dir = 0 #0 - left, 1 - right
var damage_anim_timer = 0

var weapon_m = preload("res://PlayerEntity/flare_bow.tscn")
var weapon = weapon_m.instance()

var ui = preload("res://GameEntity/CharUI.tscn")
var ui_inst = ui.instance()

func _ready():
	add_child(weapon)
	
	ui_inst.NORMAL_STACK = false	#normal can stack
	ui_inst.SPEC_STACK = false		#special can stack
	ui_inst.N_STACK_MAX = weapon.STACK_MAX
	ui_inst.S_STACK_MAX = 3			#max stack count of special
	ui_inst.S_CHARGE_MODE = 0		#0 if auto charge, else offensive charge
	ui_inst.N_COOLDOWN = weapon.COOLDOWN
	ui_inst.S_COOLDOWN = 1
	ui_inst.N_ANIM_DUR = 0
	ui_inst.S_ANIM_DUR = 1
	ui_inst.scale = (Vector2(0.5,0.5))
	add_child(ui_inst)
	
	ui_manipulation(0)

func _physics_process(delta):
	var axis = get_input_axis()
	
	if Input.is_action_just_pressed("mouse_click"):
		ui_manipulation(1)
		
	if Input.is_action_just_pressed("mouse_click_r"):
		ui_manipulation(2)
	
	if damage_anim_timer > 0:
		damage_anim_timer -= delta
	
	if axis == Vector2.ZERO:
		apply_friction(ACCELERATION*delta)
	else:
		apply_movement(axis*ACCELERATION*delta)
	motion = move_and_slide(motion)
	
	pos_timer += delta
	if pos_timer >= POS_UPDATE_TIMER:
		pos_timer = 0
		GameHandler.player_pos = global_position

func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	anim_update(axis)
	return axis.normalized()

func apply_friction(amount):
	if motion.length() > amount:
		motion -= motion.normalized() * amount
	else:
		motion = Vector2.ZERO

func apply_movement(acceleration):
	motion += acceleration
	motion = motion.clamped(MAX_SPEED)

func anim_update(axis):
	if damage_anim_timer > 0:
		if last_anim_dir == 0:
			$AnimatedSprite.play("damage_left")
		else:
			$AnimatedSprite.play("damage_right")
	elif axis.x != 0 || axis.y != 0:
		if axis.x > 0:
			$AnimatedSprite.play("walk_right")
			last_anim_dir = 1
		elif axis.x < 0:
			$AnimatedSprite.play("walk_left")
			last_anim_dir = 0
		elif last_anim_dir == 0:
			$AnimatedSprite.play("walk_left")
		else:
			$AnimatedSprite.play("walk_right")
	else:
		if last_anim_dir == 0:
			$AnimatedSprite.play("idle_left")
		else:
			$AnimatedSprite.play("idle_right")

func take_damage(damage, type, effect, eValue):
	#damage_anim_timer = DAMAGE_ANIM_DUR #remove comment when damage animation available
	HP -= damage
	print("HP: ",HP)
	if HP <= 0:
		print("dead")
	else:
		ui_manipulation(0)

func ui_manipulation(n):
	#	0 - update life
	#	1 - normal click
	#	2 - special click
	#
	if n == 0:
		ui_inst.update_HP(HP,MAX_HP)
		ui_inst.update_shp_self(HP,MAX_HP)
	elif n == 1:
		ui_inst.Skill_normal_update(-1)
	elif n == 2:
		ui_inst.Skill_special_update(-1)
