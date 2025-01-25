shader_type spatial;

uniform vec4 some_color : source_color;
uniform sampler2D noise;

void vertex() {
	//VERTEX.y = texture(noise, VERTEX.xz).r;
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
