shader_type spatial;
/* WATER SHADER 3.2 "Back to the roots" */

uniform vec2 amplitude = vec2(0.5, 0.3);
uniform vec2 frequency = vec2(.2, .2);
uniform vec2 time_factor = vec2(2.0, 2.0);
uniform bool waves_by_height = false;
uniform float water_height = 2.5;
uniform float water_clearnes = 0.4;
uniform float water_refraction = 0.014;
uniform float water_alpha = 0.2;
uniform float water_shore = 0.37;
uniform float water_color_contrast = 6.0;

uniform sampler2D height_map;

float height(vec2 pos, float time, float noise){
	float t_height = texture(height_map, pos.xy).r;
	float th = 1.0;
	if (waves_by_height) {
		th = t_height*.2;
	}
	return (amplitude.x * th * sin(pos.x * frequency.x * noise + time * time_factor.x)) + (amplitude.y * th * sin(pos.y * frequency.y * noise + time * time_factor.y));
}

float fake_random(vec2 p){
	return fract(sin(dot(p.xy, vec2(12.9898,78.233))) * 43758.5453);
}

vec2 faker(vec2 p){
	return vec2(fake_random(p), fake_random(p*124.32));
}

void vertex(){
	float noise = faker(VERTEX.xz).x;
	VERTEX.y = water_height + height(VERTEX.xz, TIME, noise);
	TANGENT = normalize( vec3(0.0, height(VERTEX.xz + vec2(0.0, 0.2), TIME, noise) - height(VERTEX.xz + vec2(0.0, -0.2), TIME, noise), 0.4));
	BINORMAL = normalize( vec3(0.4, height(VERTEX.xz + vec2(0.2, 0.0), TIME, noise) - height(VERTEX.xz + vec2(-0.2, 0.0), TIME, noise), 0.0));
	NORMAL = cross(TANGENT, BINORMAL);
}

void fragment(){
	vec2 uv2 = UV * -1.0;
	float height = texture(height_map, uv2.xy).r;
	float gfx = smoothstep(0.0, water_shore, height);
	vec3 w_color = vec3(gfx, gfx, gfx) * water_color_contrast;
	
	ROUGHNESS = 0.5 * gfx;
	METALLIC = 0.0;
	SPECULAR = 1.0 - gfx;
	ALPHA = water_alpha;
	ALBEDO = clamp(w_color, 0.0, 1.0);
}