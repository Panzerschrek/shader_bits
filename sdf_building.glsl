float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float pix_size= 2.2 / min(iResolution.x, iResolution.y);
    vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;

    float sphere_radius= 0.4;
    vec3 sphere_center= vec3( 0.0, 0.0, 1.0 );

    vec3 dir_normalized= normalize(vec3(coord, 1.0));

    vec3 pos= vec3(0.0, 0.0, 0.0);
    bool hit= false;
    for( int i= 0; i < 128; ++i )
    {
        float dist= sdSphere( pos - sphere_center, sphere_radius );
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
            sdSphere( pos - sphere_center + grad_step * vec3(1.0, 0.0, 0.0), sphere_radius ) -
            sdSphere( pos - sphere_center - grad_step * vec3(1.0, 0.0, 0.0), sphere_radius ),
            sdSphere( pos - sphere_center + grad_step * vec3(0.0, 1.0, 0.0), sphere_radius ) -
            sdSphere( pos - sphere_center - grad_step * vec3(0.0, 1.0, 0.0), sphere_radius ),
            sdSphere( pos - sphere_center + grad_step * vec3(0.0, 0.0, 1.0), sphere_radius ) -
            sdSphere( pos - sphere_center - grad_step * vec3(0.0, 0.0, 1.0), sphere_radius ));
        normal= normalize(normal);

        fragColor= vec4( normal * 0.5 + vec3(0.5, 0.5, 0.5), 0.0 );
    }
    else
        fragColor= vec4( 0.0, 0.0, 0.0, 0.0 );
}