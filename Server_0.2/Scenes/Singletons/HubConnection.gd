extends Node


var multiplayer_api: MultiplayerAPI
var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var ip: String = "127.0.0.1" 
var port: int = 1912  
var gameserver

func _ready():
	gameserver = get_node("/root/GameServer")
	connect_to_server()  # Inicia la conexión al servidor

func connect_to_server():
	var result = peer.create_client(ip, port)
	if result != OK:
		print("Error al intentar conectarse al servidor:", result)
		return
	multiplayer_api = MultiplayerAPI.create_default_interface()  # Crear instancia de MultiplayerAPI
	multiplayer_api.multiplayer_peer = peer  # Establecer el peer de juego
	get_tree().set_multiplayer(multiplayer_api, self.get_path())  # Establecer la ruta para RPC
	multiplayer.connected_to_server.connect(_on_connection_success)
	multiplayer.connection_failed.connect(_on_connection_failed)

func _on_connection_failed():
	print("Error al conectarse al servidor")  # Mensaje de error

func _on_connection_success():
	print("CONECTADO AL HOST DE SERVIDORES EN AUTH")  # Mensaje de éxito

@rpc
func FetchToken(_player_id):
	pass


@rpc
func DistributeLoginToken(_token, _new_gameserver):
	pass

@rpc
func ReceiveLoginToken(token):
	gameserver.expected_tokens.append(token)
