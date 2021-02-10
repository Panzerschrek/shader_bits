const float golden_ratio= 0.61803;

float getGoldenRatioDepth( vec2 coord )
{
	const float ratio= golden_ratio;
	const int max_depth= 16;
	for( int i= 0; i < max_depth; ++i )
	{
		if( coord.x > ratio )
		   return float(i) - coord.x;
		coord= coord.yx / ratio;
	}
	return float(max_depth);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float pix_size= 1.0 / min(iResolution.x, iResolution.y);
	vec2 coord= fragCoord.xy * pix_size;

	float b= getGoldenRatioDepth(coord);
	vec3 c= vec3( sin(b), sin(2.0 * b), sin(3.0 * b) ) * 0.5 + vec3( 0.5, 0.5, 0.5 );

	fragColor = vec4( c, 1.0 );
}