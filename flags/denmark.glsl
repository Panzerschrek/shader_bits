void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const vec3 red= vec3( 0.776, 0.047, 0.188 );
	const vec3 white= vec3( 1.0, 1.0, 1.0 );

	vec2 coord= fragCoord / iResolution.y;
	float delta= 0.5 / iResolution.y;

	const float c_strip_half_size= 1.0 / 14.0;

	float cross_factor=
		smoothstep( 0.5 - c_strip_half_size - delta, 0.5 - c_strip_half_size + delta, coord.y ) *
		( 1.0 - smoothstep( 0.5 + c_strip_half_size - delta, 0.5 + c_strip_half_size + delta, coord.y ) ) +
		smoothstep( 0.5 - c_strip_half_size - delta, 0.5 - c_strip_half_size + delta, coord.x ) *
		( 1.0 - smoothstep( 0.5 + c_strip_half_size - delta, 0.5 + c_strip_half_size + delta, coord.x ) );

	vec3 color= mix( red, white, min( 1.0, cross_factor ) );
	fragColor= vec4( color, 1.0 );
}
