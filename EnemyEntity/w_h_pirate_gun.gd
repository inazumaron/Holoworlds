extends Node2D

var ATTACK_DURATION = 1
var timer = 0
var idle = true

func _process(delta):
	if timer <= 0 and !idle:
		idle = true
		$AnimatedSprite.play("idle")
	elif !idle:
		timer -= delta

func attack():
	timer = ATTACK_DURATION
	$AnimatedSprite.play("attack")
	idle = false

func flip(n):
	$AnimatedSprite.set_scale(Vector2(n,1))
