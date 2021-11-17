extends Node2D

var ENEMY_CHECK = 1 #check enemy state every n seconds

var borders = Rect2(-100,-100,1000,1000)
var level = 0
var enemy_budget = 0
var enemy_list = []
var enemy_check_timer = 0
var last_val = 0 #for debugging, mainly for printing check
var room_list = [] #will hold every rooms initial creation spot

onready var tileMap = $TileMap

var player = GameHandler.return_player_path(0)
var c1_path = GameHandler.return_player_path(GameHandler.co_char_1)
var c2_path = GameHandler.return_player_path(GameHandler.co_char_2)
var e_1_1 = preload("res://EnemyEntity/e_g_zombie_basic.tscn")
var e_1_2 = preload("res://EnemyEntity/e_g_fandead_basic.tscn")

var item_handler = preload("res://GameEntity/ItemHandler.tscn")
var IH_inst

var player_inst
var collab_char_1 = "none"
var collab_char_2 = "none"

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	level = GameHandler.level
	GameHandler.curr_world_id = self
	enemy_budget = 5 + (level * 5)
	generate_level()
	generate_player()
	generate_collab()
	IH_inst = item_handler.instance()
	get_tree().get_root().add_child(IH_inst)

func _process(delta):
	enemy_check_timer += delta
	if enemy_check_timer >= ENEMY_CHECK:
		check_enemies()
		enemy_check_timer = 0
	
func check_enemies():
	for e in enemy_list:
		if e.is_dead == true:
			e.queue_free()
			enemy_list.erase(e)
	if last_val != len(enemy_list):
		print(len(enemy_list))
		last_val = len(enemy_list)
	if len(enemy_list) == 0:
		level_end()

func generate_player():
	player_inst = player.instance()
	player_inst.position = Vector2(100,100)
	get_tree().get_root().add_child(player_inst)

func generate_collab(): #generate characters if there are already existing collab mate before
	if GameHandler.co_char_1 != 0:
		collab_recruit(1,false)
		print("recruited?")
	if GameHandler.co_char_2 != 0:
		collab_recruit(2,false)

func collab_recruit(num, active): #call this in case of recruiting collab mid level
	if num == 1:
		if c1_path == player:
			c1_path = GameHandler.return_player_path(GameHandler.co_char_1)
		collab_char_1 = c1_path.instance()
		collab_char_1.position = GameHandler.player_pos
		collab_char_1.ACTIVE = active
		if active:
			player_inst.activate(false)
			if typeof(collab_char_2) != 4: #if not string
				collab_char_2.activate(false)
		get_tree().get_root().add_child(collab_char_1)
		
	if num == 2:
		if c2_path == player:
			c2_path = GameHandler.return_player_path(GameHandler.co_char_2)
		collab_char_2 = c2_path.instance()
		collab_char_2.position = GameHandler.player_pos
		collab_char_2.ACTIVE = active
		if active:
			player_inst.activate(false)
			if typeof(collab_char_1) != 4:
				collab_char_1.activate(false)
		get_tree().get_root().add_child(collab_char_2)

func switch_active_char(code):
	if code == 0:
		player_inst.position = GameHandler.player_pos
		player_inst.activate(true)
		if typeof(collab_char_1) != 4:
			collab_char_1.activate(false)
		if typeof(collab_char_2) != 4:
			collab_char_2.activate(false)
	if code == 1:
		collab_char_1.position = GameHandler.player_pos
		collab_char_1.activate(true)
		player_inst.activate(false)
		if typeof(collab_char_2) != 4:
			collab_char_2.activate(false)
	if code == 2:
		collab_char_2.position = GameHandler.player_pos
		collab_char_2.activate(true)
		player_inst.activate(false)
		if typeof(collab_char_1) != 4:
			collab_char_1.activate(false)

