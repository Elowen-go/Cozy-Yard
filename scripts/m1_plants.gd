class_name M1Plants
extends RefCounted

const PLANT_IDS: Array[String] = ["wheat", "herb", "carrot", "radish", "tomato", "cabbage", "corn", "cucumber", "golden_tomato"]
const SELECTABLE_PLANT_IDS: Array[String] = ["wheat", "herb", "carrot", "radish", "tomato", "cabbage", "corn", "cucumber"]
const RESOURCE_IDS: Array[String] = ["wood", "herb", "gold"]
const DEFINITIONS: Dictionary = {
	"wheat": {
		"name": "小麦",
		"duration": 20.0,
		"reward_resource": "wood",
		"reward_amount": 1,
		"accent": Color("#e5c64d"),
	},
	"herb": {
		"name": "草药",
		"duration": 16.0,
		"reward_resource": "herb",
		"reward_amount": 2,
		"accent": Color("#78bd65"),
	},
	"carrot": {
		"name": "胡萝卜",
		"duration": 24.0,
		"reward_resource": "gold",
		"reward_amount": 2,
		"accent": Color("#e7863d"),
	},
	"radish": {
		"name": "萝卜",
		"duration": 18.0,
		"reward_resource": "gold",
		"reward_amount": 1,
		"accent": Color("#d96b72"),
	},
	"tomato": {
		"name": "番茄",
		"duration": 28.0,
		"reward_resource": "gold",
		"reward_amount": 3,
		"accent": Color("#df6251"),
	},
	"golden_tomato": {
		"name": "金色番茄",
		"duration": 28.0,
		"reward_resource": "gold",
		"reward_amount": 8,
		"accent": Color("#f2c94c"),
	},
	"cabbage": {
		"name": "白菜",
		"duration": 22.0,
		"reward_resource": "herb",
		"reward_amount": 2,
		"accent": Color("#9bcf78"),
	},
	"corn": {
		"name": "玉米",
		"duration": 26.0,
		"reward_resource": "wood",
		"reward_amount": 2,
		"accent": Color("#e7c84d"),
	},
	"cucumber": {
		"name": "黄瓜",
		"duration": 18.0,
		"reward_resource": "gold",
		"reward_amount": 2,
		"accent": Color("#72b85f"),
	},
}


static func all_ids() -> Array[String]:
	return PLANT_IDS.duplicate()


static func selectable_ids() -> Array[String]:
	return SELECTABLE_PLANT_IDS.duplicate()


static func is_valid_id(plant_id: String) -> bool:
	return PLANT_IDS.has(plant_id)


static func is_plantable_id(plant_id: String) -> bool:
	return SELECTABLE_PLANT_IDS.has(plant_id)


static func harvest_result_id(plant_id: String, fertilized: bool) -> String:
	if plant_id == "tomato" and fertilized:
		return "golden_tomato"
	return plant_id if is_valid_id(plant_id) else "wheat"


static func get_definition(plant_id: String) -> Dictionary:
	var safe_id: String = plant_id if is_valid_id(plant_id) else "wheat"
	return DEFINITIONS[safe_id]


static func stage_name(stage: String) -> String:
	match stage:
		"idle":
			return "空地"
		"prepared":
			return "已开垦"
		"growing":
			return "生长中"
		"mature":
			return "可收获"
	return "空地"


static func plant_name(plant_id: String) -> String:
	return str(get_definition(plant_id).get("name", "小麦"))


static func resource_name(resource_id: String) -> String:
	match resource_id:
		"wood":
			return "木头"
		"herb":
			return "草药"
		"gold":
			return "金币"
	return "未知资源"
