const float c_two_pi= 3.1415926535 * 2.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float c_spiral_scale= 30.0;
	const float c_corners= 6.0;

	vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) / max( iResolution.x, iResolution.y );
	float delta= c_spiral_scale / max( iResolution.x, iResolution.y );

	float angle= fract( atan(coord.y, coord.x)  / c_two_pi - iTime * 0.125 );

	float r= length(coord) * c_spiral_scale;
	r*= cos( (fract(angle * c_corners) - 0.5) * ( c_two_pi / c_corners ) );
	r+= angle;
	float r_fract= fract( r );

	float color_factor= angle * 10.0 * ( ceil(r) );

	vec3 color= vec3(
		sin( iTime * 1.1 * 2.0 + color_factor * 0.3 * c_two_pi ) * 0.5 + 0.5,
		sin( iTime * 2.3 * 2.0 + color_factor * 0.4 * c_two_pi ) * 0.5 + 0.5,
		sin( iTime * 3.7 * 2.0 + color_factor * 0.5 * c_two_pi ) * 0.5 + 0.5 );

	float spiral_factor=
		smoothstep( 0.0, 2.0 * delta, r_fract ) *
		( 1.0 - smoothstep( 0.9 - delta, 0.9 + delta , r_fract ) );
	fragColor= vec4( spiral_factor * color, 1.0 );
}
