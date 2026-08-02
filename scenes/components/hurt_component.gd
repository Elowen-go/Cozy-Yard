class_name HurtComponent
extends Area2D

signal hurt(tool: DataTypes.Tools, damage: int, hit_component: HitComponent)

@export var tool: DataTypes.Tools = DataTypes.Tools.None


func receive_hit(
	hit_tool: DataTypes.Tools,
	hit_damage: int,
	hit_component: HitComponent = null
) -> bool:
	if tool == DataTypes.Tools.None or hit_tool != tool:
		return false

	var applied_damage := maxi(hit_damage, 0)
	hurt.emit(hit_tool, applied_damage, hit_component)
	return true
