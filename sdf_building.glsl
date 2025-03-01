const float g_two_pi= 2.0 * 3.1415926535;

const float g_min_marching_step= 0.02;
const int g_max_marcging_iterations= 256;
const float g_derivative_calculation_delta= 0.01;

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
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

float sdYInfiniteCylinder( vec3 p, float r )
{
    return length( p.xz ) - r;
}

float sdXInfiniteCylinder( vec3 p, float r )
{
    return length( p.yz ) - r;
}

float sdYInfiniteHollowCylinder( vec3 p, float base_radius, float walls_half_thikness )
{
    float l= length( p.xz );
    return abs( l - base_radius ) - walls_half_thikness;
}

float DistanceFunction( vec3 pos )
{
    const int num_sectors= 20;
    const float sector_scale = g_two_pi / float(num_sectors);
    float sector_radius= length( pos.xz );
    // From -0.5 to 0.5
    float angle_within_sector= (fract( atan(pos.z, pos.x) / sector_scale ) - 0.5) * sector_scale;
    
    vec3 pos_within_sector= vec3( cos(angle_within_sector) * sector_radius, pos.y, sin(angle_within_sector) * sector_radius );
        
    const float cylinder_height= 128.0;
    const float ground_level= -0.5 * cylinder_height;
    const float window_radius= 14.0;
    const float cylinder_radius= 128.0;
    const float cylinder_walls_half_thikness= 6.0;
    const float floor_cylinder_walls_half_thikness= 9.0;
    const vec3 window_center= vec3( 0.0, 35.0, 0.0 );
    const float window_box_half_height= 10.0;
    const float window_box_half_depth= cylinder_walls_half_thikness * 4.0;
    const vec3 window_box_center= vec3( cylinder_radius, window_center.y - window_box_half_height, 0.0 );
    const float floor_cylinder_start_height= window_center.y + window_radius + 2.0;
    const float floor_cylinder_end_height= floor_cylinder_start_height + 4.0;
    
    float ground_plane= sdHorizontalPlane( pos, ground_level );
    
    float window_round= sdXInfiniteCylinder( pos_within_sector - window_center, window_radius );
    float window_box= sdBox( pos_within_sector - window_box_center, vec3( window_box_half_depth, window_box_half_height, window_radius ) );
    float window= min( window_round, window_box);
    
    float cylinder_body= sdYInfiniteHollowCylinder( pos, cylinder_radius - cylinder_walls_half_thikness, cylinder_walls_half_thikness );
    float cylinder_top= sdHorizontalPlane( pos, ground_level + cylinder_height );
    float cylinder= max( cylinder_top, cylinder_body );
    
    float floor_cylinder_body= sdYInfiniteHollowCylinder( pos, cylinder_radius - cylinder_walls_half_thikness, floor_cylinder_walls_half_thikness );
    float floor_cylinder_borders= max( -sdHorizontalPlane( pos, floor_cylinder_start_height ), sdHorizontalPlane( pos, floor_cylinder_end_height ) );
    float floor_cylinder= max( floor_cylinder_body, floor_cylinder_borders );
    
    float additive_res= min( ground_plane, min( cylinder, floor_cylinder ) );
    
    return max( additive_res, -window );
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
        
    float rot_angle= 0.2 * iTime;
    float c= cos(rot_angle);
    float s= sin(rot_angle);

    mat3 timed_rotate_mat= mat3(
        vec3(c, 0.0, -s),
        vec3(0.0, 1.0, 0.0),
        vec3(s, 0.0, c));

    return tilt_mat * timed_rotate_mat;
}

vec3 TextureFetch3d( vec3 coord, float smooth_size )
{
	vec3 tc_mod= abs( fract( coord ) - vec3( 0.5, 0.5, 0.5 ) );
	vec3 tc_step= smoothstep( 0.25 - smooth_size, 0.25 + smooth_size, tc_mod );

	float bit= abs( abs( tc_step.x - tc_step.y ) - tc_step.z );
	bit= bit * 0.5 + 0.3;
	return vec3( bit, bit, bit );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float pix_size= 2.2 / min(iResolution.x, iResolution.y);
    vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;

    vec3 dir_normalized= normalize(vec3(coord, 1.5));

    vec3 cam_pos= vec3(0.0, 0.0, -256.0);
    
    mat3 rotate_mat= CalculateRotationMatrix();
    dir_normalized= dir_normalized * rotate_mat;
    cam_pos= cam_pos * rotate_mat;
    
    vec3 pos = cam_pos;
    
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
    
    const vec3 sky_color= vec3( 0.7, 0.7, 0.9 );

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
        
        vec3 shadow_pos= pos + 0.1 * normal;
        bool shadow_hit= false;
        const vec3 sun_dir_normalized= normalize(vec3(1.0, 0.5, 0.3));
        for( int i= 0; i < g_max_marcging_iterations; ++i )
        {
            float dist= DistanceFunction( shadow_pos );
            if( dist <= 0.0 )
            {
                shadow_hit= true;
                break;
            }
            shadow_pos+= sun_dir_normalized * max(g_min_marching_step, dist);
        }
        
        float sun_factor= max(0.0, dot(normal, sun_dir_normalized));
        if(shadow_hit)
            sun_factor= 0.0;
            
        const vec3 sun_color= vec3( 0.95, 0.9, 0.6 );
        
        const float coord_scale= 1.0 / 16.0;
            
        float smooth_size= pix_size * coord_scale * length( pos - cam_pos ) / max( 0.01, abs(dot(dir_normalized, normal)) );

        fragColor= vec4( TextureFetch3d(pos * coord_scale, smooth_size) * ( sun_factor * sun_color + sky_color ), 0.0 );
    }
    else
        fragColor= vec4( sky_color, 0.0 );
}