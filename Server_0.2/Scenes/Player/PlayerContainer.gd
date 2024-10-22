extends Node


var player_nickname
var player_stats
var player_clase



func SetStats(nickname):
	player_stats = ServerData.player_data[nickname]


#con esta funcion puedo mantener la posicion
func SetPosition(position_x,position_y):
	ServerData.player_data[player_nickname]["Px"] = position_x
	ServerData.player_data[player_nickname]["Py"] = position_y

func GetPosition(player_Nickname):
	var new_position : Vector2 
	new_position.x = ServerData.player_data[player_Nickname]["Px"]
	new_position.y = ServerData.player_data[player_Nickname]["Py"]
	return new_position
