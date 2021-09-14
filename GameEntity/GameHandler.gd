extends Node
#For holding variable values

#Character related data
var main_char = 0
var main_char_stats = {"HP": 0, "MAX_HP": 0, "ACCELERATION":0, "MAX_SPEED": 0, "BASE_DMG":0}

var co_char_1 = 0
var co_char_1_stats = {}
var co_char_2 = 0
var co_char_2_stats = {}

#Game related data
var level = 1
var level_list = []

var MAX_LEVELS = 10		#how many levels 
var WORLD_NUM = 5		#amount of available worlds

var worlds = []
var pos = Vector2(0, MAX_LEVELS-1)
var next_step = "none"
var player_pos = Vector2.ZERO

func comm_attack_types():
	#0 - physical
	#1 - magic
	#2 - true
	pass

func comm_collision_layers():
	#1 - movement
	#2 - hit box and bullets
	#3 - detection
	pass

func comm_attack_effects():
	#0 - no additional effects
	#%2 - knockback
	pass

func generate_worlds(base):
	if len(worlds) == 0:
		randomize()
		for j in range(0,MAX_LEVELS):
			var temp = []
			for i in range(0,MAX_LEVELS):
				if j == 0:
					temp.append(base)
				else:
					var n = randi() % WORLD_NUM
					while n == base:
						n = randi() % WORLD_NUM
					temp.append(n)
			worlds.append(temp)
	return worlds
	
func move():
	print(pos)
	if next_step == "left":
		pos.y -= 1
		pos.x = (MAX_LEVELS + int(pos.x - 1)) % MAX_LEVELS
	if next_step == "up":
		pos.y -= 1
	if next_step == "right":
		pos.y -= 1
		pos.x = int(pos.x + 1) % MAX_LEVELS
	print("moved ",next_step)
	print(pos)
	next_step = "none"
	return pos

func return_player_path():
	if main_char == 130:	#flare
		return preload("res://PlayerEntity/char_Flare.tscn")
	elif main_char == 131:	#marine
		return ""
	elif main_char == 132:	#noel
		return preload("res://PlayerEntity/Player_melee.tscn")
	elif main_char == 133:	#pekora
		return ""
	elif main_char == 134:	#rushia
		return ""
