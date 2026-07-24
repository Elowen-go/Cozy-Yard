extends Node2D

const State = preload("res://scripts/m0_state.gd")
const PlotVisual = preload("res://scripts/m0_plot.gd")
const Plants = preload("res://scripts/m1_plants.gd")
const Recipes = preload("res://scripts/m1_recipes.gd")
const Exploration = preload("res://scripts/m2_exploration.gd")
const Merchant = preload("res://scripts/m3_merchant.gd")
const PLAYER_SCENE_POSITION := Vector2(0, 32)
const WOOD_POSITION := Vector2(-80, -48)
const PLOT_POSITIONS := [Vector2(-64, 48), Vector2(0, 48), Vector2(64, 48)]
const CAMPFIRE_POSITION := Vector2(64, -48)
const INTERACTION_RADIUS := 26.0
const MAP_HALF_SIZE := 144.0

var state: M0State
var wood_cooldown := 0.0
var message_time := 0.0
var message_text := ""
var resource_label: Label
var help_label: Label
var message_label: Label
var crop_label: Label
var encyclopedia_panel: ColorRect
var encyclopedia_label: Label
var kitchen_panel: ColorRect
var kitchen_label: Label
var compost_panel: ColorRect
var compost_label: Label
var merchant_panel: ColorRect
var merchant_label: Label
var world_modulate: CanvasModulate
var map_panel: ColorRect
var map_label: Label
var map_preview: TextureRect
var log_panel: ColorRect
var log_label: Label
var plot_visuals: Array = []
var selected_plant_id: String = "wheat"
var selected_recipe_id: String = "radish_soup"
var selected_merchant_item_id: String = "fertilizer"
var selected_province_id: String = "sichuan"
var selected_scene_id: String = "sichuan_forest"
var map_result_text: String = ""
var fertilizer_mode := false
var last_night_state := false
var fire_sprite: Sprite2D
var campfire_root: Node2D


func _ready() -> void:
	y_sort_enabled = true
	state = State.new()
	state.load()
	world_modulate = CanvasModulate.new()
	world_modulate.name = "DayNightModulate"
	add_child(world_modulate)
	last_night_state = state.is_night()
	$Player.position = PLAYER_SCENE_POSITION
	$Player.z_index = 1
	_create_world_visuals()
	_create_collision_world()
	_create_ui()
	_set_message("欢迎来到闲庭。先点击左侧木桩获得木头。", 5.0)
	queue_redraw()


