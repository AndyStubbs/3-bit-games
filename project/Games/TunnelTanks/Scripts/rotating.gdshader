shader_type canvas_item;

uniform sampler2D spin_texture;
uniform bool clockwise = true;
uniform float speed : hint_range( 0.0, 2.0 ) = 1.0;

vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
			vec2(cos(angle), sin(angle)));
    
    uv -= pivot;
    uv = uv * rotation;
    uv += pivot;
    return uv;
}

void fragment()
{
	float direction = clockwise ? 1.0 : -1.0;
	vec2 rotated_uv = rotate(UV, vec2(0.5), TIME * speed * direction);
	COLOR = texture(spin_texture, rotated_uv);
}