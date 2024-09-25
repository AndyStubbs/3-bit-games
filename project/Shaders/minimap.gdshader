shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture( TEXTURE, UV );
    if (
		tex_color.r > 0.25 && tex_color.r < 0.45 &&
		tex_color.g > 0.1 && tex_color.g < 0.31 &&
		tex_color.b > 0.04 && tex_color.b < 0.18
	) {
        COLOR = vec4( 0.36, 0.22, 0.11, 1.0 );
    }
	else if(
		tex_color.r == tex_color.g && tex_color.r == tex_color.b &&
		tex_color.r > 0.15 && tex_color.r < 0.45 &&
		tex_color.g > 0.15 && tex_color.g < 0.45 &&
		tex_color.b > 0.15 && tex_color.b < 0.45
	) {
		COLOR = vec4( 0.3, 0.3, 0.3, 1.0 );
	}
	else if( tex_color.r == 0.0 && tex_color.g == 0.0 && tex_color.b == 0.0 ) {
		COLOR = vec4( 0.0, 0.0, 0.0, 1.0 - tex_color.a );
	}
	else {
		COLOR = tex_color;
	}
}
