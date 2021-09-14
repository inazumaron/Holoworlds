extends Node

func rng_move(rng, direction,TO_PLAYER, random_movement, global_position):
	var offset = deg2rad(rng.randi_range(0, 30))
	direction = global_position.angle_to_point(GameHandler.player_pos)
	if TO_PLAYER:
		direction += deg2rad(180)
	if random_movement: #if chasing, no random movement
		direction += offset

func apply_friction(amount, movement):
	if movement.length() > amount:
		movement -= movement.normalized() * amount
	else:
		movement = Vector2.ZERO
		
func apply_movement(acceleration, movement, direction, MAX_SPEED):
	movement += Vector2(acceleration,0).rotated(direction)
	movement = movement.clamped(MAX_SPEED)

func take_damage(dam, type, effect, hp, is_dead, visible, position):
	#type is either physical, magic or true
	hp -= dam
	if hp <= 0:
		is_dead = true
		visible = false
		position = Vector2(0,0)
		
func check_player_near(global_position, player_deteted):
	$PlayerDetect.rotation = global_position.angle_to_point(GameHandler.player_pos)
	if $PlayerDetect.is_colliding():
		player_deteted = true