func _process(delta: float) -> void:
	state.advance_world_time(delta)
	if state.is_night() != last_night_state:
		last_night_state = state.is_night()
		state.save()
	var recovered_energy: int = state.refresh_energy()
	if recovered_energy > 0:
		state.save()
	if state.refresh_merchant():
		state.save()
	wood_cooldown = maxf(0.0, wood_cooldown - delta)
	for index in range(State.PLOT_COUNT):
		if state.advance_crop(index, delta):
			_set_message("第 %d 块菜圃的%s成熟了，点击收获。" % [index + 1, Plants.plant_name(state.plot_plant_id(index))], 3.0)
			state.save()
			queue_redraw()
	_update_ui()
	_update_day_night_visuals()
	if fire_sprite:
		fire_sprite.frame = int(Time.get_ticks_msec() / 140.0) % 8
	if message_time > 0.0:
		message_time -= delta
		if message_time <= 0.0:
			message_label.text = ""


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if not event.pressed or event.echo:
			return
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode == KEY_Q or key_event.keycode == KEY_E:
			if map_panel and map_panel.visible:
				_cycle_province(-1 if key_event.keycode == KEY_Q else 1)
			elif not _any_overlay_visible():
				_cycle_plant(-1 if key_event.keycode == KEY_Q else 1)
			return
		if key_event.keycode == KEY_Z or key_event.keycode == KEY_X:
			if map_panel and map_panel.visible:
				_cycle_scene(-1 if key_event.keycode == KEY_Z else 1)
			return
		var key_index: int = _plant_key_index(key_event.keycode)
		if key_index >= 0:
			if merchant_panel and merchant_panel.visible:
				var merchant_item_ids: Array[String] = Merchant.all_ids()
				if key_index < merchant_item_ids.size():
					selected_merchant_item_id = merchant_item_ids[key_index]
					_update_merchant()
				return
			if kitchen_panel and kitchen_panel.visible:
				var recipe_ids: Array[String] = Recipes.all_ids()
				if key_index < recipe_ids.size():
					selected_recipe_id = recipe_ids[key_index]
					_update_kitchen()
				return
			if map_panel and map_panel.visible:
				var province_ids: Array[String] = Exploration.all_ids()
				if key_index < province_ids.size():
					selected_province_id = province_ids[key_index]
					selected_scene_id = str(Exploration.get_scenes(selected_province_id)[0].get("scene_id", ""))
					_update_map()
				return
			var plant_ids: Array[String] = Plants.selectable_ids()
			selected_plant_id = plant_ids[key_index]
			_set_message("已选择 %s，下一次点击已开垦菜圃时播种。" % Plants.plant_name(selected_plant_id), 2.0)
			_update_ui()
			return
		if key_event.keycode == KEY_M:
			_toggle_map()
			return
		if key_event.keycode == KEY_L:
			_toggle_log()
			return
		if key_event.keycode == KEY_B:
			_toggle_compost()
			return
		if key_event.keycode == KEY_T:
			_toggle_merchant()
			return
		if key_event.keycode == KEY_F:
			fertilizer_mode = not fertilizer_mode
			_set_message("已进入施肥模式，点击生长中的菜圃。" if fertilizer_mode else "已退出施肥模式。", 2.0)
			return
		if (key_event.keycode == KEY_ENTER or key_event.keycode == KEY_KP_ENTER) and map_panel and map_panel.visible:
			_explore_selected_province()
			return
		if key_event.keycode == KEY_I:
			_toggle_encyclopedia()
			return
		if key_event.keycode == KEY_K:
			_toggle_kitchen()
			return
		if (key_event.keycode == KEY_ENTER or key_event.keycode == KEY_KP_ENTER) and compost_panel and compost_panel.visible:
			_make_fertilizer()
			return
		if (key_event.keycode == KEY_ENTER or key_event.keycode == KEY_KP_ENTER) and merchant_panel and merchant_panel.visible:
			_buy_merchant_item()
			return
		if (key_event.keycode == KEY_ENTER or key_event.keycode == KEY_KP_ENTER) and kitchen_panel and kitchen_panel.visible:
			_cook_selected_recipe()
			return
		return
	if not event is InputEventMouseButton:
		return
	if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
		return

	var world_position := get_global_mouse_position()
	if world_position.distance_to(WOOD_POSITION) <= INTERACTION_RADIUS:
		_collect_wood()
	elif world_position.distance_to(CAMPFIRE_POSITION) <= INTERACTION_RADIUS:
		_upgrade_campfire()
	else:
		for index in range(PLOT_POSITIONS.size()):
			if world_position.distance_to(PLOT_POSITIONS[index]) <= INTERACTION_RADIUS:
				if fertilizer_mode:
					_fertilize_plot(index)
				else:
					_interact_with_plot(index)
				break


func _plant_key_index(keycode: int) -> int:
	var key_indexes: Dictionary = {
		KEY_1: 0,
		KEY_2: 1,
		KEY_3: 2,
		KEY_4: 3,
		KEY_5: 4,
		KEY_6: 5,
	}
	return int(key_indexes.get(keycode, -1))


func _any_overlay_visible() -> bool:
	return (encyclopedia_panel and encyclopedia_panel.visible) or (kitchen_panel and kitchen_panel.visible) or (compost_panel and compost_panel.visible) or (merchant_panel and merchant_panel.visible) or (map_panel and map_panel.visible) or (log_panel and log_panel.visible)


func _cycle_plant(direction: int) -> void:
	var plant_ids: Array[String] = Plants.selectable_ids()
	var current_index: int = plant_ids.find(selected_plant_id)
	if current_index < 0:
		current_index = 0
	var next_index: int = posmod(current_index + direction, plant_ids.size())
	selected_plant_id = plant_ids[next_index]
	_set_message("已选择 %s。" % Plants.plant_name(selected_plant_id), 1.5)
	_update_ui()


func _cycle_province(direction: int) -> void:
	var province_ids: Array[String] = Exploration.all_ids()
	var current_index: int = province_ids.find(selected_province_id)
	if current_index < 0:
		current_index = 0
	var next_index: int = posmod(current_index + direction, province_ids.size())
	selected_province_id = province_ids[next_index]
	var scenes: Array = Exploration.get_scenes(selected_province_id)
	if not scenes.is_empty():
		selected_scene_id = str(scenes[0].get("scene_id", ""))
	_update_map()


func _cycle_scene(direction: int) -> void:
	var scenes: Array = Exploration.get_scenes(selected_province_id)
	if scenes.is_empty():
		return
	var scene_index: int = 0
	for index in range(scenes.size()):
		var scene: Dictionary = scenes[index]
		if str(scene.get("scene_id", "")) == selected_scene_id:
			scene_index = index
			break
	var next_index: int = posmod(scene_index + direction, scenes.size())
	var next_scene: Dictionary = scenes[next_index]
	selected_scene_id = str(next_scene.get("scene_id", ""))
	_update_map()


