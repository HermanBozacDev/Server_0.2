extends Node

var enemy_id_counter = 0

var enemy_types = ["SkullMan"] #,"Demon"list of enemies that  can spawn on the map
var map = "Mapa2"


#var open_locations =  [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]
#var enemy_spawn_points = [
#	Vector2(-600,-100),
#	Vector2(-800,50),
#	Vector2(-950,0),
#	Vector2(-1050,150),
#	Vector2(-115,-50),
#	Vector2(-800,-250),
#	Vector2(-1000,-308),
#	Vector2(-430,-380),
#	Vector2(-1250,-150),
#	Vector2(550,275),
#	Vector2(650,75),
#	Vector2(850,-50),
#	Vector2(1000,200),
#	Vector2(-90,330),
#	Vector2(160,331),
#	]
#var enemy_maximum = 15
var open_locations =  [0]
var enemy_spawn_points = [Vector2(0,0)] 
var enemy_maximum = 1
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
					"M": "Mapa2",
					"G": ServerData.enemy_data[type]["Gold"],
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


#func SpawnPlayer(player_id, player_position):
#	get_parent().get_node("CiudadPrincipal").SpawnPlayer(player_id, player_position)


# Función que controla el daño a los enemigos
func EnemyHurt(enemy_id, damage, player_id):
	#get_node("/root/GameServer").SendEnemyHurt(enemy_id,map)
	# Convertir enemy_id a string para asegurarse de que se accede correctamente
	print("danio")
	var enemy_key = str(enemy_id)
	if enemy_list[enemy_key]["H"] <= 0:
		pass
	else:
		enemy_list[enemy_key]["H"] -= damage
		if enemy_list[enemy_key]["H"] <= 0:
			var loot_node = get_parent().get_node("LootProcessing")
			var player_nickname = get_node("/root/GameServer/" + str(player_id)).player_nickname
			var enemy_node = get_node("/root/GameServer/Mapa2/MapElements/Enemies/" + enemy_key)
			var player_node = get_node("/root/GameServer/" + str(player_id))
			player_node.SetExp(enemy_list,enemy_id)
			loot_node.DetermineLootCount(enemy_list[enemy_id]["T"])
			loot_node.LootSelector(enemy_list[enemy_id]["T"],player_nickname,player_id,map)
			enemy_node.set_physics_process(false)
			enemy_node.queue_free()
			enemy_list[enemy_key]["S"] = "Dead"
			open_locations.append(occupied_locations[enemy_key])
			occupied_locations.erase(enemy_key)
			var key = "UpdateInventory"
			var new_value = ServerData.inventary_data[player_nickname]
			get_node("/root/GameServer").ServerSendDataToOneClient(player_id,key,new_value)

func PlayerHit(player_hurt, damage, _attack_caster_id):
	var new_nickname = get_node("/root/GameServer/" + player_hurt).player_nickname
	ServerData.player_data[new_nickname].health -= damage
	get_node("/root/GameServer").player_state_collection[player_hurt]["H"] = ServerData.player_data[new_nickname].health
