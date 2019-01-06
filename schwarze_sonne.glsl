void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float two_pi= 2.0 * 3.1415926535;
	const float c_outer_circle_radius= 1.0;
	const float c_outer_circle_width= 0.08;

	const float c_inner_circle_radius= 0.4;
	const float c_inner_circle_width= 0.08;

	const int c_spokes= 12;
	const float c_spoke_width= float(c_spokes) / 150.0;

	const float c_middle_circle_radius= 0.75;
	const float c_middle_circle_width= 0.08;

	const float c_outer_spikes_shift= 0.5;

	const float c_rotation_period= 48.0;

	float pix_size=  2.2 / min(iResolution.x, iResolution.y);
	float pix_size_r= pix_size * float(c_spokes) / two_pi;
	vec2 coord= (fragCoord - 0.5 * iResolution.xy) * pix_size;
	float square_radius= dot( coord, coord );
	float radius= sqrt(square_radius);
	float angle_normalized= fract( atan( coord.y, coord.x ) / two_pi + iTime / c_rotation_period );

	float outer_circle=
		smoothstep( c_outer_circle_radius - c_outer_circle_width, c_outer_circle_radius - c_outer_circle_width + pix_size, radius ) *
		( 1.0 - smoothstep( c_outer_circle_radius, c_outer_circle_radius + pix_size, radius ) );

	float inner_circle=
		smoothstep( c_inner_circle_radius - c_inner_circle_width, c_inner_circle_radius - c_inner_circle_width + pix_size, radius ) *
		( 1.0 - smoothstep( c_inner_circle_radius, c_inner_circle_radius + pix_size, radius ) );

	float spoke_coord= fract( float(c_spokes) * angle_normalized );
	float spoke_coord_shifted= fract( spoke_coord + c_outer_spikes_shift * step( c_middle_circle_radius, radius ) );
	float spoke_factor=
		smoothstep( 0.5 - c_spoke_width / radius, 0.5 - c_spoke_width / radius + pix_size_r / radius, spoke_coord_shifted ) *
		( 1.0 - smoothstep( 0.5 + c_spoke_width / radius, 0.5 + c_spoke_width / radius + pix_size_r / radius, spoke_coord_shifted ) );

	spoke_factor*= 1.0 - step( c_outer_circle_radius, radius );

	float middle_circle=
		smoothstep( c_middle_circle_radius - c_middle_circle_width, c_middle_circle_radius - c_middle_circle_width + pix_size, radius ) *
		( 1.0 - smoothstep( c_middle_circle_radius, c_middle_circle_radius + pix_size, radius ) );

	float middle_circle_cut=
		smoothstep( 0.5 + c_spoke_width / radius, 0.5 + c_spoke_width / radius + pix_size_r / radius, spoke_coord ) *
		( 1.0 - smoothstep( 0.5 + 1.0 - c_outer_spikes_shift - c_spoke_width / radius, 0.5 + 1.0 - c_outer_spikes_shift - c_spoke_width / radius + pix_size_r / radius, spoke_coord ) );
	middle_circle *= 1.0 - middle_circle_cut;

	float sonne= min( 1.0, outer_circle + inner_circle + spoke_factor + middle_circle );
	fragColor= vec4( 1.0 - sonne );
}
