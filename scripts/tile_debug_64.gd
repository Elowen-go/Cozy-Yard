#!/usr/bin/env godot -s
extends SceneTree

func _init():
	var tileset := load("res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/tileset_ground.tres") as TileSet
	
	var root := Node2D.new()
	root.name = "TileDebug64"
	
	var tilemap := TileMap.new()
	tilemap.name = "Grid"
	tilemap.tile_set = tileset
	tilemap.add_layer(0)
	
	# 9x6 atlas at 64x64
	for atlas_x in range(9):
		for atlas_y in range(6):
			tilemap.set_cell(0, Vector2i(atlas_x, atlas_y), 0, Vector2i(atlas_x, atlas_y))
	
	var font := SystemFont.new()
	font.font_names = ["Consolas", "Courier New", "Arial"]
	
	for atlas_x in range(9):
		for atlas_y in range(6):
			var label := Label.new()
			label.text = "%d,%d" % [atlas_x, atlas_y]
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.position = Vector2(atlas_x * 64, atlas_y * 64)
			label.size = Vector2(64, 64)
			label.add_theme_font_override("font", font)
			label.add_theme_font_size_override("font_size", 14)
			label.add_theme_color_override("font_color", Color.WHITE)
			label.add_theme_color_override("font_shadow_color", Color.BLACK)
			label.add_theme_constant_override("shadow_outline_size", 3)
			root.add_child(label, true)
			label.owner = root
	
	var camera := Camera2D.new()
	camera.name = "Camera"
	camera.position = Vector2(288, 192)
	camera.zoom = Vector2(1.5, 1.5)
	
	root.add_child(tilemap, true)
	tilemap.add_child(camera, true)
	tilemap.owner = root
	camera.owner = root
	
	var scene := PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/tile_debug_64.tscn")
	print("Saved tile_debug_64.tscn")
	root.free()
	quit(0)