func _collect_wood() -> void:
	if wood_cooldown > 0.0:
		_set_message("木桩还需要等待 %.1f 秒。" % wood_cooldown, 2.0)
		return
	wood_cooldown = 3.0
	state.add_wood()
	state.save()
	_set_message("获得木头 x1。", 2.0)
	_update_ui()


func _interact_with_plot(index: int) -> void:
	match state.plot_stage(index):
		"idle":
			if state.prepare_plot(index):
				_set_message("第 %d 块菜圃已开垦，再点击一次播种。" % (index + 1), 2.0)
			else:
				_set_message("开垦需要木头 x1。", 2.0)
		"prepared":
			state.plant_crop(index, selected_plant_id)
			_set_message("第 %d 块菜圃已播种%s。" % [index + 1, Plants.plant_name(selected_plant_id)], 2.0)
		"growing":
			var growing_definition: Dictionary = Plants.get_definition(state.plot_plant_id(index))
			var growing_duration: float = float(growing_definition.get("duration", State.CROP_DURATION))
			_set_message("第 %d 块菜圃的%s正在生长，进度 %.0f%%。" % [index + 1, Plants.plant_name(state.plot_plant_id(index)), state.plot_elapsed(index) / growing_duration * 100.0], 2.0)
		"mature":
			var mature_plant_id: String = state.plot_plant_id(index)
			var harvested_plant_id: String = Plants.harvest_result_id(mature_plant_id, state.is_plot_fertilized(index))
			var mature_definition: Dictionary = Plants.get_definition(harvested_plant_id)
			state.harvest_crop(index)
			_set_message("第 %d 块菜圃收获%s，获得%s x%d。" % [index + 1, Plants.plant_name(harvested_plant_id), Plants.resource_name(str(mature_definition.get("reward_resource", "wood"))), int(mature_definition.get("reward_amount", 1))], 2.0)
	state.save()
	_update_ui()
	queue_redraw()


func _fertilize_plot(index: int) -> void:
	if state.fertilize_plot(index):
		state.save()
		_set_message("第 %d 块菜圃已施肥，生长速度提高 50%%。" % (index + 1), 2.0)
	else:
		_set_message("只能给未施肥的生长中作物施肥，且需要肥料。", 2.0)
	_update_ui()


func _upgrade_campfire() -> void:
	if state.upgrade_campfire():
		_set_message("篝火升级到 Lv.%d，作物生长加速。" % state.campfire_level, 3.0)
		state.save()
	else:
		_set_message("升级篝火需要木头 x%d。" % State.CAMPFIRE_UPGRADE_COST, 2.0)
	_update_ui()
	queue_redraw()


