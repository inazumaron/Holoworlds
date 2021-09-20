extends Node2D

var COOLDOWN = 0.5
var PROJ_SPEED = 200
var DAMAGE = 1
var TYPE = 0
var EFFECT = 1 #1 - for no effects default
var EVALUE = 100
var MAX_SCALE = 3
var MIN_SCALE = 1
var MIN_DIST = 100
var MAX_DIST = 200

var duration = 0
var distance = 0
var midway = 0
var scale_v = MIN_SCALE
var exploding = false

var bodies_entered = []

signal BombExplode(damage, type, effect, eval)
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("charging")
	distance = max(global_position.distance_to(get_global_mouse_position()), MIN_DIST)	#min distance of 200
	distance = min(distance, MAX_DIST)							#max distance of 800
	duration = distance/PROJ_SPEED
	midway = duration/2

func _process(delta):
	duration -= delta
	
	if duration <= 0:
		explode()
		scale.x = 1.5
		scale.y = 1.5
	else:
		$AnimatedSprite.rotation_degrees += delta*360
		self.translate(Vector2(PROJ_SPEED,0).rotated(rotation)*delta)
		
		if duration > midway:
			if scale.x < MAX_SCALE:
				scale.x *= 1.005
				scale.y *= 1.005
		else:
			if scale.x > MIN_SCALE:
				scale.x *= 0.995
				scale.y *= 0.995

func explode():
	$AnimatedSprite.play("explode")
	exploding = true


func _on_AnimatedSprite_animation_finished():
	if exploding:
		for body in bodies_entered:
			if !body.is_in_group("Player") and !(body == self):
				if body.has_method("take_damage"):
					self.connect("BombExplode",body,"take_damage")
		emit_signal("BombExplode",DAMAGE, TYPE, 1, 0)
		queue_free()


func _on_Area2D_body_entered(body):
	bodies_entered.append(body)


func _on_Area2D_body_exited(body):
	bodies_entered.erase(body)
