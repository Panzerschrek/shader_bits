const float tau= 2.0 * 3.1415926535;
const int ss_factor= 3;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float pix_size= 3.0 / min(iResolution.x, iResolution.y);


	vec4 c= vec4( 0.0 );
	for( int dx= 0; dx < ss_factor; ++dx )
	for( int dy= 0; dy < ss_factor; ++dy )
	{
		vec2 coord= ( fragCoord.xy + vec2( float(dx), float(dy) ) / float(ss_factor) ) * pix_size ;
		vec2 coord_fract= fract(coord);

		vec2 center_bottom= vec2( 0.5, 0.0 );
		vec2 center_top= vec2( 0.5, 1.0 );
		vec2 center_left= vec2( 0.0, 0.5 );
		vec2 center_right= vec2( 1.0, 0.5 );
		vec2 vec_bottom = coord_fract - center_bottom;
		vec2 vec_top= coord_fract - center_top;
		vec2 vec_left= coord_fract - center_left;
		vec2 vec_right= coord_fract - center_right;
		float dist2_bottom= dot( vec_bottom, vec_bottom );
		float dist2_top= dot( vec_top, vec_top );
		float dist2_left= dot( vec_left, vec_left );
		float dist2_right= dot( vec_right, vec_right );

		float radius2= 0.25;
		vec2 grid_offset;
		if( dist2_bottom < radius2 )
		{
			grid_offset= vec2( 0.0, 0.0 );
		}
		else if( dist2_left < radius2 )
		{
			grid_offset= vec2( -0.5, 0.5 );
		}
		else if( dist2_right < radius2 )
		{
			grid_offset= vec2( +0.5, 0.5 );
		}
		else
		{
			grid_offset= vec2( 0.0, 1.0 );
		}

		vec2 circle_vec= ( coord_fract - grid_offset - vec2( 0.5, -0.0 ) ) * 2.0;
		float circle_vec_length= length(circle_vec);
		float circle_vec_angle= atan( circle_vec.y, circle_vec.x );
		float num_rings= 6.0;
		float ring_dist= circle_vec_length * num_rings;
		float circle_vec_fract= fract( ring_dist );
		float circle_factor= step( circle_vec_fract, 0.8 );
		float num_spikes= 2.0 + 5.0 * floor(ring_dist);
		float phase= floor(ring_dist) * 0.125;
		float angle_split= fract( (circle_vec_angle / tau + phase ) * num_spikes );
		float gap_size= 0.03 * floor(ring_dist) / circle_vec_length;
		float radial_factor= step( gap_size, angle_split );

		float mortar_factor= 1.0 - circle_factor * radial_factor;

		vec2 tc_global= (floor(coord) + grid_offset) * 2.0;
		vec4 tex_color= textureLod( iChannel0, tc_global / 64.0, 0.0 );

		c+= vec4( mix( tex_color.rgb, vec3( 0.1, 0.1, 0.12 ), mortar_factor ), 1.0 );
	}
	fragColor = c / float( ss_factor * ss_factor );
}