shader_type canvas_item;

uniform vec4 outline_color: source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float outline_thickness: hint_range(1.0, 5.0) = 1.0;
uniform float apply: hint_range(0.0, 1.0) = 0.0;

float is_solid(float value){
	return max(0.0, sign(value));
}

void vertex() {
	// Called for every vertex the material is visible on.
}
float has_solid_neighbor(sampler2D texture_sample, vec2 uv_coord, vec2 pixel_size){
	vec2 offset = outline_thickness * pixel_size;
	float sum_alpha = texture(texture_sample, uv_coord + vec2(1.0, 0.0) * offset).a +
		texture(texture_sample, uv_coord + vec2(-1.0, 0.0) * offset).a +
		texture(texture_sample, uv_coord + vec2(0.0, 1.0) * offset).a +
		texture(texture_sample, uv_coord + vec2(0.0, -1.0) * offset).a;
	return is_solid(sum_alpha);
}
void fragment() {
	if(COLOR.a == 0.0){
		float outline_mask = has_solid_neighbor(TEXTURE, UV, TEXTURE_PIXEL_SIZE);
		if(outline_mask > 0.0 && apply == 1.0){
			COLOR = outline_color;
		}
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
