void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const vec3 pupil_color= vec3( 0.1, 0.05, 0.03 );
	const vec3 iris_inner_color= vec3( 0.2, 0.6, 0.2 );
	const vec3 iris_outer_color= vec3( 0.2, 0.4, 0.6 );
	const float c_pupil_height= 1.6;

	float pupil_radius= 0.5 * c_pupil_height + ( sin(iTime) * 1.5 + 1.51 );
	float pupil_shift= sqrt( pupil_radius * pupil_radius - 0.25 * c_pupil_height * c_pupil_height );

	vec2 coord= 2.0 * ( fragCoord - iResolution.xy * 0.5 ) / min( iResolution.x, iResolution.y );

	float circle= 1.0 - step( 1.0, length(coord) );


	float pupil_factor=
		( 1.0 - step( pupil_radius, length( coord + vec2( -pupil_shift, 0.0 ) ) ) ) *
		( 1.0 - step( pupil_radius, length( coord + vec2( +pupil_shift, 0.0 ) ) ) );


	float distance_to_pupil= max(
	   distance( coord, vec2( -pupil_shift, 0.0 ) ),
	   distance( coord, vec2( +pupil_shift, 0.0 ) ) ) - pupil_radius;
	float distance_to_center= length(coord);

	vec3 iris_color= mix( iris_inner_color, iris_outer_color, distance_to_pupil );
	vec3 color= mix( iris_color, pupil_color, pupil_factor );
	color*= circle;

	fragColor = vec4( color, 1.0 );
}
