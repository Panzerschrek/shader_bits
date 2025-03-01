const float g_two_pi= 2.0 * 3.1415926535;

const float g_min_marching_step= 0.08;
const int g_max_marching_iterations= 256;
const float g_min_shadow_marching_step= g_min_marching_step * 2.0;
const int g_max_shadow_marching_iterations= g_max_marching_iterations / 2;
const float g_derivative_calculation_delta= 0.02;

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdCone( vec3 p, vec2 c, float h )
{
  // c is the sin/cos of the angle, h is height
  // Alternatively pass q instead of (c,h),
  // which is the point at the base in 2D
  vec2 q = h*vec2(c.x/c.y,-1.0);
    
  vec2 w = vec2( length(p.xz), p.y );
  vec2 a = w - q*clamp( dot(w,q)/dot(q,q), 0.0, 1.0 );
  vec2 b = w - q*vec2( clamp( w.x/q.x, 0.0, 1.0 ), 1.0 );
  float k = sign( q.y );
  float d = min(dot( a, a ),dot(b, b));
  float s = max( k*(w.x*q.y-w.y*q.x),k*(w.y-q.y)  );
  return sqrt(d)*sign(s);
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

float opUnion( float d1, float d2 )
{
    return min(d1, d2);
}

float opIntersection( float d1, float d2 )
{
    return max(d1 ,d2);
}

float opSubtraction( float d1, float d2 )
{
    return opIntersection(d1, -d2);
}

float DistanceFunction( vec3 pos )
{
    const int num_sectors= 24;
    const float sector_scale = g_two_pi / float(num_sectors);
    float sector_radius= length( pos.xz );
    // From -0.5 to 0.5
    float angle_within_sector= (fract( atan(pos.z, pos.x) / sector_scale ) - 0.5) * sector_scale;
    
    const float half_sector_angle= g_two_pi * 0.5 / float(num_sectors);
    const float half_sector_angle_cos= cos(half_sector_angle);
    const float half_sector_angle_sin= sin(half_sector_angle);
    
    vec3 pos_within_sector= vec3( cos(angle_within_sector) * sector_radius, pos.y, sin(angle_within_sector) * sector_radius );
    
    const float cylinder_height= 128.0;
    const float ground_level= -40.0;
    const float cylinder_radius= 128.0;
    const float cylinder_walls_half_thikness= 6.0;
    const float trimming_cylinder_walls_half_thikness= 9.0;
    const float window0_radius= 12.0;
    const vec3 window0_center= vec3( 0.0, 64.0, 0.0 );
    const float window0_box_half_height= 8.0;
    const float window0_box_half_depth= cylinder_walls_half_thikness * 4.0;
    const vec3 window0_box_center= vec3( cylinder_radius, window0_center.y - window0_box_half_height, 0.0 );
    const float trimming_cylinder_start_height= window0_center.y + window0_radius + 2.0;
    const float trimming_cylinder_end_height= trimming_cylinder_start_height + 4.0;
    const float column_cylinder_radius= 2.0;
    const vec3 column_cylinder_pos0= vec3( cylinder_radius * half_sector_angle_cos, 0.0, +cylinder_radius * half_sector_angle_sin );
    const vec3 column_cylinder_pos1= vec3( cylinder_radius * half_sector_angle_cos, 0.0, -cylinder_radius * half_sector_angle_sin );
    
    const float window1_radius= 10.0;
    const vec3 window1_center= vec3( 0.0, window0_center.y - 36.0, 0.0 );
    const float window1_box_half_height= 7.0;
    const float window1_box_half_depth= cylinder_walls_half_thikness * 4.0;
    const vec3 window1_box_center= vec3( cylinder_radius, window1_center.y - window1_box_half_height, 0.0 );
  
    const float window2_radius= 8.0;
    const vec3 window2_center= vec3( 0.0, window1_center.y - 32.0, 0.0 );
    const float window2_box_half_height= 6.0;
    const float window2_box_half_depth= cylinder_walls_half_thikness * 4.0;
    const vec3 window2_box_center= vec3( cylinder_radius, window2_center.y - window2_box_half_height, 0.0 );
  
    const vec3 entrance_box_half_size= vec3( cylinder_walls_half_thikness * 4.0, 6.0, 3.0 );
    const vec3 entrance_box0_center= vec3( cylinder_radius, ground_level + entrance_box_half_size.y, +5.0 );
    const vec3 entrance_box1_center= vec3( cylinder_radius, ground_level + entrance_box_half_size.y, -5.0 );

    const float roof_cone_angle= 1.52;
    const vec3 roof_cone_center= vec3( cylinder_radius - cylinder_walls_half_thikness, window0_center.y + 40.0, 0.0 );
    const float roof_cone_height= 16.0;
    const vec3 roof_cone_sphere_center= roof_cone_center - vec3( 0.0, 10.0, 0.0 );
    const float roof_cone_sphere_radius= 1.5;
    
    const vec3 entrance_torus_center= vec3( cylinder_radius + 20.0, -40.0, 0.0 );
    const vec2 entrance_torus_size= vec2( 20.0, 3.0 );
  
    float ground_plane= sdHorizontalPlane( pos, ground_level );
    
    float window0=
        opUnion(
            sdXInfiniteCylinder( pos_within_sector - window0_center, window0_radius ),
            sdBox( pos_within_sector - window0_box_center, vec3( window0_box_half_depth, window0_box_half_height, window0_radius ) ) );
    
    float window1=
        opUnion(
            sdXInfiniteCylinder( pos_within_sector - window1_center, window1_radius ),
            sdBox( pos_within_sector - window1_box_center, vec3( window1_box_half_depth, window1_box_half_height, window1_radius ) ) );
    
    float window2=
        opUnion(
            sdXInfiniteCylinder( pos_within_sector - window2_center, window2_radius ),
            sdBox( pos_within_sector - window2_box_center, vec3( window2_box_half_depth, window2_box_half_height, window2_radius ) ) );
       
    float entrance_box=
        opUnion(
            sdBox( pos_within_sector - entrance_box0_center, entrance_box_half_size ),
            sdBox( pos_within_sector - entrance_box1_center, entrance_box_half_size ) );
    
    float cylinder_body= sdYInfiniteHollowCylinder( pos, cylinder_radius - cylinder_walls_half_thikness, cylinder_walls_half_thikness );
    float cylinder_top= sdHorizontalPlane( pos, ground_level + cylinder_height );
    float cylinder= opIntersection( cylinder_top, cylinder_body );
    
    float trimming_cylinder_body= sdYInfiniteHollowCylinder( pos, cylinder_radius - cylinder_walls_half_thikness, trimming_cylinder_walls_half_thikness );
    float trimming_cylinder_bottom= -sdHorizontalPlane( pos, trimming_cylinder_start_height );
    float trimming_cylinder_top= sdHorizontalPlane( pos, trimming_cylinder_end_height );
    float trimming_cylinder_borders= opIntersection( trimming_cylinder_bottom, trimming_cylinder_top );
    float trimming_cylinder= opIntersection( trimming_cylinder_body, trimming_cylinder_borders );
    
    float column_cylinder_body0= sdYInfiniteCylinder( pos_within_sector - column_cylinder_pos0, column_cylinder_radius );
    float column_cylinder_body1= sdYInfiniteCylinder( pos_within_sector - column_cylinder_pos1, column_cylinder_radius );
    float column_cylinder_body= opUnion( column_cylinder_body0, column_cylinder_body1 );
    float column_cylinder= opIntersection( trimming_cylinder_top, column_cylinder_body );
    
    float roof_cone= sdCone( pos_within_sector - roof_cone_center, vec2( cos(roof_cone_angle), sin(roof_cone_angle) ), roof_cone_height );
    float roof_cone_sphere= sdSphere( pos_within_sector - roof_cone_sphere_center, roof_cone_sphere_radius );
    float roof_cone_total= opUnion( roof_cone, roof_cone_sphere );
    
    float additive_res= opUnion( opUnion( ground_plane, opUnion( column_cylinder, opUnion( cylinder, trimming_cylinder ) ) ), roof_cone_total );
    
    float building= opSubtraction( additive_res, opUnion( opUnion( window0, window1 ),opUnion( window2, entrance_box ) ) );
    
    float entrance_torus= 
        opUnion(
            sdTorus( ( vec3( abs(pos.x), pos.y, pos.z ) - entrance_torus_center ).yxz, entrance_torus_size ),
            sdTorus( ( vec3( abs(pos.z), pos.y, pos.x ) - entrance_torus_center ).yxz, entrance_torus_size ) );

    return opUnion( building, entrance_torus );
}

mat3 CalculateRotationMatrix()
{
    const float tilt_angle= 0.4;
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
    float pix_size= 2.0 / min(iResolution.x, iResolution.y);
    vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;

    vec3 dir_normalized= normalize(vec3(coord, 1.5));

    vec3 cam_pos= vec3(0.0, 0.0, -250.0);
    
    mat3 rotate_mat= CalculateRotationMatrix();
    dir_normalized= dir_normalized * rotate_mat;
    cam_pos= cam_pos * rotate_mat;
    
    vec3 pos = cam_pos;
    
    bool hit= false;
    for( int i= 0; i < g_max_marching_iterations; ++i )
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
        const vec3 sun_dir_normalized= normalize(vec3(1.0, 1.1, -0.3));
        for( int i= 0; i < g_max_shadow_marching_iterations; ++i )
        {
            float dist= DistanceFunction( shadow_pos );
            if( dist <= 0.0 )
            {
                shadow_hit= true;
                break;
            }
            shadow_pos+= sun_dir_normalized * max(g_min_shadow_marching_step, dist);
        }
        
        float sun_factor= max(0.0, dot(normal, sun_dir_normalized));
        if(shadow_hit)
            sun_factor= 0.0;
            
        float sky_factor= normal.y * 0.35 + 0.65;
            
        const vec3 sun_color= vec3( 0.95, 0.9, 0.6 );
        
        const float coord_scale= 1.0 / 8.0;
            
        float smooth_size= pix_size * coord_scale * length( pos - cam_pos ) / max( 0.01, abs(dot(dir_normalized, normal)) );

        fragColor= vec4( TextureFetch3d(pos * coord_scale, smooth_size) * ( sun_factor * sun_color + sky_factor * sky_color ), 0.0 );
    }
    else
        fragColor= vec4( sky_color, 0.0 );
}