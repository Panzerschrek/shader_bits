void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 coord= fragCoord/ iResolution.xy * 2.0 - vec2( 1.0, 1.0 );
    coord.x*= (iResolution.x / iResolution.y );
    
    float log_scale= sin(iTime) * 8.0 + 10.0;
    vec2 coord_log= log( abs(coord.xy * 2000.0) * log_scale );
   
    float d= max( coord_log.x, coord_log.y );
    
    float f= floor(d);
    float b= fract(d);
    
    float step_factor= 1.0 - 0.3 / f;
    vec2 local_coord= coord_log / f;
    float corner_factor= step( step_factor, local_coord.x ) * step( step_factor, local_coord.y );
  
    vec2 rg= ( local_coord - vec2( 0.99, 0.99 ) ) * ( b * f );
   
    rg= sin( rg.yx * 3.0 + iTime * vec2( 1.5, 1.7 ) ) * 0.5 + vec2( 0.5, 0.5 );
    float blue= sin( f  + iTime * 4.0 );
    
    fragColor = vec4( rg * corner_factor, blue * corner_factor, 1.0);
}