vec3 hsv2rgb(vec3 c)
{
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 getHS( float y )
{
	float s1= 1.0;
	float s_half= 0.5;
	float s_middle= 0.75;

	if( y <  1.0 / 16.0 )
		return vec2( 0.0 / 3.0, s1 );
	if( y <  2.0 / 16.0 )
		return vec2( 0.0 / 3.0, s_half );
	if( y <  3.0 / 16.0 )
		return vec2( 1.0 / 9.0, s_half );
	if( y <  4.0 / 16.0 )
		return vec2( 1.0 / 6.0, s_middle );
	if( y <  5.0 / 16.0 )
		return vec2( 2.0 / 9.0, s_half );

	if( y <  6.0 / 16.0 )
		return vec2( 1.0 / 3.0, s1 );
	if( y <  7.0 / 16.0 )
		return vec2( 1.0 / 3.0, s_half );
	if( y <  8.0 / 16.0 )
		return vec2( 4.0 / 9.0, s_half );
	if( y <  9.0 / 16.0 )
		return vec2( 3.0 / 6.0, s_middle );
	if( y < 10.0 / 16.0 )
		return vec2( 5.0 / 9.0, s_half );

	if( y < 11.0 / 16.0 )
		return vec2( 2.0 / 3.0, s1 );
	if( y < 12.0 / 16.0 )
		return vec2( 2.0 / 3.0, s_half );
	if( y < 13.0 / 16.0 )
		return vec2( 7.0 / 9.0, s_half );
	if( y < 14.0 / 16.0 )
		return vec2( 5.0 / 6.0, s_middle );
	if( y < 15.0 / 16.0 )
		return vec2( 8.0 / 9.0, s_half );

	return vec2( 0.0, 0.0 );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 coord= fragCoord.xy / min(iResolution.x, iResolution.y );

	float y= 1.0 - coord.y;
	float x= coord.x * step( coord.x, 1.0 );
	float v= min( ceil( x * 16.0 ) / 15.0, 1.0 );

	vec3 hsv= vec3( getHS( y ), v );
	vec3 rgb= hsv2rgb( hsv );
	rgb= mix( rgb, ( floor( y * 16.0 ) / 16.0 - 1.0 / 16.0 ) * vec3( 1.0, 1.0, 1.0 ), step( 15.0 / 16.0, x ) );

	fragColor = vec4( rgb, 1.0 );
}