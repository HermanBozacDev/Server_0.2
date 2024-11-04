extends CharacterBody2D

const SPEED = 1200.0


"""CAMARA"""
func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	if Input.is_action_pressed("w"):
		direction.y -= 1
	if Input.is_action_pressed("s"):
		direction.y += 1
	if Input.is_action_pressed("a"):
		direction.x -= 1
	if Input.is_action_pressed("d"):
		direction.x += 1
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	velocity = direction * SPEED
	move_and_slide()
