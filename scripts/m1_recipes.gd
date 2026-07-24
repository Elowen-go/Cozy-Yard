class_name M1Recipes
extends RefCounted

const RECIPE_IDS: Array[String] = ["radish_soup", "tomato_stew", "cabbage_soup", "corn_cake"]
const DEFINITIONS: Dictionary = {
	"radish_soup": {
		"name": "萝卜汤",
		"ingredients": {"radish": 2},
		"wood_cost": 1,
		"gold_reward": 5,
	},
	"tomato_stew": {
		"name": "番茄炖菜",
		"ingredients": {"tomato": 2, "herb": 1},
		"wood_cost": 1,
		"gold_reward": 10,
	},
	"cabbage_soup": {
		"name": "白菜汤",
		"ingredients": {"cabbage": 2, "herb": 1},
		"wood_cost": 1,
		"gold_reward": 8,
	},
	"corn_cake": {
		"name": "玉米饼",
		"ingredients": {"corn": 2, "tomato": 1},
		"wood_cost": 1,
		"gold_reward": 12,
	},
}


static func all_ids() -> Array[String]:
	return RECIPE_IDS.duplicate()


static func is_valid_id(recipe_id: String) -> bool:
	return RECIPE_IDS.has(recipe_id)


static func get_definition(recipe_id: String) -> Dictionary:
	var safe_id: String = recipe_id if is_valid_id(recipe_id) else "radish_soup"
	return DEFINITIONS[safe_id]
