vec3 coordToColor( float c )
{
	if( c <= 12.0 / 16.0 )
	{
		if( c <=  1.0 / 16.0 )
			return vec3( 0.5, 0.0, 0.0 );
		if( c <=  2.0 / 16.0 )
			return vec3( 1.0, 0.0, 0.0 );
		if( c <=  3.0 / 16.0 )
			return vec3( 0.0, 0.5, 0.0 );
		if( c <=  4.0 / 16.0 )
			return vec3( 0.0, 1.0, 0.0 );
		if( c <=  5.0 / 16.0 )
			return vec3( 0.0, 0.0, 0.5 );
		if( c <=  6.0 / 16.0 )
			return vec3( 0.0, 0.0, 1.0 );
		if( c <=  7.0 / 16.0 )
			return vec3( 0.5, 0.5, 0.0 );
		if( c <=  8.0 / 16.0 )
			return vec3( 1.0, 1.0, 0.0 );
		if( c <=  9.0 / 16.0 )
			return vec3( 0.0, 0.5, 0.5 );
		if( c <= 10.0 / 16.0 )
			return vec3( 0.0, 1.0, 1.0 );
		if( c <= 11.0 / 16.0 )
			return vec3( 0.5, 0.0, 0.5 );
		if( c <= 12.0 / 16.0 )
			return vec3( 1.0, 0.0, 1.0 );
	}
	else
	{
		if( c <= 13.0 / 16.0 )
			return vec3( 0.0, 0.0, 0.0 );
		if( c <= 14.0 / 16.0 )
			return vec3( 0.333333, 0.333333, 0.333333 );
		if( c <= 15.0 / 16.0 )
			return vec3( 0.666666, 0.666666, 0.666666 );
		//if( c <= 16.0 / 16.0 )
			return vec3( 1.0, 1.0, 1.0 );
	}
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 coord= fragCoord.xy / ( iResolution.y * 0.8 );

	vec3 color_mixed;
	if( coord.x > 1.0 )
		color_mixed= coordToColor( coord.y );
	else if( coord.y > 1.0 )
		color_mixed= coordToColor( coord.x );
	else
		color_mixed= mix( coordToColor( coord.x ), coordToColor( coord.y ), 1.0 / 3.0 );


	fragColor = vec4( color_mixed , 1.0);
}