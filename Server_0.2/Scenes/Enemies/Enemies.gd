extends CharacterBody2D


var speed = 30
var acceleration = 50
var max_speed = 30
var friction = 150
var wander_target_range = 256
var state = "Idle"
var enemy_state
var animation_vector = Vector2()
var type = ["SkullMan"]
var map
var target_reached = false
var wander_timer_duration = 5
var state_ready = true
#onready var stats = $Stats
@onready var playerDetectionZone = $PlayerDetectionZone
@onready var hurtbox = $Hurtbox
@onready var wanderController = $WanderController



func _physics_process(delta):
	match state:
		"Idle":
			if state_ready:
				state_ready = false  # Evitar que se ejecute varias veces
				# Iniciar temporizador de 3 segundos antes de cambiar al estado "Wander"
				await get_tree().create_timer(1).timeout
				state = "Wander"
				state_ready = true  # Volver a permitir el cambio de estado
		"Wander":
			if state_ready:
				state_ready = false  # Evitar que se ejecute varias veces
				wanderController.update_target_position()  # Generar nueva posición aleatoria
			# Moverse hacia la posición objetivo
			move_towards_target(delta)
			# Verificar si se ha alcanzado el objetivo
			if global_position.distance_to(wanderController.target_position) < 5:
				state = "Idle"  # Volver al estado Idle
				state_ready = true  # Permitir cambiar de estado
	DefineEnemyState()

# Función para mover el enemigo hacia la posición objetivo

# Función para mover el enemigo hacia la posición objetivo
func move_towards_target(_delta):
	var direction = global_position.direction_to(wanderController.target_position)
	velocity = direction * speed  # Actualizar la velocidad hacia el objetivo
	
	# Usar move_and_collide() para manejar colisiones
	var collision = move_and_collide(velocity * _delta)

	if collision != null:
		var collider = collision.get_collider()  # Obtener el colisionador
		
		if collider.is_in_group("Players"):
			# Colisiona con un jugador, no hacer nada
			#sprint("Colisionó con un jugador")
			return
		else:
			# Colisiona con algo que no es un jugador, actualizar la posición para vagar de nuevo
			#print("Colisión con: ", collider.name)
			wanderController.update_target_position()  # Cambiar de dirección

#	DefineEnemyState()
func DefineEnemyState():
	var  enemy_list = get_node("/root/GameServer/CiudadPrincipalHandler/").enemy_list[str(get_name())]
	enemy_state = {
		"T": type[0],
		"G": enemy_list["G"],
		"EXP":enemy_list["EXP"], 
		"P": position, 
		"H": enemy_list["H"], 
		"mH": enemy_list["mH"], 
		"S": state, 
		"TO": 1, 
		"A": animation_vector  
		}
	get_node("/root/GameServer/CiudadPrincipalHandler/").ReceiveEnemyState(enemy_state,name)

func _on_hitbox_body_entered(body: Node2D) -> void:
	var damage =  ServerData.enemy_data[type[0]]["Damage"]
	print("damage",damage)
	var player_id = body.get_name()
	print("player_id",player_id)
	state = "Attack"
	#a donde voy a enviar el danio que estoy realizando?
	#cual es el delay para volver a realizar danio?
	get_parent().get_parent().get_parent().get_parent().get_node(str(map) + "Handler").PlayerHit(body.get_name(),type)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	var ciudad_principal_node = get_node("/root/GameServer/CiudadPrincipalHandler")
	var node_name = get_name()
	var _key = "health"
	var damage = ServerData.skill_data[body.skill_name].SkillDamage
	ciudad_principal_node.EnemyHurt(str(node_name), damage,body.player_id)
 
