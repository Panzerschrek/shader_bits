const int c_radius= 6;
const float c_threshold= 1.0 / 6.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 coord= fragCoord / iResolution.xy;

	const int c_colors= ( c_radius * 2 + 1 ) * ( c_radius * 2 + 1 ) / 4;
	
	float colors_weight[ c_colors ];
	vec3 common_colors[ c_colors ];
	int fetched_color_count= 0;
	
	for( int dx= -c_radius; dx <= c_radius; ++dx )
	for( int dy= -c_radius; dy <= c_radius; ++dy )
	{
		if( dx * dx + dy * dy > c_radius * c_radius )
			continue;
		
		vec3 color= texelFetch( iChannel0, ivec2( fragCoord ) + ivec2( dx, dy ), 0 ).xyz;
		int nearest_color_index= 0;
		float min_diff= 500.0;
		for( int i= 0; i < fetched_color_count; ++i )
		{
			vec3 test_color= common_colors[i] / colors_weight[i];
			float diff= abs( test_color.x - color.x ) + abs( test_color.y - color.y ) + abs( test_color.z - color.z );
			if( diff < min_diff )
			{
				min_diff= diff;
				nearest_color_index= i;
			}
		}
		if( min_diff < c_threshold || fetched_color_count >= c_colors )
		{
			float weight= 1.0 - sqrt( float( dx * dx + dy * dy ) ) / float(c_radius);
			common_colors[nearest_color_index]+= color * weight;
			colors_weight[nearest_color_index]+= weight;
		}
		else
		{
			common_colors[fetched_color_count]= color;
			colors_weight[fetched_color_count]= 1.0;
			++fetched_color_count;
		}
	}

	int max_color_index= 0;
	for( int i= 0; i < fetched_color_count; ++i )
	{
		if( colors_weight[i] > colors_weight[max_color_index] )
			max_color_index= i;
	}

	vec3 result_color= common_colors[max_color_index] / colors_weight[max_color_index];

	fragColor= vec4( result_color, 1.0 );
}
