const float g_two_pi= 2.0 * 3.1415926535;

const float g_min_marching_step= 0.08;
const int g_max_marching_iterations= 256;
const float g_min_shadow_marching_step= g_min_marching_step * 2.0;
const int g_max_shadow_marching_iterations= g_max_marching_iterations / 2;
const float g_derivative_calculation_delta= 0.02;

const float max_distance= 500.0;
const vec3 sun_dir_normalized= normalize(vec3(1.0, 1.1, -0.3));

const vec3 sky_color= vec3( 0.7, 0.7, 0.9 );
const vec3 sun_color= vec3( 0.95, 0.9, 0.6 );

const float tc_scale= 1.0 / 6.0;
const float tc_angle= g_two_pi / 16.0;

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdCone( vec3 p, vec2 c )
{
  
  float u= length(p.xz);
  float v= p.y;
  
  return u * c.y + v * c.x;
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
    
    const float seats_cone_angle= 0.65;
    const float seats_radius= 108.0;
    const vec3 seats_cone_center= vec3( 0.0, -78.0, 0.0 );
  
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
    
    float roof_cone= 
        opSubtraction(
            sdCone( pos_within_sector - roof_cone_center, vec2( cos(roof_cone_angle), sin(roof_cone_angle) ) ),
            sdHorizontalPlane( pos_within_sector - roof_cone_center, -roof_cone_height ) );
            
    float roof_cone_sphere= sdSphere( pos_within_sector - roof_cone_sphere_center, roof_cone_sphere_radius );
    float roof_cone_total= opUnion( roof_cone, roof_cone_sphere );
    
    float additive_res= opUnion( opUnion( column_cylinder, opUnion( cylinder, trimming_cylinder ) ), roof_cone_total );
    
    float building= opSubtraction( additive_res, opUnion( opUnion( window0, window1 ),opUnion( window2, entrance_box ) ) );
    
    float seats_cone= sdCone( -(pos - seats_cone_center), vec2( cos(seats_cone_angle), sin(seats_cone_angle) ) );
    float seats_cylinder_body= sdYInfiniteCylinder( pos_within_sector - seats_cone_center, seats_radius );
    float seats= opSubtraction( seats_cylinder_body, seats_cone);
        
    float entrance_torus= 
        opUnion(
            sdTorus( ( vec3( abs(pos.x), pos.y, pos.z ) - entrance_torus_center ).yxz, entrance_torus_size ),
            sdTorus( ( vec3( abs(pos.z), pos.y, pos.x ) - entrance_torus_center ).yxz, entrance_torus_size ) );

    return opUnion( opUnion( seats, building ), opUnion( ground_plane, entrance_torus ) );
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

float CheckerboardTextureBase( vec2 coord, float smooth_size )
{
    vec2 tc_mod= abs( fract( coord ) - vec2( 0.5, 0.5 ) );
    vec2 tc_step= smoothstep( 0.25 - smooth_size, 0.25 + smooth_size, tc_mod );

    return abs( tc_step.x - tc_step.y );
}

float CheckerboardTextureModulate( float val )
{
    return  val * 0.4 + 0.4;
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
    
    float distance_traced= 0.0;
    vec3 pos= cam_pos;
    
    bool hit= false;
        
    for( int i= 0; i < g_max_marching_iterations; ++i )
    {
        pos= cam_pos + dir_normalized * distance_traced;
        float dist= DistanceFunction( pos );
        if( dist <= 1.5 * g_min_marching_step )
        {
            hit= true;
            break;
        }
        distance_traced+= max(g_min_marching_step, dist);
        if( distance_traced > max_distance )
            break;
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
        

        float sun_factor= max(0.0, dot(normal, sun_dir_normalized));
        
        vec3 shadow_pos= pos + g_min_shadow_marching_step * normal;
        
        float shadow_distance_traced= 0.0;
        for( int i= 0; i < g_max_shadow_marching_iterations; ++i )
        {
            
            float dist= DistanceFunction( shadow_pos + shadow_distance_traced * sun_dir_normalized );
            if( dist <= 0.75 * g_min_shadow_marching_step )
            {
                sun_factor= 0.0;
                break;
            }
            shadow_distance_traced+= max(g_min_shadow_marching_step, dist);
            if(shadow_distance_traced > max_distance )
                break;
        }
        
        float sky_factor= normal.y * 0.35 + 0.65;
                        
        float smooth_size= tc_scale * pix_size * distance_traced / max( 0.01, abs(dot(dir_normalized, normal)) );

        vec3 tc_base= pos * tc_scale;
        
        vec2 tc_axis0_rotated= vec2( tc_base.x * cos(+tc_angle) - tc_base.y * sin(+tc_angle), tc_base.x * sin(+tc_angle) + tc_base.y * cos(+tc_angle) );
        vec2 tc_axis1_rotated= vec2( tc_base.y * cos(-tc_angle) - tc_base.z * sin(-tc_angle), tc_base.y * sin(-tc_angle) + tc_base.z * cos(-tc_angle) );
        
        // Triplanar texturing.
        float tex_value=
            CheckerboardTextureBase( tc_axis0_rotated, smooth_size ) * (normal.z * normal.z) +
            CheckerboardTextureBase( tc_base.xz, smooth_size ) * (normal.y * normal.y) + 
            CheckerboardTextureBase( tc_axis1_rotated, smooth_size ) * (normal.x * normal.x);
        
        tex_value= CheckerboardTextureModulate( tex_value );
        
        fragColor= vec4( vec3( tex_value ) * ( sun_factor * sun_color + sky_factor * sky_color ), 0.0 );
    }
    else
        fragColor= vec4( sky_color, 0.0 );
}