void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float two_pi= 2.0 * 3.1415926535;
	const float deg_to_rad = two_pi / 360.0;
	const float golden_ratio= ( sqrt(5.0) - 1.0 ) / 2.0;
	const float angle_scale= 5.0 / two_pi;

	float pix_size=  1.0 / min(iResolution.x, iResolution.y);
	vec2 coord= (fragCoord - 0.5 * iResolution.xy) * pix_size;
        
    float c= 0.0;

    float step_scale= 1.0 / ( golden_ratio * golden_ratio ); 
    for( int i= 0; i < 4; ++i )
    {
        float angle5= fract( atan( coord.y, coord.x ) * angle_scale );
        float radius= length(coord);
    
        float angle10= 1.0 - abs( angle5 - 0.5 ) * 2.0;
        
        vec2 rel_coord= 1.0 * radius * vec2( cos( angle10 / ( 2.0 * angle_scale ) ), sin( angle10 / ( 2.0 * angle_scale ) ) );

		float inside_main_pentagon= step( rel_coord.x, 0.225 ); // TODO - tune this
		if( inside_main_pentagon > 0.0 )
		{
			float s= sin( -180.0 * deg_to_rad );
			float c = cos( -180.0 * deg_to_rad );

			coord = vec2( coord.x * c - coord.y * s, coord.x * s + coord.y * c ) * step_scale;
		}
		else
		{
			float k1= tan( 18.0 * deg_to_rad );
			float offset1= 0.09; // TODO - tune this
            
            float k0= tan( -54.0 * deg_to_rad );
            float offset0= 1.0;

			if( step( rel_coord.y, k0 * rel_coord.x + offset0 ) == 0.0 ||
                step( rel_coord.y, k1 * rel_coord.x + offset1 ) == 0.0 )
			{
				break;
			}
			else
			{
				rel_coord.x -= 0.44; // TODO - tune this
				coord = rel_coord * step_scale;
                c += 0.15;
			}
		}
	}
    
    fragColor = vec4(
        0.0,
        0.0,
        c,
        1.0);
}