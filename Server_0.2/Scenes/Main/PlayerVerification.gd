extends Node

@onready var  main_interface = get_parent()
@onready var player_container_scene = preload("res://Scenes/Player/PlayerContainer.tscn")
var awaiting_verification: Dictionary = {}

"""INIT Y VERIFICACION"""
func Start(player_id):
	awaiting_verification[player_id] =  {"Timestamp": Time.get_unix_time_from_system()}
	var key = "FetchToken"
	var value = null
	main_interface.ServerSendDataToOneClient(player_id,key,value)
func Verify(player_id, token):
	var token_verification = false
	var token_timestamp = int(token.right(64))
	while Time.get_unix_time_from_system() - token_timestamp <= 30:
		if main_interface.expected_tokens.has(token):
			token_verification = true
			awaiting_verification.erase(player_id)
			main_interface.expected_tokens.erase(token)
			break
		else:
			await get_tree().create_timer(2).timeout
	# Desconecta al jugador si la verificación falla
	if not token_verification:
		awaiting_verification.erase(player_id)
		main_interface.network.disconnect_peer(player_id)
	var key  = "TokenVresult"
	main_interface.ServerSendDataToOneClient(player_id,key, token_verification)

"""CREAR PLAYER CONTAINER """
func CreatePlayerContainer(player_id, value, new_class):
	#value = [nickanme, username]
	# Instancia el contenedor de jugador
	var new_player_container = player_container_scene.instantiate()
	# Configura los atributos del contenedor del jugador
	new_player_container.name = str(player_id)
	new_player_container.player_nickname = value[0]
	new_player_container.player_username = value[1]
	new_player_container.player_clase = new_class
	new_player_container.player_stats = ServerData.player_data[value[0]]
	new_player_container.player_rpc_id = player_id
	# Agrega el contenedor del jugador a la interfaz principal
	get_parent().add_child(new_player_container, true)
