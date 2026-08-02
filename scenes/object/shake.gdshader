shader_type canvas_item;

uniform float shake_intensity : hint_range(0.0, 4.0) = 0.0;
uniform float shake_speed : hint_range(0.0, 30.0) = 20.0;

void vertex() {
	// Keep the lower half, where the trunk base is, completely stable.
	if (VERTEX.y < 0.0) {
		VERTEX.x += sin(TIME * shake_speed + VERTEX.y) * shake_intensity;
	}
}

void fragment() {
	COLOR = texture(TEXTURE, UV) * COLOR;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
