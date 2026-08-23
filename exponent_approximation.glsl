float c_exp_e_to_exp_two_scale= 1.4426950408889634073599246810019;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 coord = ( fragCoord / iResolution.xy + vec2( -0.535, 0.0 ) ) * vec2( 6.0, 16.0 );

	float exp_real= exp( coord.x );

	float exp_approx=
		intBitsToFloat(
			int( coord.x * ( c_exp_e_to_exp_two_scale * float( 1 << 23 ) ) ) +
			( 127 << 23 ) );

	vec3 color=
		vec3(
			step( exp_real, coord.y ),
			step( exp_approx, coord.y ),
			step( coord.y, exp_approx - exp_real ) );

	fragColor = vec4( color, 1.0 );
}
