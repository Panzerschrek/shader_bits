const float c_deg_to_rad= 3.1415926535 / 180.0;

float Moon( vec2 coord, float delta )
{
	const float c_outer_radius= 1.0;
	const float c_inner_radius= 0.8;
	const float c_shift= -0.25;
	float r0= length(coord);
	float r1= length( coord + vec2( c_shift, 0.0 ) );

	return
		( 1.0 - smoothstep( c_outer_radius - delta, c_outer_radius + delta, r0 ) ) *
		( 1.0 - smoothstep( c_inner_radius + delta, c_inner_radius - delta, r1 ) );
}

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
	const float c_moon_size= 0.5;
	const float c_star_size= 0.25;
	const float c_star_center_shift= - 15.0 / 24.0;
	const float c_base_shift= 1.0 / 2.0;

	const vec3 red= vec3( 0.89, 0.036, 0.09 );
	const vec3 white= vec3( 1.0, 1.0, 1.0 );

	float delta= 2.0 / iResolution.y;
	vec2 coord= 2.0 * ( fragCoord - 0.5 * iResolution.xy ) / min( iResolution.x, iResolution.y );
	coord.x+= c_base_shift;

	float moon_factor= Moon(coord / c_moon_size, delta / c_moon_size );
	float star_factor=
	   Star(
		 ( coord + vec2( c_star_center_shift, 0.0 ) ).yx / (-c_star_size),
		 delta / c_star_size );

	vec3 color= mix( red, white, min( moon_factor + star_factor, 1.0 ) );

	fragColor= vec4( color, 1.0 );
}
