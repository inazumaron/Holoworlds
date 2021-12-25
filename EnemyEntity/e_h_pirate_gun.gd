extends KinematicBody2D

var MOVE_TIMER = 5
var FIRE_TIMER = 2 #delay before 
var ACCELERATION = 1000
var MAX_SPEED = 100
var SEED = 0
var ATTACK_DELAY = 0.25 #animation delay before executing attack
var ATTACK_DURATION = 0.25 #animation delay after attack delay setting animation to idle
var COST = 1
var TO_PLAYER = false
var BUBLLET_SPEED = 100
var ATTACK_COOLDOWN = 3

var animation_state = 1
var last_dir = 1 #-1 - left, 1 - right

var general_timer = 0
var attack_cooldown_timer = 2

var hp = 2
var move_count = 1
var movement = Vector2.ZERO
var can_move = false
var direction = 0

var attacking = false
var attack_delay_timer = 0

var in_camera = false
var is_dead = false
var player_detected = false;

var rng = RandomNumberGenerator.new()
var projectile = preload("res://EnemyEntity/p_fandead.tscn")

var weapon_m = preload("res://EnemyEntity/w_h_pirate_gun.tscn")
var weapon = weapon_m.instance()


func _ready():
	rng.seed = SEED
	add_to_group("enemy_list")
	change_animation("idle")
	add_child(weapon)
	weapon.position = $ArmPoint.position

func rng_move(random):
	var offset = deg2rad(rng.randi_range(0, 30))
	direction = global_position.angle_to_point(GameHandler.player_pos)
	if TO_PLAYER:
		direction += deg2rad(180)
	if random:
		direction += offset
	change_animation("walk")

func _physics_process(delta):
	if in_camera:
		
		general_timer += delta
		move_count += delta/MOVE_TIMER
		
		if attack_cooldown_timer < ATTACK_COOLDOWN:
			attack_cooldown_timer += delta
			if attack_cooldown_timer < ATTACK_COOLDOWN/3:
				animation_state = 1
			elif attack_cooldown_timer < (2/3)*ATTACK_COOLDOWN:
				animation_state = 2
			else:
				animation_state = 3
		
		if general_timer > 1:
			check_player_near()
			general_timer = 0
		
		#-------------------------------------moving randomly
		if move_count >= .5:
			move_count = 0
			rng_move(!player_detected)
		
		if move_count > 0.3:
			can_move = true
		else:
			can_move = false
			
		if can_move:
			apply_movement(ACCELERATION*delta)
			$AnimatedSprite.scale.x = sgn(movement.x)
			weapon.flip(-(sgn(movement.x)))
			last_dir = sgn(movement.x)
		else:
			apply_friction(ACCELERATION*delta)
		movement = move_and_slide(movement)
		
		#------------------------------------- player detection
		if attacking:
			attack()
	else:
		player_detected = false
		
func check_player_near():
	$PlayerDetect.rotation = global_position.angle_to_point(GameHandler.player_pos)
	if $PlayerDetect.is_colliding() and attack_cooldown_timer:
		player_detected = true
		attacking = true
		
func sgn(num):
	if num >= 0:
		return -1
	else:
		return 1

func flip(): #since generally this type of enemy is facing away from player, so look before attacking
	$AnimatedSprite.scale.x = sgn(last_dir)
	weapon.flip(sgn(last_dir))

func attack():
	flip()
	weapon.attack()
	attacking = false
	change_animation("attack")
	yield(get_tree().create_timer(ATTACK_DELAY),"timeout")
	attack_cooldown_timer = 0
	var p_inst = projectile.instance()
	p_inst.global_position = global_position
	get_tree().get_root().add_child(p_inst)
	yield(get_tree().create_timer(ATTACK_DURATION),"timeout")
	change_animation("idle")

func apply_friction(amount):
	if movement.length() > amount:
		movement -= movement.normalized() * amount
	else:
		movement = Vector2.ZERO
		
func apply_movement(acceleration):
	movement += Vector2(acceleration,0).rotated(direction)
	movement = movement.clamped(MAX_SPEED)

func take_damage(dam, type, effect, eValue):
	#type is either physical, magic or true
	change_animation("damage")
	hp -= dam
	if hp <= 0:
		is_dead = true
		visible = false
		position = Vector2(0,0)

func change_animation(code):
	if code == "attack":
		pass
	if code == "idle":
		$AnimatedSprite.play("idle")
	if code == "walk":
		$AnimatedSprite.play("walk")
	if code == "damage":
		$AnimatedSprite.play("damaged")
	$AnimatedSprite.scale.x = last_dir

func _on_VisibilityNotifier2D_screen_entered():
	in_camera = true

func _on_VisibilityNotifier2D_screen_exited():
	in_camera = false
