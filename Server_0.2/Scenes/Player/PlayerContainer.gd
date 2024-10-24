extends Node

var player_rpc_id
var player_nickname
var player_stats
var player_clase
var die_cooldown = false

func UpdateServerDataKey(key,value):
	var node = ServerData.player_data[player_nickname]
	node[key] = value
	ServerData.SavePlayers()
	
func UpdatePlayerStateKey(key,value):
	var node = get_node("/root/GameServer").player_state_collection[str(player_rpc_id)]
	node[key] = value



func SetStats(nickname):
	player_stats = ServerData.player_data[nickname]


func GetPosition(player_Nickname):
	var new_position : Vector2 
	new_position.x = ServerData.player_data[player_Nickname]["Px"]
	new_position.y = ServerData.player_data[player_Nickname]["Py"]
	return new_position




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










func Get_health():
	return ServerData.player_data[player_nickname]["health"]
	

func PlayerDie():
	print("matar al personaje")
	if !die_cooldown:
		die_cooldown = true
		print("Player is dying...")
		UpdateServerDataKey("Px",0)
		UpdateServerDataKey("Py",0)
		UpdateServerDataKey("health", 50)
		UpdatePlayerStateKey("Px",0)
		UpdatePlayerStateKey("Py",0)
		UpdatePlayerStateKey("H",100)
		get_node("/root/GameServer/CiudadPrincipal/MapElements/OtherPlayers/" + str(get_name())).queue_free()
		var key = "PlayerDie"
		get_parent().ServerSendDataToOneClient(player_rpc_id, key, null)
		await get_tree().create_timer(4).timeout
		get_node("/root/GameServer/CiudadPrincipal").SpawnPlayer(get_name(), player_nickname)
		die_cooldown = false
	else:
		print("Already dead, cooldown active")




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
	
func esperate():
	for skill in ServerData.skill_data:
		if ServerData.skill_data[skill].SkillLevel <= player_stats["level"]:
			ServerData.learn_skills_data[player_nickname][skill] = [skill,ServerData.skill_data[skill].SkillActivePasive]
	ServerData.SaveLearnSkill()
	
	print("yendo al game server")
	var key = "new_skills"
	var player_id = get_name()
	var new_value = ServerData.learn_skills_data[player_nickname]
	print("ServerData.learn_skills_data[player_nickname]",ServerData.learn_skills_data[player_nickname])
	get_parent().UpdateKeyState(player_id,key,new_value)
