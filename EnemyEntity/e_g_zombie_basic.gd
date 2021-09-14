extends KinematicBody2D

var MOVE_TIMER = 5
var FIRE_TIMER = 2 #delay before 
var ACCELERATION = 1000
var MAX_SPEED = 150
var SEED = 0
var COST = 0.5
var TO_PLAYER = true
var ATTACK_COOLDOWN = 0.5
var ATTACK_DURATION = 0.5
var DAMAGE = 1
var TYPE = 0
var EFFECT = 0
var EVALUE = 0
var DAMAGE_ANIMATION = 0.2

var hp = 3
var move_count = 1
var movement = Vector2.ZERO
var can_move = false
var direction = 0
var attack_cooldown_timer = 0
var general_timer = 0
var attacking = false
var chasing = false
var damaged = false
#effect related
var knock_back_duration = 0
var debuff_val = 0

var in_camera = false
var is_dead = false
var player = null

var rng = RandomNumberGenerator.new()

signal EntityHit(damage,type, effect)

func _ready():
	rng.seed = SEED
	add_to_group("enemy_list")

func rng_move():
	var offset = deg2rad(rng.randi_range(0, 30))
	direction = global_position.angle_to_point(GameHandler.player_pos)
	if TO_PLAYER:
		direction += deg2rad(180)
	if !chasing: #if chasing, no random movement
		direction += offset

func _physics_process(delta):
	if in_camera and !damaged:
		
		general_timer += delta
		move_count += delta/MOVE_TIMER
		
		if attack_cooldown_timer < ATTACK_COOLDOWN:
			attack_cooldown_timer += delta
			
		if general_timer > 1 and !chasing:
			check_player_near()
			general_timer = 0
		
		#-------------------------------------moving randomly
		if !chasing:
			if move_count >= .5:
				move_count = 0
				rng_move()
			
			if move_count > 0.3:
				can_move = true
			else:
				can_move = false
		else:
			if move_count >= .1:
				move_count = 0
				rng_move()
				if !attacking and attack_cooldown_timer >= ATTACK_COOLDOWN:
					check_player_in_range()
			can_move = true
			
		if can_move and !attacking:
			$AnimatedSprite.play("walk")
			$AnimatedSprite.scale.x = sgn(movement.x)
			apply_movement(ACCELERATION*delta)
		elif !attacking:
			$AnimatedSprite.play("idle")
			apply_friction(ACCELERATION*delta)
		else:
			apply_friction(ACCELERATION*delta)
		movement = move_and_slide(movement)
	else:
		if knock_back_duration > 0:
			knock_back_duration -= delta
			apply_movement(ACCELERATION*delta)
			movement = move_and_slide(movement)
		chasing = false

func sgn(num):
	if num >= 0:
		return -1
	else:
		return 1

func attack():
	$AnimatedSprite.play("attack")
	yield(get_tree().create_timer(ATTACK_DURATION),"timeout")
	$AnimatedSprite.stop()
	if player != null:
		self.connect("EntityHit",player,"take_damage")
		emit_signal("EntityHit",DAMAGE, TYPE, EFFECT, EVALUE)
	attack_cooldown_timer = 0
	attacking = false
	
func check_player_near():
	$PlayerDetect.rotation = global_position.angle_to_point(GameHandler.player_pos)
	if $PlayerDetect.is_colliding():
		chasing = true
		
func check_player_in_range():
	if player != null:
		attacking = true
		attack()

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
	if effect % 2 == 0 and effect != 0: #knockback effect
		direction = 180 + (GameHandler.player_pos).angle_to_point(global_position) #get direction of hit
		knock_back_duration = DAMAGE_ANIMATION
		debuff_val = eValue
	
	hp -= dam
	if hp <= 0:
		is_dead = true
		visible = false
		position = Vector2(0,0)
		
	#play damaged animation
	$AnimatedSprite.play("damaged")
	damaged = true
	yield(get_tree().create_timer(DAMAGE_ANIMATION),"timeout")
	damaged = false

func _on_VisibilityNotifier2D_screen_entered():
	in_camera = true

func _on_VisibilityNotifier2D_screen_exited():
	in_camera = false

func _on_AttackBox_body_entered(body):
	if body.has_method("take_damage") and !body.is_in_group("enemy_list"):
		player = body

func _on_AttackBox_body_exited(body):
	if body == player:
		player = null
