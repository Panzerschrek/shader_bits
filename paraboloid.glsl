void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float two_pi= 2.0 * 3.1415926535;

	float pix_size= 2.0 / min(iResolution.x, iResolution.y);
	vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;
    coord.y+= 1.0;
    
    vec2 focus= coord - vec2( 0.0, 0.5 );
    
    float angle= atan( focus.x, focus.y ) / two_pi + 0.5;
    
    float b= step( coord.y, coord.x * coord.x );
    float s= fract( angle * 24.0 );
    
    
    float t= fract( sqrt(1.0 + abs(coord.x)) * 5.0 * sqrt(2.0) );
    
    fragColor = vec4( b, s, t, 1.0);
}