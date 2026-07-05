#!/usr/bin/env godot -s
extends SceneTree

func _init():
	var tile_size := 32
	var texture_path := "res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color1.png"
	var tileset_path := "res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/tileset_ground.tres"
	
	print("Generating TileSet...")
	
	# Load texture
	var texture := load(texture_path) as Texture2D
	if not texture:
		print("Failed to load texture: ", texture_path)
		quit(1)
		return
	
	print("Texture loaded: ", texture.get_width(), "x", texture.get_height())
	
	# Create TileSet
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(tile_size, tile_size)
	
	# Create atlas source
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(tile_size, tile_size)
	
	# Calculate tiles
	var cols := texture.get_width() / tile_size
	var rows := texture.get_height() / tile_size
	
	# Add all tiles from the atlas
	for y in range(rows):
		for x in range(cols):
			var atlas_coords := Vector2i(x, y)
			source.create_tile(atlas_coords)
	
	# Add source to tileset
	tileset.add_source(source)
	
	# Save the tileset
	var err := ResourceSaver.save(tileset, tileset_path)
	if err != OK:
		print("Failed to save tileset: ", err)
		quit(1)
		return
	
	print("TileSet saved: ", tileset_path)
	print("Total tiles: ", cols * rows, " (", cols, "x", rows, ")")
	
	quit(0)
