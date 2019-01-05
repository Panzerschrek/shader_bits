void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 num= ( fragCoord.xy ) / ( 0.5 * iResolution.xy ) - vec2( 1.0, 1.0 );
	num.x*= iResolution.x / iResolution.y;

	const int c_iterations= 256;
	vec2 z= vec2( 0.0, 0.0 );
	int i= 0;
	for(; i < c_iterations; ++i )
	{
		z= num + vec2( z.x * z.x - z.y * z.y, 2.0 * z.x * z.y );
		if( dot(z, z) >= 4.0 )
			break;
	}

	float set_factor= step( 4.0, dot(z, z) );
	float color_factor= pow( float(i) / float(c_iterations), 0.25 );

	vec3 color= vec3(
		sin( iTime * 1.0 + color_factor * 7.0 ) * 0.5 + 0.5,
		sin( iTime * 1.5 + color_factor * 8.0 ) * 0.5 + 0.5,
		sin( iTime * 2.0 + color_factor * 9.0 ) * 0.5 + 0.5 );

	fragColor= vec4( set_factor * color, 0.0 );
}
