
shader_type canvas_item;

uniform float progress : hint_range(0.0, 100.0, 0.1);
uniform sampler2D noise : filter_nearest, repeat_enable;
uniform vec2 tile_factor = vec2(0.0, 0.0);
uniform vec2 tile_offset = vec2(0.0, 0.0);
uniform float speed = 0.1;
uniform vec4 base_color : source_color;
uniform vec4 shine_color : source_color;

void fragment() {
	vec2 pixel_size = 1.0 / vec2(textureSize(noise, 0));
	vec2 diff = pixel_size / TEXTURE_PIXEL_SIZE;

	vec2 centered_uv = UV * 2.0 - 1.0 * vec2(sin(TIME * speed * 0.1), sin(TIME * speed)) + tile_offset;
	vec2 tiled_uv = centered_uv * tile_factor * diff;

	tiled_uv = tiled_uv * 0.5 + 0.5;

	tiled_uv += tile_offset;
	vec4 noise_tex = texture(noise, tiled_uv);

	vec4 fill_color = mix(base_color, shine_color, noise_tex.r);
	vec4 is_filled = UV.x < progress / 100.0 ? fill_color : vec4(0.0);

	COLOR = is_filled;
}