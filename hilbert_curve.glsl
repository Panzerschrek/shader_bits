void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float pix_size= 2.0 / min(iResolution.x, iResolution.y);
	vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;

	float b= 0.0;
	int max_iterations= min( 7, int( 1.0 + iTime * 0.5 ) );
	float base_width= 0.2 / exp2( float(max_iterations) );
	for( int i= 0; i < max_iterations; ++i )
	{
		float bar_width= exp2( float(i) ) * base_width;

		float bar_offset= exp2( -float(max_iterations - i) );
		float bar_half_length= bar_offset;
		float horizontal_bar_pos= -bar_offset;
		float left_bar_pos = -1.0 + bar_offset;
		float right_bar_pos= +1.0 - bar_offset;

		float horizontal_bar= step( horizontal_bar_pos - bar_width, coord.y ) * step( coord.y, horizontal_bar_pos + bar_width ) * step( -bar_half_length, coord.x ) * step( coord.x, +bar_half_length );

		float vertical_bar_cut= step( -bar_half_length, coord.y ) * step( coord.y, bar_half_length );
		float left_bar = step( left_bar_pos  - bar_width, coord.x ) * step( coord.x, left_bar_pos  + bar_width );
		float right_bar= step( right_bar_pos - bar_width, coord.x ) * step( coord.x, right_bar_pos + bar_width );

		b+= horizontal_bar;
		b+= left_bar  * vertical_bar_cut;
		b+= right_bar * vertical_bar_cut;

		if( coord.x > 0.0 && coord.y > 0.0 )
		{
			coord= coord * 2.0 + vec2( -1.0, -1.0 );
			coord= vec2( -coord.y, +coord.x );
		}
		else if( coord.x < 0.0 && coord.y > 0.0 )
		{
			coord= coord * 2.0 + vec2( +1.0, -1.0 );
			coord= vec2( coord.y, -coord.x );
		}
		else if( coord.x > 0.0 && coord.y < 0.0 )
		{
			coord= coord * 2.0 + vec2( -1.0, +1.0 );
			coord= vec2( -coord.x, coord.y );
		}
		else //if( coord.x < 0.0 && coord.y < 0.0 )
		{
			coord= coord * 2.0 + vec2( +1.0, +1.0 );
		}
	}

	fragColor = vec4( b, b, b, 1.0);
}