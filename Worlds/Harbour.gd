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
var e_1_1 = preload("res://EnemyEntity/e_h_pirate_axe.tscn")
var e_1_2 = preload("res://EnemyEntity/e_h_pirate_gun.tscn")

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
	enemy_budget = 5 + (level * 7)
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
	walker.WIDEN_PATH = false
	walker.SQR_ROOMS = true
	walker.ROOM_SIZE_OFFSET = 3
	walker.PATH_LENGTH_OFFSET = 12
	var temp = walker.walk(200)
	var map = temp[0]
	var min_coor = Vector2(INF,INF)
	var max_coor = Vector2(0,0)
	room_list = temp[1]
	walker.queue_free()
	
	#setting walkable path
	for location in map:
		if location.x < min_coor.x:
			min_coor.x = location.x
		if location.x > max_coor.x:
			max_coor.x = location.x
		if location.y < min_coor.y:
			min_coor.y = location.y
		if location.y > max_coor.y:
			max_coor.y = location.y
	
	var mid_y = min_coor.y + ceil((0.5)*(max_coor.y-min_coor.y))
	
	
	for location in map:
		if location.y < mid_y:
			tileMap.set_cellv(location, 0)
		else:
			tileMap.set_cellv(location, 48)
	#adding tiles to whole map
	# 0 - path
	# 2 - water
	for y_coor in range (min_coor.y-10, max_coor.y+10):
		for x_coor in range (min_coor.x-10, max_coor.x+10):
			if tileMap.get_cellv(Vector2(x_coor,y_coor)) == -1:
				if y_coor < mid_y:
					tileMap.set_cellv(Vector2(x_coor,y_coor), 1)
					if cell_free(x_coor,y_coor - 1) and cell_free(x_coor + 1,y_coor):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 36)
					elif cell_free(x_coor,y_coor + 1) and cell_free(x_coor + 1,y_coor):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 12)
					elif cell_free(x_coor,y_coor + 1) and cell_free(x_coor - 1,y_coor):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 11)
					elif cell_free(x_coor,y_coor - 1) and cell_free(x_coor - 1,y_coor):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 10)
					elif cell_free(x_coor,y_coor + 1):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 5)
					elif cell_free(x_coor + 1,y_coor):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 3)
					elif cell_free(x_coor,y_coor - 1):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 4)
					elif cell_free(x_coor - 1,y_coor):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 2)
					elif cell_free(x_coor + 1 ,y_coor - 1):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 7)
					elif cell_free(x_coor - 1,y_coor - 1):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 6)
					elif cell_free(x_coor + 1 ,y_coor + 1):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 9)
					elif cell_free(x_coor - 1,y_coor + 1):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 8)
				else:
					tileMap.set_cellv(Vector2(x_coor,y_coor), 49)
					if cell_free(x_coor,y_coor - 1) and cell_free(x_coor + 1,y_coor):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 59)
					elif cell_free(x_coor,y_coor + 1) and cell_free(x_coor + 1,y_coor):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 61)
					elif cell_free(x_coor,y_coor + 1) and cell_free(x_coor - 1,y_coor):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 60)
					elif cell_free(x_coor,y_coor - 1) and cell_free(x_coor - 1,y_coor):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 58)
					elif cell_free(x_coor,y_coor + 1):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 51)
					elif cell_free(x_coor + 1,y_coor):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 53)
					elif cell_free(x_coor,y_coor - 1):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 50)
					elif cell_free(x_coor - 1,y_coor):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 52)
					elif cell_free(x_coor + 1 ,y_coor - 1):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 55)
					elif cell_free(x_coor - 1,y_coor - 1):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 54)
					elif cell_free(x_coor + 1 ,y_coor + 1):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 57)
					elif cell_free(x_coor - 1,y_coor + 1):
						tileMap.set_cellv(Vector2(x_coor,y_coor), 56)
	generate_obtsacles(mid_y)
	tileMap.update_bitmask_region(borders.position, borders.end)
	print("generating enemies")
	generate_enemies(map)

