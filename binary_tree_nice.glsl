const float pi= 3.1415926535;

const int ss_factor= 4;
const int c_iterations= 20;

const float branch_width= 0.15;

vec3 MakeTree( vec2 coord, mat3 transform_mat_left, mat3 transform_mat_right )
{
	float depth= 0.0;

	for( int i= 0; i < c_iterations; ++i )
	{
		if(coord.y >= -1.0 && coord.y <= 1.0 && coord.x >= -branch_width && coord.x <= branch_width )
		{
			depth= float(i + 1) / float(c_iterations);
			break;
		}

		if(coord.x >= 0.0 )
			coord= (transform_mat_left * vec3(coord, 1.0)).xy;
		else
			coord= (transform_mat_right * vec3(coord, 1.0)).xy;
	}

	return
		step( 0.01, depth ) *
		vec3(
			sin(depth * (64.0 /  7.0) + iTime * ( 4.0 / 13.0 )) * 0.5 + 0.5,
			sin(depth * (64.0 / 11.0) + iTime * ( 4.0 / 11.0 )) * 0.5 + 0.5,
			sin(depth * (64.0 / 13.0) + iTime * ( 4.0 /  7.0 )) * 0.5 + 0.5 );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float scale_phase= iTime * 0.666;
	float rot_angle_phase= iTime * 0.5;

	const float scale_base= 2.0 / (sqrt(5.0) - 1.0); // Golden ratio
	float scale_left = scale_base * (sin(scale_phase) * 0.03 + 1.03);
	float scale_right= scale_base * (cos(scale_phase) * 0.03 + 1.03);

	mat3 scale_mat_left = mat3(vec3(scale_left , 0.0, 0.0), vec3(0.0, scale_left , 0.0), vec3(0.0, 0.0, scale_left ));
	mat3 scale_mat_right= mat3(vec3(scale_right, 0.0, 0.0), vec3(0.0, scale_right, 0.0), vec3(0.0, 0.0, scale_right));

	float rot_angle_left =  pi / 3.0 * (sin(rot_angle_phase) * 0.1 + 1.1);
	float rot_angle_right= -pi / 3.0 * (cos(rot_angle_phase) * 0.1 + 1.1);

	mat3 shift_mat_left = mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(-sin(rot_angle_left ) / scale_left , -1.0 - cos(rot_angle_left ) / scale_left , 0.0));
	mat3 shift_mat_right= mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(-sin(rot_angle_right) / scale_right, -1.0 - cos(rot_angle_right) / scale_right, 0.0));

	mat3 rot_mat_left = mat3(vec3(cos(rot_angle_left ), sin(rot_angle_left ), 0.0), vec3(-sin(rot_angle_left ), cos(rot_angle_left ), 0.0), vec3(0.0, 0.0, 1.0));
	mat3 rot_mat_right= mat3(vec3(cos(rot_angle_right), sin(rot_angle_right), 0.0), vec3(-sin(rot_angle_right), cos(rot_angle_right), 0.0), vec3(0.0, 0.0, 1.0));

	mat3 transform_mat_left = scale_mat_left  * rot_mat_left *  shift_mat_left ;
	mat3 transform_mat_right= scale_mat_right * rot_mat_right * shift_mat_right;

	vec2 coord_base= fragCoord.xy - iResolution.xy * 0.5;
	float coord_scale= 8.0 / max( iResolution.x, iResolution.y );
	vec3 c= vec3( 0.0 );
	for( int dx= 0; dx < ss_factor; ++dx )
	for( int dy= 0; dy < ss_factor; ++dy )
	{
		vec2 ss_offset= vec2( float(dx), float(dy) ) / float(ss_factor);
		vec2 coord= ( coord_base + ss_offset ) * coord_scale;
		coord.y+= 1.2;

		c+= MakeTree( coord, transform_mat_left, transform_mat_right );
	}


	fragColor= vec4( c / float(ss_factor * ss_factor), 1.0 );
}