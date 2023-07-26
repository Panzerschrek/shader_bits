const float two_pi= 2.0 * 3.1415926535;
const float deg_to_rad = two_pi / 360.0;
const float golden_ratio= ( sqrt(5.0) + 1.0 ) / 2.0;
const float angle_scale= 5.0 / two_pi;

vec2 transformPoint( vec2 coord, vec2 new_center, float rotate_angle_deg, float scale )
{
    float rot_c= scale * cos( rotate_angle_deg * deg_to_rad );
    float rot_s= scale * sin( rotate_angle_deg * deg_to_rad );
    vec2 coord_shifted = coord - new_center;
    return vec2( coord_shifted.x * rot_c - coord_shifted.y * rot_s, coord_shifted.x * rot_s + coord_shifted.y * rot_c );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
    const float cos18= cos( 18.0 * deg_to_rad );
    const float sin18= sin( 18.0 * deg_to_rad );
    const float cos36= cos( 36.0 * deg_to_rad );
    const float sin36= sin( 36.0 * deg_to_rad );
    const float tan18= tan( 18.0 * deg_to_rad );
    const float tan36= tan( 36.0 * deg_to_rad );
    const float tan54= tan( 54.0 * deg_to_rad );
    const float tan72= tan( 72.0 * deg_to_rad );
    const float tan126= tan( 126.0 * deg_to_rad );
    const float tan144= tan( 144.0 * deg_to_rad );
    const float tan162= tan( 162.0 * deg_to_rad );
    
    float pix_size=  1.1 / min(iResolution.x, iResolution.y);
	vec2 coord_initial= (fragCoord - 0.5 * iResolution.xy) * pix_size;
    vec2 coord= coord_initial;

    vec3 c= vec3( 0.0, 0.0, 0.0 );
    
    bool is_fat= false;
    for( int i= 0; i < 1; ++i )
    {
        if( is_fat )
        {
            if( coord.y >= 0.0 )
            {
                if( coord.y >= coord.x * tan72 + sin36 )
                {
                    coord= transformPoint( coord, vec2(-cos36 * 0.5, sin36 * 0.5), 144.0, golden_ratio );
                    is_fat= true;
                    continue;
                }
                if( coord.y > coord.x * tan36 + sin36 / tan72 * tan36 )
                {
                    coord= transformPoint( coord, vec2(cos36 * 0.5 - 0.25, sin36 * 0.5 + sin36 / (sqrt(5.0) + 1.0)), 126.0, golden_ratio );
                    is_fat= false;
                    continue;
                }
            }
            else
            {
                if( coord.y < -coord.x * tan72 - sin36 )
                {
                    coord= transformPoint( coord, vec2(-cos36 * 0.5, -sin36 * 0.5), -144.0, golden_ratio );
                    is_fat= true;
                    continue;
                }
                else if( coord.y < -coord.x * tan36 - sin36 / tan72 * tan36 )
                {
                    coord= transformPoint( coord, vec2(cos36 * 0.5 - 0.25, -sin36 * 0.5 - sin36 / (sqrt(5.0) + 1.0)), 54.0, golden_ratio );
                    is_fat= false;
                    continue;
                }
             }
             
            coord= transformPoint( coord, vec2(cos36 - 0.5, 0.0), 180.0, golden_ratio );
        }
        else
        {
            if( coord.y < coord.x * tan126 - sin18 )
            {
                coord= transformPoint( coord, vec2(-cos18 * 0.5, -sin18 * 0.5), 18.0, golden_ratio );
                is_fat= true;
            }
            else if( coord.y < coord.x * tan54 - sin18 )
            {
                coord= transformPoint( coord, vec2(cos18 * 0.5, -sin18 * 0.5), 162.0, golden_ratio );
                is_fat= true;
            }
            else if( coord.x <= 0.0 )
            {
               coord= transformPoint( coord, vec2(-cos18 * (3.0 - sqrt(5.0)) / 4.0, sin18 - sin18 * (3.0 - sqrt(5.0)) / 4.0 ), -108.0, golden_ratio );
               is_fat= false;
            }
            else // if( coord.x > 0.0 )
            {
               coord= transformPoint( coord, vec2(cos18 * (3.0 - sqrt(5.0)) / 4.0, sin18 - sin18 * (3.0 - sqrt(5.0)) / 4.0 ), 108.0, golden_ratio );
               is_fat= false;
            }
        }
    }
    
   c= vec3( coord.x * 0.3 + 0.3, coord.y * 0.3 + 0.3, 0.0);
   // c= texture(iChannel0, coord * 0.5 + vec2(0.5, 0.5)).rgb;

      //c= vec3( 0.0, 0.0, 0.0 );

     float eps= 0.01;

    if( is_fat )
    {
        vec2 green_center= vec2( -cos36, 0.0 );
        float l_green= length( coord - green_center );
        float pos_green= 0.333 / golden_ratio;
        c += vec3( 0.1, 0.5, 0.1 ) * ( step( pos_green - eps, l_green ) * step( l_green, pos_green + eps ) );
        
        vec2 red_center= vec2( cos36, 0.0 );
        float l_red= length( coord - red_center );
        float pos_red= 1.292 / golden_ratio;
        c += vec3( 0.5, 0.1, 0.1 ) * ( step( pos_red - eps, l_red ) * step( l_red, pos_red + eps ) );
        
         c *= smoothstep( 0.0, pos_red, l_red );
        c *= smoothstep( 0.0, pos_green, l_green );
       //= vec3(1.0, 0.0, 0.0);

    }
    else
    {
        vec2 green_center= vec2( 0.0, - sin18 );
        float l_green= length( coord - green_center );
        float pos_green= 0.333 / golden_ratio;
        c += vec3( 0.1, 0.5, 0.1 ) * ( step( pos_green - eps, l_green ) * step( l_green, pos_green + eps ) );
        
        vec2 red_center= vec2( 0.0, sin18 );
        float l_red= length( coord - red_center );
        float pos_red= 0.333 / golden_ratio;
        c += vec3( 0.5, 0.1, 0.1 ) * ( step( pos_red - eps, l_red ) * step( l_red, pos_red + eps ) );
       
        c *= smoothstep( 0.0, pos_red, l_red );
        c *= smoothstep( 0.0, pos_green, l_green );
       //= vec3(0.0, 0.0, 1.0);
    }
    
    

     if(coord_initial.y >=  coord_initial.x * tan18+ sin18||
        coord_initial.y >=  coord_initial.x * tan162+ sin18 ||
        coord_initial.y <= -coord_initial.x * tan18- sin18 ||
        coord_initial.y < -coord_initial.x * tan162 - sin18)
    {
        c*= vec3( 0.7, 0.5, 0.7 );
        c += vec3( 0.1, 0.2, 0.1 );
        c= vec3( 1.0, 1.0, 1.0 );
    }
   
    
    
    fragColor = vec4(c, 1.0);
}