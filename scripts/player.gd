class_name M0Player
extends CharacterBody2D

const SPEED := 90.0
const BOUNDS := Rect2(Vector2(-112, -112), Vector2(224, 224))

var sprite: Sprite2D


func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = load("res://assets/Tiny Swords (Free Pack)/Units/Blue Units/Pawn/Pawn_Idle.png")
	sprite.hframes = 8
	sprite.frame = 0
	sprite.position = Vector2(0, -24)
	sprite.scale = Vector2(0.4, 0.4)
	add_child(sprite)
	queue_redraw()


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED
	move_and_slide()
	global_position.x = clampf(global_position.x, BOUNDS.position.x, BOUNDS.end.x)
	global_position.y = clampf(global_position.y, BOUNDS.position.y, BOUNDS.end.y)
	if sprite:
		sprite.frame = int(Time.get_ticks_msec() / 180.0) % 8
	queue_redraw()
