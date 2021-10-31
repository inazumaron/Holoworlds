extends Node
#For holding variable values

#Character related data
var main_char_active = true
var main_char = 0
var main_char_stats = {"CHAR_CODE":0, "HP": 0, "MAX_HP": 0, "MAX_SPEED": 0, "ATTACK_DMG":0, "ATTACK_COOLDOWN":0, 
	"ATTACK_STACK":0 ,"ATTACK_EFFECT":0, "SPECIAL_CODE":0}
	#Special code will just simply correspond to ability ID, 0 means no skill
var co_1_active = false
var co_char_1 = 0
var co_char_1_stats = main_char_stats
var co_2_active = false
var co_char_2 = 0
var co_char_2_stats = main_char_stats

var item1 = "pekora_collab"
var item2 = "flare_collab"
#Game related data
var level = 1
var level_list = []

var MAX_LEVELS = 10		#how many levels 
var WORLD_NUM = 5		#amount of available worlds
var curr_world_id = "none"

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
	#0/1 - no additional effects
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

func return_player_path(code):
	if code == 0:
		code = main_char
	if code == 130:	#flare
		return preload("res://PlayerEntity/char_Flare.tscn")
	elif code == 131:	#marine
		return ""
	elif code == 132:	#noel
		return preload("res://PlayerEntity/char_Noel.tscn")
	elif code == 133:	#pekora
		return preload("res://PlayerEntity/char_Pekora.tscn")
	elif code == 134:	#rushia
		return ""

func is_char_blank(n):
	if n == main_char:
		if main_char_stats["CHAR_CODE"] == 0:
			return true
		return false
	if n == co_char_1:
		if co_char_1_stats["CHAR_CODE"] == 0:
			return true
		return false
	if n == co_char_2:
		if co_char_2_stats["CHAR_CODE"] == 0:
			return true
		return false
		
func get_char_stat(n):
	if n == main_char:
		return main_char_stats
	if n == co_char_1:
		return co_char_1_stats
	if n == co_char_2:
		return co_char_2_stats
		
func update_char_stat(n, stats):
	if n == main_char:
		main_char_stats = stats
	if n == co_char_1:
		co_char_1_stats = stats
	if n == co_char_2:
		co_char_2_stats = stats

func next_level(char_data):
	level += 1
	save_data(char_data)

func save_data(data):
	var file = File.new()
	
	file.open("res://Data/save.sv", File.WRITE)
	file.store_string(var2str(data))
	file.close()
	
func load_data(path):
	var file = File.new()
	
	file.open(path, File.READ)
	var data = str2var(file.get_as_text())
	file.close()
	
	return data

func collab_recruit(stats,slot):
	if slot == 1:
		co_1_active = true
		main_char_active = false
		co_char_1_stats = stats
		co_char_1 = stats["CHAR_CODE"]
		curr_world_id.collab_recruit(slot,true)
	if slot == 2:
		co_2_active = true
		main_char_active = false
		co_char_2_stats = stats
		co_char_2 = stats["CHAR_CODE"]
		curr_world_id.collab_recruit(slot,true)
