extends Node2D

signal EntityHit(damage, type, effect, eValue)

var DAMAGE = 1
var TYPE = 0 #physical
var ROTATION_SPEED = 180
var SPEED = 300
var EFFECT = 0
var EVALUE = 0

func _ready():
	look_at(GameHandler.player_pos)

func _process(delta):
	$Sprite.rotation += deg2rad(delta*ROTATION_SPEED)
	self.translate(Vector2(SPEED*delta,0).rotated(rotation))

func _on_Hitbox_area_entered(body):
	if body != self and !body.is_in_group("enemy_list"):
		queue_free()

func _on_Hitbox_body_entered(body):
	if body != self and !body.is_in_group("enemy_list"):
		if body.has_method("take_damage"):
			self.connect("EntityHit",body,"take_damage")
			emit_signal("EntityHit",DAMAGE, TYPE, EFFECT, EVALUE)
		queue_free()
