shader_type spatial;
render_mode blend_mix, cull_front, shadows_disabled;

uniform vec4 color : source_color = vec4(0,0,0,1);
uniform float size : hint_range(1.0, 1.5, 0.01) = 1.05;
uniform float min_dist = 5.0;
uniform float max_dist = 15.0;

void vertex() {
	VERTEX *= size;
}

void fragment() {
	ALBEDO = color.rgb;
	vec3 world_camera = (INV_VIEW_MATRIX * vec4(vec3(0.0), 1.0)).xyz;
	vec4 a = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	ALPHA = smoothstep(min_dist, max_dist, distance(a.xyz, world_camera));
	//EMISSION = ALBEDO;
}

void light () {
    DIFFUSE_LIGHT += ATTENUATION;
}
