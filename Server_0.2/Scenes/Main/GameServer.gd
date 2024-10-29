extends Node 

@onready var player_verification_process = get_node("PlayerVerification")

var game_server: ENetMultiplayerPeer
var multiplayer_api: MultiplayerAPI
var expected_tokens = []
var player_state_collection = {}
var latency_array = []
var latency = 0

"""FUNCIONES DE CONFIGURACION PRINCIPALES"""

func _ready():
	start_game_server(1909, 100)

func start_game_server(port: int, max_players: int):
	game_server = ENetMultiplayerPeer.new()
	var result = game_server.create_server(port, max_players)
	if result != OK:
		print("Error starting game server:", result)
		return
	multiplayer_api = MultiplayerAPI.create_default_interface()  # Crear instancia de MultiplayerAPI
	multiplayer_api.multiplayer_peer = game_server  # Establecer el peer de juego
	get_tree().set_multiplayer(multiplayer_api, self.get_path())  # Establecer la ruta para RPC
	print("EL GAMESERVER ESTA CORRIENDO EN EL PUERTO ", port)
	multiplayer_api.peer_connected.connect(_on_peer_connected)
	multiplayer_api.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")
	if get_node(str(player_id)) == null:
		return
	var map = get_node(str(player_id)).player_stats["M"]
	var other_players_node = get_node("/root/GameServer/" + str(map) + "/MapElements/OtherPlayers/")
	if other_players_node.has_node(str(player_id)):
		other_players_node.get_node(str(player_id)).queue_free()
	if has_node(str(player_id)):
		get_node(str(player_id)).queue_free()
		player_state_collection.erase(str(player_id))
		get_node("/root/GameServer/StateProcessing").world_state.erase(str(player_id))
		var key = "DespawnPlayer"
		ServerSendDataToAllClients(key,player_id)

func _on_peer_connected(player_id):
	print("NUEVO USUARIO CONECTADO:", player_id)
	player_verification_process.Start(player_id)