func generate_level():
	var walker = Walker.new(Vector2(0,0), borders)
	var temp = walker.walk(200)
	var map = temp[0]
	var min_coor = Vector2(INF,INF)
	var max_coor = Vector2(0,0)
	room_list = temp[1]
	walker.queue_free()
	
	#setting walkable path
	for location in map:
		tileMap.set_cellv(location, 24 + randi()%2)
		if location.x < min_coor.x:
			min_coor.x = location.x
		if location.x > max_coor.x:
			max_coor.x = location.x
		if location.y < min_coor.y:
			min_coor.y = location.y
		if location.y > max_coor.y:
			max_coor.y = location.y
	
	#adding tiles to whole map
	# 0 - def
	# 2 - wall start
	# 4 - wall end
	# 6 - dg
	# 8 - dg right g
	# 10 - dg left g
	# 12 - dg up
	# 14 - dg right ws
	# 16 - dg left ws
	# 18 - dg right we
	# 20 - dg left we
	# 22 - dg topright g (top and right not g)
	# 24 - dg topleft g
	# 26 - wall right
	# 28 - wall left
	# 30 - dg top and right g
	# 32 - dg top and left g
	# 34 - tomb row up/down
	# 38 - tomb col left/right
	# 42 - 2x2 tomb
	# 44 - 1 tomb tl/tr/bl/br
	# 52 - 3x3 tl/tm/tr/ml...
	# 61 - m statue f/d/z
	# 67 - b statue c/r/o
	for y_coor in range (min_coor.y-10, max_coor.y+10):
		for x_coor in range (min_coor.x-10, max_coor.x+10):
			if tileMap.get_cellv(Vector2(x_coor,y_coor)) == -1:
				if cell_free(x_coor,y_coor + 1):
					tileMap.set_cellv(Vector2(x_coor,y_coor - 1), 24 + 4)
					tileMap.set_cellv(Vector2(x_coor,y_coor), 24 + 2)
					#no texture for wall start side
				else:
					tileMap.set_cellv(Vector2(x_coor,y_coor), 24 + 6)
					if cell_free(x_coor,y_coor - 1) and cell_free(x_coor + 1,y_coor):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 24 + 30)
					elif cell_free(x_coor + 1,y_coor):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 24 + 8)
					elif cell_free(x_coor,y_coor - 1):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 24 + 12)
					elif cell_free(x_coor,y_coor - 1) and cell_free(x_coor - 1,y_coor):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 24 + 32)
					elif cell_free(x_coor - 1,y_coor):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 24 + 10)
					elif cell_free(x_coor + 1 ,y_coor - 1):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 24 + 22)
					elif cell_free(x_coor - 1,y_coor - 1):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 24 + 24)
					
		
	generate_obtsacles()
	tileMap.update_bitmask_region(borders.position, borders.end)
	
	generate_enemies(map)

func cell_free(x,y): #mainly used in generate level function
	if tileMap.get_cellv(Vector2(x,y)) == 24 or tileMap.get_cellv(Vector2(x,y)) == 25:
		return true
	return false

func adjacent_free(map, loc):
	var adj_free = true
	for i in range(-1,2):
		for j in range(-1,2):
			if tileMap.get_cellv(loc + Vector2(i,j)) != 8:
				adj_free = false
				break
	return adj_free

func generate_obtsacles():
	#obstacles in tilemap
	for temp in room_list:
		if temp[3] == false:
			var rand_num = randf()
			if rand_num < 0.1:
				generate_room(temp[0],temp[1],0)
			elif rand_num < 0.2:
				generate_room(temp[0],temp[1],1)
			elif rand_num < 0.3:
				generate_room(temp[0],temp[1],2)
			elif rand_num < 0.4:
				generate_room(temp[0],temp[1],3)
			elif rand_num < 0.5:
				generate_room(temp[0],temp[1],4)
			elif rand_num < 0.6:
				generate_room(temp[0],temp[1],5)
			elif rand_num < 0.7:
				generate_room(temp[0],temp[1],6)
			elif rand_num < 0.8:
				generate_room(temp[0],temp[1],7)
			elif rand_num < 0.85:
				generate_room(temp[0],temp[1],8)
			elif rand_num < 0.9:
				generate_room(temp[0],temp[1],9)
			elif rand_num < 0.95:
				generate_room(temp[0],temp[1],10)
			else:
				generate_room(temp[0],temp[1],11)

