class_name M3Merchant
extends RefCounted

const ITEM_IDS: Array[String] = ["fertilizer", "wood_bundle", "herb_bundle"]
const INITIAL_STOCK := 3
const DEFINITIONS: Dictionary = {
	"fertilizer": {"name": "肥料 x1", "price": 5},
	"wood_bundle": {"name": "木头 x3", "price": 5},
	"herb_bundle": {"name": "草药 x2", "price": 5},
}


static func all_ids() -> Array[String]:
	return ITEM_IDS.duplicate()


static func is_valid_id(item_id: String) -> bool:
	return ITEM_IDS.has(item_id)


static func get_definition(item_id: String) -> Dictionary:
	var safe_id: String = item_id if is_valid_id(item_id) else ITEM_IDS[0]
	return DEFINITIONS[safe_id]


static func default_stock() -> Dictionary:
	return {
		"fertilizer": INITIAL_STOCK,
		"wood_bundle": INITIAL_STOCK,
		"herb_bundle": INITIAL_STOCK,
	}