func _create_ui() -> void:
	var layer := CanvasLayer.new()
	layer.name = "M0UI"
	add_child(layer)

	var panel := ColorRect.new()
	panel.color = Color(0.06, 0.09, 0.12, 0.86)
	panel.position = Vector2(16, 16)
	panel.size = Vector2(320, 146)
	layer.add_child(panel)

	resource_label = Label.new()
	resource_label.position = Vector2(30, 28)
	resource_label.add_theme_font_size_override("font_size", 16)
	layer.add_child(resource_label)

	help_label = Label.new()
	help_label.position = Vector2(30, 72)
	help_label.text = "方向键移动\n1-5 选植物，Q/E 切换植物\nI 图鉴，K 厨房，M 地图，L 日志\nB 堆肥，F 施肥，T 商人"
	help_label.add_theme_color_override("font_color", Color("#c9d6df"))
	layer.add_child(help_label)

	message_label = Label.new()
	message_label.position = Vector2(16, 148)
	message_label.add_theme_font_size_override("font_size", 18)
	message_label.add_theme_color_override("font_color", Color("#fff3b0"))
	layer.add_child(message_label)

	crop_label = Label.new()
	crop_label.visible = false
	crop_label.add_theme_color_override("font_color", Color("#1f2933"))
	layer.add_child(crop_label)

	encyclopedia_panel = ColorRect.new()
	encyclopedia_panel.name = "EncyclopediaPanel"
	encyclopedia_panel.color = Color(0.06, 0.09, 0.12, 0.94)
	encyclopedia_panel.position = Vector2(352, 16)
	encyclopedia_panel.size = Vector2(272, 246)
	encyclopedia_panel.visible = false
	layer.add_child(encyclopedia_panel)

	encyclopedia_label = Label.new()
	encyclopedia_label.position = Vector2(14, 12)
	encyclopedia_label.add_theme_font_size_override("font_size", 14)
	encyclopedia_label.add_theme_color_override("font_color", Color("#f1f5dc"))
	encyclopedia_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	encyclopedia_label.size = Vector2(244, 224)
	encyclopedia_panel.add_child(encyclopedia_label)

	kitchen_panel = ColorRect.new()
	kitchen_panel.name = "KitchenPanel"
	kitchen_panel.color = Color(0.12, 0.08, 0.05, 0.96)
	kitchen_panel.position = Vector2(352, 16)
	kitchen_panel.size = Vector2(272, 246)
	kitchen_panel.visible = false
	layer.add_child(kitchen_panel)

	kitchen_label = Label.new()
	kitchen_label.position = Vector2(14, 12)
	kitchen_label.add_theme_font_size_override("font_size", 14)
	kitchen_label.add_theme_color_override("font_color", Color("#fff0c2"))
	kitchen_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	kitchen_label.size = Vector2(244, 224)
	kitchen_panel.add_child(kitchen_label)

	compost_panel = ColorRect.new()
	compost_panel.name = "CompostPanel"
	compost_panel.color = Color(0.10, 0.13, 0.07, 0.96)
	compost_panel.position = Vector2(352, 16)
	compost_panel.size = Vector2(272, 246)
	compost_panel.visible = false
	layer.add_child(compost_panel)

	compost_label = Label.new()
	compost_label.position = Vector2(14, 12)
	compost_label.add_theme_font_size_override("font_size", 14)
	compost_label.add_theme_color_override("font_color", Color("#e5f2c2"))
	compost_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	compost_label.size = Vector2(244, 224)
	compost_panel.add_child(compost_label)

	merchant_panel = ColorRect.new()
	merchant_panel.name = "MerchantPanel"
	merchant_panel.color = Color(0.13, 0.10, 0.07, 0.96)
	merchant_panel.position = Vector2(352, 16)
	merchant_panel.size = Vector2(272, 246)
	merchant_panel.visible = false
	layer.add_child(merchant_panel)

	merchant_label = Label.new()
	merchant_label.position = Vector2(14, 12)
	merchant_label.add_theme_font_size_override("font_size", 14)
	merchant_label.add_theme_color_override("font_color", Color("#ffe7b0"))
	merchant_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	merchant_label.size = Vector2(244, 224)
	merchant_panel.add_child(merchant_label)

	map_panel = ColorRect.new()
	map_panel.name = "MapPanel"
	map_panel.color = Color(0.08, 0.12, 0.16, 0.96)
	map_panel.position = Vector2(336, 16)
	map_panel.size = Vector2(304, 392)
	map_panel.visible = false
	layer.add_child(map_panel)

	map_label = Label.new()
	map_label.position = Vector2(14, 12)
	map_label.add_theme_font_size_override("font_size", 14)
	map_label.add_theme_color_override("font_color", Color("#e7f2ff"))
	map_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	map_label.size = Vector2(276, 264)
	map_panel.add_child(map_label)

	map_preview = TextureRect.new()
	map_preview.position = Vector2(14, 280)
	map_preview.size = Vector2(276, 96)
	map_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	map_panel.add_child(map_preview)

	log_panel = ColorRect.new()
	log_panel.name = "ExplorationLogPanel"
	log_panel.color = Color(0.10, 0.08, 0.06, 0.96)
	log_panel.position = Vector2(336, 16)
	log_panel.size = Vector2(304, 360)
	log_panel.visible = false
	layer.add_child(log_panel)

	log_label = Label.new()
	log_label.position = Vector2(14, 12)
	log_label.add_theme_font_size_override("font_size", 14)
	log_label.add_theme_color_override("font_color", Color("#fff0c2"))
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.size = Vector2(276, 336)
	log_panel.add_child(log_label)
	_update_ui()


