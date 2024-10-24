extends Area2D

var player = null

func can_see_player():
	return player != null

func _on_body_entered(body: Node2D) -> void:
	get_parent().target_attack = body
	player = body

func _on_body_exited(_body: Node2D) -> void:
	player = null
