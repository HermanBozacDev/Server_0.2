extends Node

# Diccionario que guarda los ítems del loot_selector
var loot_count
var loot_dic = {}
var prev_key

# Determina la cantidad de items del loot de acuerdo al enemigo
func DetermineLootCount(enemy_name):
	var ItemCountMin = ServerData.loot_data[enemy_name].ItemCountMin
	var ItemCountMax = ServerData.loot_data[enemy_name].ItemCountMax
	randomize()
	loot_count = randi() % ((int(ItemCountMax) - int(ItemCountMin)) + 1 ) + int(ItemCountMin)

# Selecciona los ítems de loot para un enemigo y jugador específico
func LootSelector(enemy_name, player_nickname, player_id, map):
	loot_dic.clear()
	for _i in range(1, loot_count + 1):
		randomize()
		var loot_selector = randi() % 100 + 1
		var counter = 1
		while loot_selector >= 0:
			if loot_selector <= ServerData.loot_data[enemy_name]["Item" + str(counter) + "Chance"]:
				#print("enemy loot data", ServerData.loot_data[enemy_name])
				var loot = []
				loot.append(ServerData.loot_data[enemy_name]["Item" + str(counter) + "Name"])
				randomize()
				var nombre_item_actual = ServerData.loot_data[enemy_name]["Item" + str(counter) + "Name"]
				if ServerData.item_data[nombre_item_actual].ItemCount == "true":
					@warning_ignore("narrowing_conversion")
					loot.append(int(randi_range(float(ServerData.loot_data[enemy_name]["Item" + str(counter) + "MinQ"]), float(ServerData.loot_data[enemy_name]["Item" + str(counter) + "MaxQ"]))))
				loot_dic[loot_dic.size() + 1] = loot
				break
			else:
				loot_selector -= ServerData.loot_data[enemy_name]["Item" + str(counter) + "Chance"]
				counter += 1
	_on_LootButton_pressed(player_nickname, loot_dic, player_id, map)

# Acción al presionar el botón de loot
func _on_LootButton_pressed(nickname, my_loot_dic, player_id, _map):
	for key_loot in my_loot_dic.keys():
		@warning_ignore("unused_variable")
		var my_key_inven
		var repetido
		for key_inven in ServerData.inventary_data[nickname].keys():
			if ServerData.inventary_data[nickname][key_inven][0] == my_loot_dic[key_loot][0]:
				my_key_inven = key_inven
				repetido = "si"
		if repetido == "si":
			if ServerData.item_data[my_loot_dic[key_loot][0]].ItemCount == "true":
				pass
				#ServerData.inventary_data[nickname][my_key_inven][1] += my_loot_dic[key_loot][1]
				#my_loot_dic.erase(key_loot)
			else:
				if !checkslot(nickname):
					print("sin lugar en el inventario")
				else:
					var slot_libre = checkslot(nickname)
					print("slotlibre", slot_libre)
					ServerData.inventary_data[nickname][str(slot_libre)] = my_loot_dic[key_loot]
					my_loot_dic.erase(key_loot)
			repetido = "no"
		else:
			var slot_libre = checkslot(nickname)
			ServerData.inventary_data[nickname][str(slot_libre)] = loot_dic[key_loot]
			loot_dic.erase(key_loot)
			
	ServerData.SaveInventory()
	var key = "inventory"
	var new_value = ServerData.inventary_data[nickname]
	#get_parent().UpdateKeyState(player_id,key,new_value)

# Verifica si hay espacio disponible en el inventario
func checkslot(nickname):
	var slot_checker_start = 1
	var slot_checker_max = 25
	while slot_checker_start <= slot_checker_max + 1:
		if slot_checker_start > slot_checker_max:
			print("your Inventory is Full")
			break
		elif ServerData.inventary_data[nickname].has(str(slot_checker_start)):
			slot_checker_start += 1
		else:
			return slot_checker_start
