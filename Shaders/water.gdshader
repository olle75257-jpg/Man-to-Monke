shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;
uniform sampler2D noise_texture1: repeat_enable;
uniform sampler2D noise_texture2: repeat_enable;
uniform vec2 offset1 = vec2(0.1);
uniform vec2 offset2 = vec2(0.2);

uniform float distortion_strength: hint_range(-1.0, 1.0) = 0.02;

void fragment() {
	vec4 noise1 = texture(noise_texture1, UV + offset1 * TIME);
	//vec4 original_color = texture(TEXTURE, UV + offset * TIME);
	vec4 noise2 = texture(noise_texture2, UV + offset2 * TIME);
	
	float final_noise = noise1.r * noise2.r;
	//vec4 final_color = vec4(vec3(final_noise), 1.0);
	vec4 final_color = texture(screen_texture, SCREEN_UV + final_noise * distortion_strength);
	
	COLOR = final_color;
	
}