@rpc("any_peer") func ClientSendDataToServer(key, value):
	#print("KEY",key)
	var player_id = multiplayer_api.get_remote_sender_id()
	
	match key:
		"PlayerState":
			#value = player_State
			#print("AVER ",player_state_collection,value)
			# Si el jugador ya tiene un estado en player_state_collection
			if player_state_collection.has(str(player_id)):
				UpdateExistPlayerState(player_id,value,)

			else:
				UpdatenNewPlayerState(player_id, value)
		"FetchServerTime":
			var new_value = [Time.get_ticks_msec(),value]
			ServerSendDataToOneClient(player_id,key,new_value)
		"DetermineLatency":
			ServerSendDataToOneClient(player_id,key,value)
		"FetchToken":
			player_verification_process.Verify(player_id,value)
		"NewPlayerRegister":
			#value = [username,nickname,new_class,new_type]
			if !ServerData.CheckNickOpen(value[1]):
				print("no disponible")
			else:
				#CREAR BASES DE DATOS
				ServerData.CreateNewPlayerDatabase(value)
				ServerData.CreatePlayerSave(value)
				
				#CREAR EL CONTAINER
				player_verification_process.CreatePlayerContainer(player_id, value[1], value[2])
				
				#SPAWNEAR EN EL MAPA CORRECTO EN EL SERVER
				var stats = get_node("/root/GameServer/" + str(player_id)).player_stats
				var map = get_node("/root/GameServer/" + str(player_id)).player_stats["M"]
				get_node("/root/GameServer/" + str(map)).SpawnPlayer(player_id, value[1],Vector2(0,0))
				#ENVIAR LA INFORMACION FINAL AL CLIENTE
					#value = [stats[0],inventory[1],hotbar[2],equipitem[3],learnskill[4],nickname[5],map[6]
				var inventory = {}
				var hotbar = {}
				var equipItems = {}
				value = [stats,inventory,hotbar,equipItems,ServerData.learn_skills_data[value[1]],value[1]]
				rpc_id(player_id, "ServerSendDataToOneClient", player_id,key,value)
		"PlayerPool":
			#value = username
			ServerData.PlayerPoolSearch(player_id, value)
		"LoadPlayer":
			#value =nickname
			#CREAR EL CONTAINER
			var clase = ServerData.player_data[value]["Class"]
			player_verification_process.CreatePlayerContainer(player_id, value, clase)
			#CARGAR LOS DATOS DEL JUGADOR AL CONTAINER
			get_node("/root/GameServer/" + str(player_id)).SetStats(value)
			#SPAWNEAR AL JUGADOR EN EL MAPA Y POSICION CORRECTAS EN EL SERVIDOR
			var map = get_node("/root/GameServer/" + str(player_id)).player_stats["M"]
			var load_position = Vector2(0,0)
			load_position.x =get_node("/root/GameServer/" + str(player_id)).player_stats["Px"]
			load_position.y = get_node("/root/GameServer/" + str(player_id)).player_stats["Py"]
			get_node("/root/GameServer/" + str(map)).SpawnPlayer(player_id, value,load_position)
			
			
			#ENVIO LA INFORMACION COMPLETA AL CLIENTE
			var new_player_stats =  [
				ServerData.player_data[value],
				ServerData.inventary_data[value],
				ServerData.hot_bar_data[value],
				ServerData.equip_item_data[value],
				ServerData.learn_skills_data[value],
				value
				]
			rpc_id(player_id, "ServerSendDataToOneClient", player_id,key,new_player_stats)
		"Inventory":
			var nickname = get_node("/root/GameServer/" + str(player_id)).player_nickname
			ServerData.inventary_data[nickname] = value
			ServerData.SaveInventory()
		"Hotbar":
			var nickname = get_node("/root/GameServer/" + str(player_id)).player_nickname
			ServerData.hot_bar_data[nickname] = value
			ServerData.SaveHotBar()
		"EquipItems":
			var nickname = get_node("/root/GameServer/" + str(player_id)).player_nickname
			ServerData.equip_item_data[nickname] = value
			ServerData.SaveEquipItem()
		"PlayerAttack":
			get_node("/root/GameServer/" + str(player_id)).HandleSkill(value, player_id)
			





@rpc func ServerSendDataToOneClient(player_id,key,value):
	rpc_id(player_id, "ServerSendDataToOneClient", player_id,key,value)


@rpc func ServerSendDataToAllClients(key,value):
	rpc_id(0, "ServerSendDataToAllClients", key,value)






@rpc func ServerSendWorldState(world_state):
	rpc_id(0, "ServerSendWorldState", world_state)





func UpdateExistPlayerState(player_id,value,):
	var current_state = player_state_collection[str(player_id)]
	var updated_state = CompletePlayerState(player_id, current_state,value)
	player_state_collection[str(player_id)] = updated_state
	
	var player_node = get_node_or_null("/root/GameServer/" + str(player_id))
	if player_node:
		player_node.UpdateServerDataKey("Px",updated_state["Px"])
		player_node.UpdateServerDataKey("Py",updated_state["Py"])
		#print("playermap",ServerData.player_data[playerNickname]["M"])
		var position = player_node.GetPosition(player_node.player_nickname)
		var map = updated_state["M"]
		var other_player_node = get_node_or_null("/root/GameServer/" + str(map) + "/MapElements/OtherPlayers/" + str(player_id))
		if other_player_node:
			get_node("/root/GameServer/" + str(map)).MovePlayer(player_id, position)


