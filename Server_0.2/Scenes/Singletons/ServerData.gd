extends Node

# Variables para almacenar datos
var account_data: Dictionary = {}
var enemy_data: Dictionary = {}
var skill_data: Dictionary = {}
var class_data: Dictionary = {}
var player_data: Dictionary = {}
var loot_data: Dictionary = {}
var inventary_data: Dictionary = {}
var item_data: Dictionary = {}
var hot_bar_data: Dictionary = {}
var equip_item_data: Dictionary = {}
var learn_skills_data: Dictionary = {}

func _ready() -> void:
	print("Cargando datos del servidor")
	# Carga de datos desde archivos
	skill_data = load_json("res://Data/SkillData.json")
	class_data = load_json("res://Data/ClaseBaseStats.json")
	enemy_data = load_json("res://Data/EnemyData.json")
	loot_data = load_json("res://Data/LootData.json")
	item_data = load_json("res://Data/ItemData.json")
	player_data = load_json("user://PlayerData.json")
	account_data = load_json("user://AccountData.json")
	inventary_data = load_json("user://InventaryData.json")
	hot_bar_data = load_json("user://HotBarData.json")
	equip_item_data = load_json("user://EquipItemData.json")
	learn_skills_data = load_json("user://LearnSkillData.json")

# Función para cargar JSON desde un archivo
func load_json(file_path: String) -> Dictionary:
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var file_content: String = file.get_as_text()
		file.close()

		if file_content.strip_edges() == "":
			print("Archivo JSON vacío:", file_path)
			return {}

		var json_parser = JSON.new()
		var parse_result = json_parser.parse(file_content)

		if parse_result == OK:
			return json_parser.get_data()
		else:
			print("Error al parsear el archivo JSON:", json_parser.get_error_message())
	else:
		print("Archivo no encontrado:", file_path)
	return {}

# Funciones para guardar datos
func save_json(file_path: String, data: Dictionary) -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

# Funciones para guardar cada tipo de datos
func SavePlayers() -> void:
	save_json("user://PlayerData.json", player_data)

func SaveAccounts() -> void:
	print("Registrando un nuevo personaje en una cuenta")
	save_json("user://AccountData.json", account_data)

func SaveInventory() -> void:
	save_json("user://InventaryData.json", inventary_data)

func SaveHotBar() -> void:
	save_json("user://HotBarData.json", hot_bar_data)

func SaveEquipItem() -> void:
	save_json("user://EquipItemData.json", equip_item_data)

func SaveLearnSkill() -> void:
	save_json("user://LearnSkillData.json", learn_skills_data)



# Función para crear un nuevo jugador
func CreateNewPlayerDatabase(value):
	if player_data.has(value[1]):
		print("El nombre ya existe")
	else:
		print("Creando un nuevo jugador")
		var stats = class_data[value[2]]
		player_data[value[1]] = {
			"healthreg": stats["HEALTHREG"],
			"manareg": stats["MANAREG"],
			"maxhealth": stats["MAXHEALTH"],
			"maxmana": stats["MAXMANA"],
			"health": stats["HEALTH"],
			"mana": stats["MANA"],
			"clase": value[2],
			"type": value[3],
			"level": 1,
			"exp": 0,
			"gold": 0,
			"str": stats["STR"],
			"dex": stats["DEX"],
			"vit": stats["VIT"],
			"int": stats["INT"],
			"Px": 0,
			"Py": 0,
			"M": "CiudadPrincipal",
			"expFaltante": 100,
			"expRequerida": 100,
			"T": 0
		}
		inventary_data[value[1]] = {}
		hot_bar_data[value[1]] = {}
		equip_item_data[value[1]] = {}
		var type = value[3]
		match type:
			"wizard":
				var skill = class_data[value[2]]["SkillAMage"]
				learn_skills_data[value[1]] = {
					skill: [
						skill, 
						skill_data[skill]["SkillActivePasive"], 
						skill_data[skill]["SkillType"],
						skill_data[skill]["ProjectileSpeed"],
						skill_data[skill]["SkillDamage"]
						
						]}
			"fighter":
				for skill in class_data[value[2]]["SkillAWarrior"]:
					if !learn_skills_data.has(value[1]):
						learn_skills_data[value[1]] = {
							skill: [
								skill, 
								skill_data[skill]["SkillActivePasive"], 
								skill_data[skill]["SkillType"],
								skill_data[skill]["ProjectileSpeed"],
								skill_data[skill]["SkillDamage"]
								]}
					else:
						learn_skills_data[value[1]][skill] = [
							skill, 
							skill_data[skill]["SkillActivePasive"], 
							skill_data[skill]["SkillType"],
							skill_data[skill]["ProjectileSpeed"],
							skill_data[skill]["SkillDamage"]
							]
						

		# Guardar los datos
		SavePlayers()
		SaveAccounts()
		SaveInventory()
		SaveHotBar()
		SaveEquipItem()
		SaveLearnSkill()




func CreatePlayerSave(value):
	#value=username,nickname,new_class,new_type
	# Verifica si ya hay una entrada para el usuario
	if !account_data.has(value[0]):
		account_data[value[0]] = {}
		var player_save = account_data[value[0]]
		player_save[str(value[1])] = {"clase": value[2], "type": value[3],"level": player_data[value[1]]["level"] }
		account_data[str(value[0])] = player_save
		SaveAccounts()
	else:
		var player_save = account_data[value[0]]
		player_save[str(value[1])] = {"clase": value[2], "type": value[3],"level": player_data[value[1]]["level"]}
		account_data[str(value[0])] = player_save
		SaveAccounts()







# Función para buscar personajes de un usuario y devolver el pool de personajes
func PlayerPoolSearch(player_id, username):
	
	# Crear un diccionario vacío para almacenar el pool de personajes
	var player_pool: Dictionary = {}

	# Verificar si el usuario existe en los datos de cuenta
	if account_data.has(username):
		# Obtener los personajes del usuario como diccionario
		var user_characters = account_data[username] as Dictionary  
		# Inicializar el pool de personajes del usuario en player_pool
		player_pool[username] = {}
		# Iterar sobre los personajes del usuario
		for nickname in user_characters.keys():
			print("player:", nickname)
			# Agregar el personaje al pool del usuario
			player_pool[username][nickname] = user_characters[nickname]  
	else:
		print("Usuario no encontrado:", username)
	# Enviar la respuesta al servidor con el pool de personajes
	var key = "PlayerPool"
	get_node("/root/GameServer").ServerSendDataToOneClient(player_id, key, player_pool)








func CheckNickOpen(nickname):
	if player_data.has(nickname):
		print("El nombre ya existe")
		return false
	else:
		print("disponible")
		return true
