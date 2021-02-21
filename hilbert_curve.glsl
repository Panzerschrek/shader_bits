void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float pix_size= 2.0 / min(iResolution.x, iResolution.y);
	vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;

	float b= 0.0;
	int max_iterations= 5;
	float base_width= 0.25 / exp2( float(max_iterations) );
	int dist= (1 << (max_iterations * 2)) - 1;
	float t= 32.0 * iTime;
	for( int i= 0; i < max_iterations; ++i )
	{
		float bar_width= exp2( float(i) ) * base_width;

		float bar_offset= exp2( -float(max_iterations - i) );
		float bar_half_length= bar_offset;
		float horizontal_bar_pos= -bar_offset;
		float left_bar_pos = -1.0 + bar_offset;
		float right_bar_pos= +1.0 - bar_offset;

		float horizontal_bar= step( horizontal_bar_pos - bar_width, coord.y ) * step( coord.y, horizontal_bar_pos + bar_width ) * step( -bar_half_length, coord.x ) * step( coord.x, +bar_half_length );

		float vertical_bar_cut= step( -bar_half_length - bar_width, coord.y ) * step( coord.y, bar_half_length + bar_width );
		float left_bar = vertical_bar_cut * step( left_bar_pos  - bar_width, coord.x ) * step( coord.x, left_bar_pos  + bar_width );
		float right_bar= vertical_bar_cut * step( right_bar_pos - bar_width, coord.x ) * step( coord.x, right_bar_pos + bar_width );
 
		int half_delta= 1 << (max_iterations * 2 - i * 2 - 2);
		int delta= half_delta << 1;
		float dist_horizontal= float(dist);
		float dist_left = float(dist - delta);
		float dist_right= float(dist + delta);

		b+= horizontal_bar * step( dist_horizontal, t );
		b+= left_bar  * step( dist_left , t );
		b+= right_bar * step( dist_right, t );

		if( coord.x > 0.0 && coord.y > 0.0 )
		{
			coord= coord * 2.0 + vec2( -1.0, -1.0 );
			coord= vec2( coord.y, +coord.x );
			dist+= 3 * half_delta;
		}
		else if( coord.x < 0.0 && coord.y > 0.0 )
		{
			coord= coord * 2.0 + vec2( +1.0, -1.0 );
			coord= vec2( -coord.y, -coord.x );
			dist-= 3 * half_delta;
		}
		else if( coord.x > 0.0 && coord.y < 0.0 )
		{
			coord= coord * 2.0 + vec2( -1.0, +1.0 );
			dist+= half_delta;
		}
		else //if( coord.x < 0.0 && coord.y < 0.0 )
		{
			coord= coord * 2.0 + vec2( +1.0, +1.0 );
			dist-= half_delta;
		}
	}

	fragColor = vec4( b, b, b, 1.0);
}