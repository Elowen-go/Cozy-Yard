class_name M0State
extends RefCounted

const SAVE_PATH := "user://anzhi_m0_save.json"
const Plants = preload("res://scripts/m1_plants.gd")
const Recipes = preload("res://scripts/m1_recipes.gd")
const Exploration = preload("res://scripts/m2_exploration.gd")
const Merchant = preload("res://scripts/m3_merchant.gd")
const CROP_DURATION := 20.0
const PLOT_COUNT := 3
const PLOT_PREPARE_COST := 1
const CAMPFIRE_UPGRADE_COST := 2
const FERTILIZER_HERB_COST := 2
const FERTILIZER_WOOD_COST := 1
const FERTILIZER_SPEED_MULTIPLIER := 1.5
const DAY_NIGHT_CYCLE_SECONDS := 120.0
const DAY_NIGHT_DAY_SECONDS := 60.0
const MAX_ENERGY := 5
const EXPLORATION_HISTORY_LIMIT := 10
# Temporary test interval. Restore to 1800 seconds before release.
const ENERGY_RECOVERY_INTERVAL := 10

var wood: int = 3
var herb: int = 0
var gold: int = 0
var fertilizer: int = 0
var merchant_stock: Dictionary = Merchant.default_stock()
var merchant_refresh_day: int = 0
var world_time_seconds: float = 0.0
var campfire_level: int = 1
var plots: Array = []
var collected_plants: Array[String] = []
var plant_inventory: Dictionary = {}
var unlocked_recipes: Array[String] = []
var dish_inventory: Dictionary = {}
var energy: int = MAX_ENERGY
var energy_recovery_timestamp: int = 0
var exploration_logs: Array[String] = []
var exploration_count: Dictionary = {}
var exploration_history: Array[Dictionary] = []


func _init() -> void:
	energy_recovery_timestamp = int(Time.get_unix_time_from_system())
	merchant_refresh_day = _current_day()
	_reset_plots()


func _current_day() -> int:
	return int(Time.get_unix_time_from_system() / 86400)


func refresh_merchant() -> bool:
	var current_day: int = _current_day()
	if merchant_refresh_day <= 0:
		merchant_refresh_day = current_day
		return false
	if current_day <= merchant_refresh_day:
		return false
	merchant_refresh_day = current_day
	merchant_stock = Merchant.default_stock()
	return true


func advance_world_time(delta: float) -> void:
	world_time_seconds = fmod(maxf(0.0, world_time_seconds + maxf(0.0, delta)), DAY_NIGHT_CYCLE_SECONDS)


func is_night() -> bool:
	return world_time_seconds >= DAY_NIGHT_DAY_SECONDS


func day_phase_name() -> String:
	return "夜晚" if is_night() else "白昼"


func refresh_energy() -> int:
	var now: int = int(Time.get_unix_time_from_system())
	if energy_recovery_timestamp <= 0:
		energy_recovery_timestamp = now
	if energy >= MAX_ENERGY:
		energy_recovery_timestamp = now
		return 0
	var elapsed: int = maxi(0, now - energy_recovery_timestamp)
	var recovered: int = floori(float(elapsed) / float(ENERGY_RECOVERY_INTERVAL))
	if recovered <= 0:
		return 0
	energy = mini(MAX_ENERGY, energy + recovered)
	energy_recovery_timestamp += recovered * ENERGY_RECOVERY_INTERVAL
	if energy >= MAX_ENERGY:
		energy_recovery_timestamp = now
	return recovered


func energy_recovery_seconds_remaining() -> int:
	refresh_energy()
	if energy >= MAX_ENERGY:
		return 0
	var now: int = int(Time.get_unix_time_from_system())
	var elapsed: int = maxi(0, now - energy_recovery_timestamp)
	return maxi(0, ENERGY_RECOVERY_INTERVAL - (elapsed % ENERGY_RECOVERY_INTERVAL))


func _reset_plots() -> void:
	plots.clear()
	for _index in range(PLOT_COUNT):
		plots.append(_empty_plot())


func _empty_plot() -> Dictionary:
	return {"stage": "idle", "plant_id": "wheat", "elapsed": 0.0, "harvests": 0, "fertilized": false}


func _ensure_plots() -> void:
	while plots.size() < PLOT_COUNT:
		plots.append(_empty_plot())
	if plots.size() > PLOT_COUNT:
		plots.resize(PLOT_COUNT)


func plot_stage(index: int) -> String:
	_ensure_plots()
	return str(plots[index].get("stage", "idle"))


