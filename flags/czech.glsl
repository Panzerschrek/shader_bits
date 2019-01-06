vec3 TwoColor( float y, float delta, vec3 c0, vec3 c1 )
{
	vec3 color;
	if( y < 1.0 / 4.0 )
		color= c0;
	else if( y < 3.0 /4.0 )
		color= mix( c0, c1, smoothstep( 1.0 / 2.0 - delta * 0.5, 1.0 / 2.0 + delta * 0.5, y ) );
	else
		color= c1;
	return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 white= vec3( 1.0, 1.0, 1.0 );
	vec3 blue= vec3( 0.066, 0.27, 0.49 );
	vec3 red= vec3( 0.843, 0.078, 0.102 );

	float delta= 2.0 / iResolution.y;
	vec2 coord= fragCoord / min( iResolution.x, iResolution.y );

	vec3 stripes_color= TwoColor( coord.y, delta, red, white );

	float trianlge_factor=
		smoothstep( coord.x - 0.5 * delta, coord.x + 0.5 * delta, coord.y ) *
		smoothstep( coord.x - 0.5 * delta, coord.x + 0.5 * delta, 1.0 - coord.y );

	vec3 color= mix( stripes_color, blue, trianlge_factor );

	fragColor= vec4( color, 1.0 );
}
