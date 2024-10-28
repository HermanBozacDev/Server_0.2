extends Node

var rangedSingleTargetSkill = preload("res://Scenes/Skills/ServerRangedSingleTargetSkill.tscn")
var fisicAttack = preload("res://Scenes/Skills/FisicAttack.tscn")
var meleeSingleTargetSkill = preload("res://Scenes/Skills/MeleeSingleTargetSkill.tscn")
var targetBuffDebuff = preload("res://Scenes/Skills/TargetBuffDebuff.tscn")

var player_rpc_id
var player_nickname
var player_stats
var player_clase
var die_cooldown = false


func _ready() -> void:
	set_physics_process(false)
	await (get_tree().create_timer(3).timeout)
	set_physics_process(true)
func _physics_process(delta):
	player_stats["Health"] += player_stats["HealthR"]
	if player_stats["Health"] >= player_stats["MHealth"]:
		player_stats["Health"] = player_stats["MHealth"]

	player_stats["Mana"] += player_stats["ManaR"]
	if player_stats["Mana"] >= player_stats["MMana"]:
		player_stats["Mana"] = player_stats["MMana"]

	UpdatePlayerStateKey("Health", player_stats["Health"])
	UpdatePlayerStateKey("Mana", player_stats["Mana"])
func GetMAtk():
	return ServerData.player_data[player_nickname]["MAtk"]
func GetPAtk():
	return ServerData.player_data[player_nickname]["PAtk"]
func GetMana():
	return ServerData.player_data[player_nickname]["Mana"]
func SetStats(nickname):
	player_stats = ServerData.player_data[nickname]
func GetPosition(player_Nickname):
	var new_position : Vector2 
	new_position.x = ServerData.player_data[player_Nickname]["Px"]
	new_position.y = ServerData.player_data[player_Nickname]["Py"]
	return new_position
func Get_health():
	return ServerData.player_data[player_nickname]["Health"]
func SetExp(enemy_list,enemy_id):
	ServerData.player_data[player_nickname]["Exp"]  += enemy_list[enemy_id]["Exp"]
	ServerData.player_data[player_nickname]["ExpF"] = ServerData.player_data[player_nickname]["ExpR"] - ServerData.player_data[player_nickname]["Exp"]
	if ServerData.player_data[player_nickname]["ExpF"] <= 0:
		LevelUp()
func SetExpSobrante(sobra_experiencia):
	ServerData.player_data[player_nickname]["Exp"]  += sobra_experiencia
	ServerData.player_data[player_nickname]["ExpF"] = ServerData.player_data[player_nickname]["ExpR"] - ServerData.player_data[player_nickname]["Exp"]
	if ServerData.player_data[player_nickname]["ExpF"] <= 0:
		LevelUp()
func LevelUp():
	var sobra_experiencia = ServerData.player_data[player_nickname]["ExpF"] * (-1)
	ServerData.player_data[player_nickname]["Level"] += 1
	ServerData.player_data[player_nickname]["Exp"] = 0
	ServerData.player_data[player_nickname]["ExpR"] += 200
	ServerData.player_data[player_nickname]["ExpF"] = ServerData.player_data[player_nickname]["ExpR"]
	#upgrading habilities
	ServerData.player_data[player_nickname]["HealthR"] += 0.005
	ServerData.player_data[player_nickname]["ManaR"] += 0.005
	ServerData.player_data[player_nickname]["MHealth"] += 20
	ServerData.player_data[player_nickname]["MMana"] += 10
	ServerData.player_data[player_nickname]["Mana"] = ServerData.player_data[player_nickname]["MMana"]
	ServerData.player_data[player_nickname]["Health"] = ServerData.player_data[player_nickname]["MHealth"]
	
	
	CheckForNewSkills()
	if sobra_experiencia > 0:
		SetExpSobrante(sobra_experiencia)
