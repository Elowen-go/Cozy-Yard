#!/usr/bin/env godot -s
extends SceneTree

func _init():
	var tileset := load("res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/tileset_ground.tres") as TileSet
	
	var root := Node2D.new()
	root.name = "TileDebug"
	
	var tilemap := TileMap.new()
	tilemap.name = "Grid"
	tilemap.tile_set = tileset
	tilemap.add_layer(0)
	
	# Place every atlas tile at its own world coordinate (1 tile = 32 px)
	for atlas_x in range(18):
		for atlas_y in range(10):
			tilemap.set_cell(0, Vector2i(atlas_x, atlas_y), 0, Vector2i(atlas_x, atlas_y))
	
	var camera := Camera2D.new()
	camera.name = "Camera"
	camera.position = Vector2(288, 160)
	camera.zoom = Vector2(2, 2)
	
	root.add_child(tilemap, true)
	tilemap.add_child(camera, true)
	tilemap.owner = root
	camera.owner = root
	
	var scene := PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/tile_debug.tscn")
	print("Debug scene saved: res://scenes/tile_debug.tscn")
	print("Open it in editor to see atlas coordinates")
	root.free()
	quit(0)
