const float c_two_pi= 3.1415926535 * 2.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) / max( iResolution.x, iResolution.y );

    const float c_div= 5.0;
    float angle= fract( atan(coord.y, coord.x) * ( c_div / c_two_pi ) );
    coord*= 1.0 * cos( (angle - 0.5) * ( c_two_pi / c_div ) );
    float r= length(coord) * 50.0;
    float r_fract= fract( r );
    
    float chess=
       step( 0.5, fract( angle * 1.0 * floor(r) + float(iTime) ) );
    
    fragColor = vec4(chess);
}