func plot_elapsed(index: int) -> float:
	_ensure_plots()
	return float(plots[index].get("elapsed", 0.0))


func plot_plant_id(index: int) -> String:
	_ensure_plots()
	var plant_id: String = str(plots[index].get("plant_id", "wheat"))
	return plant_id if Plants.is_valid_id(plant_id) else "wheat"


func growth_speed() -> float:
	return 1.0 + float(campfire_level - 1) * 0.25


func prepare_plot(index: int) -> bool:
	_ensure_plots()
	if plot_stage(index) != "idle" or wood < PLOT_PREPARE_COST:
		return false
	wood -= PLOT_PREPARE_COST
	plots[index]["stage"] = "prepared"
	return true


func plant_crop(index: int, plant_id: String = "wheat") -> bool:
	_ensure_plots()
	if plot_stage(index) != "prepared":
		return false
	plots[index]["stage"] = "growing"
	plots[index]["plant_id"] = plant_id if Plants.is_plantable_id(plant_id) else "wheat"
	plots[index]["elapsed"] = 0.0
	plots[index]["fertilized"] = false
	return true


func advance_crop(index: int, delta: float) -> bool:
	_ensure_plots()
	if plot_stage(index) != "growing":
		return false
	var definition: Dictionary = Plants.get_definition(plot_plant_id(index))
	var duration: float = float(definition.get("duration", 20.0))
	var fertilizer_speed: float = FERTILIZER_SPEED_MULTIPLIER if bool(plots[index].get("fertilized", false)) else 1.0
	plots[index]["elapsed"] = plot_elapsed(index) + delta * growth_speed() * fertilizer_speed
	if plot_elapsed(index) >= duration:
		plots[index]["elapsed"] = duration
		plots[index]["stage"] = "mature"
		return true
	return false


func harvest_crop(index: int) -> bool:
	_ensure_plots()
	if plot_stage(index) != "mature":
		return false
	var plant_id: String = plot_plant_id(index)
	var harvest_result_id: String = Plants.harvest_result_id(plant_id, bool(plots[index].get("fertilized", false)))
	var definition: Dictionary = Plants.get_definition(harvest_result_id)
	var resource_id: String = str(definition.get("reward_resource", "wood"))
	var reward_amount: int = int(definition.get("reward_amount", 1))
	add_resource(resource_id, reward_amount)
	add_plant_item(harvest_result_id, 1)
	mark_plant_collected(harvest_result_id)
	plots[index]["harvests"] = int(plots[index].get("harvests", 0)) + 1
	plots[index]["stage"] = "idle"
	plots[index]["plant_id"] = "wheat"
	plots[index]["elapsed"] = 0.0
	plots[index]["fertilized"] = false
	return true


func fertilize_plot(index: int) -> bool:
	_ensure_plots()
	if index < 0 or index >= PLOT_COUNT or plot_stage(index) != "growing":
		return false
	if bool(plots[index].get("fertilized", false)) or fertilizer <= 0:
		return false
	fertilizer -= 1
	plots[index]["fertilized"] = true
	return true


func is_plot_fertilized(index: int) -> bool:
	_ensure_plots()
	if index < 0 or index >= PLOT_COUNT:
		return false
	return bool(plots[index].get("fertilized", false))


func can_make_fertilizer() -> bool:
	return herb >= FERTILIZER_HERB_COST and wood >= FERTILIZER_WOOD_COST


func make_fertilizer() -> bool:
	if not can_make_fertilizer():
		return false
	herb -= FERTILIZER_HERB_COST
	wood -= FERTILIZER_WOOD_COST
	fertilizer += 1
	return true


func buy_merchant_item(item_id: String) -> bool:
	refresh_merchant()
	if not Merchant.is_valid_id(item_id):
		return false
	var item_definition: Dictionary = Merchant.get_definition(item_id)
	var item_price: int = int(item_definition.get("price", 0))
	if int(merchant_stock.get(item_id, 0)) <= 0 or gold < item_price:
		return false
	gold -= item_price
	merchant_stock[item_id] = int(merchant_stock.get(item_id, 0)) - 1
	match item_id:
		"fertilizer":
			fertilizer += 1
		"wood_bundle":
			add_wood(3)
		"herb_bundle":
			add_resource("herb", 2)
	return true


func buy_merchant_fertilizer() -> bool:
	return buy_merchant_item("fertilizer")


