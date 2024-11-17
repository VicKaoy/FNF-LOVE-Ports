extern float hue;
extern float saturation;
extern float brightness;

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 effect(vec4 color, Image texture, vec2 tex_coords, vec2 screen_coords) {
	vec4 texColor = Texel(texture, tex_coords);
	vec3 hsv = rgb2hsv(texColor.rgb);

	hsv.r = mod(hsv.r + hue, 1.0);
	hsv.g = clamp(hsv.g + saturation, 0.0, 1.0);
	hsv.b = clamp(hsv.b * (1.0 + brightness), 0.0, 1.0);

	vec3 rgb = hsv2rgb(hsv);
	return vec4(rgb, texColor.a) * color;
}
