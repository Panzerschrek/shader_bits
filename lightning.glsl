const float c_amplitude= 0.4;
const float c_frequency= 1.0 / 20.0;
const float c_time_factor= 1.0 / 32.0;
const int c_octaves= 5;
const float c_lightning_width= 0.04;
const float c_anchor_factor= 0.3;

float GetNoize( vec2 tc )
{
	float r= 0.0;
	float n= 0.0;
	for( int i= 0; i < c_octaves; ++i )
	{
	float s= float(1 << i);
	n += 1.0 / s;
	r+= texture( iChannel0, tc * s ).x / s;
	}
	return r / n;
}

vec4 InitencityToColor( float i )
{
	const vec4 c_white= vec4( 1.0, 1.0, 1.0, 1.0 );
	const vec4 c_blue= vec4( 0.5, 0.5, 1.0, 1.0 );
	const vec4 c_dark_blue= vec4( 0.1, 0.1, 0.5, 1.0 );
	const vec4 c_black= vec4( 0.0, 0.0, 0.0, 1.0 );

	if( i < 0.4 )
		return mix( c_white, c_blue, smoothstep( 0.0, 0.4, i ) );
	if( i < 0.8 )
		return mix( c_blue, c_dark_blue, smoothstep( 0.4, 0.8, i ) );
	if( i < 1.0 )
		return mix( c_dark_blue, c_black, smoothstep( 0.8, 1.0, i ) );
	return c_black;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord/iResolution.xy;
	float x_shift= GetNoize( vec2( iTime * c_time_factor, uv.y * c_frequency ) ) * 2.0 - 1.0;

	float anchor_factor= smoothstep( 1.0, 1.0 - c_anchor_factor, abs( uv.y * 2.0 - 1.0 ) );

	float lightning_dist= abs( uv.x * 2.0 - 1.0 + x_shift * anchor_factor * c_amplitude );
	float lightning_k= smoothstep( 0.0, c_lightning_width, lightning_dist );

	fragColor = InitencityToColor( lightning_k );
}
