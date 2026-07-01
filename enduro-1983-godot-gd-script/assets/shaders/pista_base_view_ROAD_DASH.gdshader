shader_type canvas_item;

/// Offset UV animado proporcionalmente à velocidade do carro —
/// cria o efeito de tracejado "correndo" para baixo
uniform float offset : hint_range(0.0, 1.0) = 0.0;

/// Proporção do traço visível (0.0 = sem traço | 1.0 = linha contínua)
uniform float dash_ratio : hint_range(0.0, 1.0) = 0.5;

/// Suavidade das bordas do traço — evita aliasing no corte
uniform float smoothness : hint_range(0.0, 0.1) = 0.02;

/// Cor da linha — branco por padrão, CORNFLOWER_BLUE na neve.
/// Controlado pelo DayViewController via set_shader_parameter("line_color")
/// Usar self_modulate não funciona quando ShaderMaterial está ativo
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec2 uv = UV;
	uv.y = fract(uv.y + offset);
	float dash = smoothstep(dash_ratio, dash_ratio - smoothness, uv.y);
	COLOR = texture(TEXTURE, UV) * vec4(line_color.rgb, dash * line_color.a);
}