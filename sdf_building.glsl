float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b + r;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

float DistanceFunction( vec3 pos )
{
    float sphere_radius= 0.5;
    vec3 sphere_center= vec3( 0.0, 0.0, 2.0 );
    vec3 cube_center= vec3( 0.0, 0.3, 2.0 );
    vec3 cube_size= vec3( 0.6, 0.4, 0.3 );
    
    float sphere= sdSphere( pos - sphere_center, sphere_radius );
    float box= sdRoundBox( pos - cube_center, cube_size, 0.2 );
    
    return min(sphere, box );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float pix_size= 2.2 / min(iResolution.x, iResolution.y);
    vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;

    vec3 dir_normalized= normalize(vec3(coord, 1.0));

    vec3 pos= vec3(0.0, 0.0, 0.0);
    bool hit= false;
    for( int i= 0; i < 128; ++i )
    {
        float dist= DistanceFunction( pos );
        if( dist <= 0.0 )
        {
            hit= true;
            break;
        }
        pos+= dir_normalized * max(0.01, dist);
    }

    if(hit)
    {
        const float grad_step= 0.01;
        vec3 normal= vec3(
            DistanceFunction( pos + grad_step * vec3(1.0, 0.0, 0.0 ) ) -
            DistanceFunction( pos - grad_step * vec3(1.0, 0.0, 0.0 ) ),
            DistanceFunction( pos + grad_step * vec3(0.0, 1.0, 0.0 ) ) -
            DistanceFunction( pos - grad_step * vec3(0.0, 1.0, 0.0 ) ),
            DistanceFunction( pos + grad_step * vec3(0.0, 0.0, 1.0 ) ) -
            DistanceFunction( pos - grad_step * vec3(0.0, 0.0, 1.0) ) );
        normal= normalize(normal);

        fragColor= vec4( normal * 0.5 + vec3(0.5, 0.5, 0.5), 0.0 );
    }
    else
        fragColor= vec4( 0.0, 0.0, 0.0, 0.0 );
}