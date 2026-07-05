#!/usr/bin/env godot -s
extends SceneTree

func _init():
	var tileset_path := "res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/tileset_ground.tres"
	
	# Load existing tileset
	if not ResourceLoader.exists(tileset_path):
		print("ERROR: TileSet not found, run generate_tileset.gd first")
		quit(1)
		return
	
	var tileset := load(tileset_path) as TileSet
	
	# Create scene root
	var root := Node2D.new()
	root.name = "MainScene"
	root.scene_file_path = "res://scenes/main.tscn"
	
	# Create TileMap
	var tilemap := TileMap.new()
	tilemap.name = "Ground"
	tilemap.tile_set = tileset
	tilemap.add_layer(0)
	tilemap.set_layer_name(0, "Ground")
	
	# Place tiles - large ground area
	var source_id := 0
	for x in range(-15, 16):
		for y in range(-15, 16):
			# Use different tiles for variety
			var tile_x := x % 6
			var tile_y := 0 if y % 3 != 0 else 1
			tilemap.set_cell(0, Vector2i(x, y), source_id, Vector2i(tile_x, tile_y))
	
	# Add a dirt path
	for x in range(-2, 3):
		for y in range(-15, 16):
			tilemap.set_cell(0, Vector2i(x, y), source_id, Vector2i(6, 5))
	
	# Add Camera2D
	var camera := Camera2D.new()
	camera.name = "Camera"
	camera.position = Vector2(0, 0)
	camera.zoom = Vector2(2, 2)
	
	# Build scene tree
	root.add_child(tilemap, true)
	tilemap.add_child(camera, true)
	
	# Set owners for packed scene
	tilemap.owner = root
	camera.owner = root
	
	# Save the scene
	var scene := PackedScene.new()
	var pack_result := scene.pack(root)
	if pack_result != OK:
		print("ERROR: Failed to pack scene: ", pack_result)
		quit(1)
		return
	
	var save_result := ResourceSaver.save(scene, "res://scenes/main.tscn")
	if save_result != OK:
		print("ERROR: Failed to save scene: ", save_result)
		quit(1)
		return
	
	print("Scene saved successfully: res://scenes/main.tscn")
	print("Tiles placed: 31x31 ground area with path")
	
	# Set as main scene
	ProjectSettings.set_setting("application/run/main_scene", "res://scenes/main.tscn")
	var save_settings := ProjectSettings.save()
	if save_settings != OK:
		print("Warning: Failed to save project settings")
	else:
		print("Main scene set in project settings")
	
	root.free()
	quit(0)
