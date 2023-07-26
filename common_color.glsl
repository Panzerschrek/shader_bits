void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   const float c_arrow_width= 0.2;
   const float c_arrow_head_width= 0.1;
    
   vec2 coord= fragCoord / iResolution.xy;
    
   int radius= 4;
   
   int colors[256];
   for( int i= 0; i < 256; ++i )
       colors[i]= 0;
    
   for( int dx= -radius; dx <= radius; ++dx )
   for( int dy= -radius; dy <= radius; ++dy )
   {
       if( dx * dx + dy * dy > radius * radius )
           continue;
           
       	vec3 color= texelFetch( iChannel0, ivec2( fragCoord ) + ivec2( dx, dy ), 0 ).xyz;
    	int color_index= 1 * int(color.r * 7.99) + 8 * int(color.g * 7.99) + 64 * int(color.b * 3.99);
        ++colors[color_index];
   }
    
   int max_color= 0;
   int max_color_index= 0;
   for( int i= 0; i < 256; ++i )
   {
       if( colors[i] > max_color )
       {
          max_color= colors[i];
          max_color_index= i;
       }
   }
    
   vec3 result_color= vec3(
      float( ( max_color_index >> 0 ) & 7 ) / 8.0 + 0.0625,
      float( ( max_color_index >> 3 ) & 7 ) / 8.0 + 0.0625, 
      float( ( max_color_index >> 6 ) & 3 ) / 4.0 + 0.125 );
    
   fragColor= vec4( result_color, 1.0 );
}