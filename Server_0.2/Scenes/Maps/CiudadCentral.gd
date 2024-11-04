extends Node2D
var rangedSingleTargetSkill = preload("res://Scenes/Skills/ServerRangedSingleTargetSkill.tscn")
var player_spawn = preload("res://Scenes/Player/PlayerTemplate.tscn")

"""PLAYER SETTINGS"""
func SetPosition(position_x,position_y):
	position.x = position_x
	position.y = position_y
func SpawnPlayer(player_id,_nickname,spawn_point):
	var new_player = player_spawn.instantiate()
	new_player.name = str(player_id)
	new_player.position = spawn_point
	get_node("MapElements/OtherPlayers").call_deferred("add_child", new_player)
func MovePlayer(player_id, player_position):
	if get_node("MapElements/OtherPlayers/" + str(player_id)):
		get_node("MapElements/OtherPlayers/" + str(player_id)).position = player_position


"""SKILLS SETTINGS"""
func SpawnAttack(skill_new_instance):
	add_child(skill_new_instance)
