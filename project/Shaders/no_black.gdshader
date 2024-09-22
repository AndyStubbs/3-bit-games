shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture( TEXTURE, UV );

    if( tex_color.r == 0.0 && tex_color.g == 0.0 && tex_color.b == 0.0 ) {
        COLOR = vec4( 0.0, 0.0, 0.0, 1.0 - tex_color.a );
    } else {
		//COLOR = vec4(0.0, 0.0, 0.0, 1.0);
		tex_color.a = 1.0;
		COLOR = tex_color;
    }
}