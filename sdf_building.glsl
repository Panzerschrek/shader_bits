const float g_min_marching_step= 0.002;
const int g_max_marcging_iterations= 256;
const float g_derivative_calculation_delta= 0.001;

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b + r;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float DistanceFunction( vec3 pos )
{
    float distant_sphere_radius= 64.0;
    float sphere_radius= 0.5;
    vec3 sphere_center= vec3( 0.0, 0.0, 2.0 );
    vec3 cube_center= vec3( 0.0, 0.3, 2.0 );
    vec3 cube_size= vec3( 0.6, 0.4, 0.3 );
    vec3 torus_center= vec3( 0.5, -0.3, 2.0 );
    vec3 torus_subtract_center= vec3( -0.5, 0.52, 2.0 );
    
    // Inverted sphere representing environment map.
    float distant_sphere= -sdSphere( pos, distant_sphere_radius );
    
    float sphere= sdSphere( pos - sphere_center, sphere_radius );
    float box= sdRoundBox( pos - cube_center, cube_size, 0.2 );
    float torus= sdTorus( pos - torus_center, vec2( 0.5, 0.1 ) );
    float torus_subtract= sdTorus( pos - torus_subtract_center, vec2( 0.4, 0.2 ) );
    
    float additive_res=  min( distant_sphere, min( min( sphere, box ), torus ) );
    
    return max( -torus_subtract, additive_res );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float pix_size= 2.2 / min(iResolution.x, iResolution.y);
    vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;

    vec3 dir_normalized= normalize(vec3(coord, 1.5));

    vec3 pos= vec3(0.0, 0.0, 0.0);
    pos.xy+= ( iResolution.xy * 0.5 - iMouse.xy ) * pix_size;
    
    bool hit= false;
    for( int i= 0; i < g_max_marcging_iterations; ++i )
    {
        float dist= DistanceFunction( pos );
        if( dist <= 0.0 )
        {
            hit= true;
            break;
        }
        pos+= dir_normalized * max(g_min_marching_step, dist);
    }

    if(hit)
    {
        vec3 normal= vec3(
            DistanceFunction( pos + g_derivative_calculation_delta * vec3(1.0, 0.0, 0.0 ) ) -
            DistanceFunction( pos - g_derivative_calculation_delta * vec3(1.0, 0.0, 0.0 ) ),
            DistanceFunction( pos + g_derivative_calculation_delta * vec3(0.0, 1.0, 0.0 ) ) -
            DistanceFunction( pos - g_derivative_calculation_delta * vec3(0.0, 1.0, 0.0 ) ),
            DistanceFunction( pos + g_derivative_calculation_delta * vec3(0.0, 0.0, 1.0 ) ) -
            DistanceFunction( pos - g_derivative_calculation_delta * vec3(0.0, 0.0, 1.0) ) );
        normal= normalize(normal);

        fragColor= vec4( normal * 0.5 + vec3(0.5, 0.5, 0.5), 0.0 );
    }
    else
        fragColor= vec4( 0.0, 0.0, 0.0, 0.0 );
}