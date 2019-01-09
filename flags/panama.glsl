const float c_deg_to_rad= 3.1415926535 / 180.0;

float Star( vec2 coord, float delta )
{
	if( dot( coord, coord ) > 1.0 )
		return 0.0;

	coord.x= abs(coord.x);

	const float c_upper_point_y= 1.0;
	const float c_lower_point_y= -sin(18.0 * c_deg_to_rad) / cos(36.0 * c_deg_to_rad);
	const float c_middle_point_y= -c_lower_point_y * sin( 54.0 * c_deg_to_rad );
	const float tan72= tan( 72.0 * c_deg_to_rad );
	const float tan36= tan( 36.0 * c_deg_to_rad );
	const float inv_cos_72= 1.0 / cos( 72.0 * c_deg_to_rad );
	const float inv_cos_36= 1.0 / cos( 36.0 * c_deg_to_rad );

	float triangle0=
		smoothstep( coord.y - delta * inv_cos_72, coord.y + delta * inv_cos_72, c_upper_point_y - coord.x * tan72 ) *
		( 1.0 - smoothstep( coord.y - delta * inv_cos_36, coord.y + delta * inv_cos_36, c_lower_point_y - coord.x * tan36 ) );

	float trianlge1=
		smoothstep( coord.y - delta, coord.y + delta, c_middle_point_y ) *
		( 1.0 - smoothstep( coord.y - delta * inv_cos_36, coord.y + delta * inv_cos_36, coord.x * tan36 + c_lower_point_y ) );

	return min( 1.0, triangle0 + trianlge1 );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 red= vec3( 0.824, 0.063, 0.204 );
	vec3 blue= vec3( 0.0, 0.322, 0.576 );
	vec3 white= vec3( 1.0, 1.0, 1.0 );

	const float c_star_size= 3.5;
	const vec2 c_star_shift= vec2( -0.75, 0.5 );
	const float c_flag_aspect_ratio= 1.5;

	float delta= 2.0 / iResolution.y;
	vec2 coord= 2.0 * ( fragCoord - 0.5 * iResolution.xy ) / iResolution.y;
	float sign_x= sign(coord.x);
	vec2 star_coord= coord + c_star_shift * sign_x;

	float star_factor= Star( star_coord * c_star_size , delta * c_star_size );
	float side_factor= step( 0.0, coord.x );
	float flip_factor= step( 0.0, coord.y * sign_x );

	vec3 color= mix( blue, red, side_factor );
	color= mix( white, color, flip_factor + star_factor );

	color*=
		step( abs(coord.x), c_flag_aspect_ratio ) *
		step( abs(coord.y), 1.0 );

	fragColor= vec4( color, 1.0 );
}