func _create_world_visuals() -> void:
	var wood_sprite := Sprite2D.new()
	wood_sprite.name = "WoodResource"
	wood_sprite.texture = load("res://assets/Tiny Swords (Free Pack)/Terrain/Resources/Wood/Wood Resource/Wood Resource.png")
	wood_sprite.position = WOOD_POSITION
	wood_sprite.offset = Vector2(0, -8)
	wood_sprite.scale = Vector2(0.5, 0.5)
	wood_sprite.z_index = 1
	add_child(wood_sprite)

	for index in range(PLOT_POSITIONS.size()):
		var plot_visual: M0PlotVisual = PlotVisual.new()
		plot_visual.name = "CropPlot%d" % (index + 1)
		plot_visual.position = PLOT_POSITIONS[index]
		# The plots are ground decoration, so they never occlude the player.
		plot_visual.z_index = 0
		add_child(plot_visual)
		plot_visuals.append(plot_visual)

	campfire_root = Node2D.new()
	campfire_root.name = "Campfire"
	campfire_root.position = CAMPFIRE_POSITION
	campfire_root.z_index = 1
	add_child(campfire_root)

	var log_a := Sprite2D.new()
	log_a.texture = load("res://assets/Tiny Swords (Free Pack)/Terrain/Resources/Wood/Wood Resource/Wood Resource.png")
	log_a.position = Vector2(-7, 0)
	log_a.rotation = -0.18
	log_a.scale = Vector2(0.42, 0.42)
	campfire_root.add_child(log_a)

	var log_b := Sprite2D.new()
	log_b.texture = log_a.texture
	log_b.position = Vector2(7, 0)
	log_b.rotation = 0.18
	log_b.scale = Vector2(0.42, 0.42)
	campfire_root.add_child(log_b)

	fire_sprite = Sprite2D.new()
	fire_sprite.name = "Flame"
	fire_sprite.texture = load("res://assets/Tiny Swords (Free Pack)/Particle FX/Fire_01.png")
	fire_sprite.hframes = 8
	fire_sprite.frame = 0
	fire_sprite.position = Vector2(0, -23)
	fire_sprite.scale = Vector2(0.65, 0.65)
	campfire_root.add_child(fire_sprite)


func _create_collision_world() -> void:
	var boundary := StaticBody2D.new()
	boundary.name = "MapBoundary"
	add_child(boundary)
	_add_wall(boundary, Vector2(0, -MAP_HALF_SIZE), Vector2(MAP_HALF_SIZE * 2.0, 12.0))
	_add_wall(boundary, Vector2(0, MAP_HALF_SIZE), Vector2(MAP_HALF_SIZE * 2.0, 12.0))
	_add_wall(boundary, Vector2(-MAP_HALF_SIZE, 0), Vector2(12.0, MAP_HALF_SIZE * 2.0))
	_add_wall(boundary, Vector2(MAP_HALF_SIZE, 0), Vector2(12.0, MAP_HALF_SIZE * 2.0))
	# Only the small contact point under the logs blocks movement.
	_add_obstacle(boundary, WOOD_POSITION + Vector2(0, 9), Vector2(12.0, 4.0))
	# The campfire collision covers the logs, never the flame above them.
	_add_obstacle(boundary, CAMPFIRE_POSITION + Vector2(0, 9), Vector2(18.0, 4.0))


