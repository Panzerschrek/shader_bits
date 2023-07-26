void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 c_black_color= vec3( 0.05, 0.05, 0.01 );
    vec2 c_cell_size= vec2( 0.5 * sqrt(3.0), 1.0 ) * 64.0;
    const float c_sep_size= 0.05;
    const float c_tan= 3.0 / 2.0;
    
    vec2 cell_coord= fragCoord.xy / c_cell_size;
    cell_coord.y+= 0.5 * step( 0.5, fract( 0.5 * cell_coord.x ) );
    vec2 coord_inside_cell= fract( cell_coord );
    
    //float factor0= step( coord_inside_cell.y, 0.5 + coord_inside_cell.x  );
    //float factor1= 1.0 - step( coord_inside_cell.y, 0.5 - coord_inside_cell.x );
    
    vec3 color= vec3( 0.5 );
    
    float s0=
        ( step( 1.0 - c_sep_size * 0.5, coord_inside_cell.y ) + ( 1.0 - step( c_sep_size * 0.5, coord_inside_cell.y ) ) )
        * step( 1.0 / 3.0, coord_inside_cell.x );
    float s1=
        step( coord_inside_cell.y, 0.5 + c_sep_size + c_tan * coord_inside_cell.x ) *
        ( 1.0 - step( coord_inside_cell.y, 0.5 - c_sep_size + c_tan * coord_inside_cell.x ) );
     float s2=
        ( 1.0 - step( coord_inside_cell.y, 0.5 - c_sep_size - c_tan * coord_inside_cell.x ) ) *
        step( coord_inside_cell.y, 0.5 + c_sep_size - c_tan * coord_inside_cell.x );
    
    color= mix( color, c_black_color, s0 );
    color= mix( color, c_black_color, s1 );
    color= mix( color, c_black_color, s2 );
    
    fragColor= vec4( color, 0.0 );
}