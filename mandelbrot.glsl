void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const int c_ss_size= 3;
	fragColor= vec4( 0.0, 0.0, 0.0, 0.0 );
	for( int dx= 0; dx < c_ss_size; ++dx )
	for( int dy= 0; dy < c_ss_size; ++dy )
	{
		float angle= iTime * 0.1;
		float scale= exp(-iTime * 0.1);
		float ts= sin(angle);
		float tc= cos(angle);
		vec2 num= ( fragCoord.xy + vec2(dx, dy) / float(c_ss_size) ) / ( 0.5 * iResolution.xy );
		num-= vec2( 1.0, 1.0 );
		num.x*= iResolution.x / iResolution.y;
		num*= mat2(tc, -ts, ts, tc);
		num*= scale;
		num+= vec2( -0.7076599, 0.3527965 );;

		const int c_iterations= 256;
		float c= 1.0;
		if(dot(num, num) <= 4.0)
		{
			vec2 z= vec2( 0.0, 0.0 );
			for(int i= 0; i < c_iterations; ++i )
			{
				z= num + vec2( z.x * z.x - z.y * z.y, 2.0 * z.x * z.y );
				float d= dot(z, z);
				if( d>= 4.0 )
					break;

				c+= 4.0 - d;
			}
		}

		float color_factor= log(c) * 0.25;

		vec3 color= vec3(
			sin( iTime * 1.0 + color_factor * 7.0 ) * 0.5 + 0.5,
			sin( iTime * 1.5 + color_factor * 8.0 ) * 0.5 + 0.5,
			sin( iTime * 2.0 + color_factor * 9.0 ) * 0.5 + 0.5 );

		fragColor+= vec4( color, 0.0 );
	}
	fragColor/= float(c_ss_size * c_ss_size);
}
