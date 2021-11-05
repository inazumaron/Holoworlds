extends Control

var ITEM_COOLDOWN = 0.5
var item_1 = "none"
var item_2 = "none"
var map_char = []	#characters can be cllabed on this map
var cooldown_1 = 0
var cooldown_2 = 0

func comm_item_list():
	#item = [name, type, stackable, stack, values...]
	#types:
	#	non_consumable		-	does not disappear, generally gives passive
	#	temp_stat_up		-	item not consumable but disappears after a while
	#	round_stat_up		-	gives stat boost for 1 level
	#	permanent_stat_up	-	bonus stat is permanent
	#	collab_ticket		-	allows player to recruit another talent
	#	switch_character	-	collab tickets are converted to character switching once used
	pass

func _ready():
	item_1 = GameHandler.item1
	item_2 = GameHandler.item2

func _process(delta):
	if cooldown_1 > 0:
		cooldown_1 -= delta
		
	if cooldown_2 > 0:
		cooldown_2 -= delta
	
	if Input.is_action_just_pressed("item_1_use") and cooldown_1 <= 0:
		item_use(item_1,1)
		cooldown_1 = ITEM_COOLDOWN
		
	if Input.is_action_just_pressed("item_2_use") and cooldown_2 <= 0:
		item_use(item_2,2)
		cooldown_2 = ITEM_COOLDOWN

func item_use(item_name,src): #src is if its from item1 or item2
	var item = get_item_value(item_name)
	if item[1] == "non_consumable":
		pass
	if item[1] == "temp_stat_up":
		pass
	if item[1] == "round_stat_up":
		pass
	if item[1] == "permanent_stat_up":
		pass
	if item[1] == "collab_ticket":
		collab_ticket_handler(item,src)
	if item[1] == "switch_character":
		switch_character_handler(item,src)

func switch_character_handler(item,src):
	var code = char_name_to_code(item[0])
	var new_code = GameHandler.switch_char(code)
	if src == 1:
		print("updating ",item_1)
		item_1 = char_code_to_name(new_code) + " switch"
		print(item_1)
	if src == 2:
		item_2 = char_code_to_name(new_code) + " switch"
	update_items()

func update_items(): #update items on gamehandler side
	GameHandler.update_item(item_1,item_2)
	
func get_item_value(item_name):
	if item_name == "pekora_collab":
		return ["Pekora collab ticket", "collab_ticket", 0, 1, 0]
	if item_name == "flare_collab":
		return ["Flare collab ticket", "collab_ticket", 0, 1, 0]
	if item_name == "collab_ticket":
		return ["Collab ticket", "collab_ticket", 0, 1, 0]
	if item_name == "Flare switch":
		return ["Flare", "switch_character", 0, 1, 0]
	if item_name == "Noel switch":
		return ["Noel", "switch_character", 0, 1, 0]
	if item_name == "Pekora switch":
		return ["Pekora", "switch_character", 0, 1, 0]

func collab_ticket_handler(item, src):
	var new_code = 0
	if item[0] == "Pekora collab ticket":
		var data = get_char_data(133)
		new_code = GameHandler.collab_recruit(data,src)
		ticket_update(new_code,src)
	if item[0] == "Flare collab ticket":
		var data = get_char_data(130)
		new_code = GameHandler.collab_recruit(data,src)
		ticket_update(new_code,src)
	if item[0] == "Noel collab ticket":
		var data = get_char_data(132)
		new_code = GameHandler.collab_recruit(data,src)
		ticket_update(new_code,src)
	if item[0] == "Normal collab ticket":		#map restricted characters
		pass
	if item[0] == "Universal collab ticket":	#all available characters unlocked
		pass
		
func get_char_data(code):
	var file = File.new()
	
	file.open("res://Data/charst.sv", File.READ)
	var data = str2var(file.get_as_text())
	file.close()
	
	var char_stats_en = data[var2str(code)]
	var char_stats_dc = {
		"CHAR_CODE":		code,
		"ATTACK_COOLDOWN": 	char_stats_en[0],
		"ATTACK_DMG": 		char_stats_en[1],
		"ATTACK_EFFECT": 	char_stats_en[2],
		"ATTACK_STACK": 	char_stats_en[3],
		"HP": 				char_stats_en[4],
		"MAX_HP": 			char_stats_en[5],
		"MAX_SPEED": 		char_stats_en[6],
		"SPECIAL_CODE": 	char_stats_en[7]
		}
	
	return char_stats_dc

func ticket_update(code, src):
	if src == 1:
		item_1 = char_code_to_name(code) + " switch"
	if src == 2:
		item_2 = char_code_to_name(code) + " switch"
	update_items()
	
func char_code_to_name(code):
	if code == 130:
		return "Flare"
	if code == 131:
		return "Marine"
	if code == 132:
		return "Noel"
	if code == 133:
		return "Pekora"
	if code == 134:
		return "Rushia"

func char_name_to_code(nam):
	if nam == "Flare":
		return 130
	if nam == "Marine":
		return 131
	if nam == "Noel":
		return 132
	if nam == "Pekora":
		return 133
	if nam == "Rushia":
		return 134
