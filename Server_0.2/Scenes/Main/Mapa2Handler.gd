extends Node

var enemy_id_counter = 0

var enemy_types = ["SkullMan"] #,"Demon"list of enemies that  can spawn on the map
var map = "Mapa2"

var open_locations =  [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
var enemy_spawn_points = [
	Vector2(-640,-320),
	Vector2(-448,-448),
	Vector2(-256,-384),
	Vector2(-448,-128),
	Vector2(-672,232),
	Vector2(-592,432),
	Vector2(-384,280),
	Vector2(-216,424),
	Vector2(-320,216),
	Vector2(80,416),
	Vector2(408,272),
	Vector2(208,64),
	Vector2(432,-448),
	Vector2(-120,-224),
	Vector2(280,-120),
	Vector2(96,-328),
	]
var enemy_maximum = 15
#var open_locations =  [0]
#var enemy_spawn_points = [Vector2(0,0)] 
#var enemy_maximum = 1
var occupied_locations = {}
var enemy_list = {}

func _ready():
	
	
	var timer  = Timer.new()
	timer.wait_time = 1
	timer.autostart = true
	timer.timeout.connect(SpawnEnemy)
	self.add_child(timer)



func SpawnEnemy():
	if enemy_list.size() >= enemy_maximum:
		pass
	else:
		randomize()
		var type = enemy_types[randi() % enemy_types.size()]
		var rng_location_index = randi() % open_locations.size()
		var location = enemy_spawn_points[open_locations[rng_location_index]]
		
		# Asegurarse de que las claves son strings
		occupied_locations[str(enemy_id_counter)] = open_locations[rng_location_index]
		open_locations.erase(rng_location_index)
		
		match type:
			"SkullMan":
				enemy_list[str(enemy_id_counter)] = {
					"T": "SkullMan",
					"Exp": ServerData.enemy_data[type]["Exp"],
					"P": location,
					"Health": ServerData.enemy_data[type]["EnemyHealth"],
					"MHealth": ServerData.enemy_data[type]["EnemyMaxHealth"],
					"S": ServerData.enemy_data[type]["EnemyState"],
					"TO": ServerData.enemy_data[type]["time_out"],
					"A": ServerData.enemy_data[type]["A"],
					"M": "Mapa2",
				}
		
		get_parent().get_node("Mapa2").SpawnEnemy(enemy_id_counter, location)
		enemy_id_counter += 1

	# Eliminar enemigos muertos
	for enemy in enemy_list.keys():
		if enemy_list[enemy]["S"] == "Dead":
			if enemy_list[enemy]["TO"] == 0:
				enemy_list.erase(enemy)
			else:
				enemy_list[enemy]["TO"] -= 1


func ReceiveEnemyState(enemy_state, enemy_id):
	enemy_list[str(enemy_id)] = enemy_state



func CalculatingDamage(value):
	var skill_type =  ServerData.skill_data[value[0].skill_name].SkillType
	if skill_type == "FisicAttack":
		#ACLARACION: ACA ESTOY USANDO GETPATK PLANO SIN METERLE LA INLFUENCIA DE LAS NUEVAS TABLAS DE STR DESPUES LO VEO ESO
		var playerPAtk = get_node("/root/GameServer/" +str(value[0].player_id)).GetPAtk()
		var enemyPDef = ServerData.enemy_data[value[3]]["PDef"]
		var final_damage = get_node("/root/GameServer/DamageProcessing").CalculateSimpleMeleeAttackDamage(playerPAtk, enemyPDef)
		return final_damage
	else:
		print("aca entra cauqluier otro tipo de skill")
		#capas que tengo que hacer una nueva caracteristica skill family o algo asi para ver si es mago o fighter
		#ESTA SOLUCION NO SIRVE EN EL FUTURO CUANDO TENGA SUBCLASES
		if get_node("/root/GameServer/" + str(value[2])).player_stats["Type"] == "fighter":
			print("es un skill de guerrero")
			var playerPAtk = get_node("/root/GameServer/" +str(value[0].player_id)).GetPAtk()
			var enemyPDef = ServerData.enemy_data[value[3]]["PDef"]
			var skillPower = ServerData.skill_data[value[0].skill_name].SkillPower
			var final_damage = get_node("/root/GameServer/DamageProcessing").CalculatedMagicSkillDamage(playerPAtk, skillPower,enemyPDef)
			return final_damage
		else:
			print("es un skill de mago")
			var playerMAtk = get_node("/root/GameServer/" +str(value[0].player_id)).GetMAtk()
			var enemyMDef = ServerData.enemy_data[value[3]]["MDef"]
			var skillPower = ServerData.skill_data[value[0].skill_name].SkillPower
			var final_damage = get_node("/root/GameServer/DamageProcessing").CalculatedMagicSkillDamage(playerMAtk, skillPower,enemyMDef)
			return final_damage
	
	#var skill_name =  ServerData.skill_data[attack.skill_name].SkillName
	#var map_node = get_node("/root/GameServer/"+ map + "Handler")
	#var power = ServerData.skill_data[attack.skill_name].SkillPower
	#var enemyMDef = ServerData.enemy_data[type[0]]["MDef"]
	
	
	
	
func EnemyHurt(value):
	var damage = CalculatingDamage(value)

	var enemy_key = str(value[1])
	if enemy_list[enemy_key]["Health"] <= 0:
		pass
	else:
		enemy_list[enemy_key]["Health"] -= damage
		if enemy_list[enemy_key]["Health"] <= 0:
			var loot_node = get_parent().get_node("LootProcessing")
			var player_nickname = get_node("/root/GameServer/" + str(value[2])).player_nickname
			var enemy_node = get_node("/root/GameServer/Mapa2/MapElements/Enemies/" + enemy_key)
			var player_node = get_node("/root/GameServer/" + str(value[2]))
			#imagino que enemy id es enemy getname
			player_node.SetExp(enemy_list,enemy_key)
			loot_node.DetermineLootCount(enemy_list[enemy_key]["T"])
			loot_node.LootSelector(enemy_list[enemy_key]["T"],player_nickname,value[2],map)
			enemy_node.set_physics_process(false)
			enemy_node.queue_free()
			enemy_list[enemy_key]["S"] = "Dead"
			open_locations.append(occupied_locations[enemy_key])
			occupied_locations.erase(enemy_key)
			var key = "UpdateInventory"
			var new_value = ServerData.inventary_data[player_nickname]
			get_node("/root/GameServer").ServerSendDataToOneClient(value[2],key,new_value)



func EnemyBuffDebuff(value):
	var multiplier = ServerData.skill_data[value[0].skill_name]["BuffDebuffMultiplier"]
	var timer  = ServerData.skill_data[value[0].skill_name]["BuffDebuffTime"]
	var key = ServerData.skill_data[value[0].skill_name]["BuffDebuffKey"]
	#voy a hacer que mana touch de vida maxima solo para ver si funciona bien
	print("correcto",value)
	print("enemy_list",enemy_list[value[1]]["Health"])
	enemy_list[value[1]]["Health"]  = (enemy_list[value[1]]["Health"] * multiplier)
	print("enemy_list",enemy_list[value[1]]["Health"])
	#estoy curando al enemigo
	
	
	
	
	
	
	
	
	
	
	
	
	
	


func PlayerHit(player_hurt, damage, _attack_caster_id):
	var new_nickname = get_node("/root/GameServer/" + player_hurt).player_nickname
	ServerData.player_data[new_nickname].health -= damage
	get_node("/root/GameServer").player_state_collection[player_hurt]["Health"] = ServerData.player_data[new_nickname].health
