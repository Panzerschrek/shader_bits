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
	const vec3 red= vec3( 0.698, 0.132, 0.203 );
	const vec3 white= vec3( 1.0, 1.0, 1.0 );
	const vec3 blue= vec3( 0.234, 0.233, 0.430 );

	const float c_flag_aspect= 1.9;
	const float c_blue_rectangle_ralative_width= 0.4;
	const float c_blue_rectangle_relative_height= 6.0 / 13.0;

	const float c_star_row_height= ( 1.0 - c_blue_rectangle_relative_height ) / 10.0;
	const float c_star_column_width= c_blue_rectangle_ralative_width / 12.0;
	const vec2 c_star_scale= 1.9 * vec2( 1.0, c_star_row_height / c_star_column_width / c_flag_aspect );

	float delta= 1.0 / iResolution.y;
	vec2 coord= fragCoord  / min( iResolution.x, iResolution.y );
	float width_scale= c_flag_aspect * iResolution.y / min( iResolution.x, iResolution.y );

	float strip_number= fract( coord.y * 0.5 * 13.0 + 0.75 );
	float delta_scaled= delta * 0.25 * 13.0;
	float strip_factor=
		smoothstep( 0.25 - delta_scaled, 0.25 + delta_scaled, strip_number ) *
		( 1.0 - smoothstep( 0.75 - delta_scaled, 0.75 + delta_scaled, strip_number ) );

	vec3 color= mix( red, white, strip_factor );

	float blue_rectangle_factor=
		( 1.0 - smoothstep( c_blue_rectangle_ralative_width * width_scale - delta, c_blue_rectangle_ralative_width * width_scale + delta, coord.x ) ) *
		smoothstep( c_blue_rectangle_relative_height - delta, c_blue_rectangle_relative_height + delta, coord.y );

	color= mix( color, blue, blue_rectangle_factor );

	if( blue_rectangle_factor >= 0.99 )
	{
		float stars_column= coord.x / ( c_star_column_width * width_scale  );
		float stars_row= (coord.y - c_blue_rectangle_relative_height) / c_star_row_height;

		float column_i= floor(stars_column);
		float row_i= floor(stars_row);

		float column_coord= fract(stars_column);
		float row_coord= fract(stars_row);

		float left_edge_factor= step( 0.5, column_i );
		float right_edge_factor= step( column_i, 10.5 );
		float lower_edge_factor= step( 0.5, row_i );
		float upper_edge_factor= step( row_i, 8.5 );

		float star_delta= delta * 20.0;
		float star_factor;
		if( ( int( column_i + row_i ) & 1 ) == 0 )
			star_factor=
				Star( vec2( column_coord - 1.0, row_coord - 1.0 ) * c_star_scale, star_delta ) * right_edge_factor * upper_edge_factor +
				Star( vec2( column_coord - 0.0, row_coord - 0.0 ) * c_star_scale, star_delta ) * left_edge_factor  * lower_edge_factor;
		else
			star_factor=
				Star( vec2( column_coord - 0.0, row_coord - 1.0 ) * c_star_scale, star_delta ) * left_edge_factor  * upper_edge_factor +
				Star( vec2( column_coord - 1.0, row_coord - 0.0 ) * c_star_scale, star_delta ) * right_edge_factor * lower_edge_factor;

		color= mix( color, white, star_factor );
	}

	fragColor= vec4( color, 1.0 );
}