func CheckForNewSkills():
	print("LLEGO AL CHEKIN")
	match ServerData.player_data[player_nickname]["Level"]:
		5:
			if ServerData.player_data[player_nickname]["Type"] ==  "fighter":
				print("nivel5")
				LearningSkill("Sprint")
				LearningSkill("AirCut")
				LearningSkill("StrongMind")
				LearningSkill("Valor")
				var key = "UpdateSkills"
				var new_value = ServerData.learn_skills_data[player_nickname]
				get_node("/root/GameServer").ServerSendDataToOneClient(player_rpc_id,key,new_value)
			else:
				print("no entre")
				print("soy wizard")
				print("nivel5")
				LearningSkill("MindSlow")
				LearningSkill("ManaTouch")
				LearningSkill("StrongMind")
				LearningSkill("BoostMana")
				var key = "UpdateSkills"
				var new_value = ServerData.learn_skills_data[player_nickname]
				get_node("/root/GameServer").ServerSendDataToOneClient(player_rpc_id,key,new_value)
		10:
			if ServerData.player_data[player_nickname]["Type"] ==  "fighter":
				print("nivel10")
				LearningSkill("LifeFervor")
				LearningSkill("StuningAttack")
				LearningSkill("ShadowShield")
				LearningSkill("BoostMana")
				var key = "UpdateSkills"
				var new_value = ServerData.learn_skills_data[player_nickname]
				get_node("/root/GameServer").ServerSendDataToOneClient(player_rpc_id,key,new_value)
			else:
				print("soy wizard")
				print("nivel10")
				LearningSkill("WaterBubble")
				LearningSkill("LifeHelp")
				LearningSkill("ShadowShield")
				LearningSkill("BattleFervor")
				var key = "UpdateSkills"
				var new_value = ServerData.learn_skills_data[player_nickname]
				get_node("/root/GameServer").ServerSendDataToOneClient(player_rpc_id,key,new_value)
		15:
			if ServerData.player_data[player_nickname]["Type"] ==  "fighter":
				print("nivel15")
				LearningSkill("BattleCry")
				LearningSkill("HearthPunch")
				LearningSkill("CriticalVision")
				LearningSkill("MoreAccurate")
				var key = "UpdateSkills"
				var new_value = ServerData.learn_skills_data[player_nickname]
				get_node("/root/GameServer").ServerSendDataToOneClient(player_rpc_id,key,new_value)
			else:
				print("soy wizard")
				print("nivel15")
				LearningSkill("FastWalk")
				LearningSkill("WaterArrow")
				LearningSkill("StrongHearth")
				LearningSkill("Valor")
				var key = "UpdateSkills"
				var new_value = ServerData.learn_skills_data[player_nickname]
				get_node("/root/GameServer").ServerSendDataToOneClient(player_rpc_id,key,new_value)
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
	#aca da error aveces cuando se me desconecta en el cliente creo
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
		UpdateServerDataKey("Health", 50)
		UpdatePlayerStateKey("Health", 100)
		
		# Enviar información al cliente y temporizador para sincronizar con respawn
		var key = "PlayerDie"
		get_parent().ServerSendDataToOneClient(player_rpc_id, key, defeat_map)
		await get_tree().create_timer(4).timeout
		
		# Ahora hacer respawn para sincronización
		get_node("/root/GameServer/CiudadPrincipal").SpawnPlayer(get_name(), player_nickname, Vector2(0, 0))
		die_cooldown = false
	else:
		print("Already dead, cooldown active")

func PlayerHurtbox():
	pass

#funcion para tomar danio
func ApplyDamageOnPlayer(damage):
	if ServerData.player_data[player_nickname]["Health"] <= 0:
		return
	else:
		var value = ServerData.player_data[player_nickname]["Health"] - damage
		UpdateServerDataKey("Health",value)
		UpdatePlayerStateKey("Health",value)
		if value <= 0: 
			value = 0
			PlayerDie()
		var key_fx = "SoundFx"
		get_parent().ServerSendDataToOneClient(player_rpc_id, key_fx, null)




	
	#(_spawn_time,  a_rotation, a_position, a_direction, player_id,map,attack_name,attack_type)
	#value[2], value[3], value[4], value[5], player_id, value[6], value[7], value[8]
