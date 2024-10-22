extends Node2D

var wander_range = 128  # Rango dentro del cual el enemigo puede vagar.
@onready var start_position = Vector2()
@onready var target_position = Vector2()

@onready var timer = $Timer

func _ready():
	start_position = global_position  # Guardar la posición inicial del enemigo
	update_target_position()

func update_target_position():
	# Generar un vector aleatorio dentro del rango
	var target_vector = Vector2(
		randi_range(-wander_range, wander_range),
		randi_range(-wander_range, wander_range)
	)
	target_position = start_position + target_vector  # Posición destino

func start_wander_timer(duration):
	timer.start(duration)

func get_time_left() -> float:
	return timer.time_left()