func mark_plant_collected(plant_id: String) -> void:
	if Plants.is_valid_id(plant_id) and not collected_plants.has(plant_id):
		collected_plants.append(plant_id)


func is_plant_collected(plant_id: String) -> bool:
	return collected_plants.has(plant_id)


func collected_plant_count() -> int:
	return collected_plants.size()


func add_plant_item(plant_id: String, amount: int = 1) -> void:
	if not Plants.is_valid_id(plant_id):
		return
	var safe_amount: int = maxi(0, amount)
	plant_inventory[plant_id] = int(plant_inventory.get(plant_id, 0)) + safe_amount


func plant_item_count(plant_id: String) -> int:
	return maxi(0, int(plant_inventory.get(plant_id, 0)))


func is_recipe_unlocked(recipe_id: String) -> bool:
	return unlocked_recipes.has(recipe_id)


func dish_count(recipe_id: String) -> int:
	return maxi(0, int(dish_inventory.get(recipe_id, 0)))


func can_cook(recipe_id: String) -> bool:
	if not Recipes.is_valid_id(recipe_id):
		return false
	var definition: Dictionary = Recipes.get_definition(recipe_id)
	if wood < int(definition.get("wood_cost", 0)):
		return false
	var ingredients: Dictionary = definition.get("ingredients", {})
	var ingredient_ids: Array = ingredients.keys()
	for ingredient_index in range(ingredient_ids.size()):
		var ingredient_id: String = str(ingredient_ids[ingredient_index])
		if plant_item_count(str(ingredient_id)) < int(ingredients[ingredient_id]):
			return false
	return true


func cook_recipe(recipe_id: String) -> bool:
	if not can_cook(recipe_id):
		return false
	var definition: Dictionary = Recipes.get_definition(recipe_id)
	var ingredients: Dictionary = definition.get("ingredients", {})
	var ingredient_ids: Array = ingredients.keys()
	for ingredient_index in range(ingredient_ids.size()):
		var ingredient_id: String = str(ingredient_ids[ingredient_index])
		var safe_id: String = str(ingredient_id)
		plant_inventory[safe_id] = plant_item_count(safe_id) - int(ingredients[ingredient_id])
	wood -= int(definition.get("wood_cost", 0))
	gold += int(definition.get("gold_reward", 0))
	dish_inventory[recipe_id] = dish_count(recipe_id) + 1
	if not unlocked_recipes.has(recipe_id):
		unlocked_recipes.append(recipe_id)
	return true


func explore_province(province_id: String, scene_id: String = "") -> Dictionary:
	refresh_energy()
	if not Exploration.is_valid_id(province_id):
		return {"ok": false, "message": "未知省份。"}
	if not Exploration.is_unlocked(province_id, exploration_count):
		return {"ok": false, "message": "%s，暂时无法出发。" % Exploration.unlock_text(province_id)}
	if energy <= 0:
		return {"ok": false, "message": "精力不足，暂时无法出发。"}
	var definition: Dictionary = Exploration.get_scene_definition(province_id, scene_id)
	if definition.is_empty():
		return {"ok": false, "message": "未知探索场景。"}
	energy -= 1
	var reward_type: String = str(definition.get("reward_type", "resource"))
	var reward_id: String = str(definition.get("reward_id", "gold"))
	var reward_amount: int = int(definition.get("reward_amount", 1))
	if reward_type == "plant":
		add_plant_item(reward_id, reward_amount)
		mark_plant_collected(reward_id)
	else:
		add_resource(reward_id, reward_amount)
	var log_id: String = str(definition.get("log_id", ""))
	if Exploration.is_valid_log_id(log_id) and not exploration_logs.has(log_id):
		exploration_logs.append(log_id)
	exploration_count[province_id] = int(exploration_count.get(province_id, 0)) + 1
	exploration_history.append({
		"province_id": province_id,
		"scene_id": str(definition.get("scene_id", "")),
		"province_name": str(definition.get("name", "未知省份")),
		"scene_name": str(definition.get("scene_name", definition.get("scene_type", "探索场景"))),
		"scene_type": str(definition.get("scene_type", "探索场景")),
		"reward_type": reward_type,
		"reward_id": reward_id,
		"reward_amount": reward_amount,
		"log_text": str(definition.get("log_text", "")),
	})
	while exploration_history.size() > EXPLORATION_HISTORY_LIMIT:
		exploration_history.pop_front()
	return {
		"ok": true,
		"province_name": str(definition.get("name", "未知省份")),
		"scene_name": str(definition.get("scene_name", definition.get("scene_type", "探索场景"))),
		"scene_type": str(definition.get("scene_type", "探索场景")),
		"reward_type": reward_type,
		"reward_id": reward_id,
		"reward_amount": reward_amount,
		"log_text": str(definition.get("log_text", "")),
	}


