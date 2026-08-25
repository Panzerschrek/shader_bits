void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 coord = ( fragCoord / iResolution.xy ) * vec2( 1.1, 16.0 );

	float val_real= 1.0 / coord.x;

	float val_approx= intBitsToFloat( ( 254 << 23 ) - floatBitsToInt( coord.x ) );

	float ratio= val_approx / val_real;

	vec3 color=
		vec3(
			step( val_real, coord.y ),
			step( val_approx, coord.y ),
			step( coord.y, ratio ) * step( 1.0, coord.y ) );

	fragColor = vec4( color, 1.0 );
}