func UpdatenNewPlayerState(player_id, value):
	var new_state = CompleteFirstPlayerState(player_id, value)
	player_state_collection[str(player_id)] = new_state
	
	# Crear el nodo del jugador en el servidor si es necesario
	var player_node = get_node_or_null("/root/GameServer/" + str(player_id))
	if player_node:
		player_node.UpdateServerDataKey("Px",new_state["Px"])
		player_node.UpdateServerDataKey("Py",new_state["Py"])

		var position = player_node.GetPosition(player_node.player_nickname)
		var map = new_state["M"]
		var other_player_node = get_node_or_null("/root/GameServer/" + str(map) + "/MapElements/OtherPlayers/" + str(player_id))
		if other_player_node:
			get_node("/root/GameServer/" + str(map)).MovePlayer(player_id, position)


"""ACA COMPLETO"""

# Función para completar los datos del jugador
func CompletePlayerState(player_id, current_state,client_stat):
	var player_node = get_node_or_null("/root/GameServer/" + str(player_id))
	# Obtener los datos adicionales del jugador desde la base de datos
	var player_data_from_db = ServerData.player_data[player_node.player_nickname]
	
	# Completar el estado del jugador con los datos que faltan
	current_state["Level"] = player_data_from_db["Level"]
	current_state["Health"] = player_data_from_db["Health"]
	current_state["MHealth"] = player_data_from_db["MHealth"]
	current_state["Mana"] = player_data_from_db["Mana"]
	current_state["MMana"] = player_data_from_db["MMana"]
	current_state["Exp"] = player_data_from_db["Exp"]
	current_state["ExpF"] = player_data_from_db["ExpF"]
	current_state["ExpR"] = player_data_from_db["ExpR"]
	current_state["M"] = player_data_from_db["M"]
	current_state["Px"] = client_stat["Px"]
	current_state["Py"] = client_stat["Py"]
	current_state["A"] = client_stat["A"]
	current_state["T"] = client_stat["T"]
	current_state["PAtk"] = player_data_from_db["PAtk"]
	current_state["MAtk"] = player_data_from_db["MAtk"]
	current_state["PDef"] = player_data_from_db["PDef"]
	current_state["MDef"] = player_data_from_db["MDef"]
	current_state["Crit"] = player_data_from_db["Crit"]
	current_state["MCrit"] = player_data_from_db["MCrit"]
	current_state["Speed"] = player_data_from_db["Speed"]
	current_state["CSpeed"] = player_data_from_db["CSpeed"]
	current_state["ASpeed"] = player_data_from_db["ASpeed"]
	return current_state


# Función para completar los datos del jugador
func CompleteFirstPlayerState(player_id, value):
	var player_node = get_node_or_null("/root/GameServer/" + str(player_id))
	# Obtener los datos adicionales del jugador desde la base de datos
	var player_data_from_db = ServerData.player_data[player_node.player_nickname]
	
	# Completar el estado del jugador con los datos que faltan
	value["Level"] = player_data_from_db["Level"]
	value["Health"] = player_data_from_db["Health"]
	value["MHealth"] = player_data_from_db["MHealth"]
	value["Mana"] = player_data_from_db["Mana"]
	value["MMana"] = player_data_from_db["MMana"]
	value["M"] = player_data_from_db["M"]
	value["Exp"] = player_data_from_db["Exp"]
	value["ExpF"] = player_data_from_db["ExpF"]
	value["ExpR"] = player_data_from_db["ExpR"]
	value["Px"] = value["Px"]
	value["Py"] = value["Py"]
	value["A"] = value["A"]
	value["T"] = value["T"]
	value["PAtk"] = player_data_from_db["PAtk"]
	value["MAtk"] = player_data_from_db["MAtk"]
	value["PDef"] = player_data_from_db["PDef"]
	value["MDef"] = player_data_from_db["MDef"]
	value["Crit"] = player_data_from_db["Crit"]
	value["MCrit"] = player_data_from_db["MCrit"]
	value["Speed"] = player_data_from_db["Speed"]
	value["CSpeed"] = player_data_from_db["CSpeed"]
	value["ASpeed"] = player_data_from_db["ASpeed"]
	return value
