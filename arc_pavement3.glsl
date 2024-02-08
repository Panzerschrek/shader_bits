const float tau= 2.0 * 3.1415926535;
const int ss_factor= 2;
const float num_rings= 7.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 c= vec3( 0.0 );
	for( int dx= 0; dx < ss_factor; ++dx )
	for( int dy= 0; dy < ss_factor; ++dy )
	{
		vec2 ss_offset= vec2( float(dx), float(dy) ) / float(ss_factor);
		vec2 coord= (4.0 * vec2( 1.0, 2.0 ) ) * ( fragCoord.xy + ss_offset ) / max( iResolution.x, iResolution.y );
		vec2 coord_fract= fract(coord) * vec2( 1.0, 0.5 );

		vec2 center_bottom= vec2( 0.5, -0.25 );
		vec2 center_top= vec2( 0.5, 0.25 );
		vec2 center_left= vec2( 0.0, 0.0 );
		vec2 center_right= vec2( 1.0, 0.0 );
		vec2 center_left_top= vec2( 0.0, 0.5 );
		vec2 center_right_top= vec2( 1.0, 0.5 );
		vec2 vec_bottom = coord_fract - center_bottom;
		vec2 vec_top= coord_fract - center_top;
		vec2 vec_left= coord_fract - center_left;
		vec2 vec_right= coord_fract - center_right;
		vec2 vec_left_top= coord_fract - center_left_top;
		vec2 vec_right_top= coord_fract - center_right_top;
		float dist2_bottom= dot( vec_bottom, vec_bottom );
		float dist2_top= dot( vec_top, vec_top );
		float dist2_left= dot( vec_left, vec_left );
		float dist2_right= dot( vec_right, vec_right );
		float dist2_left_top= dot( vec_left_top, vec_left_top );
		float dist2_right_top= dot( vec_right_top, vec_right_top );

		float radius2= 0.25;
		vec2 grid_offset;
		if( dist2_bottom < radius2 )
		{
			grid_offset= vec2( 0.0, -0.25 );
		}
		else if( dist2_left < radius2 )
		{
			grid_offset= vec2( -0.5, 0.0 );
		}
		else if( dist2_right < radius2 )
		{
			grid_offset= vec2( +0.5, 0.0 );
		}
		else if( dist2_top < radius2 )
		{
			grid_offset= vec2( 0.0, 0.25 );
		}
		else if( dist2_left_top < radius2 )
		{
			grid_offset= vec2( -0.5, 0.5 );
		}
		else// if( dist2_right_top < radius2 )
		{
			grid_offset= vec2( +0.5, 0.5 );
		}

		vec2 circle_vec= ( coord_fract - grid_offset - vec2( 0.5, -0.0 ) ) * 2.0;
		float circle_vec_length= length(circle_vec);
		float circle_vec_angle= atan( circle_vec.x, circle_vec.y );
		float ring_dist= circle_vec_length * num_rings;
		float circle_vec_fract= fract( ring_dist );
		float circle_factor= step( circle_vec_fract, 0.85 );
		float num_spikes= 2.0 + 6.0 * floor(ring_dist);
		float phase= floor(ring_dist) * 0.125;
		float angle_split= fract( (circle_vec_angle / tau + phase ) * num_spikes );
		float gap_size= 0.02 * floor(ring_dist) / circle_vec_length;
		float radial_factor= step( gap_size, angle_split );

		float mortar_factor= 1.0 - circle_factor * radial_factor;

		vec2 tc_global= (floor(coord) + grid_offset * vec2( 1.0, 2.0 )) * 1.0 + vec2( 0.5, 0.5 );
		vec4 tex_color= textureLod( iChannel0, tc_global / 64.0, 0.0 );

		float tex_brightness= dot( tex_color.rgb, vec3( 0.299, 0.587, 0.114 ) );
		vec3 tex_color_desaturated= mix( vec3( tex_brightness ), tex_color.rgb, 0.5 );

		c+= mix( tex_color_desaturated, vec3( 0.1, 0.1, 0.12 ), mortar_factor );
	}
	fragColor = vec4( c / float( ss_factor * ss_factor ), 1.0 );
}
