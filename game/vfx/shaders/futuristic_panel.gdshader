shader_type spatial;
// Painel futurista para as pecas de nivel (caixas): chanfro SIMULADO nas normais (a luz desenha a quina), friso de borda emissivo com
// pulso de energia que viaja pela peca, costuras de painel, circuitos no topo e brilho de contorno (rim). So aparencia: nenhuma colisao
// e nenhuma regra de jogo depende deste shader. `pulse_amount` = 0 desliga o movimento (acessibilidade: reduzir movimento).

uniform vec4 base_color : source_color = vec4(0.2, 0.3, 0.4, 1.0);
uniform vec4 trim_color : source_color = vec4(0.3, 0.9, 1.0, 1.0);
uniform vec3 half_size = vec3(1.0, 1.0, 1.0);
uniform float bevel = 0.18;
uniform float trim_width = 0.05;
uniform float trim_energy = 1.4;
uniform float seam_size = 1.5;
uniform float rim_power = 3.0;
uniform float rim_energy = 0.55;
uniform float fill_glow = 0.0;
uniform float pulse_amount = 1.0;
uniform float circuit_amount = 1.0;

varying vec3 v_local;
varying vec3 v_normal_local;

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void vertex() {
	v_local = VERTEX;
	v_normal_local = NORMAL;
}

void fragment() {
	vec3 d = max(half_size - abs(v_local), vec3(0.0));
	float d_min = min(d.x, min(d.y, d.z));
	float d_max = max(d.x, max(d.y, d.z));
	float edge = d.x + d.y + d.z - d_min - d_max;
	vec3 face = abs(v_normal_local);
	vec3 w = clamp(vec3(1.0) - d / bevel, vec3(0.0), vec3(1.0)) * (vec3(1.0) - face);
	vec3 bent = normalize(v_normal_local + sign(v_local) * w * 1.3);
	NORMAL = normalize(mat3(VIEW_MATRIX) * mat3(MODEL_MATRIX) * bent);
	vec3 g = abs(fract(v_local / seam_size + vec3(0.5)) - vec3(0.5));
	vec3 seams = (vec3(1.0) - smoothstep(vec3(0.0), vec3(0.025), g)) * (vec3(1.0) - face);
	float seam = max(seams.x, max(seams.y, seams.z));
	float trim = 1.0 - smoothstep(0.0, trim_width, edge);
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);
	// Pulso: uma faixa de luz viaja pela peca (fase pela posicao local; amplitude 0 = estatico).
	float wave = 0.5 + 0.5 * sin(dot(v_local, vec3(0.9, 0.6, 0.4)) * 1.1 - fract(TIME * 0.12) * 6.2832 * 6.0);
	float pulse = mix(1.0, 0.45 + 1.1 * wave, pulse_amount);
	// Circuitos: tracos finos no topo (celulas de 0,6 m com tracos aleatorios horizontais/verticais).
	vec2 cell = floor(v_local.xz / 0.6);
	vec2 local_uv = fract(v_local.xz / 0.6);
	float h = hash21(cell);
	float line_x = step(0.55, h) * (1.0 - smoothstep(0.0, 0.05, abs(local_uv.y - 0.5)));
	float line_z = step(0.8, hash21(cell + 7.0)) * (1.0 - smoothstep(0.0, 0.05, abs(local_uv.x - 0.5)));
	float circuit = max(line_x, line_z) * step(0.5, v_normal_local.y) * circuit_amount;
	ALBEDO = base_color.rgb * (1.0 - 0.3 * seam);
	METALLIC = 0.35;
	ROUGHNESS = 0.5;
	EMISSION = trim_color.rgb * (trim * trim_energy * pulse + seam * 0.12 + rim * rim_energy + circuit * 0.35 * pulse) + base_color.rgb * fill_glow;
}
