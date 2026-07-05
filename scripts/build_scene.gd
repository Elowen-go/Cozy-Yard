#!/usr/bin/env godot -s
extends SceneTree

func _init():
	var tileset_path := "res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/tileset_ground.tres"
	
	if not ResourceLoader.exists(tileset_path):
		print("ERROR: TileSet not found")
		quit(1)
		return
	
	var tileset := load(tileset_path) as TileSet
	
	var root := Node2D.new()
	root.name = "MainScene"
	
	var tilemap := TileMap.new()
	tilemap.name = "Ground"
	tilemap.tile_set = tileset
	tilemap.add_layer(0)
	tilemap.set_layer_name(0, "Ground")
	
	# 9x9 island with proper 3x3 borders
	var size := 4
	for x in range(-size, size + 1):
		for y in range(-size, size + 1):
			var atlas := Vector2i(1, 1)  # interior grass
			
			if x == -size and y == -size:
				atlas = Vector2i(0, 0)  # top-left corner
			elif x == size and y == -size:
				atlas = Vector2i(2, 0)  # top-right corner
			elif x == -size and y == size:
				atlas = Vector2i(0, 2)  # bottom-left corner
			elif x == size and y == size:
				atlas = Vector2i(2, 2)  # bottom-right corner
			elif x == -size:
				atlas = Vector2i(0, 1)  # left edge
			elif x == size:
				atlas = Vector2i(2, 1)  # right edge
			elif y == -size:
				atlas = Vector2i(1, 0)  # top edge
			elif y == size:
				atlas = Vector2i(1, 2)  # bottom edge
			
			tilemap.set_cell(0, Vector2i(x, y), 0, atlas)
	
	var camera := Camera2D.new()
	camera.name = "Camera"
	camera.position = Vector2(16, 16)
	camera.zoom = Vector2(1.5, 1.5)
	
	root.add_child(tilemap, true)
	tilemap.add_child(camera, true)
	tilemap.owner = root
	camera.owner = root
	
	var scene := PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/main.tscn")
	print("Saved 9x9 bordered scene with 32x32 tiles")
	
	root.free()
	quit(0)
