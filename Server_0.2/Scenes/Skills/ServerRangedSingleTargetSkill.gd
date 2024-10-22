extends RigidBody2D

var projectile_speed 
var life_time = 1.5
var skill_name
var skill_damage
var player_id
var map
var direction
var skill_id

func _ready():
	SetDamage()
	apply_central_impulse(Vector2(projectile_speed, 0).rotated(rotation))
	SelfDestruct()

func SelfDestruct():
	await get_tree().create_timer(life_time).timeout
	queue_free()

func SetDamage():
	skill_damage = ServerData.skill_data["WindStrike"].SkillDamage * (0.1 * get_node("/root/GameServer/"+ str(player_id)).player_stats["int"]) 

func _on_body_entered(_body: Node) -> void:
	get_node("CollisionShape2D").set_deferred("disabled", true)
	self.hide()
