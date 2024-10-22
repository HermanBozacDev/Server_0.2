extends Node

var enemy_id_counter = 0

var enemy_types = ["SkullMan"] #,"Demon"list of enemies that  can spawn on the map
var map = "CiudadPrincipal"


var open_locations =  [0,1,2,3,4,5]
var enemy_spawn_points = [Vector2(-48,-32),Vector2(-50,100),Vector2(100,0),Vector2(0,100),Vector2(-100,0),Vector2(0,110)]
var enemy_maximum = 6
#var open_locations =  [0]
#var enemy_spawn_points = [Vector2(0,64)] 
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
					"EXP": ServerData.enemy_data[type]["EXP"],
					"P": location,
					"H": ServerData.enemy_data[type]["EnemyHealth"],
					"mH": ServerData.enemy_data[type]["EnemyMaxHealth"],
					"S": ServerData.enemy_data[type]["EnemyState"],
					"TO": ServerData.enemy_data[type]["time_out"],
					"A": ServerData.enemy_data[type]["A"],
					"M": "Exterior_1",
					"G": ServerData.enemy_data[type]["Gold"]
				}
		
		get_parent().get_node("CiudadPrincipal").SpawnEnemy(enemy_id_counter, location)
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


#func SpawnPlayer(player_id, player_position):
#	get_parent().get_node("CiudadPrincipal").SpawnPlayer(player_id, player_position)


# Función que controla el daño a los enemigos
func EnemyHurt(enemy_id, damage, player_id):
	get_node("/root/GameServer").SendEnemyHurt(enemy_id,map)
	# Convertir enemy_id a string para asegurarse de que se accede correctamente
	var enemy_key = str(enemy_id)
	if enemy_list[enemy_key]["EnemyHealth"] <= 0:
		pass
	else:
		enemy_list[enemy_key]["EnemyHealth"] -= damage
		if enemy_list[enemy_key]["EnemyHealth"] <= 0:
			print("ESTOY MUERTO")
			
			get_node("/root/GameServer/" + str(player_id)).SetExp(enemy_list[enemy_id]["EXP"])
			get_node("/root/GameServer/" + str(player_id)).SetGold(enemy_list[enemy_id]["Gold"])
			get_parent().get_node("LootProcessing").DetermineLootCount(enemy_list[enemy_id]["TYPE"])
			get_parent().get_node("LootProcessing").LootSelector(enemy_list[enemy_id]["TYPE"],get_node("/root/GameServer/" + str(player_id)).player_nickname,player_id,map)
			
			get_node("/root/GameServer/CiudadPrincipal/MapElements/Enemies/" + enemy_key).set_physics_process(false)
			get_node("/root/GameServer/CiudadPrincipal/MapElements/Enemies/" + enemy_key).queue_free()
			enemy_list[enemy_key]["EnemyState"] = "Dead"
			
			# Asegurarse de que las claves de occupied_locations son strings
			open_locations.append(occupied_locations[enemy_key])
			occupied_locations.erase(enemy_key)
			print("aca ya mate ya di experiencia oro y guarde el loot")
			var key = "stats"
			var new_value = get_node("/root/GameServer/" + str(player_id)).GetStats()
			get_node("/root/GameServer").UpdateKeyState(player_id,key,new_value)


func PlayerHit(player_hurt, damage, _attack_caster_id):
	var new_nickname = get_node("/root/GameServer/" + player_hurt).player_nickname
	ServerData.player_data[new_nickname].health -= damage
	get_node("/root/GameServer").player_state_collection[player_hurt]["H"] = ServerData.player_data[new_nickname].health
