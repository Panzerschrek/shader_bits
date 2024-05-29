const int ss_factor= 4;

const int c_iterations= 10;

const float branch_width= 0.1;
const float center_branch_width= branch_width / (2.0 * sqrt(2.0));

vec3 MakeTree( vec2 coord, mat3 transform_mat_left, mat3 transform_mat_right, mat3 transform_mat_center )
{
	float branch_factor= 0.0;
	float depth= 0.0;
	for( int i= 0; i < c_iterations; ++i )
	{
		if( coord.y + coord.x < 0.0 || coord.y - coord.x < 0.0 )
			break;

		if( coord.y + coord.x > 0.5 )
		{
			coord= (transform_mat_right * vec3(coord, 1.0)).xy;
			depth+= 1.1;
		}
		else if( coord.y - coord.x > 0.5 )
		{
			coord= (transform_mat_left * vec3(coord, 1.0)).xy;
			depth+= 0.9;
		}
		else
		{
			float inclination= 1.0 - 2.0 * branch_width;
			if( coord.y + coord.x * inclination < branch_width || coord.y - coord.x * inclination < branch_width )
				branch_factor= 1.0;

			float vertical_inclination= branch_width;
			if( coord.y < 0.25 + branch_width * 0.25 &&
				coord.x + coord.y * vertical_inclination < center_branch_width &&
				coord.x - coord.y * vertical_inclination > -center_branch_width)
				branch_factor= 1.0;

			if( coord.y + coord.x > 0.25 && coord.y - coord.x > 0.25 )
			{
				coord= (transform_mat_center * vec3(coord, 1.0)).xy;
				depth+= 2.1;
			}
			else
				break;
		}
	}

	return
		branch_factor *
			vec3(
				sin(depth * (64.0 /  7.0) + iTime * ( 4.0 / 13.0 )) * 0.5 + 0.5,
				sin(depth * (64.0 / 11.0) + iTime * ( 4.0 / 11.0 )) * 0.5 + 0.5,
				sin(depth * (64.0 / 13.0) + iTime * ( 4.0 /  7.0 )) * 0.5 + 0.5 );

}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float scale_phase= iTime * 0.666;

	float scale_left = 2.0 * (sin(scale_phase) * 0.05 + 1.0);
	float scale_right= 2.0 * (cos(scale_phase) * 0.05 + 1.0);

	mat3 scale_mat_left  = mat3(scale_left );
	mat3 scale_mat_right = mat3(scale_right);
	mat3 scale_mat_center= mat3(scale_left * scale_right);

	const mat3 shift_mat_left  = mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(+0.25, -0.25, 0.0));
	const mat3 shift_mat_right = mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(-0.25, -0.25, 0.0));
	const mat3 shift_mat_center= mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(  0.0, -0.25, 0.0));

	mat3 transform_mat_left  = scale_mat_left   * shift_mat_left  ;
	mat3 transform_mat_right = scale_mat_right  * shift_mat_right ;
	mat3 transform_mat_center= scale_mat_center * shift_mat_center;

	vec2 coord_base= fragCoord.xy - iResolution.xy * 0.5;
	float coord_scale= 1.1 / max( iResolution.x, iResolution.y );
	vec3 c= vec3( 0.0 );
	for( int dx= 0; dx < ss_factor; ++dx )
	for( int dy= 0; dy < ss_factor; ++dy )
	{
		vec2 ss_offset= vec2( float(dx), float(dy) ) / float(ss_factor);
		vec2 coord= ( coord_base + ss_offset ) * coord_scale;
		coord.y+= 0.3;

		c+= MakeTree( coord, transform_mat_left, transform_mat_right, transform_mat_center );
	}

	fragColor = vec4(c / float(ss_factor * ss_factor), 1.0);
}