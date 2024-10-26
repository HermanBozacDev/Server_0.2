extends Node

# Contador para sincronización de estados
var sync_clock_counter = 0

# Estado del mundo que se enviará a los clientes
var world_state

# Función que se ejecuta en cada frame de física
func _physics_process(_delta):
	sync_clock_counter += 1
	if sync_clock_counter == 3:
		sync_clock_counter = 0
		if get_parent().player_state_collection.size() > 0:
			# Duplica el estado de los jugadores para evitar referencias directas
			world_state = get_parent().player_state_collection.duplicate(true)
			for player in world_state.keys():
				world_state[player].erase("T")
			# Añade el tiempo actual del sistema en milisegundos
			world_state["T"] = Time.get_ticks_msec()
			world_state["CiudadPrincipal"] = get_node("../CiudadPrincipalHandler").enemy_list
			world_state["Mapa2"] = get_node("../Mapa2Handler").enemy_list
			ServerData.SavePlayers()
			get_parent().ServerSendWorldState(world_state)
			#print("             FULL WORLD STATE",world_state)
