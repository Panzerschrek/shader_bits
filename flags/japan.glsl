void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float c_sun_size= 3.0 / 5.0;
	const vec3 red= vec3( 0.737, 0.0, 0.176 );
	const vec3 white= vec3( 1.0, 1.0, 1.0 );

	float delta= 2.0 / iResolution.y;
	vec2 coord= 2.0 * ( fragCoord - 0.5 * iResolution.xy ) / min( iResolution.x, iResolution.y );

	vec3 color= mix( red, white, smoothstep( c_sun_size - delta, c_sun_size + delta, length(coord) ) );

	fragColor= vec4( color, 1.0 );
}
