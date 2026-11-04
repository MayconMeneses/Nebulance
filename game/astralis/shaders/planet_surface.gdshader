shader_type spatial;
// Superficie procedural de um planeta do Mapa Galactico: continentes e mares por ruido 3D, nuvens que derivam, veias de corrupcao
// (Caeldron) e brilho de atmosfera na borda. So aparencia. `dim` escurece o planeta bloqueado; `corruption` liga as veias magenta.

uniform vec4 color_land : source_color = vec4(0.3, 0.7, 0.4, 1.0);
uniform vec4 color_sea : source_color = vec4(0.05, 0.2, 0.3, 1.0);
uniform vec4 glow_color : source_color = vec4(0.5, 0.9, 1.0, 1.0);
uniform float seed = 0.0;
uniform float sea_level = 0.5;
uniform float cloud_amount = 0.5;
uniform float dim = 1.0;
uniform float corruption = 0.0;
uniform float drift = 1.0;

varying vec3 v_obj;

float hash31(vec3 p) {
	p = fract(p * vec3(0.1031, 0.1030, 0.0973));
	p += dot(p, p.yxz + 33.33);
	return fract((p.x + p.y) * p.z);
}

float noise3(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float n000 = hash31(i);
	float n100 = hash31(i + vec3(1.0, 0.0, 0.0));
	float n010 = hash31(i + vec3(0.0, 1.0, 0.0));
	float n110 = hash31(i + vec3(1.0, 1.0, 0.0));
	float n001 = hash31(i + vec3(0.0, 0.0, 1.0));
	float n101 = hash31(i + vec3(1.0, 0.0, 1.0));
	float n011 = hash31(i + vec3(0.0, 1.0, 1.0));
	float n111 = hash31(i + vec3(1.0, 1.0, 1.0));
	return mix(mix(mix(n000, n100, f.x), mix(n010, n110, f.x), f.y), mix(mix(n001, n101, f.x), mix(n011, n111, f.x), f.y), f.z);
}

float fbm(vec3 p) {
	float a = 0.5;
	float s = 0.0;
	for (int i = 0; i < 4; i++) {
		s += a * noise3(p);
		p = p * 2.03 + 11.7;
		a *= 0.5;
	}
	return s;
}

void vertex() {
	v_obj = normalize(VERTEX);
}

void fragment() {
	vec3 p = v_obj * 2.2 + vec3(seed * 7.3);
	float h = fbm(p);
	float land = smoothstep(sea_level - 0.03, sea_level + 0.03, h);
	vec3 col = mix(color_sea.rgb, color_land.rgb * (0.75 + 0.5 * h), land);
	float cl = fbm(v_obj * 3.4 + vec3(seed * 3.1) + vec3(TIME * 0.015 * drift, 0.0, 0.0));
	float clouds = smoothstep(0.52, 0.78, cl) * cloud_amount;
	col = mix(col, vec3(0.95, 0.97, 1.0), clouds * 0.75);
	float vein = (1.0 - smoothstep(0.0, 0.045, abs(fbm(v_obj * 4.5 + vec3(seed)) - 0.5))) * corruption;
	col = mix(col, vec3(0.75, 0.1, 0.65), vein * 0.9);
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.6);
	ALBEDO = col * dim;
	ROUGHNESS = mix(0.35, 0.85, land);
	EMISSION = glow_color.rgb * rim * 0.9 * dim + vec3(0.9, 0.15, 0.75) * vein * 1.4 * (0.6 + 0.4 * sin(TIME * 1.6 + v_obj.x * 6.0));
}
