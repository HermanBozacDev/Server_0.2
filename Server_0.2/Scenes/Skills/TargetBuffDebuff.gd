extends Node2D

var skill_name
var player_id
var map

var processing_body = false

func _ready() -> void:
	await (get_tree().create_timer(5).timeout)
	queue_free()



func _on_target_area_body_entered(body: Node2D) -> void:
	if processing_body == false:
		processing_body = true
		if body.has_method("EnemyBuffDebuff"):
			body.EnemyBuffDebuff(self)
		elif body.has_method("PlayerBuffDebuff"):
			body.PlayerBuffDebuff(self)
		else:
			print("ME COMI UN HIT DE MIS PROPIAS BALAS MEPA")
			return
		get_node("TargetArea/CollisionShape2D").set_deferred("disabled", true)
		self.hide()
	else:
		return
