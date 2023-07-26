void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   const float c_arrow_width= 0.2;
   const float c_arrow_head_width= 0.1;
    
   vec2 coord= fragCoord / iResolution.xy;
    
   int radius= 6;
   
   const int c_color_gradations= 128;
   int colors[c_color_gradations];
   for( int i= 0; i < c_color_gradations; ++i )
       colors[i]= 0;
    
   for( int dx= -radius; dx <= radius; ++dx )
   for( int dy= -radius; dy <= radius; ++dy )
   {
       if( dx * dx + dy * dy > radius * radius )
           continue;
           
       	vec3 color= texelFetch( iChannel0, ivec2( fragCoord ) + ivec2( dx, dy ), 0 ).xyz;
       	float gray= dot( color, vec3( 0.299, 0.587, 0.114) );
    	int color_index= int(gray * float(c_color_gradations - 1 ));
        ++colors[color_index];
   }
    
   int max_color= 0;
   int max_color_index= 0;
   for( int i= 0; i < c_color_gradations; ++i )
   {
       if( colors[i] > max_color )
       {
          max_color= colors[i];
          max_color_index= i;
       }
   }
    
   vec3 result_color= vec3( float(max_color_index) / float(c_color_gradations - 1) );
   
   fragColor= vec4( result_color, 1.0 );
}