#!/usr/bin/env godot -s
extends SceneTree

func _init():
	var tile_size := Vector2i(64, 64)
	var tileset_path := "res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/tileset_ground.tres"
	var tilemap_path := "res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color1.png"
	
	# Create tileset
	var tileset := TileSet.new()
	tileset.tile_size = tile_size
	
	# Add atlas source
	var atlas := TileSetAtlasSource.new()
	var texture := load(tilemap_path) as Texture2D
	if texture == null:
		print("ERROR: Failed to load texture: ", tilemap_path)
		quit(1)
		return
	
	atlas.texture = texture
	atlas.texture_region_size = tile_size
	atlas.margins = Vector2i(0, 0)
	
	# Create tiles in 9x6 grid
	var atlas_width := 9
	var atlas_height := 6
	for x in range(atlas_width):
		for y in range(atlas_height):
			var coord := Vector2i(x, y)
			atlas.create_tile(coord)
			# Make all tiles walkable for now
			atlas.set_tile_animation_columns(coord, 0)
	
	var source_id := tileset.add_source(atlas)
	
	# Save tileset
	var save_result := ResourceSaver.save(tileset, tileset_path)
	if save_result != OK:
		print("ERROR: Failed to save tileset: ", save_result)
		quit(1)
		return
	
	print("TileSet saved successfully: ", tileset_path)
	print("Atlas size: ", atlas_width, "x", atlas_height)
	print("Tile size: ", tile_size)
	print("Source ID: ", source_id)
	
	quit(0)
