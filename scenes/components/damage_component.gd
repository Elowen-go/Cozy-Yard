class_name DamageComponent
extends Node2D

signal max_damage_reached

@export_range(0, 9999, 1) var max_damage: int = 1
@export_range(0, 9999, 1) var current_damage: int = 0


func apply_damage(amount: int) -> int:
	if current_damage >= max_damage:
		return current_damage

	current_damage = mini(current_damage + maxi(amount, 0), max_damage)
	if current_damage >= max_damage:
		max_damage_reached.emit()

	return current_damage
