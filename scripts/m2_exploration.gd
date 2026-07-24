class_name M2Exploration
extends RefCounted

const PROVINCE_IDS: Array[String] = ["sichuan", "guangdong", "shandong", "jiangsu", "zhejiang", "fujian", "henan", "hunan", "hubei", "yunnan", "shaanxi", "anhui"]
const LOG_IDS: Array[String] = ["sichuan_forest", "sichuan_tea_hill", "sichuan_river", "guangdong_market", "guangdong_orchard", "guangdong_coast", "shandong_farmland", "shandong_village", "shandong_coast", "jiangsu_water_town", "jiangsu_rice_field", "jiangsu_garden", "zhejiang_tea_garden", "zhejiang_lake", "zhejiang_bamboo", "fujian_bamboo_forest", "fujian_coast", "fujian_tea_mountain", "henan_plain", "henan_wheat_field", "henan_village", "hunan_rice_field", "hunan_lake", "hunan_hills", "hubei_lotus_lake", "hubei_river", "hubei_farmland", "yunnan_mountain", "yunnan_terrace", "yunnan_tea_garden", "shaanxi_plateau", "shaanxi_orchard", "shaanxi_village", "anhui_tea_village", "anhui_huangshan", "anhui_river"]
const SCENE_DEFINITIONS: Dictionary = {
	"sichuan": [
		{"scene_id": "sichuan_forest", "scene_name": "竹影山林", "scene_type": "山林", "log_text": "山风穿过竹影，潮湿的土壤里露出一片新鲜的萝卜叶。", "reward_type": "plant", "reward_id": "radish", "reward_amount": 1},
		{"scene_id": "sichuan_tea_hill", "scene_name": "云雾茶坡", "scene_type": "茶园", "log_text": "云雾贴着茶坡缓缓流动，嫩芽在晨光里泛着清亮的绿。", "reward_type": "resource", "reward_id": "herb", "reward_amount": 2},
		{"scene_id": "sichuan_river", "scene_name": "溪边石滩", "scene_type": "溪谷", "log_text": "溪水绕过圆润的石头，岸边的野草间藏着几颗饱满的种子。", "reward_type": "resource", "reward_id": "wood", "reward_amount": 2},
	],
	"guangdong": [
		{"scene_id": "guangdong_market", "scene_name": "岭南市集", "scene_type": "市集", "log_text": "午后的市集飘来草药和热茶的香气，摊主递来一小包香草。", "reward_type": "resource", "reward_id": "herb", "reward_amount": 2},
		{"scene_id": "guangdong_orchard", "scene_name": "荔枝果园", "scene_type": "果园", "log_text": "果树的枝叶压得很低，红亮的果实在叶影间露出甜甜的颜色。", "reward_type": "resource", "reward_id": "gold", "reward_amount": 3},
		{"scene_id": "guangdong_coast", "scene_name": "潮汐海岸", "scene_type": "海岸", "log_text": "潮水退去后留下细碎贝壳，海风把远处渔船的歌声送到岸边。", "reward_type": "resource", "reward_id": "wood", "reward_amount": 2},
	],
	"shandong": [
		{"scene_id": "shandong_farmland", "scene_name": "金色农田", "scene_type": "农田", "log_text": "田埂被阳光晒得温暖，远处的麦浪沿着风一层层起伏。", "reward_type": "resource", "reward_id": "gold", "reward_amount": 3},
		{"scene_id": "shandong_village", "scene_name": "齐鲁村落", "scene_type": "村落", "log_text": "村口的大葱晾在竹架上，炊烟从屋檐后升起，带来家的味道。", "reward_type": "plant", "reward_id": "wheat", "reward_amount": 2},
		{"scene_id": "shandong_coast", "scene_name": "黄海滩涂", "scene_type": "海岸", "log_text": "海鸟掠过潮间带，湿润的滩涂里闪着一线银色的光。", "reward_type": "resource", "reward_id": "gold", "reward_amount": 4},
	],
	"jiangsu": [
		{"scene_id": "jiangsu_water_town", "scene_name": "烟雨水乡", "scene_type": "水乡", "log_text": "水巷的船桨轻轻划过桥影，米香从临河的小屋里飘了出来。", "reward_type": "plant", "reward_id": "wheat", "reward_amount": 2},
		{"scene_id": "jiangsu_rice_field", "scene_name": "江南稻田", "scene_type": "农田", "log_text": "稻田在风里泛起波纹，田鼠从稻梗间探出头又很快躲了回去。", "reward_type": "resource", "reward_id": "gold", "reward_amount": 3},
		{"scene_id": "jiangsu_garden", "scene_name": "园林花窗", "scene_type": "园林", "log_text": "花窗框住一角青石小径，墙边的香草在雨后散发出清新的气息。", "reward_type": "resource", "reward_id": "herb", "reward_amount": 3},
	],
	"zhejiang": [
		{"scene_id": "zhejiang_tea_garden", "scene_name": "龙井茶园", "scene_type": "茶园", "log_text": "山雾落在茶垄之间，采茶人指给你看一株带着清香的嫩芽。", "reward_type": "resource", "reward_id": "herb", "reward_amount": 3},
		{"scene_id": "zhejiang_lake", "scene_name": "西湖荷塘", "scene_type": "湖畔", "log_text": "湖面映着淡淡天光，荷叶下的水声和远处的橹声交织在一起。", "reward_type": "resource", "reward_id": "gold", "reward_amount": 4},
		{"scene_id": "zhejiang_bamboo", "scene_name": "安吉竹海", "scene_type": "竹林", "log_text": "竹海随着山风起伏，竹叶间落下一枚带着露水的嫩笋。", "reward_type": "resource", "reward_id": "wood", "reward_amount": 3},
	],
	"fujian": [
		{"scene_id": "fujian_bamboo_forest", "scene_name": "武夷竹林", "scene_type": "竹林", "log_text": "竹影沿着山路铺开，林间的风把远处海潮声送到了耳边。", "reward_type": "resource", "reward_id": "gold", "reward_amount": 5},
		{"scene_id": "fujian_coast", "scene_name": "闽南海湾", "scene_type": "海岸", "log_text": "海湾被午后的光照亮，渔网边的木箱里放着刚晒好的香料。", "reward_type": "resource", "reward_id": "herb", "reward_amount": 4},
		{"scene_id": "fujian_tea_mountain", "scene_name": "高山茶场", "scene_type": "茶园", "log_text": "茶场沿着山势层层铺开，山泉旁长着一簇清香的野草。", "reward_type": "plant", "reward_id": "radish", "reward_amount": 2},
	],
	"henan": [
		{"scene_id": "henan_plain", "scene_name": "中原平原", "scene_type": "麦田", "log_text": "平原上的麦穗在风里低下头，农人把一束饱满的种子交给了你。", "reward_type": "resource", "reward_id": "wood", "reward_amount": 4},
		{"scene_id": "henan_wheat_field", "scene_name": "丰收麦田", "scene_type": "农田", "log_text": "金色麦田一直铺到地平线，晒谷场上堆着刚收下的粮食。", "reward_type": "plant", "reward_id": "wheat", "reward_amount": 3},
		{"scene_id": "henan_village", "scene_name": "古村炊烟", "scene_type": "村落", "log_text": "老屋门前的石榴树结满果实，灶台上的热气慢慢散进院子。", "reward_type": "resource", "reward_id": "gold", "reward_amount": 5},
	],
	"hunan": [
		{"scene_id": "hunan_rice_field", "scene_name": "湘水稻田", "scene_type": "稻田", "log_text": "水田映着晚霞，田埂边的香草带着雨后的清甜气息。", "reward_type": "resource", "reward_id": "herb", "reward_amount": 4},
		{"scene_id": "hunan_lake", "scene_name": "洞庭湖畔", "scene_type": "湖畔", "log_text": "湖风吹动芦苇，岸边的小船带回一篮新鲜的水生植物。", "reward_type": "resource", "reward_id": "gold", "reward_amount": 5},
		{"scene_id": "hunan_hills", "scene_name": "湘西山路", "scene_type": "山林", "log_text": "山路拐过一片青石坡，山野蔬菜在阳光下显出鲜明的绿色。", "reward_type": "plant", "reward_id": "cabbage", "reward_amount": 2},
	],
	"hubei": [
		{"scene_id": "hubei_lotus_lake", "scene_name": "江城荷塘", "scene_type": "荷塘", "log_text": "湖面荷叶摇曳，岸边的集市传来热闹的叫卖声和饭香。", "reward_type": "resource", "reward_id": "gold", "reward_amount": 6},
		{"scene_id": "hubei_river", "scene_name": "长江渡口", "scene_type": "江岸", "log_text": "渡船靠上岸边，船夫从竹筐里分出几枚带着水汽的莲藕。", "reward_type": "resource", "reward_id": "herb", "reward_amount": 5},
		{"scene_id": "hubei_farmland", "scene_name": "江汉平畴", "scene_type": "农田", "log_text": "平畴一望无际，稻穗低垂在风里，露水沿着叶尖落下。", "reward_type": "plant", "reward_id": "wheat", "reward_amount": 3},
	],
	"yunnan": [
		{"scene_id": "yunnan_mountain", "scene_name": "高原山野", "scene_type": "山林", "log_text": "山风掠过梯田边的野花，远处云雾散开，露出一片带着清香的菌菇地。", "reward_type": "resource", "reward_id": "herb", "reward_amount": 5},
		{"scene_id": "yunnan_terrace", "scene_name": "云岭梯田", "scene_type": "梯田", "log_text": "梯田顺着山势一层层落下，水面映出远方慢慢移动的云影。", "reward_type": "resource", "reward_id": "gold", "reward_amount": 6},
		{"scene_id": "yunnan_tea_garden", "scene_name": "古树茶园", "scene_type": "茶园", "log_text": "古茶树的枝干盘过石坡，采茶人把一把新叶放在你的手心。", "reward_type": "plant", "reward_id": "cabbage", "reward_amount": 2},
	],
	"shaanxi": [
		{"scene_id": "shaanxi_plateau", "scene_name": "黄土高原", "scene_type": "高原", "log_text": "黄土坡上的风吹过枣树，农人把一篮新鲜果实放在窑洞门前。", "reward_type": "resource", "reward_id": "gold", "reward_amount": 7},
		{"scene_id": "shaanxi_orchard", "scene_name": "关中果园", "scene_type": "果园", "log_text": "果园沿着坡地铺开，枝头的苹果在秋光里沉甸甸地垂着。", "reward_type": "plant", "reward_id": "radish", "reward_amount": 3},
		{"scene_id": "shaanxi_village", "scene_name": "秦地村庄", "scene_type": "村落", "log_text": "窑洞前的石桌晒着粮食，村人把一捆干柴放到了院墙边。", "reward_type": "resource", "reward_id": "wood", "reward_amount": 6},
	],
	"anhui": [
		{"scene_id": "anhui_tea_village", "scene_name": "徽州茶村", "scene_type": "茶村", "log_text": "薄雾停在茶山之间，村口的竹篮里装着刚摘下来的嫩茶叶。", "reward_type": "resource", "reward_id": "herb", "reward_amount": 6},
		{"scene_id": "anhui_huangshan", "scene_name": "黄山云海", "scene_type": "山林", "log_text": "云海从石松脚下漫过，山泉旁的野菜沾着细小的水珠。", "reward_type": "plant", "reward_id": "cucumber", "reward_amount": 2},
		{"scene_id": "anhui_river", "scene_name": "新安江畔", "scene_type": "江岸", "log_text": "新安江绕过白墙黛瓦，江边的菜畦里长着一排整齐的嫩苗。", "reward_type": "resource", "reward_id": "gold", "reward_amount": 8},
	],
}
const DEFINITIONS: Dictionary = {
	"sichuan": {
		"name": "四川",
		"scene_type": "山林",
		"unlock_count": 0,
		"log_id": "sichuan_forest",
		"log_text": "山风穿过竹影，潮湿的土壤里露出一片新鲜的萝卜叶。",
		"reward_type": "plant",
		"reward_id": "radish",
		"reward_amount": 1,
	},
	"guangdong": {
		"name": "广东",
		"scene_type": "市集",
		"unlock_count": 2,
		"log_id": "guangdong_market",
		"log_text": "午后的市集飘来草药和热茶的香气，摊主递来一小包香草。",
		"reward_type": "resource",
		"reward_id": "herb",
		"reward_amount": 2,
	},
	"shandong": {
		"name": "山东",
		"scene_type": "农田",
		"unlock_count": 4,
		"log_id": "shandong_farmland",
		"log_text": "田埂被阳光晒得温暖，远处的麦浪沿着风一层层起伏。",
		"reward_type": "resource",
		"reward_id": "gold",
		"reward_amount": 3,
	},
	"jiangsu": {
		"name": "江苏",
		"scene_type": "水乡",
		"unlock_count": 6,
		"log_id": "jiangsu_water_town",
		"log_text": "水巷的船桨轻轻划过桥影，米香从临河的小屋里飘了出来。",
		"reward_type": "plant",
		"reward_id": "wheat",
		"reward_amount": 2,
	},
	"zhejiang": {
		"name": "浙江",
		"scene_type": "茶园",
		"unlock_count": 8,
		"log_id": "zhejiang_tea_garden",
		"log_text": "山雾落在茶垄之间，采茶人指给你看一株带着清香的嫩芽。",
		"reward_type": "resource",
		"reward_id": "herb",
		"reward_amount": 3,
	},
	"fujian": {
		"name": "福建",
		"scene_type": "竹林",
		"unlock_count": 10,
		"log_id": "fujian_bamboo_forest",
		"log_text": "竹影沿着山路铺开，林间的风把远处海潮声送到了耳边。",
		"reward_type": "resource",
		"reward_id": "gold",
		"reward_amount": 5,
	},
	"henan": {
		"name": "河南",
		"scene_type": "麦田",
		"unlock_count": 12,
		"log_id": "henan_plain",
		"log_text": "平原上的麦穗在风里低下头，农人把一束饱满的种子交给了你。",
		"reward_type": "resource",
		"reward_id": "wood",
		"reward_amount": 4,
	},
	"hunan": {
		"name": "湖南",
		"scene_type": "稻田",
		"unlock_count": 14,
		"log_id": "hunan_rice_field",
		"log_text": "水田映着晚霞，田埂边的香草带着雨后的清甜气息。",
		"reward_type": "resource",
		"reward_id": "herb",
		"reward_amount": 4,
	},
	"hubei": {
		"name": "湖北",
		"scene_type": "荷塘",
		"unlock_count": 16,
		"log_id": "hubei_lotus_lake",
		"log_text": "湖面荷叶摇曳，岸边的集市传来热闹的叫卖声和饭香。",
		"reward_type": "resource",
		"reward_id": "gold",
		"reward_amount": 6,
	},
	"yunnan": {
		"name": "云南",
		"scene_type": "高原山野",
		"unlock_count": 18,
		"log_id": "yunnan_mountain",
		"log_text": "山风掠过梯田边的野花，远处云雾散开，露出一片带着清香的菌菇地。",
		"reward_type": "resource",
		"reward_id": "herb",
		"reward_amount": 5,
	},
	"shaanxi": {
		"name": "陕西",
		"scene_type": "黄土高原",
		"unlock_count": 20,
		"log_id": "shaanxi_plateau",
		"log_text": "黄土坡上的风吹过枣树，农人把一篮新鲜果实放在窑洞门前。",
		"reward_type": "resource",
		"reward_id": "gold",
		"reward_amount": 7,
	},
	"anhui": {
		"name": "安徽",
		"scene_type": "茶村",
		"unlock_count": 22,
		"log_id": "anhui_tea_village",
		"log_text": "薄雾停在茶山之间，村口的竹篮里装着刚摘下来的嫩茶叶。",
		"reward_type": "resource",
		"reward_id": "herb",
		"reward_amount": 6,
	},
}


