extends Node

var level_damage_bonus = 1.5
var constant_multiplier = 10  
""" Simple Melee Attack: """
func CalculateSimpleMeleeAttackDamage(PlayerPAtk, EnemyPDef):
	var final_damage = (PlayerPAtk /  EnemyPDef) * constant_multiplier 
	return final_damage


""" Physical Damage Skills """
func CalculatedPhysicSkillDamage(PlayerPAtk := 1, SkillPower := 1, EnemyPDef := 1):
	var skill_damage = PlayerPAtk * (SkillPower / 100)
	var attack_component = PlayerPAtk + skill_damage
	var final_damage = (attack_component / EnemyPDef) * constant_multiplier
	return final_damage


""" Magical Damage Skills """
func CalculatedMagicSkillDamage(PlayerMAtk := 1, SkillPower := 1, EnemyMDef := 1):
	var skill_damage = PlayerMAtk * (SkillPower / 100)
	var attack_component = PlayerMAtk + skill_damage
	var final_damage = (attack_component / EnemyMDef) * constant_multiplier
	return final_damage
