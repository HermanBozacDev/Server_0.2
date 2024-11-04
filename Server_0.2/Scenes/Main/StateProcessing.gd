extends Node

var sync_clock_counter = 0
var world_state

"""ACA SE RECOPILA LA INFORMACION Y SE CREA EL WORLD STATE"""
func _physics_process(_delta):
	sync_clock_counter += 1
	if sync_clock_counter == 3:
		sync_clock_counter = 0
		if get_parent().player_state_collection.size() > 0:
			world_state = get_parent().player_state_collection.duplicate(true)
			for player in world_state.keys():
				world_state[player].erase("T")
			world_state["T"] = Time.get_ticks_msec()
			world_state["CiudadPrincipal"] = get_node("../CiudadPrincipalHandler").enemy_list #saque esto porque no se usa a ver si no da bug
			world_state["Mapa2"] = get_node("../Mapa2Handler").enemy_list
			#world_state["CiudadCentral"] = get_node("../CiudadCentralHandler").enemy_list
			ServerData.SavePlayers()
			get_parent().ServerSendWorldState(world_state)
