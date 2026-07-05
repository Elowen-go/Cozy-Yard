#!/usr/bin/env godot -s
extends SceneTree

func _init():
	var texture_path := "res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color1.png"
	var save_path := "res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/tileset_ground.tres"
	
	if not FileAccess.file_exists(texture_path):
		print("ERROR: texture not found: ", texture_path)
		quit(1)
		return
	
	var texture := load(texture_path) as Texture2D
	
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(32, 32)
	
	var atlas_source := TileSetAtlasSource.new()
	atlas_source.texture = texture
	atlas_source.texture_region_size = Vector2i(32, 32)
	
	var atlas_width := int(texture.get_width() / 32)
	var atlas_height := int(texture.get_height() / 32)
	
	for x in range(atlas_width):
		for y in range(atlas_height):
			atlas_source.create_tile(Vector2i(x, y))
	
	tileset.add_source(atlas_source)
	
	ResourceSaver.save(tileset, save_path)
	print("Saved 32x32 TileSet: ", save_path)
	quit(0)