func add_resource(resource_id: String, amount: int) -> void:
	var safe_amount: int = maxi(0, amount)
	match resource_id:
		"wood":
			wood += safe_amount
		"herb":
			herb += safe_amount
		"gold":
			gold += safe_amount


func upgrade_campfire() -> bool:
	if wood < CAMPFIRE_UPGRADE_COST:
		return false
	wood -= CAMPFIRE_UPGRADE_COST
	campfire_level += 1
	return true


func add_wood(amount: int = 1) -> void:
	wood += amount


func to_dict() -> Dictionary:
	_ensure_plots()
	return {
		"wood": wood,
		"herb": herb,
		"gold": gold,
		"fertilizer": fertilizer,
		"merchant_stock": merchant_stock.duplicate(true),
		"merchant_refresh_day": merchant_refresh_day,
		"world_time_seconds": world_time_seconds,
		"campfire_level": campfire_level,
		"collected_plants": collected_plants.duplicate(),
		"plant_inventory": plant_inventory.duplicate(true),
		"unlocked_recipes": unlocked_recipes.duplicate(),
		"dish_inventory": dish_inventory.duplicate(true),
		"energy": energy,
		"energy_recovery_timestamp": energy_recovery_timestamp,
		"exploration_logs": exploration_logs.duplicate(),
		"exploration_count": exploration_count.duplicate(true),
		"exploration_history": exploration_history.duplicate(true),
		"plots": plots.duplicate(true),
	}


func save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(to_dict()))
		file.close()


