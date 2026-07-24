class_name M0PlotVisual
extends Node2D

var stage := "idle"
var plant_id := "wheat"
var fertilized := false


func set_stage(value: String, value_plant_id: String = "wheat", value_fertilized: bool = false) -> void:
	stage = value
	plant_id = value_plant_id
	fertilized = value_fertilized
	queue_redraw()


func _draw() -> void:
	var color := Color("#8d603b")
	match stage:
		"prepared": color = Color("#a16c43")
		"growing": color = Color("#93613a")
		"mature": color = Color("#95643b")

	# Flat soil patch with a grass-colored edge, not a raised wooden box.
	draw_rect(Rect2(-32, -22, 64, 44), Color("#547b43"))
	draw_rect(Rect2(-29, -19, 58, 38), color)
	draw_rect(Rect2(-29, -19, 58, 38), Color("#c18a51"), false, 1.5)

	# Three shallow furrows with small highlights that match the pixel terrain.
	for y in [-10, 0, 10]:
		draw_line(Vector2(-25, y), Vector2(25, y), Color("#5e402b"), 2.0)
		draw_line(Vector2(-23, y - 2), Vector2(23, y - 2), Color("#b57c4a"), 1.0)

	# Six planting spots make the plot readable before a crop is planted.
	for y in [-10, 0, 10]:
		for x in [-18, 0, 18]:
			draw_circle(Vector2(x, y + 3), 3.0, Color("#68452e"))
	if fertilized and stage == "growing":
		draw_circle(Vector2(23, -15), 3.0, Color("#c9e66b"))

	if stage == "growing":
		_draw_growing_plants()
	elif stage == "mature":
		_draw_mature_plants()


func _draw_growing_plants() -> void:
	for y in [-10, 0, 10]:
		for x in [-18, 0, 18]:
			var base := Vector2(x, y + 3)
			draw_line(base, base + Vector2(0, -6), Color("#2f6a38"), 2.0)
			match plant_id:
				"herb":
					draw_circle(base + Vector2(-3, -6), 2.5, Color("#65a94d"))
					draw_circle(base + Vector2(3, -7), 2.5, Color("#83c75c"))
				"carrot", "radish":
					draw_line(base + Vector2(0, -4), base + Vector2(-4, -8), Color("#4e8d45"), 2.0)
					draw_line(base + Vector2(0, -5), base + Vector2(4, -9), Color("#68a94f"), 2.0)
				_:
					draw_line(base + Vector2(0, -3), base + Vector2(-4, -6), Color("#4e8d45"), 2.0)
					draw_line(base + Vector2(0, -4), base + Vector2(4, -7), Color("#68a94f"), 2.0)


func _draw_mature_plants() -> void:
	for y in [-10, 0, 10]:
		for x in [-18, 0, 18]:
			var base := Vector2(x, y + 4)
			match plant_id:
				"herb":
					_draw_herb(base)
				"carrot":
					_draw_root_crop(base, Color("#e7863d"))
				"radish":
					_draw_root_crop(base, Color("#d96b72"))
				"tomato":
					_draw_tomato(base)
				_:
					_draw_wheat(base)


func _draw_wheat(base: Vector2) -> void:
	draw_line(base, base + Vector2(0, -13), Color("#2f6a38"), 2.0)
	draw_line(base + Vector2(0, -7), base + Vector2(-5, -12), Color("#4e8d45"), 2.0)
	draw_line(base + Vector2(0, -9), base + Vector2(5, -14), Color("#4e8d45"), 2.0)
	draw_circle(base + Vector2(5, -14), 3.5, Color("#e5c64d"))


func _draw_herb(base: Vector2) -> void:
	draw_line(base, base + Vector2(0, -10), Color("#2f6a38"), 2.0)
	draw_circle(base + Vector2(-5, -8), 4.5, Color("#65a94d"))
	draw_circle(base + Vector2(5, -10), 4.5, Color("#83c75c"))
	draw_circle(base + Vector2(0, -14), 4.0, Color("#6fb957"))


func _draw_root_crop(base: Vector2, root_color: Color) -> void:
	draw_line(base, base + Vector2(0, -12), Color("#2f6a38"), 2.0)
	draw_line(base + Vector2(0, -7), base + Vector2(-6, -13), Color("#4e8d45"), 2.0)
	draw_line(base + Vector2(0, -8), base + Vector2(6, -14), Color("#68a94f"), 2.0)
	draw_circle(base + Vector2(0, -1), 4.0, root_color)


func _draw_tomato(base: Vector2) -> void:
	draw_line(base, base + Vector2(0, -11), Color("#2f6a38"), 2.0)
	draw_circle(base + Vector2(-5, -8), 4.0, Color("#65a94d"))
	draw_circle(base + Vector2(5, -10), 4.0, Color("#83c75c"))
	draw_circle(base + Vector2(-3, -1), 4.0, Color("#df6251"))
	draw_circle(base + Vector2(4, -3), 4.0, Color("#df6251"))
