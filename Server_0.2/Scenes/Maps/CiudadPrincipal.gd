extends Node2D
var rangedSingleTargetSkill = preload("res://Scenes/Skills/ServerRangedSingleTargetSkill.tscn")

var player_spawn = preload("res://Scenes/Player/PlayerTemplate.tscn")
var skullman_spawn = preload("res://Scenes/Enemies/Enemies.tscn")


func SetPosition(position_x,position_y):
	position.x = position_x
	position.y = position_y

func SpawnPlayer(player_id,nickname):
	var new_player = player_spawn.instantiate()
	new_player.name = str(player_id)
	new_player.position = get_node("/root/GameServer/" + str(player_id)).GetPosition(nickname) 
	get_node("MapElements/OtherPlayers").add_child(new_player)

func MovePlayer(player_id, player_position):
	if get_node("MapElements/OtherPlayers/" + str(player_id)):
		get_node("MapElements/OtherPlayers/" + str(player_id)).position = player_position
func SpawnAttack(_spawn_time,  a_rotation, a_position, a_direction, player_id,map,attack_name,attack_type):
	match attack_type:
		"RangedSingleTargetSkill":
			var skill_new_instance = rangedSingleTargetSkill.instantiate()
			skill_new_instance.player_id = player_id
			skill_new_instance.map = map
			skill_new_instance.position = a_position
			skill_new_instance.direction = a_direction
			skill_new_instance.rotation = a_rotation
			skill_new_instance.projectile_speed = ServerData.skill_data[attack_name].ProjectileSpeed
			skill_new_instance.skill_name = attack_name
			add_child(skill_new_instance)




func SpawnEnemy(enemy_id, location):
	var type = get_node("/root/GameServer/CiudadPrincipalHandler").enemy_list[str(enemy_id)]["T"]
	match type:
		"SkullMan":
			var new_enemy = skullman_spawn.instantiate()
			new_enemy.position = location
			new_enemy.name = str(enemy_id)
			get_node("MapElements/Enemies/").add_child(new_enemy, true)
