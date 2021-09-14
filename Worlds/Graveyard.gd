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

var player = GameHandler.return_player_path()
var e_1_1 = preload("res://EnemyEntity/e_g_zombie_basic.tscn")
var e_1_2 = preload("res://EnemyEntity/e_g_fandead_basic.tscn")

var player_inst

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	level = GameHandler.level
	enemy_budget = level * 10
	generate_level()
	generate_player()

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
		print("level cleared")
		player_inst.queue_free()
		get_tree().change_scene("res://GameEntity/routeList.tscn")

func generate_player():
	player_inst = player.instance()
	player_inst.position = Vector2(100,100)
	get_tree().get_root().add_child(player_inst)

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
		tileMap.set_cellv(location, 0)
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
	# 1 - def top
	# 5 - def right
	# 6 - def left
	# 7 - def bot
	# 18 - top left
	# 19 - top right
	# 20 - bot left
	# 21 - bot right
	# 2 - top
	# 4 - top grass above wall
	# 16 - top grass
	for y_coor in range (min_coor.y-10, max_coor.y+10):
		for x_coor in range (min_coor.x-10, max_coor.x+10):
			if tileMap.get_cellv(Vector2(x_coor,y_coor)) == -1:
				if tileMap.get_cellv(Vector2(x_coor,y_coor + 1)) == 0:
					tileMap.set_cellv(Vector2(x_coor,y_coor - 1), 4)
					tileMap.set_cellv(Vector2(x_coor,y_coor), 2)
					tileMap.set_cellv(Vector2(x_coor,y_coor + 1), 1)
				else:
					tileMap.set_cellv(Vector2(x_coor,y_coor), 16)
					if tileMap.get_cellv(Vector2(x_coor,y_coor - 1)) == 0:
						tileMap.set_cellv(Vector2(x_coor,y_coor - 1), 7)
					if tileMap.get_cellv(Vector2(x_coor + 1,y_coor)) == 0:
						tileMap.set_cellv(Vector2(x_coor + 1,y_coor), 6)
					if tileMap.get_cellv(Vector2(x_coor - 1,y_coor)) == 0:
						tileMap.set_cellv(Vector2(x_coor - 1,y_coor), 5)
					if tileMap.get_cellv(Vector2(x_coor + 1,y_coor)) == 1:
						tileMap.set_cellv(Vector2(x_coor + 1,y_coor), 18)
					if tileMap.get_cellv(Vector2(x_coor - 1,y_coor)) == 1:
						tileMap.set_cellv(Vector2(x_coor - 1,y_coor), 19)
					if tileMap.get_cellv(Vector2(x_coor,y_coor - 1)) == 6:
						tileMap.set_cellv(Vector2(x_coor,y_coor - 1), 20)
					if tileMap.get_cellv(Vector2(x_coor,y_coor - 1)) == 5:
						tileMap.set_cellv(Vector2(x_coor,y_coor - 1), 21)
					
		
	generate_obtsacles()
	tileMap.update_bitmask_region(borders.position, borders.end)
	
	generate_enemies(map)

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
	# no change				22%
	# 3 - tile variant 		30%
	# 8 - 11 light blockage	32%
	# 12 - 15 big blockage	16%
	for temp in room_list:
		var cell_list = temp[2]
		for cell in cell_list:
			var rand_num = randf()
			if rand_num < 0.04:
				tileMap.set_cellv(cell,15)
			elif rand_num < 0.08:
				tileMap.set_cellv(cell,14)
			elif rand_num < 0.12:
				tileMap.set_cellv(cell,13)
			elif rand_num < 0.16:
				tileMap.set_cellv(cell,12)
			elif rand_num < 0.24:
				tileMap.set_cellv(cell,11)
			elif rand_num < 0.32:
				tileMap.set_cellv(cell,10)
			elif rand_num < 0.40:
				tileMap.set_cellv(cell,9)
			elif rand_num < 0.48:
				tileMap.set_cellv(cell,8)
			elif rand_num < 0.78:
				tileMap.set_cellv(cell,3)

func generate_enemies(map):
	var e_pos = []
	var e_val = []
	
	var room_budget = enemy_budget/len(room_list)
	
	for room in room_list:
		var room_cell = room[2]
		var budget = room_budget
		while budget > 0 and len(room_cell) > 0:
			for cell in room_cell:
				if randf() < 0.1:
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
