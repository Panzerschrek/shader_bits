const float c_deg_to_rad= 3.1415926535 / 180.0;

float Star( vec2 coord, float delta )
{
	if( dot( coord, coord ) > 1.0 )
		return 0.0;

	coord.x= abs(coord.x);

	const float c_upper_point_y= 1.0;
	const float c_lower_point_y=  -sin(22.5 * c_deg_to_rad);
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
