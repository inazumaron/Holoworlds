extends Node2D

#for member numberings, it wil be 3 digits, 100 digit - branch,  tens digit - generation, 1s digit - alphabetical order
# jp 1, id 2, en 3

var char_flare = preload("res://Sprites/char_card_flare.png")
var char_marine = preload("res://Sprites/char_card_marine.png")
var char_noel = preload("res://Sprites/char_card_noel.png")
var char_pekora = preload("res://Sprites/char_card_pekora.png")
var char_rushia = preload("res://Sprites/char_card_rushia.png")

var card = preload("res://GameEntity/CharCard.tscn")

var all_cards = []

func _ready():
	generate_cards()

func _process(delta):
	for x in all_cards:
		if x.clicked:
			for n in all_cards:
				n.queue_free()
			get_tree().change_scene("res://GameEntity/routeList.tscn")

func generate_cards():
	for i in range(0,5):
		var card_inst = card.instance()
		card_inst.position = Vector2(i*128 - 200, 32 - 200)
		card_inst.scale.x = 0.5
		card_inst.scale.y = 0.5
		card_inst.CHAR_VALUE = get_char_code(i);
		card_inst.change_texture(switch_texture(i))
		all_cards.append(card_inst)
		get_tree().get_root().add_child(card_inst)

func get_char_code(i):
	if i == 0:
		return 130
	if i == 1:
		return 131
	if i == 2:
		return 132
	if i == 3:
		return 133
	if i == 4:
		return 134

func switch_texture(i):
	if i == 0:
		return char_flare
	if i == 1:
		return char_marine
	if i == 2:
		return char_noel
	if i == 3:
		return char_pekora
	if i == 4:
		return char_rushia
