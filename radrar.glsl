void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float two_pi= 2.0 * 3.1415926535;

	float pix_size= 2.2 / min(iResolution.x, iResolution.y);
	vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;
	float angle= atan( coord.y, coord.x ) / two_pi + 0.5;
	float square_radius= dot( coord, coord );
	float radius= sqrt(square_radius);
	float inv_radius= 1.0 / max(radius, 0.001);
	float pix_size_r= pix_size * inv_radius / two_pi;
	float pix_size_r72= pix_size_r * 72.0;

	float angle_speed= 0.5;
	float phase= iTime * angle_speed;
	float beam_angle= fract( - angle - phase );
	float radar_start_factor= 1.0 - smoothstep( 0.5, 0.5 + 2.0 * pix_size_r, beam_angle );
	float radar_beam_end_factor= smoothstep( 0.45, 0.5, beam_angle );
	float radar_target_end_factor= smoothstep( 0.0, 0.5, beam_angle );
	float radar_beam_factor= radar_start_factor * radar_beam_end_factor;

	float sector12= fract( angle * 12.0 + 0.5 );
	float sector72= fract( angle * 72.0 + 0.5 );

	float sector_factor_12= step( 0.5 - 1.0 / 12.0, sector12 ) * step( sector12, 0.5 + 1.0 / 12.0 );

	float half_mark_width= 0.05 * inv_radius;
	float mark_factor= 1.0 - smoothstep( 0.02, 0.1, abs(sector72 - 0.5) );
	mark_factor*= smoothstep( 0.89,  0.91, radius );

	float circles_factor= 1.0 - smoothstep( 0.0, 0.05, abs( fract( 0.5 + radius * 5.0 ) - 0.5 ) );
	float sector_factor= 1.0 - smoothstep( 0.0, 0.02 / radius, abs( sector12 - 0.5 ) );
	float grid_factor= circles_factor + sector_factor;

	const vec2 target_start_pos= vec2( -0.8, 0.9 );
	const vec2 target_velocity= vec2( 0.05, -0.04 );
	vec2 target_pos= target_start_pos + target_velocity * iTime;

	vec2 vec_to_target= target_pos - coord;
	float target_square_distance= dot( vec_to_target, vec_to_target );
	float target_factor= 1.0 - smoothstep( 0.0, 0.0008, target_square_distance );

	target_factor*= radar_target_end_factor * radar_start_factor;

	float inner_circle= smoothstep( 0.97 - pix_size, 0.97 + pix_size, radius );
	float outer_circle= smoothstep( 1.0 - pix_size, 1.0 + pix_size, radius );

	const vec2 flare_pos= vec2( 0.3, 0.6 );
	float flare_factor= 1.0 - smoothstep( 0.0, 2.0, distance( flare_pos, coord ) );
	flare_factor= pow( flare_factor, 7.0 );

	const vec3 display_color= vec3( 0.1, 0.1, 0.1 );
	const vec3 flare_color= vec3( 0.3, 0.3, 0.3 );
	const vec3 beam_color= vec3( 0.1, 0.8, 0.1 );
	const vec3 target_color= beam_color;
	const vec3 grid_color= vec3( 0.01, 0.1, 0.01 );
	const vec3 marks_color= vec3( 0.01, 0.1, 0.01 );
	const vec3 outer_color= vec3( 0.3, 0.3, 0.3 );
	const vec3 framing_color= vec3( 0.5, 0.5, 0.5 );

	vec3 internal_color=
		display_color +
		flare_color * flare_factor +
		grid_color * grid_factor +
		marks_color * mark_factor +
		beam_color * radar_beam_factor +
		target_color * target_factor;

	vec3 framing_color_corrected= framing_color * ( 1.0 - smoothstep( 0.0, 0.03, abs( radius - 0.985 ) ) );

	vec3 result_color= mix( internal_color, framing_color_corrected + flare_color * flare_factor, inner_circle );
	result_color= mix( result_color, outer_color, outer_circle );

	fragColor = vec4( result_color, 1.0);
}