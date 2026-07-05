def encode_tile(x, y, atlas_x, atlas_y, source_id=0):
    coord = (y << 16) | (x & 0xFFFF)
    source = source_id << 16
    atlas = (atlas_x << 16) | (atlas_y & 0xFFFF)
    return [coord, source, atlas]

size = 4  # -4 to 4 inclusive -> 9x9
tile_data = []

for y in range(-size, size + 1):
    for x in range(-size, size + 1):
        ax, ay = 1, 1  # default grass
        
        if x == -size and y == -size:
            ax, ay = 0, 0
        elif x == size and y == -size:
            ax, ay = 5, 0
        elif x == -size and y == size:
            ax, ay = 0, 3
        elif x == size and y == size:
            ax, ay = 5, 3
        elif x == -size:
            ax, ay = 0, 2
        elif x == size:
            ax, ay = 5, 2
        elif y == -size:
            ax, ay = 2, 0
        elif y == size:
            ax, ay = 2, 3
        
        tile_data.extend(encode_tile(x, y, ax, ay))

content = f"""[gd_scene load_steps=2 format=3]

[ext_resource type="TileSet" path="res://assets/Tiny Swords (Free Pack)/Terrain/Tileset/tileset_ground.tres" id="1_3v4nm"]

[node name="MainScene" type="Node2D"]

[node name="Ground" type="TileMap" parent="."]
tile_set = ExtResource("1_3v4nm")
format = 2
layer_0/name = "Ground"
layer_0/tile_data = PackedInt32Array({', '.join(str(n) for n in tile_data)})

[node name="Camera" type="Camera2D" parent="Ground"]
zoom = Vector2(1, 1)
"""

with open("d:/GodotDemo/Godot_Demo/AnZhi/scenes/main.tscn", "w", encoding="utf-8") as f:
    f.write(content)

print("Generated 9x9 scene")
print("Tile count:", len(tile_data) // 3)
