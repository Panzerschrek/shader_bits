float Swastic( vec2 coord, float delta )
{
	coord*= sign(coord.x);

	float square_factor=
		( 1.0 - smoothstep( 1.0 - delta, 1.0 + delta, coord.x ) ) *
		( 1.0 - smoothstep( 1.0 - delta, 1.0 + delta, coord.y ) ) *
		smoothstep( -1.0 - delta, -1.0 + delta, coord.y );

	float cut0_factor=
		smoothstep( 0.2 - delta, 0.2 + delta, coord.y ) *
		( 1.0 - smoothstep( 0.6 - delta, 0.6 + delta, coord.y ) ) *
		smoothstep( 0.2 - delta, 0.2 + delta, coord.x );

	float cut1_factor=
		smoothstep( 0.2 - delta, 0.2 + delta, coord.x ) *
		( 1.0 - smoothstep( 0.6 - delta, 0.6 + delta, coord.x ) ) *
		( 1.0 - smoothstep( -0.2 - delta, -0.2 + delta, coord.y ) );

	return square_factor - square_factor * min( 1.0, cut1_factor + cut0_factor );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float c_half_sqrt_2= inversesqrt(2.0);

	const float c_swastic_size= 1.0 / 2.0;
	const float c_circle_radius= 1.1 * c_swastic_size / c_half_sqrt_2;

	const vec3 red= vec3( 1.0, 0.0, 0.0 );
	const vec3 white= vec3( 1.0, 1.0, 1.0 );
	const vec3 black= vec3( 0.0, 0.0, 0.0 );

	vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) / ( 0.5 * iResolution.y );
	float delta= 1.0 / iResolution.y;

	vec2 swastic_coord= coord.x * vec2( c_half_sqrt_2, -c_half_sqrt_2 ) + coord.y * vec2( c_half_sqrt_2, c_half_sqrt_2 );

	float swastic_factor= Swastic( swastic_coord / c_swastic_size, delta / c_swastic_size );

	float circle_factor= smoothstep( c_circle_radius - delta, c_circle_radius + delta, length(coord) );

	vec3 color= mix( white, black, swastic_factor );
	color= mix( color, red, circle_factor );

	fragColor= vec4(color, 1.0);
}
