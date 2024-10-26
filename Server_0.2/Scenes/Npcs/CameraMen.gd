extends CharacterBody2D

const SPEED = 600.0

func _physics_process(_delta: float) -> void:
	# Inicializar la dirección del movimiento en cero.
	var direction := Vector2.ZERO

	# Verificar las teclas de movimiento y ajustar la dirección.
	if Input.is_action_pressed("w"):
		direction.y -= 1
	if Input.is_action_pressed("s"):
		direction.y += 1
	if Input.is_action_pressed("a"):
		direction.x -= 1
	if Input.is_action_pressed("d"):
		direction.x += 1

	# Normalizar la dirección para mantener la velocidad constante en diagonales.
	if direction != Vector2.ZERO:
		direction = direction.normalized()

	# Mover al personaje.
	velocity = direction * SPEED
	move_and_slide()
