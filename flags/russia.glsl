vec3 TriColor( float y, float delta, vec3 c0, vec3 c1, vec3 c2 )
{
	vec3 color;
	if( y < 1.0 / 6.0 )
		color= c0;
	else if( y < 1.0 / 2.0 )
		color= mix( c0, c1, smoothstep( 1.0 / 3.0 - delta * 0.5, 1.0 / 3.0 + delta * 0.5, y ) );
	else if( y < 5.0 / 6.0 )
		color= mix( c1, c2, smoothstep( 2.0 / 3.0 - delta * 0.5, 2.0 / 3.0 + delta * 0.5, y ) );
	else
		color= c2;
	return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 white= vec3( 1.0, 1.0, 1.0 );
	vec3 blue= vec3( 0.0, 0.224, 0.65 );
	vec3 red= vec3( 0.836, 0.169, 0.118 );

	vec3 color= TriColor( fragCoord.y / iResolution.y, 2.0 / iResolution.y, red, blue, white );
	fragColor= vec4( color, 1.0 );
}
