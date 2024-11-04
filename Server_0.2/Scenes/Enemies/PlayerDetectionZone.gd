extends Area2D

var player = null


"""DEVOLVER PLAYER BODY"""
func can_see_player():
	return player != null


"""PLAYER ENTRO AL AREA"""
func _on_body_entered(body: Node2D) -> void:
	get_parent().target_attack = body
	player = body

"""PLAYER SALIO DEL AREA"""
func _on_body_exited(_body: Node2D) -> void:
	player = null
