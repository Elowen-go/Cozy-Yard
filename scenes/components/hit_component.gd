class_name HitComponent
extends Area2D

signal hit(hurt_component: HurtComponent)

@export var current_tool: DataTypes.Tools = DataTypes.Tools.None
@export_range(0, 9999, 1) var damage: int = 1

var _hit_hurt_components: Dictionary[HurtComponent, bool] = {}


func _on_area_entered(area: Area2D) -> void:
	if not area is HurtComponent:
		return

	var hurt_component := area as HurtComponent
	if _hit_hurt_components.has(hurt_component):
		return

	if hurt_component.receive_hit(current_tool, damage, self):
		_hit_hurt_components[hurt_component] = true
		hit.emit(hurt_component)


func clear_hit_targets() -> void:
	_hit_hurt_components.clear()
