shader_type canvas_item;

uniform float offset : hint_range(0.0, 1.0) = 0.0;
uniform float dash_ratio : hint_range(0.0, 1.0) = 0.5;
uniform float smoothness : hint_range(0.0, 0.1) = 0.02;

void fragment() {
	vec2 uv = UV;
	uv.y = fract(uv.y + offset);
	float dash = smoothstep(dash_ratio, dash_ratio - smoothness, uv.y);
	COLOR = texture(TEXTURE, UV) * vec4(1.0, 1.0, 1.0, dash);
}