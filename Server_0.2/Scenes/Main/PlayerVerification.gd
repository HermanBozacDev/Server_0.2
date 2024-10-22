extends Node

@onready var  main_interface = get_parent()
@onready var player_container_scene = preload("res://Scenes/Player/PlayerContainer.tscn")
var awaiting_verification: Dictionary = {}




func Start(player_id):
	awaiting_verification[player_id] =  {"Timestamp": Time.get_unix_time_from_system()}
	var key = "FetchToken"
	var value = null
	main_interface.ServerSendDataToOneClient(player_id,key,value)

func Verify(player_id, token):
	var token_verification = false
	# Separa la parte entera del token antes del punto decimal
	var token_parts = token.right(64).split(".")
	var token_timestamp = 0
	if token_parts.size() > 0:
		# Convierte solo la parte entera a entero
		token_timestamp = token_parts[0].to_int()
	else:
		print("Error: el token no contiene un timestamp válido.")
		main_interface.ReturnTokenVerificationResults(player_id, false)
		return
	# Verifica si el token está dentro del tiempo permitido
	while Time.get_unix_time_from_system() - token_timestamp <= 30:
		if main_interface.expected_tokens.has(token):
			token_verification = true
			awaiting_verification.erase(player_id)
			main_interface.expected_tokens.erase(token)
			break
		else:
			await get_tree().create_timer(2).timeout
	

	var key  = "TokenVresult"
	
	main_interface.ServerSendDataToOneClient(player_id,key, token_verification)
	if not token_verification:
		awaiting_verification.erase(player_id)
		main_interface.multiplayer_api.disconnect_peer(player_id)




func CreatePlayerContainer(player_id, nickname, new_class):
	print("Creating player container for player ID:", player_id)
	
	
	# Instancia el contenedor de jugador
	var new_player_container = player_container_scene.instantiate()
	
	# Configura los atributos del contenedor del jugador
	new_player_container.name = str(player_id)
	new_player_container.player_nickname = nickname
	new_player_container.player_clase = new_class
	new_player_container.player_stats = ServerData.player_data[nickname]
	
	# Agrega el contenedor del jugador a la interfaz principal
	get_parent().add_child(new_player_container, true)
