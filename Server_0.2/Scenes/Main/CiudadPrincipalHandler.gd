extends Node

var enemy_id_counter = 0

var enemy_types = ["SkullMan"] #,"Demon"list of enemies that  can spawn on the map
var map = "CiudadPrincipal"
var open_locations =  [0]
var enemy_spawn_points = [] 
var enemy_maximum = 0
var occupied_locations = {}
var enemy_list = {}

func _ready():
	pass
