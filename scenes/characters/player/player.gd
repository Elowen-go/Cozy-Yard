class_name Player
extends CharacterBody2D

signal tool_changed(tool: DataTypes.Tools)

@export var current_tool: DataTypes.Tools = DataTypes.Tools.None

var player_direction := Vector2.DOWN

func _process(_delta: float) -> void:
	if GameInputEvents.is_tool_selection_pressed():
		set_current_tool(GameInputEvents.tool_selection_input())


func set_current_tool(tool: DataTypes.Tools) -> void:
	if current_tool == tool:
		return

	current_tool = tool
	tool_changed.emit(current_tool)


func get_current_tool_state() -> StringName:
	match current_tool:
		DataTypes.Tools.AxeWood:
			return &"chopping"
		DataTypes.Tools.TillGround:
			return &"tilling"
		DataTypes.Tools.WaterCrops:
			return &"watering"
		_:
			return &""