func load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return
	var data: Variant = json.get_data()
	file.close()
	if data is not Dictionary:
		return
	wood = maxi(0, int(data.get("wood", wood)))
	herb = maxi(0, int(data.get("herb", herb)))
	gold = maxi(0, int(data.get("gold", gold)))
	fertilizer = maxi(0, int(data.get("fertilizer", fertilizer)))
	merchant_stock = Merchant.default_stock()
	var saved_merchant_stock: Variant = data.get("merchant_stock", {})
	if saved_merchant_stock is Dictionary:
		for merchant_item_id in Merchant.all_ids():
			merchant_stock[merchant_item_id] = clampi(int(saved_merchant_stock.get(merchant_item_id, Merchant.INITIAL_STOCK)), 0, Merchant.INITIAL_STOCK)
	else:
		# M3 merchant v1 stored a single fertilizer stock integer.
		merchant_stock["fertilizer"] = clampi(int(saved_merchant_stock), 0, Merchant.INITIAL_STOCK)
	merchant_refresh_day = maxi(0, int(data.get("merchant_refresh_day", merchant_refresh_day)))
	refresh_merchant()
	world_time_seconds = fmod(maxf(0.0, float(data.get("world_time_seconds", world_time_seconds))), DAY_NIGHT_CYCLE_SECONDS)
	campfire_level = maxi(1, int(data.get("campfire_level", campfire_level)))
	collected_plants.clear()
	plant_inventory.clear()
	unlocked_recipes.clear()
	dish_inventory.clear()
	energy = MAX_ENERGY
	energy_recovery_timestamp = int(Time.get_unix_time_from_system())
	exploration_logs.clear()
	exploration_count.clear()
	exploration_history.clear()
	var saved_collected: Variant = data.get("collected_plants", [])
	if saved_collected is Array:
		for collected_index in range(saved_collected.size()):
			var saved_plant: Variant = saved_collected[collected_index]
			var saved_plant_id: String = str(saved_plant)
			mark_plant_collected(saved_plant_id)
	var saved_inventory: Variant = data.get("plant_inventory", {})
	if saved_inventory is Dictionary:
		var saved_keys: Array = saved_inventory.keys()
		for saved_key_index in range(saved_keys.size()):
			var saved_key: String = str(saved_keys[saved_key_index])
			var saved_inventory_id: String = str(saved_key)
			if Plants.is_valid_id(saved_inventory_id):
				plant_inventory[saved_inventory_id] = maxi(0, int(saved_inventory[saved_key]))
	var saved_recipes: Variant = data.get("unlocked_recipes", [])
	if saved_recipes is Array:
		for recipe_index in range(saved_recipes.size()):
			var saved_recipe_id: String = str(saved_recipes[recipe_index])
			if Recipes.is_valid_id(saved_recipe_id) and not unlocked_recipes.has(saved_recipe_id):
				unlocked_recipes.append(saved_recipe_id)
	var saved_dishes: Variant = data.get("dish_inventory", {})
	if saved_dishes is Dictionary:
		var saved_dish_keys: Array = saved_dishes.keys()
		for saved_dish_index in range(saved_dish_keys.size()):
			var saved_dish_id: String = str(saved_dish_keys[saved_dish_index])
			if Recipes.is_valid_id(saved_dish_id):
				dish_inventory[saved_dish_id] = maxi(0, int(saved_dishes[saved_dish_id]))
	energy = clampi(int(data.get("energy", MAX_ENERGY)), 0, MAX_ENERGY)
	energy_recovery_timestamp = int(data.get("energy_recovery_timestamp", int(Time.get_unix_time_from_system())))
	refresh_energy()
	var saved_logs: Variant = data.get("exploration_logs", [])
	if saved_logs is Array:
		for log_index in range(saved_logs.size()):
			var saved_log_id: String = str(saved_logs[log_index])
			if Exploration.is_valid_log_id(saved_log_id) and not exploration_logs.has(saved_log_id):
				exploration_logs.append(saved_log_id)
	var saved_counts: Variant = data.get("exploration_count", {})
	if saved_counts is Dictionary:
		var saved_count_keys: Array = saved_counts.keys()
		for saved_count_index in range(saved_count_keys.size()):
			var saved_province_id: String = str(saved_count_keys[saved_count_index])
			if Exploration.is_valid_id(saved_province_id):
				exploration_count[saved_province_id] = maxi(0, int(saved_counts[saved_province_id]))
	var saved_history: Variant = data.get("exploration_history", [])
	if saved_history is Array:
		for history_index in range(saved_history.size()):
			var saved_entry: Variant = saved_history[history_index]
			if not (saved_entry is Dictionary):
				continue
			var saved_province_id: String = str(saved_entry.get("province_id", ""))
			if not Exploration.is_valid_id(saved_province_id):
				continue
			exploration_history.append({
				"province_id": saved_province_id,
				"scene_id": str(saved_entry.get("scene_id", "")),
				"province_name": str(saved_entry.get("province_name", "未知省份")),
				"scene_name": str(saved_entry.get("scene_name", saved_entry.get("scene_type", "探索场景"))),
				"scene_type": str(saved_entry.get("scene_type", "探索场景")),
				"reward_type": str(saved_entry.get("reward_type", "resource")),
				"reward_id": str(saved_entry.get("reward_id", "gold")),
				"reward_amount": maxi(0, int(saved_entry.get("reward_amount", 0))),
				"log_text": str(saved_entry.get("log_text", "")),
			})
		while exploration_history.size() > EXPLORATION_HISTORY_LIMIT:
			exploration_history.pop_front()
	_reset_plots()
	var saved_plots: Variant = data.get("plots", null)
	if saved_plots is Array:
		for index in range(min(saved_plots.size(), PLOT_COUNT)):
			var saved_plot: Variant = saved_plots[index]
			if saved_plot is Dictionary:
				var stage: String = str(saved_plot.get("stage", "idle"))
				if stage not in ["idle", "prepared", "growing", "mature"]:
					stage = "idle"
				var saved_plant_id: String = str(saved_plot.get("plant_id", "wheat"))
				if not Plants.is_valid_id(saved_plant_id):
					saved_plant_id = "wheat"
				var definition: Dictionary = Plants.get_definition(saved_plant_id)
				var duration: float = float(definition.get("duration", 20.0))
				plots[index] = {
					"stage": stage,
					"plant_id": saved_plant_id,
					"elapsed": clampf(float(saved_plot.get("elapsed", 0.0)), 0.0, duration),
					"harvests": maxi(0, int(saved_plot.get("harvests", 0))),
					"fertilized": bool(saved_plot.get("fertilized", false)),
				}
	else:
		# Migrate the original M0 single-plot save into the first plot.
		var old_stage: String = str(data.get("crop_stage", "idle"))
		if old_stage not in ["idle", "prepared", "growing", "mature"]:
			old_stage = "idle"
		plots[0] = {
			"stage": old_stage,
			"plant_id": "wheat",
			"elapsed": clampf(float(data.get("crop_elapsed", 0.0)), 0.0, 20.0),
			"harvests": maxi(0, int(data.get("crop_harvests", 0))),
			"fertilized": false,
		}
