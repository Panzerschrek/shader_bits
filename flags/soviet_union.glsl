const float c_two_pi= 2.0 * 3.1415926535;
const float c_deg_to_rad= c_two_pi / 360.0;

float Sickle( vec2 coord, float delta )
{
	const float c_cut_angle= 0.27;
	const float c_handle_start_angle= 0.24;
	const float c_handle_end_angle= 0.26;

	coord*= vec2( 0.9, 1.0 );
	const float c_circle0_radius= 1.0;
	const float c_circle1_radius= 0.9;
	const float c_circle1_shift= 0.15;
	const float c_handle_inner_radius= 0.8;
	const float c_handle_outer_radius= 1.4;

	float r0= length( coord );
	float r1= length( coord + vec2( c_circle1_shift, 0.0 ) );

	float blade_factor=
	   smoothstep( c_circle1_radius - delta, c_circle1_radius + delta, r1 ) *
	   ( 1.0 - smoothstep( c_circle0_radius - delta, c_circle0_radius + delta, r0 ) );

	float angle_normalized= atan( -coord.y, coord.x ) / c_two_pi;
	float radial_delta= delta / c_two_pi;
	blade_factor*= 1.0 - smoothstep( c_cut_angle - radial_delta, c_cut_angle + radial_delta, angle_normalized );


	radial_delta*= ( c_handle_inner_radius + c_handle_outer_radius ) * 0.5;
	float handle_factor=
		smoothstep( c_handle_start_angle - radial_delta, c_handle_start_angle + radial_delta, angle_normalized ) *
		( 1.0 - smoothstep( c_handle_end_angle - radial_delta, c_handle_end_angle + radial_delta, angle_normalized ) ) *
		smoothstep( c_handle_inner_radius - delta, c_handle_inner_radius + delta, r0 ) *
		( 1.0 - smoothstep( c_handle_outer_radius - delta, c_handle_outer_radius + delta, r0 ) );

	return min( 1.0, blade_factor + handle_factor );
}

float Hammer( vec2 coord, float delta )
{
	float abs_x= abs(coord.x);

	float handle_factor=
		1.0 - smoothstep( 0.125 - delta, 0.125 + delta, abs_x );

	float head_factor=
		smoothstep( 0.5 - delta, 0.5 + delta, coord.y ) *
		( 1.0 - smoothstep( 0.5 - delta, 0.5 + delta, abs_x ) ) *
		smoothstep( coord.y - delta, coord.y + delta, 1.25 - coord.x );

	float cut_factor=
	   smoothstep( -1.0 - delta, -1.0 + delta, coord.y ) *
	   ( 1.0 - smoothstep( 1.0 - delta, 1.0 + delta, coord.y ) );

	return min( 1.0, ( handle_factor + head_factor ) * cut_factor );
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
	float c_sickle_angle= -0.7;
	const float c_hammer_angle= c_two_pi / 8.0;

	const float c_star_inner_size= 0.07;
	const float c_star_outer_size= 0.1;
	const float c_sickle_size= 1.0 / 10.0;
	const float c_hammer_size= 1.0 / 10.0;
	const float c_circle_radius= 1.1;
	const vec2 c_hammer_sift= vec2( 0.0, 0.3 );
	const vec2 c_cross_shift= vec2( 0.3, 0.65 );
	const vec2 c_star_shift= vec2( 0.3, 0.85 );

	const vec3 red= vec3( 0.737, 0.0, 0.0 );
	const vec3 yellow= vec3( 0.988, 0.82, 0.086 );

	vec2 coord= fragCoord.xy / iResolution.y;
	float delta= 1.0 / iResolution.y;

	float cross_factor;
	{
	   vec2 cross_coord= coord - c_cross_shift;

		vec2 sickle_coord= cross_coord.y * vec2( sin(c_sickle_angle), cos(c_sickle_angle) ) + cross_coord.x * vec2( cos(c_sickle_angle), -sin(c_sickle_angle) );
		vec2 hammer_coord= cross_coord.y * vec2( sin(c_hammer_angle), cos(c_hammer_angle) ) + cross_coord.x * vec2( cos(c_hammer_angle), -sin(c_hammer_angle) );


		float sickle_factor= Sickle( sickle_coord / c_sickle_size, delta / c_sickle_size );
		float hammer_factor= Hammer( hammer_coord / c_hammer_size + c_hammer_sift, delta / c_hammer_size );
		cross_factor= min( 1.0, sickle_factor + hammer_factor );
	}

	float star_factor;
	{
		vec2 star_coord= coord - c_star_shift;
		star_factor= Star( star_coord / c_star_outer_size, delta / c_star_outer_size ) - Star( star_coord / c_star_inner_size, delta / c_star_inner_size );
	}

	vec3 color= mix( red, yellow, cross_factor + star_factor );
	fragColor= vec4(color, 1.0);
}