static func all_ids() -> Array[String]:
	return PROVINCE_IDS.duplicate()


static func is_valid_id(province_id: String) -> bool:
	return PROVINCE_IDS.has(province_id)


static func is_valid_log_id(log_id: String) -> bool:
	return LOG_IDS.has(log_id)


static func get_definition(province_id: String) -> Dictionary:
	var safe_id: String = province_id if is_valid_id(province_id) else "sichuan"
	return DEFINITIONS[safe_id]


static func get_scenes(province_id: String) -> Array:
	var safe_id: String = province_id if is_valid_id(province_id) else "sichuan"
	var raw_scenes: Variant = SCENE_DEFINITIONS.get(safe_id, [])
	if raw_scenes is Array:
		return raw_scenes.duplicate(true)
	return []


static func scene_count(province_id: String) -> int:
	return get_scenes(province_id).size()


static func get_scene_definition(province_id: String, scene_id: String = "") -> Dictionary:
	var safe_id: String = province_id if is_valid_id(province_id) else "sichuan"
	var scenes: Array = get_scenes(safe_id)
	for raw_scene in scenes:
		if raw_scene is Dictionary:
			var scene: Dictionary = raw_scene
			if scene_id.is_empty() or str(scene.get("scene_id", "")) == scene_id:
				scene["province_id"] = safe_id
				scene["name"] = str(DEFINITIONS[safe_id].get("name", "未知省份"))
				scene["province_name"] = str(DEFINITIONS[safe_id].get("name", "未知省份"))
				return scene
	return {}


static func unlock_requirement(province_id: String) -> int:
	var definition: Dictionary = get_definition(province_id)
	return maxi(0, int(definition.get("unlock_count", 0)))


static func is_unlocked(province_id: String, exploration_count: Dictionary) -> bool:
	if not is_valid_id(province_id):
		return false
	var total_explorations: int = 0
	for known_province_id in PROVINCE_IDS:
		total_explorations += maxi(0, int(exploration_count.get(known_province_id, 0)))
	return total_explorations >= unlock_requirement(province_id)


static func unlock_text(province_id: String) -> String:
	var requirement: int = unlock_requirement(province_id)
	if requirement <= 0:
		return "已解锁"
	return "完成 %d 次探索后解锁" % requirement
