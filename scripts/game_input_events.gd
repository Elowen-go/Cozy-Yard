class_name GameInputEvents

static func movement_input(last_direction: Vector2 = Vector2.ZERO) -> Vector2:
	# A newly pressed direction takes priority over a key that is already held.
	if Input.is_action_just_pressed("walk_left"):
		return Vector2.LEFT
	elif Input.is_action_just_pressed("walk_right"):
		return Vector2.RIGHT
	elif Input.is_action_just_pressed("walk_up"):
		return Vector2.UP
	elif Input.is_action_just_pressed("walk_down"):
		return Vector2.DOWN

	# Keep the current direction while its key is still held.
	if last_direction == Vector2.LEFT and Input.is_action_pressed("walk_left"):
		return Vector2.LEFT
	elif last_direction == Vector2.RIGHT and Input.is_action_pressed("walk_right"):
		return Vector2.RIGHT
	elif last_direction == Vector2.UP and Input.is_action_pressed("walk_up"):
		return Vector2.UP
	elif last_direction == Vector2.DOWN and Input.is_action_pressed("walk_down"):
		return Vector2.DOWN

	# If the previous key was released, continue with any other held key.
	if Input.is_action_pressed("walk_left"):
		return Vector2.LEFT
	elif Input.is_action_pressed("walk_right"):
		return Vector2.RIGHT
	elif Input.is_action_pressed("walk_up"):
		return Vector2.UP
	elif Input.is_action_pressed("walk_down"):
		return Vector2.DOWN

	return Vector2.ZERO


static func is_movement_input(last_direction: Vector2 = Vector2.ZERO) -> bool:
	return movement_input(last_direction) != Vector2.ZERO


static func tool_selection_input() -> DataTypes.Tools:
	if Input.is_action_just_pressed("select_tool_none"):
		return DataTypes.Tools.None
	elif Input.is_action_just_pressed("select_tool_axe"):
		return DataTypes.Tools.AxeWood
	elif Input.is_action_just_pressed("select_tool_till"):
		return DataTypes.Tools.TillGround
	elif Input.is_action_just_pressed("select_tool_water"):
		return DataTypes.Tools.WaterCrops

	return DataTypes.Tools.None


static func is_tool_selection_pressed() -> bool:
	return Input.is_action_just_pressed("select_tool_none") \
		or Input.is_action_just_pressed("select_tool_axe") \
		or Input.is_action_just_pressed("select_tool_till") \
		or Input.is_action_just_pressed("select_tool_water")


static func is_tool_use_pressed() -> bool:
	return Input.is_action_just_pressed("use_tool")
