const float golden_ratio= (1.0 + sqrt(5.0)) / 2.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float two_pi= 2.0 * 3.1415926535;

	float pix_size= 2.2 / min(iResolution.x, iResolution.y);
	vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;
	float angle= atan( coord.x, coord.y ) / two_pi + 0.5;
	float radius= length(coord);

	float n= log( angle ) / log(golden_ratio);

	float delta= pix_size / ( max( radius, 0.0001 ) * angle * 2.0 );
	float b= floor(n) + smoothstep( 1.0 - delta, 1.0, fract(n) );

	vec3 c= vec3( sin(b), sin(b + golden_ratio), sin(b + 2.0 * golden_ratio) ) * 0.5 + vec3( 0.5, 0.5, 0.5 );
	float circle_factor= 1.0 - smoothstep( 1.0 - pix_size, 1.0 + pix_size, radius );

	fragColor = vec4( c * circle_factor, 1.0 );
}