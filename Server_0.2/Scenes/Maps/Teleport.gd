extends Area2D

@export var destiny: String 
@export var ubication: String
@export var spawn_point: Vector2



func _on_body_entered(body: Node2D) -> void:
	var new_class = body.get_class()
	match new_class:
		"TileMapLayer":
			return
		"CharacterBody2D":
			get_node("/root/GameServer/" + body.name).Teleport(destiny,ubication,body,spawn_point)
