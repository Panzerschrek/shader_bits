void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float two_pi= 2.0 * 3.1415926535;

	float pix_size= 2.2 / min(iResolution.x, iResolution.y);
	vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;
	float angle= atan( coord.x, coord.y ) / two_pi + 0.5;
	float radius= length(coord);
	
	float radius_scaled= (1.0 / 3.0) * radius;

	vec2 seed= fract( vec2( angle + radius_scaled, angle - radius_scaled ) * 32.0 ) - vec2( 0.5, 0.5 );

	seed= 0.5 / sqrt(radius) * vec2( ( seed.x + seed.y  ) * radius * 2.0, seed.x  - seed.y );

	float seed_distance= 0.5 - length(seed);

	float b= smoothstep( 0.0, 0.25, seed_distance ) * ( 1.0 - smoothstep( 1.0 - pix_size, 1.0 + pix_size, radius ) );
	fragColor = vec4( b, b, b, 1.0);
}