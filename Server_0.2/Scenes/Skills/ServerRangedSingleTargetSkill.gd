extends RigidBody2D

var projectile_speed 
var life_time = 1.5
var skill_name
var player_id
var map
var direction
var skill_id
var processing_body = false

"""INIT"""
func _ready():
	apply_central_impulse(Vector2(projectile_speed, 0).rotated(rotation))
	SelfDestruct()

"""SELF DESTRUCT TENGO QUE APLICAR EN OTROS TAMBIEN"""
func SelfDestruct():
	await get_tree().create_timer(life_time).timeout
	queue_free()

"""SKILL HANDLER  BODY"""
func _on_hitbox_body_entered(body: Node2D) -> void:
	if processing_body == false:
		processing_body = true
		var new_class = (body.get_class())
		match new_class:
			"TileMapLayer":
				return
			"CharacterBody2D":
				if body.has_method("EnemyHurtbox"):
					body.EnemyHurtbox(self)
				elif body.has_method("PlayerHurtbox"):
					body.PlayerHurtbox(self)
				else:
					return
		get_node("CollisionShape2D").set_deferred("disabled", true)
		self.hide()
	else:
		return