func cell_free(x,y): #mainly used in generate level function, free = walkable
	if tileMap.get_cellv(Vector2(x,y)) == 0 or tileMap.get_cellv(Vector2(x,y)) == 48 or tileMap.get_cellv(Vector2(x,y)) == 21:
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

func generate_obtsacles(mid_y):
	#obstacles in tilemap
	for temp in room_list:
		var boat = false
		if temp[0].y + temp[1] < mid_y:
			boat = true
		if temp[3] == false:
			var rand_num = randf()
			if rand_num < 0.3:
				generate_room(temp[0],temp[1],0,boat)
			elif rand_num < 0.4:
				generate_room(temp[0],temp[1],1,boat)
			elif rand_num < 0.5:
				generate_room(temp[0],temp[1],2,boat)
			elif rand_num < 0.6:
				generate_room(temp[0],temp[1],3,boat)
			elif rand_num < 0.7:
				generate_room(temp[0],temp[1],4,boat)
			elif rand_num < 0.8:
				generate_room(temp[0],temp[1],5,boat)
			elif rand_num < 0.9:
				generate_room(temp[0],temp[1],6,boat)
			else:
				generate_room(temp[0],temp[1],7,boat)

func generate_room(pos,s,n,boat): #(x,y) size(w,h) room var n
	var x_coor = pos.x
	var y_coor = pos.y
	if boat:
		# change walkable tiles to board tiles
		for i in range (x_coor, x_coor + s):
			for j in range (y_coor, y_coor + s):
				tileMap.set_cellv(Vector2(i,j), 21)
		#adding frame
		for i in range (x_coor-1, x_coor + s + 1):
			for j in range (y_coor-1, y_coor + s + 1):
				if i == x_coor-1 or i == x_coor + s or j == y_coor-1 or j == y_coor + s:
					if tileMap.get_cellv(Vector2(i,j)) != 0:
						if i == x_coor - 1:
							if j == y_coor - 1:
								tileMap.set_cellv(Vector2(i,j),13)
							elif j == y_coor + s:
								tileMap.set_cellv(Vector2(i,j),27)
								tileMap.set_cellv(Vector2(i-1,j),24)
							else:
								tileMap.set_cellv(Vector2(i,j),20)
						elif i == x_coor + s:
							if j == y_coor - 1:
								tileMap.set_cellv(Vector2(i,j),15)
							elif j == y_coor + s:
								tileMap.set_cellv(Vector2(i,j),29)
								tileMap.set_cellv(Vector2(i+1,j),17)
							else:
								tileMap.set_cellv(Vector2(i,j),22)
						else:
							if j == y_coor - 1:
								tileMap.set_cellv(Vector2(i,j),14)
							else:
								tileMap.set_cellv(Vector2(i,j),28)
		#adding corners
		#left
		var c_len = ceil(s/2)
		var offset = c_len
		for i in range (x_coor - c_len - 1, x_coor - 1):
			offset -= 1
			for j in range (y_coor + offset , y_coor + s - offset):
				if tileMap.get_cellv(Vector2(i,j)) != 0:
					if fmod(s,2) == 1 and i == x_coor - c_len -1:
						tileMap.set_cellv(Vector2(i,j), 18)
					elif j == y_coor + offset:
						tileMap.set_cellv(Vector2(i,j), 19)
					elif j == y_coor + s - offset -1:
						tileMap.set_cellv(Vector2(i,j), 25)
						tileMap.set_cellv(Vector2(i-1,j), 24) # connector
					else:
						tileMap.set_cellv(Vector2(i,j), 30)
		#right
		for i in range (x_coor + s + 1, x_coor + s + c_len + 1):
			for j in range (y_coor + offset , y_coor + s - offset):
				if tileMap.get_cellv(Vector2(i,j)) != 0:
					if fmod(s,2) == 1 and i == x_coor + s + c_len:
						tileMap.set_cellv(Vector2(i,j), 26)
					elif j == y_coor + offset:
						tileMap.set_cellv(Vector2(i,j), 23)
					elif j == y_coor + s - offset -1:
						tileMap.set_cellv(Vector2(i,j), 16)
						tileMap.set_cellv(Vector2(i+1,j), 17) # connector
					else:
						tileMap.set_cellv(Vector2(i,j), 30)
			offset += 1
		#adding props
		var prop_index = [32,33,34,35,37,38,39,40]
		if n == 0:#empty
			pass
		elif n == 1:#4 center
			tileMap.set_cellv(Vector2(x_coor+floor(s/3),y_coor+floor(s/3)), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+floor(2*s/3),y_coor+floor(s/3)), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+floor(s/3),y_coor+floor(2*s/3)), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+floor(2*s/3),y_coor+floor(2*s/3)), prop_index[randi()%(len(prop_index))])
		elif n == 2:#4 corner
			tileMap.set_cellv(Vector2(x_coor,y_coor), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+s-1,y_coor), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor,y_coor+s-1), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+s-1,y_coor+s-1), prop_index[randi()%(len(prop_index))])
		elif n == 3:#5 center
			tileMap.set_cellv(Vector2(x_coor+1,y_coor+1), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+s-2,y_coor+1), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+1,y_coor+s-2), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+s-2,y_coor+s-2), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+floor(s/2),y_coor+floor(s/2)), prop_index[randi()%(len(prop_index))])
		elif n == 4:#big center
			pass
		elif n == 5:#9 complex
			tileMap.set_cellv(Vector2(x_coor+1,y_coor+1), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+1,y_coor+floor(s/2)), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+1,y_coor+s-2), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+floor(s/2),y_coor+1), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+floor(s/2),y_coor+floor(s/2)), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+floor(s/2),y_coor+s-2), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+s-2,y_coor+1), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+s-2,y_coor+floor(s/2)), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+s-2,y_coor+s-2), prop_index[randi()%(len(prop_index))])
		elif n == 6:#2 uneven col
			var x1_hole = false
			var x2_hole = false
			for i in range (y_coor, y_coor+s+1):
				if y_coor<y_coor+s or x1_hole:
					if randf() < 0.66:
						tileMap.set_cellv(Vector2(x_coor+floor(s/3),i), prop_index[randi()%(len(prop_index))])
					else:
						x1_hole = true
				if y_coor<y_coor+s or x2_hole:
					if randf() < 0.66:
						tileMap.set_cellv(Vector2(x_coor+floor(2*s/3),i), prop_index[randi()%(len(prop_index))])
					else:
						x2_hole = true
		elif n == 7:#uneven row
			var y1_hole = false
			var y2_hole = false
			for i in range (x_coor, x_coor+s+1):
				if x_coor<x_coor+s or y1_hole:
					if randf() < 0.66:
						tileMap.set_cellv(Vector2(i,y_coor+floor(s/3)), prop_index[randi()%(len(prop_index))])
					else:
						y1_hole = true
				if x_coor<x_coor+s or y2_hole:
					if randf() < 0.66:
						tileMap.set_cellv(Vector2(i,y_coor+floor(2*s/3)), prop_index[randi()%(len(prop_index))])
					else:
						y2_hole = true
	else: #not boat
		#adding props
		var prop_index = [62,63,64,65,66,67,68,69,78]
		if n == 0:#empty
			pass
		elif n == 1:#4 center
			tileMap.set_cellv(Vector2(x_coor+floor(s/3),y_coor+floor(s/3)), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+floor(2*s/3),y_coor+floor(s/3)), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+floor(s/3),y_coor+floor(2*s/3)), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+floor(2*s/3),y_coor+floor(2*s/3)), prop_index[randi()%(len(prop_index))])
		elif n == 2:#4 corner
			tileMap.set_cellv(Vector2(x_coor,y_coor), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+s-1,y_coor), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor,y_coor+s-1), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+s-1,y_coor+s-1), prop_index[randi()%(len(prop_index))])
		elif n == 3:#5 center
			tileMap.set_cellv(Vector2(x_coor+1,y_coor+1), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+s-2,y_coor+1), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+1,y_coor+s-2), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+s-2,y_coor+s-2), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+floor(s/2),y_coor+floor(s/2)), prop_index[randi()%(len(prop_index))])
		elif n == 4:#big center
			var rnum = randi()%2
			rnum *= 6
			tileMap.set_cellv(Vector2(x_coor+floor(s/2),y_coor+1), 84 + rnum)
			tileMap.set_cellv(Vector2(x_coor+floor(s/2)+1,y_coor+1), 85 + rnum)
			tileMap.set_cellv(Vector2(x_coor+floor(s/2),y_coor+2), 86 + rnum)
			tileMap.set_cellv(Vector2(x_coor+floor(s/2)+1,y_coor+2), 87 + rnum)
			tileMap.set_cellv(Vector2(x_coor+floor(s/2),y_coor+3), 88 + rnum)
			tileMap.set_cellv(Vector2(x_coor+floor(s/2)+1,y_coor+3), 89 + rnum)
		elif n == 5:#9 complex
			tileMap.set_cellv(Vector2(x_coor+1,y_coor+1), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+1,y_coor+floor(s/2)), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+1,y_coor+s-2), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+floor(s/2),y_coor+1), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+floor(s/2),y_coor+floor(s/2)), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+floor(s/2),y_coor+s-2), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+s-2,y_coor+1), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+s-2,y_coor+floor(s/2)), prop_index[randi()%(len(prop_index))])
			tileMap.set_cellv(Vector2(x_coor+s-2,y_coor+s-2), prop_index[randi()%(len(prop_index))])
		elif n == 6:#2 uneven col
			var x1_hole = false
			var x2_hole = false
			for i in range (y_coor, y_coor+s+1):
				if y_coor<y_coor+s or x1_hole:
					if randf() < 0.66:
						tileMap.set_cellv(Vector2(x_coor+floor(s/3),i), prop_index[randi()%(len(prop_index))])
					else:
						x1_hole = true
				if y_coor<y_coor+s or x2_hole:
					if randf() < 0.66:
						tileMap.set_cellv(Vector2(x_coor+floor(2*s/3),i), prop_index[randi()%(len(prop_index))])
					else:
						x2_hole = true
		elif n == 7:#uneven row
			var y1_hole = false
			var y2_hole = false
			for i in range (x_coor, x_coor+s+1):
				if x_coor<x_coor+s or y1_hole:
					if randf() < 0.66:
						tileMap.set_cellv(Vector2(i,y_coor+floor(s/3)), prop_index[randi()%(len(prop_index))])
					else:
						y1_hole = true
				if x_coor<x_coor+s or y2_hole:
					if randf() < 0.66:
						tileMap.set_cellv(Vector2(i,y_coor+floor(2*s/3)), prop_index[randi()%(len(prop_index))])
					else:
						y2_hole = true
		
func generate_enemies(map):
	var e_pos = []
	var e_val = []
	
	var room_budget = enemy_budget/max((len(room_list)-1),1)
	print("1")
	for room in room_list:
		var room_cell = room[2]
		var budget = room_budget
		if room[3]: #if room is start pos, no enemies to allocate here
			budget = 0
		while budget > 0 and len(room_cell) > 0:
			var cell_available = false
			for cell in room_cell:
				if (tileMap.get_cellv(cell) == 0 or tileMap.get_cellv(cell) == 48 or tileMap.get_cellv(cell) == 21): #random chance and cell free
					cell_available = true
					if randf() < 0.2:
						var temp = rand_enemy()
						var temp_inst = temp.instance()
						if temp_inst.COST <= budget+1:
							budget -= temp_inst.COST
							e_val.append(temp)
							e_pos.append(cell)
							room_cell.erase(cell)
						temp_inst.queue_free()
			if !cell_available:
				print("no available space for enemy")
				break
	print("2")
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
	print("3")

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
