void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 coord= fragCoord.xy / min( iResolution.x, iResolution.y );
	vec2 coord_floor= floor( coord * 6.0 ) / 5.0;
	vec2 coord_fract= fract( coord * 6.0 );
	vec3 c= vec3( coord_floor.xy, 0.0 );
	c.b= floor( (coord_fract.x + coord_fract.y ) * (6.0 / 2.0 ) ) / 5.0;

	fragColor = vec4( mix( c, vec3( 0.0, 0.0, 0.0 ), step( 1.0, max(coord.x, coord.y) ) ), 1.0);
}