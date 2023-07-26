void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	const float two_pi= 2.0 * 3.1415926535;
	const float deg_to_rad = two_pi / 360.0;
	const float golden_ratio= ( sqrt(5.0) + 1.0 ) / 2.0;
	const float angle_scale= 5.0 / two_pi;
    
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
    
    float pix_size=  1.2 / min(iResolution.x, iResolution.y);
	vec2 coord_initial= (fragCoord - 0.5 * iResolution.xy) * pix_size;
    vec2 coord= coord_initial;

    vec3 c= vec3( 0.0, 0.0, 0.0 );
    
    bool is_fat= true;
    for( int i= 0; i < 1; ++i )
    {
        if( is_fat )
        {
            if( coord.y >= 0.0 )
            {
                if( coord.y >= coord.x * tan72 + sin36 )
                {
                    //c= vec3( 1.0, 0.0, 0.0 );
                    float rot_c= cos( 144.0 * deg_to_rad );
                    float rot_s= sin( 144.0 * deg_to_rad );
                    coord= vec2( coord.x * rot_c - coord.y * rot_s, coord.x * rot_s + coord.y * rot_c );
                    coord *= golden_ratio;
                    coord.x -= 0.25;
                    coord.y += tan72 * 0.25;                    
                    is_fat= true;
                    continue;
                }
                if( coord.y > coord.x * tan36 + sin36 / tan72 * tan36 )
                {
                    // TODO - transform
                    coord *= golden_ratio;
                    is_fat= false;
                    continue;
                }
            }
            else
            {
                if( coord.y < -coord.x * tan72 - sin36 )
                {
                    //c= vec3( 0.5, 0.0, 0.0 );
                    float rot_c= cos( -144.0 * deg_to_rad );
                    float rot_s= sin( -144.0 * deg_to_rad );
                    coord= vec2( coord.x * rot_c - coord.y * rot_s, coord.x * rot_s + coord.y * rot_c );
                    coord *= golden_ratio;
                    coord.x -= 0.25;
                    coord.y -= tan72 * 0.25;
                    is_fat= true;
                    continue;
                }
                else if( coord.y < -coord.x * tan36 - sin36 / tan72 * tan36 )
                {
                     // TODO - transform
                     coord *= golden_ratio;
                    is_fat= false;
                    continue;
                }
             }
             
            coord.x -= sin18;
            coord= -coord * golden_ratio;
        }
        else
        {
            if( coord.y < coord.x * tan126 - sin18 )
            {
                float rot_c= cos( 18.0 * deg_to_rad );
                float rot_s= sin( 18.0 * deg_to_rad );
                coord= vec2( coord.x * rot_c - coord.y * rot_s, coord.x * rot_s + coord.y * rot_c );
                coord *= golden_ratio;
                coord.x += tan18 * 2.0;
                coord.y += sin( 72.0 * deg_to_rad ) / 2.0;
                is_fat= true;
            }
            else if( coord.y < coord.x * tan54 - sin18 )
            {
                 float rot_c= cos( -18.0 * deg_to_rad );
                float rot_s= sin( -18.0 * deg_to_rad );
                coord= vec2( coord.x * rot_c - coord.y * rot_s, coord.x * rot_s + coord.y * rot_c );
                coord *= golden_ratio;
                coord.x *= -1.0;
                coord.x += tan18 * 2.0;
                coord.y += sin( 72.0 * deg_to_rad ) / 2.0;
                is_fat= true;
            }
            else if( coord.x <= 0.0 )
            {
                float rot_c= cos( -108.0 * deg_to_rad );
                float rot_s= sin( -108.0 * deg_to_rad );
                coord= vec2( coord.x * rot_c - coord.y * rot_s, coord.x * rot_s + coord.y * rot_c );
                coord *= golden_ratio;
                coord.y -= sin18 / 2.0;
                coord.x -= sin( 108.0 * deg_to_rad ) / 2.0;
                is_fat= false;
                continue;
            }
            else // if( coord.x > 0.0 )
            {
                float rot_c= cos( 108.0 * deg_to_rad );
                float rot_s= sin( 108.0 * deg_to_rad );
                coord= vec2( coord.x * rot_c - coord.y * rot_s, coord.x * rot_s + coord.y * rot_c );
                coord *= golden_ratio;
                coord.y -= sin18 / 2.0;
                coord.x += sin( 108.0 * deg_to_rad ) / 2.0;
                is_fat= false;
                continue;
            }
        }
    }
    
   c= vec3( coord.x * 0.3 + 0.3, coord.y * 0.3 + 0.3, 0.0);
   // c= texture(iChannel0, coord * 0.5 + vec2(0.5, 0.5)).rgb;

      //c= vec3( 0.0, 0.0, 0.0 );

     float eps= 0.01;

    if( is_fat )
    {
       // c= vec3(1.0, 0.0, 0.0);
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
    }
    else
    {
       // c= vec3(0.0, 0.0, 1.0);
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
    }
    
    

     if(coord_initial.y >=  coord_initial.x * tan36 + sin36 ||
        coord_initial.y >=  coord_initial.x * tan144 + sin36 ||
        coord_initial.y <= -coord_initial.x * tan36 - sin36 ||
        coord_initial.y < -coord_initial.x * tan144 - sin36)
    {
        c*= vec3( 0.7, 0.5, 0.7 );
        c += vec3( 0.1, 0.2, 0.1 );
        c= vec3( 1.0, 1.0, 1.0 );
    }
   
    
    
    fragColor = vec4(c, 1.0);
}