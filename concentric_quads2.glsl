float c_half_border_size= 0.03;
int c_num_iterations= 24;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float pix_size=  2.1 / min(iResolution.x, iResolution.y);
	vec2 coord= (fragCoord - 0.5 * iResolution.xy) * pix_size;

	float rot_angle= 0.1 * iTime;
	float rot_c= cos( rot_angle );
	float rot_s= sin( rot_angle );
	float rot_scale= abs(rot_c) + abs(rot_s);
	rot_c*= rot_scale;
	rot_s*= rot_scale;

	float r= 0.0;
	float border_factor= 0.0;
	for( int i= 0; i < c_num_iterations; ++i )
	{
		float dist= max( abs(coord.x), abs(coord.y) );
		if( dist > 1.0 )
		{
			border_factor+= 1.0 - smoothstep( 1.0, 1.0 + c_half_border_size, dist );
			break;
		}

		coord= vec2( coord.x * rot_c - coord.y * rot_s, coord.x * rot_s + coord.y * rot_c );
		r+= 1.0;
		border_factor= smoothstep( 1.0 - c_half_border_size, 1.0, dist );
	}
	r *= 3.0;

	vec3 color= vec3(
		sin( r /  7.0 - iTime * 0.3 ) * 0.45 + 0.55,
		sin( r / 11.0 - iTime * 0.4 ) * 0.45 + 0.55,
		sin( r / 19.0 - iTime * 0.5 ) * 0.45 + 0.55 );
	color *= 1.0 - 0.5 * min( border_factor, 1.0 );

	fragColor= vec4( color, 1.0 );
}