func generate_room(pos,s,n): #(x,y) size(w,h) room var n
	var x_coor = pos.x
	var y_coor = pos.y
	var num = (randi()%2)*2
	var num2 = randi()%3
	if n == 0:#empty
		pass
	elif n == 1:#2 even tomb row
		for x in range(1,s-1):
			tileMap.set_cellv(Vector2(x_coor+x,y_coor+1), 58 + randi()%2 + num)
			if s >= 7:
				tileMap.set_cellv(Vector2(x_coor+x,y_coor+5), 58 + randi()%2 + num)
	elif n == 2:#3 even tomb row
		for x in range(1,s-1):
			tileMap.set_cellv(Vector2(x_coor+x,y_coor+1), 58 + randi()%2 + num)
			if s >= 5:
				tileMap.set_cellv(Vector2(x_coor+x,y_coor+3), 58 + randi()%2 + num)
			if s >= 7:
				tileMap.set_cellv(Vector2(x_coor+x,y_coor+5), 58 + randi()%2 + num)
	elif n == 3:#2 uneven tomb row
		for x in range(1,s-1):
			if randi()%3 < 2:
				tileMap.set_cellv(Vector2(x_coor+x,y_coor+1), 58 + randi()%2 + num)
			if s >= 5 and randi()%3 < 2:
				tileMap.set_cellv(Vector2(x_coor+x,y_coor+3), 58 + randi()%2 + num)
			if s >= 7 and randi()%3 < 2:
				tileMap.set_cellv(Vector2(x_coor+x,y_coor+5), 58 + randi()%2 + num)
	elif n == 4:#2 even tomb col
		for y in range(1,s-1):
			tileMap.set_cellv(Vector2(x_coor+1,y_coor+y), 62 + randi()%2 + num)
			if s >= 7:
				tileMap.set_cellv(Vector2(x_coor+5,y_coor+y), 62 + randi()%2 + num)
	elif n == 5:#3 even tomb col
		for y in range(1,s-1):
			tileMap.set_cellv(Vector2(x_coor+1,y_coor+y), 62 + randi()%2 + num)
			if s >= 5:
				tileMap.set_cellv(Vector2(x_coor+3,y_coor+y), 62 + randi()%2 + num)
			if s >= 7:
				tileMap.set_cellv(Vector2(x_coor+5,y_coor+y), 62 + randi()%2 + num)
	elif n == 6:#2 uneven tomb col
		for y in range(1,s-1):
			if randi()%3 < 2:
				tileMap.set_cellv(Vector2(x_coor+1,y_coor+y), 62 + randi()%2 + num)
			if s >= 5 and randi()%3 < 2:
				tileMap.set_cellv(Vector2(x_coor+3,y_coor+y), 62 + randi()%2 + num)
			if s >= 7 and randi()%3 < 2:
				tileMap.set_cellv(Vector2(x_coor+5,y_coor+y), 62 + randi()%2 + num)
	elif n == 7:#3x3 tomb center
		var offset = 0
		if s>=5:
			offset = 1
		if s>=7:
			offset = 2
		tileMap.set_cellv(Vector2(x_coor+offset,y_coor+offset), 76)
		tileMap.set_cellv(Vector2(x_coor+offset+1,y_coor+offset), 77)
		tileMap.set_cellv(Vector2(x_coor+offset+2,y_coor+offset), 78)
		tileMap.set_cellv(Vector2(x_coor+offset,y_coor+offset+1), 79)
		tileMap.set_cellv(Vector2(x_coor+offset+1,y_coor+offset+1), 80)
		tileMap.set_cellv(Vector2(x_coor+offset+2,y_coor+offset+1), 81)
		tileMap.set_cellv(Vector2(x_coor+offset,y_coor+offset+2), 82)
		tileMap.set_cellv(Vector2(x_coor+offset+1,y_coor+offset+2), 83)
		tileMap.set_cellv(Vector2(x_coor+offset+2,y_coor+offset+2), 84)
	elif n == 8:#large statue at center
		var offset = 0
		if s>=5:
			offset = 1
		if s>=7:
			offset = 2
		if offset>0:
			tileMap.set_cellv(Vector2(x_coor+offset,y_coor+offset), 91 + num2*6)
			tileMap.set_cellv(Vector2(x_coor+offset+1,y_coor+offset), 92 + num2*6)
			tileMap.set_cellv(Vector2(x_coor+offset,y_coor+offset+1), 93 + num2*6)
			tileMap.set_cellv(Vector2(x_coor+offset+1,y_coor+offset+1), 94 + num2*6)
			tileMap.set_cellv(Vector2(x_coor+offset,y_coor+offset+2), 95 + num2*6)
			tileMap.set_cellv(Vector2(x_coor+offset+1,y_coor+offset+2), 96 + num2*6)
	elif n == 9:#2 med statues
		if s >=3: #1 statue
			tileMap.set_cellv(Vector2(x_coor+1,y_coor+1), 85 + num2*2)
			tileMap.set_cellv(Vector2(x_coor+1,y_coor+2), 86 + num2*2)
		if s >=5:
			tileMap.set_cellv(Vector2(x_coor+3,y_coor+1), 85 + num2*2)
			tileMap.set_cellv(Vector2(x_coor+3,y_coor+2), 86 + num2*2)
			
	elif n == 10:#2x2 tomb at corners
		tileMap.set_cellv(Vector2(x_coor,y_coor), 66 + randi()%2)
		tileMap.set_cellv(Vector2(x_coor+s-1,y_coor), 66 + randi()%2)
		tileMap.set_cellv(Vector2(x_coor,y_coor+s-1), 66 + randi()%2)
		tileMap.set_cellv(Vector2(x_coor+s-1,y_coor+s-1), 66 + randi()%2)
	elif n == 11:#9 tombs evenly spaced 
		if s > 3:
			tileMap.set_cellv(Vector2(x_coor,y_coor), 68 + randi()%8)
			tileMap.set_cellv(Vector2(x_coor+ceil(s/2),y_coor), 68 + randi()%8)
			tileMap.set_cellv(Vector2(x_coor+s-1,y_coor), 68 + randi()%8)
			tileMap.set_cellv(Vector2(x_coor,y_coor+ceil(s/2)), 68 + randi()%8)
			tileMap.set_cellv(Vector2(x_coor+ceil(s/2),y_coor+ceil(s/2)), 68 + randi()%8)
			tileMap.set_cellv(Vector2(x_coor+s-1,y_coor+ceil(s/2)), 68 + randi()%8)
			tileMap.set_cellv(Vector2(x_coor,y_coor+s-1), 68 + randi()%8)
			tileMap.set_cellv(Vector2(x_coor+ceil(s/2),y_coor+s-1), 68 + randi()%8)
			tileMap.set_cellv(Vector2(x_coor+s-1,y_coor+s-1), 68 + randi()%8)