func _add_wall(parent: Node, position: Vector2, size: Vector2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	var collider := CollisionShape2D.new()
	collider.position = position
	collider.shape = shape
	parent.add_child(collider)


func _add_obstacle(parent: Node, position: Vector2, size: Vector2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	var collider := CollisionShape2D.new()
	collider.position = position
	collider.shape = shape
	parent.add_child(collider)


func _update_ui() -> void:
	if not resource_label:
		return
	resource_label.text = "木头 %d  草药 %d  金币 %d  肥料 %d\n篝火 Lv.%d  %s  当前: %s" % [state.wood, state.herb, state.gold, state.fertilizer, state.campfire_level, state.day_phase_name(), Plants.plant_name(selected_plant_id)]
	for index in range(min(plot_visuals.size(), State.PLOT_COUNT)):
		var plot_visual: M0PlotVisual = plot_visuals[index]
		plot_visual.set_stage(state.plot_stage(index), state.plot_plant_id(index), state.is_plot_fertilized(index))
	_update_encyclopedia()
	_update_kitchen()
	_update_compost()
	_update_merchant()
	_update_map()
	_update_log()


func _update_day_night_visuals() -> void:
	if not world_modulate:
		return
	world_modulate.color = Color("#b8c9f0") if state.is_night() else Color("#ffffff")


func _toggle_encyclopedia() -> void:
	if not encyclopedia_panel:
		return
	if kitchen_panel:
		kitchen_panel.visible = false
	if log_panel:
		log_panel.visible = false
	if compost_panel:
		compost_panel.visible = false
	if merchant_panel:
		merchant_panel.visible = false
	encyclopedia_panel.visible = not encyclopedia_panel.visible
	_update_encyclopedia()
	_set_message("已打开植物图鉴。" if encyclopedia_panel.visible else "已关闭植物图鉴。", 1.5)


func _toggle_kitchen() -> void:
	if not kitchen_panel:
		return
	if encyclopedia_panel:
		encyclopedia_panel.visible = false
	if log_panel:
		log_panel.visible = false
	if compost_panel:
		compost_panel.visible = false
	if merchant_panel:
		merchant_panel.visible = false
	kitchen_panel.visible = not kitchen_panel.visible
	_update_kitchen()
	_set_message("已打开厨房。" if kitchen_panel.visible else "已关闭厨房。", 1.5)


func _toggle_map() -> void:
	if not map_panel:
		return
	if encyclopedia_panel:
		encyclopedia_panel.visible = false
	if kitchen_panel:
		kitchen_panel.visible = false
	if log_panel:
		log_panel.visible = false
	if compost_panel:
		compost_panel.visible = false
	if merchant_panel:
		merchant_panel.visible = false
	map_panel.visible = not map_panel.visible
	_update_map()
	_set_message("已打开地图。" if map_panel.visible else "已关闭地图。", 1.5)


func _toggle_log() -> void:
	if not log_panel:
		return
	if encyclopedia_panel:
		encyclopedia_panel.visible = false
	if kitchen_panel:
		kitchen_panel.visible = false
	if map_panel:
		map_panel.visible = false
	if compost_panel:
		compost_panel.visible = false
	if merchant_panel:
		merchant_panel.visible = false
	log_panel.visible = not log_panel.visible
	_update_log()
	_set_message("已打开探索日志。" if log_panel.visible else "已关闭探索日志。", 1.5)


func _toggle_compost() -> void:
	if not compost_panel:
		return
	if encyclopedia_panel:
		encyclopedia_panel.visible = false
	if kitchen_panel:
		kitchen_panel.visible = false
	if map_panel:
		map_panel.visible = false
	if log_panel:
		log_panel.visible = false
	if merchant_panel:
		merchant_panel.visible = false
	compost_panel.visible = not compost_panel.visible
	_update_compost()
	_set_message("已打开堆肥桶。" if compost_panel.visible else "已关闭堆肥桶。", 1.5)


func _toggle_merchant() -> void:
	if not merchant_panel:
		return
	if encyclopedia_panel:
		encyclopedia_panel.visible = false
	if kitchen_panel:
		kitchen_panel.visible = false
	if map_panel:
		map_panel.visible = false
	if log_panel:
		log_panel.visible = false
	if compost_panel:
		compost_panel.visible = false
	merchant_panel.visible = not merchant_panel.visible
	_update_merchant()
	_set_message("已打开旅行商人。" if merchant_panel.visible else "已关闭旅行商人。", 1.5)


func _buy_merchant_item() -> void:
	if state.buy_merchant_item(selected_merchant_item_id):
		state.save()
		_set_message("购买成功：%s。" % _merchant_item_name(selected_merchant_item_id), 2.0)
	else:
		_set_message("购买失败：需要金币 x%d，且该商品库存不能为零。" % int(Merchant.get_definition(selected_merchant_item_id).get("price", 0)), 2.0)
	_update_ui()


func _merchant_item_name(item_id: String) -> String:
	return str(Merchant.get_definition(item_id).get("name", "未知商品"))


func _make_fertilizer() -> void:
	if state.make_fertilizer():
		state.save()
		_set_message("制作成功：肥料 x1。", 2.0)
	else:
		_set_message("材料不足：需要草药 x2、木头 x1。", 2.0)
	_update_ui()


func _explore_selected_province() -> void:
	var result: Dictionary = state.explore_province(selected_province_id, selected_scene_id)
	if bool(result.get("ok", false)):
		var reward_type: String = str(result.get("reward_type", "resource"))
		var reward_id: String = str(result.get("reward_id", "gold"))
		var reward_amount: int = int(result.get("reward_amount", 1))
		var reward_text: String = "%s x%d" % [Plants.plant_name(reward_id), reward_amount] if reward_type == "plant" else "%s x%d" % [Plants.resource_name(reward_id), reward_amount]
		map_result_text = "%s · %s\n获得：%s\n%s" % [str(result.get("province_name", "未知省份")), str(result.get("scene_name", "探索场景")), reward_text, str(result.get("log_text", ""))]
		_set_message("探索完成，获得%s。" % reward_text, 3.0)
		state.save()
	else:
		map_result_text = str(result.get("message", "探索失败。"))
		_set_message(map_result_text, 2.0)
	_update_ui()


func _update_log() -> void:
	if not log_label:
		return
	if state.exploration_history.is_empty():
		log_label.text = "探索日志\n\n还没有完成探索。\n打开地图并按 Enter 出发。\n\n按 L 关闭"
		return
	var lines: Array[String] = ["探索日志  最近 %d 条" % state.exploration_history.size(), ""]
	for history_index in range(state.exploration_history.size() - 1, -1, -1):
		var entry: Dictionary = state.exploration_history[history_index]
		var reward_type: String = str(entry.get("reward_type", "resource"))
		var reward_id: String = str(entry.get("reward_id", "gold"))
		var reward_amount: int = int(entry.get("reward_amount", 0))
		var reward_name: String = Plants.plant_name(reward_id) if reward_type == "plant" else Plants.resource_name(reward_id)
		var scene_title: String = str(entry.get("scene_name", entry.get("scene_type", "探索场景")))
		lines.append("%s · %s" % [str(entry.get("province_name", "未知省份")), scene_title])
		lines.append("获得：%s x%d" % [reward_name, reward_amount])
		lines.append(str(entry.get("log_text", "")))
		lines.append("")
	lines.append("按 L 关闭")
	log_label.text = "\n".join(lines)


func _update_map() -> void:
	if not map_label or not map_panel:
		return
	var selected_province_definition: Dictionary = Exploration.get_definition(selected_province_id)
	var definition: Dictionary = Exploration.get_scene_definition(selected_province_id, selected_scene_id)
	var province_ids: Array[String] = Exploration.all_ids()
	var province_lines: Array[String] = []
	for province_index in range(province_ids.size()):
		var province_id: String = province_ids[province_index]
		var province_definition: Dictionary = Exploration.get_definition(province_id)
		var marker: String = ">" if province_id == selected_province_id else " "
		var province_status: String = "" if Exploration.is_unlocked(province_id, state.exploration_count) else " [锁定]"
		province_lines.append("%s%d %s%s" % [marker, province_index + 1, str(province_definition.get("name", "未知")), province_status])
	var scene_lines: Array[String] = []
	var scenes: Array = Exploration.get_scenes(selected_province_id)
	for scene_index in range(scenes.size()):
		var scene: Dictionary = scenes[scene_index]
		var scene_marker: String = ">" if str(scene.get("scene_id", "")) == selected_scene_id else " "
		scene_lines.append("%s%d %s · %s" % [scene_marker, scene_index + 1, str(scene.get("scene_name", "探索场景")), str(scene.get("scene_type", "探索"))])
	var log_count: int = state.exploration_logs.size()
	var recovery_seconds: int = state.energy_recovery_seconds_remaining()
	var recovery_text: String = "已满" if recovery_seconds == 0 else "下点恢复 %02d:%02d" % [int(recovery_seconds / 60), recovery_seconds % 60]
	var selected_status: String = Exploration.unlock_text(selected_province_id) if Exploration.is_unlocked(selected_province_id, state.exploration_count) else Exploration.unlock_text(selected_province_id)
	var action_text: String = "按 Enter 出发" if Exploration.is_unlocked(selected_province_id, state.exploration_count) else selected_status
	map_label.text = "地图探索  精力 %d/%d（%s）\n\n%s\n\n当前：%s\n场景：%s\n%s\n%s\n记录：%d 条\n%s\n\nQ/E 切省份，Z/X 切场景，M 关闭" % [state.energy, State.MAX_ENERGY, recovery_text, "\n".join(province_lines), str(selected_province_definition.get("name", "未知省份")), str(definition.get("scene_name", "探索场景")), "\n".join(scene_lines), action_text, log_count, map_result_text]
	var preview_paths: Dictionary = {
		"sichuan": "res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color1.png",
		"guangdong": "res://assets/Tiny Swords/Tiny Swords (Update 010)/Terrain/Water/Water.png",
		"shandong": "res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color2.png",
		"jiangsu": "res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color1.png",
		"zhejiang": "res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color2.png",
		"fujian": "res://assets/Tiny Swords/Tiny Swords (Update 010)/Terrain/Water/Water.png",
		"henan": "res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color1.png",
		"hunan": "res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color2.png",
		"hubei": "res://assets/Tiny Swords/Tiny Swords (Update 010)/Terrain/Water/Water.png",
		"yunnan": "res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color2.png",
		"shaanxi": "res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color1.png",
		"anhui": "res://assets/Tiny Swords/Tiny Swords (Update 010)/Terrain/Water/Water.png",
	}
	map_preview.texture = load(str(preview_paths.get(selected_province_id, preview_paths["sichuan"])))


func _cook_selected_recipe() -> void:
	var recipe: Dictionary = Recipes.get_definition(selected_recipe_id)
	if state.cook_recipe(selected_recipe_id):
		state.save()
		_set_message("制作成功：%s，获得金币 x%d。" % [str(recipe.get("name", "菜肴")), int(recipe.get("gold_reward", 0))], 2.5)
	else:
		_set_message("材料不足：需要%s。" % _recipe_requirements_text(recipe), 2.5)
	_update_ui()


func _recipe_requirements_text(recipe: Dictionary) -> String:
	var requirements: Array[String] = []
	var ingredients: Dictionary = recipe.get("ingredients", {})
	var ingredient_ids: Array = ingredients.keys()
	for ingredient_index in range(ingredient_ids.size()):
		var ingredient_id: String = str(ingredient_ids[ingredient_index])
		requirements.append("%s x%d" % [Plants.plant_name(ingredient_id), int(ingredients[ingredient_id])])
	var wood_cost: int = int(recipe.get("wood_cost", 0))
	if wood_cost > 0:
		requirements.append("木头 x%d" % wood_cost)
	return "、".join(requirements)


func _update_kitchen() -> void:
	if not kitchen_label:
		return
	if not Recipes.is_valid_id(selected_recipe_id):
		selected_recipe_id = Recipes.all_ids()[0]
	var recipe: Dictionary = Recipes.get_definition(selected_recipe_id)
	var recipe_status: String = "可制作" if state.can_cook(selected_recipe_id) else "材料不足"
	var inventory_lines: Array[String] = []
	var plant_ids: Array[String] = Plants.all_ids()
	for plant_index in range(plant_ids.size()):
		var plant_id: String = plant_ids[plant_index]
		inventory_lines.append("%s x%d" % [Plants.plant_name(plant_id), state.plant_item_count(plant_id)])
	var inventory_text: String = "、".join(inventory_lines)
	var recipe_ids: Array[String] = Recipes.all_ids()
	var recipe_lines: Array[String] = []
	for recipe_index in range(recipe_ids.size()):
		var marker: String = ">" if recipe_ids[recipe_index] == selected_recipe_id else " "
		recipe_lines.append("%s%d %s" % [marker, recipe_index + 1, str(Recipes.get_definition(recipe_ids[recipe_index]).get("name", "菜肴"))])
	kitchen_label.text = "厨房\n\n%s\n\n%s\n材料：%s\n状态：%s\n食材库存：\n%s\n\n木头：%d  已制作：x%d\n按 1-%d 选择，Enter 制作\n按 K 关闭" % ["\n".join(recipe_lines), str(recipe.get("name", "菜肴")), _recipe_requirements_text(recipe), recipe_status, inventory_text, state.wood, state.dish_count(selected_recipe_id), recipe_ids.size()]


func _update_compost() -> void:
	if not compost_label:
		return
	var status: String = "可制作" if state.can_make_fertilizer() else "材料不足"
	compost_label.text = "堆肥桶\n\n肥料：%d\n配方：草药 x2 + 木头 x1\n状态：%s\n\n施肥番茄收获时变异为金色番茄。\n\n按 Enter 制作 1 份\n按 F 进入施肥模式\n按 B 关闭" % [state.fertilizer, status]


func _update_merchant() -> void:
	if not merchant_label:
		return
	state.refresh_merchant()
	if not Merchant.is_valid_id(selected_merchant_item_id):
		selected_merchant_item_id = Merchant.all_ids()[0]
	var item_lines: Array[String] = []
	for item_index in range(Merchant.all_ids().size()):
		var item_id: String = Merchant.all_ids()[item_index]
		var marker: String = ">" if item_id == selected_merchant_item_id else " "
		var item_definition: Dictionary = Merchant.get_definition(item_id)
		item_lines.append("%s%d %s  金币 x%d  库存 %d/%d" % [marker, item_index + 1, str(item_definition.get("name", "商品")), int(item_definition.get("price", 0)), int(state.merchant_stock.get(item_id, 0)), Merchant.INITIAL_STOCK])
	merchant_label.text = "旅行商人\n\n%s\n\n当前选择：%s\n按 1-%d 选择，Enter 购买\n每天自动补充库存\n\n按 T 关闭" % ["\n".join(item_lines), _merchant_item_name(selected_merchant_item_id), Merchant.all_ids().size()]


func _update_encyclopedia() -> void:
	if not encyclopedia_label:
		return
	var lines: Array[String] = ["植物图鉴  %d/%d" % [state.collected_plant_count(), Plants.all_ids().size()], "按 I 关闭\n"]
	var plant_ids: Array[String] = Plants.all_ids()
	for plant_index in range(plant_ids.size()):
		var plant_id: String = plant_ids[plant_index]
		var definition: Dictionary = Plants.get_definition(plant_id)
		if state.is_plant_collected(plant_id):
			var resource_id: String = str(definition.get("reward_resource", "wood"))
			var reward_amount: int = int(definition.get("reward_amount", 1))
			lines.append("[已发现] %s\n  收获: %s x%d" % [Plants.plant_name(plant_id), Plants.resource_name(resource_id), reward_amount])
		else:
			lines.append("[未发现] ???")
	encyclopedia_label.text = "\n".join(lines)


func _set_message(text: String, duration: float) -> void:
	message_text = text
	message_time = duration
	if message_label:
		message_label.text = text


func _exit_tree() -> void:
	if state:
		state.save()