func HandleSkill(value, player_id):
	print("value",value)
	match value[0]:
		"FisicAttack":
			SetFisicAttack(value,player_id)
			#FALTA REENVIAR A TODOS LOS CLIENTES ACA 
			#var new_value = [value[0],value[1],value[2],value[3],value[6],player_id]
			#get_node("/root/GameServer").ServerSendDataToAllClients(key,new_value)
		"TargetBuffDebuff":
			print("bien ")
			SetTargetBuffDebuff(value,player_id)
		"SelfBuff":
			pass
		"RangedSingleTargetSkill":
			var check_mana_result =  CheckMana(value,player_id)
			if check_mana_result:
				SetRangedSingleTargetSkill(value,player_id)
				var key = "SpawnAttack"
				var new_value = [value[0],value[1],value[2],value[3],value[6],player_id]
				get_node("/root/GameServer").ServerSendDataToAllClients(key,new_value)
				#rpc_id(0, "ReceiveAttack", a_position, animation_vector, spawn_time, a_rotation , map,player_id)
			else:
				print("no mana")
				
				
		"MeleeSingleTargetSkill":
			print("LLEGUE A MELE SINGLE TARGET SKILL")
			var check_mana_result =  CheckMana(value,player_id)
			if check_mana_result:
				SetMeleeSingleTargetSkill(value,player_id)
				#var key = "SpawnAttack"
				#var new_value = [value[0],value[1],value[2],value[3],value[6],player_id]
				#get_node("/root/GameServer").ServerSendDataToAllClients(key,new_value)
				#rpc_id(0, "ReceiveAttack", a_position, animation_vector, spawn_time, a_rotation , map,player_id)
			else:
				print("no mana")
				
				
		"PointedDebuffSkill":
			pass
		"RangedAOETargetSkill":
			pass
		"MeleeAOETargetSkill":
			pass


func SetFisicAttack(value,player_id):
	var skill_new_instance = fisicAttack.instantiate()
	skill_new_instance.player_id = player_id
	skill_new_instance.rotation = value[2]
	skill_new_instance.position = value[7]
	
	skill_new_instance.map = value[5]
	skill_new_instance.skill_name = value[1]
	get_node("/root/GameServer/" + str(value[6])).SpawnAttack(skill_new_instance)
	


func CheckMana(value,player_id):
	var result
	var skill_mana_cost = ServerData.skill_data[value[1]]["ManaCost"]
	var player_current_mana = GetMana()
	if skill_mana_cost > player_current_mana:
		result = false
	else:
		result = true
		var new_mana = player_current_mana - skill_mana_cost
		UpdateServerDataKey("Mana", new_mana)
		UpdatePlayerStateKey("Mana", new_mana)
	return result



func SetRangedSingleTargetSkill(value,player_id):
	var skill_new_instance = rangedSingleTargetSkill.instantiate()
	skill_new_instance.player_id = player_id
	skill_new_instance.rotation = value[2]
	skill_new_instance.position = value[3]
	skill_new_instance.direction = value[4]
	skill_new_instance.map = value[5]
	skill_new_instance.projectile_speed = ServerData.skill_data[value[1]].ProjectileSpeed
	skill_new_instance.skill_name = value[1]
	get_node("/root/GameServer/" + str(value[5])).SpawnAttack(skill_new_instance)

func SetMeleeSingleTargetSkill(value,player_id):
	var skill_new_instance = meleeSingleTargetSkill.instantiate()
	skill_new_instance.player_id = player_id
	skill_new_instance.rotation = value[2]
	skill_new_instance.position = value[3]
	skill_new_instance.map = value[4]
	skill_new_instance.skill_name = value[1]
	get_node("/root/GameServer/" + str(value[4])).SpawnAttack(skill_new_instance)



func SetTargetBuffDebuff(value,player_id):
	var skill_new_instance = targetBuffDebuff.instantiate()
	skill_new_instance.player_id = player_id
	skill_new_instance.position = value[2]
	skill_new_instance.map = value[3]
	skill_new_instance.skill_name = value[1]
	get_node("/root/GameServer/" + str(value[3])).SpawnAttack(skill_new_instance)
	
	
	
	
	
	
	
	
	
	
	
	
	
