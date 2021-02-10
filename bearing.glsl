void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float two_pi= 2.0 * 3.1415926535;

	float pix_size= 2.2 / min(iResolution.x, iResolution.y);
	vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;
	float angle= atan( coord.x, coord.y ) / two_pi + 0.5;
	float radius= length(coord);
	float inv_radius= 1.0 / max(radius, 0.001);
	float pix_size_r= pix_size * inv_radius / two_pi;

	// Inputs
	const float inner_circle_inner_radius= 0.5;
	const float inner_circle_outer_radius= 0.6;
	const float outer_circle_inner_radius= 0.9;
	const float outer_circle_outer_radius= 1.0;
	const float inner_circle_angular_speed= 0.015;
	const float outer_circle_angular_speed= -0.025;
	const float tooth_size= 0.03;

	// Dependent constants
	const float ball_offset= 0.5 * ( inner_circle_outer_radius + outer_circle_inner_radius );
	const float ball_radius= 0.5 * ( outer_circle_inner_radius - inner_circle_outer_radius );
	const float ball_count= floor( ball_offset * two_pi / ( 2.0 * ball_radius ) );

	const float inner_circle_linear_speed= inner_circle_angular_speed * inner_circle_outer_radius;
	const float outer_circle_linear_speed= outer_circle_angular_speed * outer_circle_inner_radius;
	const float ball_rotation_angular_speed= 0.5 * ( outer_circle_linear_speed - inner_circle_linear_speed) / ball_radius;

	const float ball_movement_angular_speed= -0.5 * ( outer_circle_linear_speed + inner_circle_linear_speed) / ball_offset;

	const float inner_circle_tooths= ceil(inner_circle_outer_radius / tooth_size);
	const float outer_circle_tooths= ceil(outer_circle_inner_radius / tooth_size);
	const float ball_tooths= ceil(ball_radius / tooth_size);

	// Non-constants
	float ball_angle_shift= ball_movement_angular_speed * iTime;
	float ball_sector_angle= ball_angle_shift + floor( fract( angle - ball_angle_shift + 0.5 / ball_count ) * ball_count ) / ball_count;
	vec2 ball_coord= coord + ball_offset * vec2( sin(ball_sector_angle * two_pi), cos(ball_sector_angle * two_pi) );

	float ball_factor= step( dot( ball_coord, ball_coord ), ball_radius * ball_radius );
	float ball_angle= atan( ball_coord.x, ball_coord.y ) / two_pi;
	float ball_tex= fract( ( ball_angle + iTime * ball_rotation_angular_speed ) * ball_tooths );

	float inner_cicle_factor= step( inner_circle_inner_radius, radius ) * step( radius, inner_circle_outer_radius );
	float outer_cicle_factor= step( outer_circle_inner_radius, radius ) * step( radius, outer_circle_outer_radius );
	float inner_circle_tex= fract( ( angle + iTime * inner_circle_angular_speed ) * inner_circle_tooths );
	float outer_circle_tex= fract( ( angle + iTime * outer_circle_angular_speed ) * outer_circle_tooths );

	fragColor= vec4( inner_cicle_factor * inner_circle_tex, outer_cicle_factor * outer_circle_tex, ball_factor * ball_tex, 1.0 );
}