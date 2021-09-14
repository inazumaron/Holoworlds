extends RigidBody2D

signal EntityHit(damage, type, effect, eval)

var DAMAGE = 1
var TYPE = 0 

func _on_Area2D_body_entered(body):
	if !body.is_in_group("Player") and !(body == self):
			if body.has_method("take_damage"):
				self.connect("EntityHit",body,"take_damage")
				emit_signal("EntityHit",DAMAGE, TYPE, 1, 0)
			queue_free()
