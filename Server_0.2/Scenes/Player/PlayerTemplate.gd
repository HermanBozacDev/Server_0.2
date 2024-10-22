extends CharacterBody2D


func _on_hurtbox_body_entered(body: Node2D) -> void:
	var ciudad_principal_node = get_parent().get_parent().get_parent().get_parent().get_node("CiudadPrincipalHandler")
	var game_server = get_node("/root/GameServer")
	var node_name = get_name()
	var key = "health"
	var damage = ServerData.skill_data[body.skill_name].SkillDamage
	var new_nickname = get_node("/root/GameServer/" + node_name).player_nickname
	var new_value = ServerData.player_data[new_nickname].health 

	ciudad_principal_node.PlayerHit(node_name, damage,body.player_id)
	game_server.UpdateKeyState(name,key,new_value)
 
