const float g_min_marching_step= 0.02;
const int g_max_marcging_iterations= 256;
const float g_derivative_calculation_delta= 0.01;

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

float sdHorizontalPlane( vec3 p, float level )
{
    return p.y - level;
}

float sdVerticalInfiniteCycilder( vec3 p, float r )
{
    return length( p.xz ) - r;
}

float DistanceFunction( vec3 pos )
{
    float distant_sphere_radius= 1024.0;
    const float cylinder_height= 128.0;
    float ground_level= -0.5 * cylinder_height;
    float sphere_radius= 50.0;
    const float cylinder_radius= 128.0;
    vec3 sphere_center= vec3( 0.0, 40.0, 0.0 );
    
    // Inverted sphere representing environment map.
    float sky_sphere= -sdSphere( pos, distant_sphere_radius );
    float ground_plane= sdHorizontalPlane( pos, ground_level );
    
    float sphere= sdSphere( pos - sphere_center, sphere_radius );
    
    float cylinder_body= sdVerticalInfiniteCycilder( pos, cylinder_radius );
    float cylinder_top= sdHorizontalPlane( pos, ground_level + cylinder_height );
    float cylinder= max( cylinder_top, cylinder_body );
    
    float additive_res= min( min(sky_sphere, ground_plane), cylinder );
    
    return max( additive_res, -sphere );
}

mat3 CalculateRotationMatrix()
{
    const float tilt_angle= 0.5;
    const float tilt_angle_cos= cos(tilt_angle);
    const float tilt_angle_sin= sin(tilt_angle);
    const mat3 tilt_mat= mat3(
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, tilt_angle_cos, -tilt_angle_sin),
        vec3(0.0, tilt_angle_sin, tilt_angle_cos));
        
    float rot_angle= 0.7 * iTime;
    float c= cos(rot_angle);
    float s= sin(rot_angle);

    mat3 timed_rotate_mat= mat3(
        vec3(c, 0.0, -s),
        vec3(0.0, 1.0, 0.0),
        vec3(s, 0.0, c));

    return tilt_mat * timed_rotate_mat;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float pix_size= 2.2 / min(iResolution.x, iResolution.y);
    vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;

    vec3 dir_normalized= normalize(vec3(coord, 1.5));

    vec3 pos= vec3(0.0, 0.0, -256.0);
    
    mat3 rotate_mat= CalculateRotationMatrix();
    dir_normalized= dir_normalized * rotate_mat;
    pos= pos * rotate_mat;
    
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