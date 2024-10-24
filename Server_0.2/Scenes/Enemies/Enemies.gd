



extends CharacterBody2D

var speed = 15
var chase_speed = 15
var state = "Idle"
var animation_vector = Vector2()
var target_reached = false
var state_ready = true
var attack_distance = 8  # Distancia mínima para atacar
var wander_target_range = 128  # Rango de vagar aleatorio
var player
var target_attack
var is_attaking = false
@onready var playerDetectionZone = $PlayerDetectionZone
@onready var wanderController = $WanderController


var enemy_state

var type = ["SkullMan"]
var map

var wander_timer_duration = 5


func _ready():
	player = playerDetectionZone.player

func _physics_process(delta):
	
	match state:
		"Idle":
			if state_ready:
				state_ready = false
				await get_tree().create_timer(2).timeout  # Espera 2 segundos
				state = "Wander"
				state_ready = true
		"Wander":
			if state_ready:
				state_ready = false
				wanderController.update_target_position()  # Generar nueva posición aleatoria
			move_towards_target(delta)
			if global_position.distance_to(wanderController.target_position) < 5:
				state = "Idle"  # Volver a Idle después de llegar al punto
				state_ready = true
			seek_player()  # Ver si hay un jugador cerca para cambiar a Chase
		"Chase":
			Chase(delta)
		"Attack":
			if is_attaking == false:
				Attack()
			else:
				pass
	DefineEnemyState()
# Función que busca al jugador y cambia al estado Chase si lo detecta
func seek_player():
	if playerDetectionZone.can_see_player():  # Si el área de detección ve al jugador
		state = "Chase"  # Cambia el estado a 'Chase'
	else:
		if state == "Chase":  # Si ya no ve al jugador y estaba persiguiendo
			state = "Wander"  # Cambia de nuevo a 'Wander'



# Función principal de Chase
func Chase(delta):
	if playerDetectionZone.can_see_player() and playerDetectionZone.player != null:
		var player_pos = playerDetectionZone.player.global_position  # Obtén la posición del jugador
		var direction = global_position.direction_to(player_pos)
		
		# En lugar de verificar distancia, siempre intentamos perseguir
		ChaseMove(direction, delta)
	else:
		# Si no puede ver al jugador, debería hacer otra cosa (volver a patrullar o quedarse quieto)
		
		state = "Wander"  # O cualquier otro estado que haga sentido


# Función de movimiento hacia el jugador
func ChaseMove(direction, delta):
	velocity = direction * chase_speed * delta
	
	# Usa move_and_collide() para detectar colisiones
	var collision = move_and_collide(velocity)
	
	# Si hay una colisión
	if collision != null:
		# Verificar si colisiona con el jugador
		if collision.get_collider() == playerDetectionZone.player:
			state = "Attack"  # Cambiar al estado de ataque al colisionar con el jugador
		else:
			velocity = Vector2.ZERO  # Detener el movimiento si colisiona con algo que no sea el jugador
	
	# Continuar el movimiento si no hay colisión
	move_and_collide(velocity)

	# Actualiza el vector de animación basado en la velocidad
	animation_vector = velocity

# Función de ataque
func Attack():
	is_attaking = true
	
	var damage =  ServerData.enemy_data[type[0]]["Damage"]
	get_node("/root/GameServer/" + str(target_attack)).ApplyDamageOnPlayer(damage)
	await get_tree().create_timer(1.5).timeout
	state = "Chase"  # Después de atacar, volver a Chase
	is_attaking = false






# Función para mover el enemigo hacia una posición objetivo durante el Wander
func move_towards_target(delta):
	var direction = global_position.direction_to(wanderController.target_position)
	velocity = direction * speed * delta
	
	# Usa move_and_collide() para detectar colisiones
	var collision = move_and_collide(velocity)
	
	# Si hay una colisión
	if collision != null:
		# Asegúrate de que collider no sea null y verificar si no es el jugador
		if collision.get_collider() != playerDetectionZone.player:
			wanderController.update_target_position()
		else:
			print("Chocaste con el jugador, no cambies de objetivo.")
	
	# Actualiza el vector de animación basado en la velocidad
	animation_vector = velocity







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


func ApplyDamageOnSelf(attack):
	var ciudad_principal_node = get_node("/root/GameServer/CiudadPrincipalHandler")
	var node_name = get_name()
	var _key = "health"
	var damage = ServerData.skill_data[attack.skill_name].SkillDamage
	ciudad_principal_node.EnemyHurt(str(node_name), damage,attack.player_id)
