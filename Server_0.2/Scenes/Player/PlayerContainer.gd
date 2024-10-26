extends Node

var player_rpc_id
var player_nickname
var player_stats
var player_clase
var die_cooldown = false

func SetStats(nickname):
	player_stats = ServerData.player_data[nickname]
func GetPosition(player_Nickname):
	var new_position : Vector2 
	new_position.x = ServerData.player_data[player_Nickname]["Px"]
	new_position.y = ServerData.player_data[player_Nickname]["Py"]
	return new_position
func Get_health():
	return ServerData.player_data[player_nickname]["health"]
func SetExp(enemy_list,enemy_id):
	ServerData.player_data[player_nickname]["exp"]  += enemy_list[enemy_id]["EXP"]
	ServerData.player_data[player_nickname]["expFaltante"] = ServerData.player_data[player_nickname]["expRequerida"] - ServerData.player_data[player_nickname]["exp"]
	if ServerData.player_data[player_nickname]["expFaltante"] <= 0:
		LevelUp()
func SetExpSobrante(sobra_experiencia):
	ServerData.player_data[player_nickname]["exp"]  += sobra_experiencia
	ServerData.player_data[player_nickname]["expFaltante"] = ServerData.player_data[player_nickname]["expRequerida"] - ServerData.player_data[player_nickname]["exp"]
	if ServerData.player_data[player_nickname]["expFaltante"] <= 0:
		LevelUp()
func LevelUp():
	var sobra_experiencia = ServerData.player_data[player_nickname]["expFaltante"] * (-1)
	ServerData.player_data[player_nickname]["level"] += 1
	ServerData.player_data[player_nickname]["exp"] = 0
	ServerData.player_data[player_nickname]["expRequerida"] += 200
	ServerData.player_data[player_nickname]["expFaltante"] = ServerData.player_data[player_nickname]["expRequerida"]
	#upgrading habilities
	ServerData.player_data[player_nickname]["healthreg"] += 0.1
	ServerData.player_data[player_nickname]["manareg"] += 0.02
	ServerData.player_data[player_nickname]["mana"] += 50
	ServerData.player_data[player_nickname]["health"] += 15
	CheckForNewSkills()
	if sobra_experiencia > 0:
		SetExpSobrante(sobra_experiencia)
func CheckForNewSkills():
	match ServerData.player_data[player_nickname]["level"]:
		5:
			if ServerData.player_data[player_nickname]["type"] ==  "fighter":
				print("nivel5")
				LearningSkill("MindSlow")
				LearningSkill("ManaTouch")
				LearningSkill("StrongMind")
				LearningSkill("BoostMana")
				var key = "UpdateSkills"
				var new_value = ServerData.learn_skills_data[player_nickname]
				get_node("/root/GameServer").ServerSendDataToOneClient(player_rpc_id,key,new_value)
			else:
				print("soy wizard")
				print("nivel5")

		10:
			if ServerData.player_data[player_nickname]["type"] ==  "fighter":
				print("nivel10")
				LearningSkill("WaterBubble")
				LearningSkill("LifeHelp")
				LearningSkill("ShadowShield")
				LearningSkill("BattleFervor")
				var key = "UpdateSkills"
				var new_value = ServerData.learn_skills_data[player_nickname]
				get_node("/root/GameServer").ServerSendDataToOneClient(player_rpc_id,key,new_value)
			else:
				print("soy wizard")
				print("nivel10")

		15:
			if ServerData.player_data[player_nickname]["type"] ==  "fighter":
				print("nivel15")
				LearningSkill("FastWalk")
				LearningSkill("WaterArrow")
				LearningSkill("StrongHearth")
				LearningSkill("Valor")
				var key = "UpdateSkills"
				var new_value = ServerData.learn_skills_data[player_nickname]
				get_node("/root/GameServer").ServerSendDataToOneClient(player_rpc_id,key,new_value)
			else:
				print("soy wizard")
				print("nivel15")
func LearningSkill(skill):
	ServerData.learn_skills_data[player_nickname][skill] = [
	skill, 
	ServerData.skill_data[skill]["SkillActivePasive"], 
	ServerData.skill_data[skill]["SkillType"],
	ServerData.skill_data[skill]["ProjectileSpeed"],
	ServerData.skill_data[skill]["SkillDamage"]
	]
	ServerData.SaveLearnSkill()


func UpdateServerDataKey(key,value):
	var node = ServerData.player_data[player_nickname]
	node[key] = value
	ServerData.SavePlayers()
	
func UpdatePlayerStateKey(key,value):
	var node = get_node("/root/GameServer").player_state_collection[str(player_rpc_id)]
	node[key] = value

func Teleport(destiny,ubication,body,spawn_point):
	#ELIMINO EL NODO ANTERIOR
	get_node("/root/GameServer/" + ubication + "/MapElements/OtherPlayers/" + str(player_rpc_id)).queue_free()
	#ACTUALIZO EL EL MAPA Y LA POSICION ELN LA BASE DE DATOS Y EN EL ESTADO GLOBAL
	UpdateServerDataKey("M",destiny )
	UpdatePlayerStateKey("M",destiny)
	UpdateServerDataKey("Px",spawn_point[0])
	UpdateServerDataKey("Py",spawn_point[1])
	UpdatePlayerStateKey("Px",spawn_point[0])
	UpdatePlayerStateKey("Py",spawn_point[1])
	#CREAR DENUEVO EL JUGADOR EN EL MAPA
	get_node("/root/GameServer/" + destiny).SpawnPlayer(player_rpc_id, player_nickname,spawn_point)
	#ENVIAR INFORMACION AL CLIENTE
	var key = "Teleport"
	var value = [ubication,destiny,body,spawn_point]
	get_node("/root/GameServer").ServerSendDataToOneClient(player_rpc_id,key,value)


func PlayerDie():
	print("matar al personaje")
	if !die_cooldown:
		die_cooldown = true
		print("Player is dying...")
		
		# Intentar obtener el nodo y verificar que no sea null
		var player_node = get_node_or_null("/root/GameServer/" + player_stats["M"] + "/MapElements/OtherPlayers/" + str(get_name()))
		if player_node != null:
			player_node.queue_free()
		else:
			print("El jugador no se encuentra en el mapa para ser eliminado.")
		
		var defeat_map = player_stats["M"]
		# Actualizar base de datos y estado
		UpdateServerDataKey("Px", 0)
		UpdateServerDataKey("Py", 0)
		UpdatePlayerStateKey("Px", 0)
		UpdatePlayerStateKey("Py", 0)
		UpdateServerDataKey("health", 50)
		UpdatePlayerStateKey("H", 100)
		
		# Enviar información al cliente y temporizador para sincronizar con respawn
		var key = "PlayerDie"
		get_parent().ServerSendDataToOneClient(player_rpc_id, key, defeat_map)
		await get_tree().create_timer(4).timeout
		
		# Ahora hacer respawn para sincronización
		get_node("/root/GameServer/CiudadPrincipal").SpawnPlayer(get_name(), player_nickname, Vector2(0, 0))
		die_cooldown = false
	else:
		print("Already dead, cooldown active")



#funcion para tomar danio
func ApplyDamageOnPlayer(damage):
	if ServerData.player_data[player_nickname]["health"] <= 0:
		return
	else:
		var value = ServerData.player_data[player_nickname]["health"] - damage
		UpdateServerDataKey("health",value)
		UpdatePlayerStateKey("H",value)
		if value <= 0: 
			value = 0
			PlayerDie()
		var key_fx = "SoundFx"
		get_parent().ServerSendDataToOneClient(player_rpc_id, key_fx, null)
