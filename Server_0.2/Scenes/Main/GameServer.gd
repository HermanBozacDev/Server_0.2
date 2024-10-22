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
	var player_id = multiplayer_api.get_remote_sender_id()
	match key:
		"FetchServerTime":
			print("FetchServerTime")
			var new_value = [Time.get_ticks_msec(),value]
			ServerSendDataToOneClient(player_id,key,new_value)
		"DetermineLatency":
			rpc_id(player_id, "ServerSendDataToOneClient", player_id,key,value)
		"FetchToken":
			player_verification_process.Verify(player_id,value)
		"NewPlayerRegister":
			#value = [username,nickname,new_class,new_type]
			if !ServerData.CheckNickOpen(value[1]):
				print("no disponible")
			else:
				ServerData.CreateNewPlayerDatabase(value)
				ServerData.CreatePlayerSave(value)
				player_verification_process.CreatePlayerContainer(player_id, value[1], value[2])
				var stats = get_node("/root/GameServer/" + str(player_id)).player_stats
				var map = get_node("/root/GameServer/" + str(player_id)).player_stats["M"]
				get_node("/root/GameServer/" + str(map)).SpawnPlayer(player_id, value[1])
				value = [stats,ServerData.learn_skills_data[value[1]],value[1]]
				rpc_id(player_id, "ServerSendDataToOneClient", player_id,key,value)
				#ReturnNewPlayerRegister(stats, ServerData.learn_skills_data[value[1]])
		"PlayerState":
			#value = player_state
			if player_state_collection.has(str(player_id)):
				player_state_collection[str(player_id)] = value
				var player_node = get_node_or_null("/root/GameServer/" + str(player_id))
				if player_node:
					player_node.SetPosition(value["Px"], value["Py"])
					# Obtener posición y mapa
					var position = player_node.GetPosition(player_node.player_nickname)
					var map = value["M"]
					# Mover al jugador en el nodo correspondiente si existe
					var other_player_node = get_node_or_null("/root/GameServer/" + str(map) + "/MapElements/OtherPlayers/" + str(player_id))
					if other_player_node:
						get_node("/root/GameServer/" + str(map)).MovePlayer(player_id, position)
			else:
				print("User no tiene PLAYERSTATECOLLECTION")
				player_state_collection[str(player_id)] = value
		"PlayerPool":
			#value = username
			ServerData.PlayerPoolSearch(player_id, value)
		"LoadPlayer":
			#value =nickname

			var clase = ServerData.player_data[value]["clase"]
			player_verification_process.CreatePlayerContainer(player_id, value, clase)
			# Rellena el contenedor del jugador con sus estadísticas
			get_node("/root/GameServer/" + str(player_id)).SetStats(value)
			# Aparece en el mapa del servidor
			var map = get_node("/root/GameServer/" + str(player_id)).player_stats["M"]
			get_node("/root/GameServer/" + str(map)).SpawnPlayer(player_id, value)
			# Envía la confirmación de carga al cliente
			var new_player_stats =  [
				ServerData.player_data[value],
				ServerData.inventary_data[value],
				ServerData.hot_bar_data[value],
				ServerData.equip_item_data[value],
				ServerData.learn_skills_data[value],
				value
				]
			rpc_id(player_id, "ServerSendDataToOneClient", player_id,key,new_player_stats)





@rpc func ServerSendDataToOneClient(player_id,key,value):
	rpc_id(player_id, "ServerSendDataToOneClient", player_id,key,value)


@rpc func ServerSendDataToAllClients(key,value):
	rpc_id(0, "ServerSendDataToAllClients", key,value)



@rpc func ServerSendWorldState(world_state):
	rpc_id(0, "ServerSendWorldState", world_state)
