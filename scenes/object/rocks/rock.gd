extends Sprite2D

@export var stone_scene: PackedScene
@export_range(0.0, 4.0, 0.1) var hit_shake_intensity := 1.5
@export_range(0.05, 1.0, 0.05) var hit_shake_duration := 0.2

@onready var damage_component: DamageComponent = $DamageComponent
@onready var hurt_component: HurtComponent = $HurtComponent

var is_destroying := false
var rock_material: ShaderMaterial
var shake_tween: Tween


func _ready() -> void:
	if material is ShaderMaterial:
		material = material.duplicate()
		rock_material = material as ShaderMaterial
		rock_material.set_shader_parameter("shake_intensity", 0.0)

	hurt_component.hurt.connect(_on_hurt)
	damage_component.max_damage_reached.connect(_on_max_damage_reached)


func _on_hurt(
	_tool: DataTypes.Tools,
	_damage: int,
	_hit_component: HitComponent
) -> void:
	_play_hit_shake()
	damage_component.apply_damage(_damage)


func _play_hit_shake() -> void:
	if not rock_material:
		return

	if shake_tween:
		shake_tween.kill()

	rock_material.set_shader_parameter("shake_intensity", hit_shake_intensity)
	shake_tween = create_tween()
	shake_tween.tween_property(
		rock_material,
		"shader_parameter/shake_intensity",
		0.0,
		hit_shake_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_max_damage_reached() -> void:
	if is_destroying:
		return

	is_destroying = true
	call_deferred("_drop_stone_and_destroy")


func _drop_stone_and_destroy() -> void:
	if not is_inside_tree():
		return

	if stone_scene and get_parent():
		var stone_instance := stone_scene.instantiate() as Node2D
		get_parent().add_child(stone_instance)
		stone_instance.global_position = global_position

	queue_free()
