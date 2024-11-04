extends Node2D


var player_spawn = preload("res://Scenes/Player/PlayerTemplate.tscn")
var skullman_spawn = preload("res://Scenes/Enemies/Enemies.tscn")

"""PLAYER SPAWN AND MOVE FUNCS"""
func SetPosition(position_x,position_y):
	position.x = position_x
	position.y = position_y
func SpawnPlayer(player_id,_nickname,spawn_point):
	var new_player = player_spawn.instantiate()
	new_player.name = str(player_id)
	#new_player.position = get_node("/root/GameServer/" + str(player_id)).GetPosition(nickname) 
	new_player.position = spawn_point
	#call deferred dice aca porque estoy borrando en otro lado el player
	get_node("MapElements/OtherPlayers").call_deferred("add_child", new_player)
func MovePlayer(player_id, player_position):
	if get_node("MapElements/OtherPlayers/" + str(player_id)):
		get_node("MapElements/OtherPlayers/" + str(player_id)).position = player_position

"""EENEMY FUNCS"""
func SpawnEnemy(enemy_id, location):
	var type = get_node("/root/GameServer/Mapa2Handler").enemy_list[str(enemy_id)]["T"]
	match type:
		"SkullMan":
			var new_enemy = skullman_spawn.instantiate()
			new_enemy.position = location
			new_enemy.name = str(enemy_id)
			new_enemy.map = "Mapa2"
			get_node("MapElements/Enemies/").add_child(new_enemy, true)

"""SPAWN ATTACK FUNKS"""
func SpawnAttack(skill_new_instance):
	add_child(skill_new_instance)
