shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;
// Piso holografico do abismo: grade luminosa em perspectiva que some com a distancia. Cor/brilho vem da paleta do planeta.
// So aparencia (sem colisao). `scroll` anima a grade devagar; 0 = parada (acessibilidade: reduzir movimento).

uniform vec4 line_color : source_color = vec4(0.4, 0.9, 1.0, 1.0);
uniform float cell = 3.0;
uniform float fade_distance = 90.0;
uniform float scroll = 0.6;

varying vec3 v_world;

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = v_world.xz / cell;
	p.y += TIME * scroll * 0.1;
	vec2 f = abs(fract(p) - 0.5);
	vec2 w = fwidth(p) * 1.5 + 0.02;
	vec2 l = smoothstep(vec2(0.5) - w, vec2(0.5), f);
	float line = max(l.x, l.y);
	float fade = 1.0 - smoothstep(fade_distance * 0.2, fade_distance, length(VERTEX));
	ALBEDO = line_color.rgb * line * fade * 0.9;
}