func generate_enemies(map):
	var e_pos = []
	var e_val = []
	
	var room_budget = enemy_budget/max((len(room_list)-1),1)
	
	for room in room_list:
		var room_cell = room[2]
		var budget = room_budget
		if room[3]: #if room is start pos, no enemies to allocate here
			budget = 0
		while budget > 0 and len(room_cell) > 0:
			for cell in room_cell:
				if randf() < 0.2 and tileMap.get_cellv(cell) < 30: #random chance and cell free
					var temp = rand_enemy()
					var temp_inst = temp.instance()
					if temp_inst.COST <= budget+1:
						budget -= temp_inst.COST
						e_val.append(temp)
						e_pos.append(cell)
						room_cell.erase(cell)
					temp_inst.queue_free()
	var e_seed = randi()%100
	for i in range(0, len(e_pos)):
		var location = e_pos[i]
		var enemy = e_val[i]
		var e_inst = enemy.instance()
		e_inst.position = location*64
		e_inst.rotation_degrees = 0
		e_inst.SEED = e_seed
		e_seed += 1
		get_tree().get_root().add_child(e_inst)
		enemy_list.append(e_inst)

func rand_enemy():
	var e_list = [e_1_1, e_1_2] #update this when more enemies available
	return e_list[randi() % len(e_list)]

func level_end():
	print("level cleared")
	GameHandler.next_level(player_inst.send_data())
	player_inst.queue_free()
	if typeof(collab_char_1) != 4:
		collab_char_1.queue_free()
	if typeof(collab_char_2) != 4:
		collab_char_2.queue_free()
	IH_inst.queue_free()
	get_tree().change_scene("res://GameEntity/routeList.tscn")

func update_player_items():
	player_inst.ui_manipulation(3)
	if typeof(collab_char_1) != 4:
		collab_char_1.ui_manipulation(3)
	if typeof(collab_char_2) != 4:
		collab_char_2.ui_manipulation(3)
