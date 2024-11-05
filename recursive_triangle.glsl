const int ss_factor= 2;
const int num_steps= 7;

const float scale_speed= 0.3;
const float color_change_speed= 2.5;

vec3 MakeTrianlge( vec2 coord )
{
	coord.x *= sqrt(3.0) / 2.0;

	float coord_scaler_pow= fract(iTime * scale_speed);

	coord= (coord + vec2(0.0, -1.0)) * exp2(-coord_scaler_pow) + vec2(0.0, 1.0);

	vec3 c= vec3(0.0, 0.0, 0.0);
	float scaler= 1.0;

	if( coord.y * 0.5 + coord.x < 0.5 && coord.y * 0.5 - coord.x < 0.5 && coord.y > -1.0 )
	{
		for(int i= 0; i < num_steps; ++i )
		{
			if(coord.y > 0.0)
			{
				c += vec3(1.0, 0.0, 0.0);
				coord= coord * 2.0 + vec2(0.0, -1.0);
			}
			else if(coord.x + coord.y * 0.5 < -0.5 )
			{
				c += vec3(0.0, 1.0, 0.0);
				coord= coord * 2.0 + vec2(1.0, 1.0);
			}
			else if(coord.y * 0.5 - coord.x < -0.5 )
			{
				c += vec3(0.0, 0.0, 1.0);
				coord= coord * 2.0 + vec2(-1.0, 1.0);
			}
			else
			{
				scaler *= 0.25;
				coord= (-2.0) * coord + vec2(0.0, -1.0);
			}
		}
	}

	vec3 yuv= vec3(
		dot(c, vec3(0.299, 0.587, 0.114)),
		dot(c, vec3(-0.14713, -0.28886, 0.436)),
		dot(c, vec3(0.615, -0.51499, -0.10001)));

	float phase_sin= sin(iTime * color_change_speed);
	float phase_cos= cos(iTime * color_change_speed);

	yuv.yz= vec2(
		yuv.y * phase_cos - yuv.z * phase_sin,
		yuv.y * phase_sin + yuv.z * phase_cos);

	c= vec3(
		yuv.x + 1.13983 * yuv.z,
		yuv.x - 0.39465 * yuv.y - 0.5806 * yuv.z,
		yuv.x + 2.03211 * yuv.y);

	return c * (scaler / float(num_steps));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 coord_base= fragCoord.xy - iResolution.xy * 0.5;
	float coord_scale= 2.0 / iResolution.y;
	vec3 c= vec3( 0.0 );
	for( int dx= 0; dx < ss_factor; ++dx )
	for( int dy= 0; dy < ss_factor; ++dy )
	{
		vec2 ss_offset= vec2( float(dx), float(dy) ) / float(ss_factor);
		vec2 coord= ( coord_base + ss_offset ) * coord_scale;

		c+= MakeTrianlge( coord );
	}

	fragColor = vec4(c / float(ss_factor * ss_factor) ,1.0);
}