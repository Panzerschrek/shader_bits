const float pi= 3.1415926535;
const float inv_pi= 1.0 / pi;
const float almost_infinity= 1.0e16;

// returns min/max
vec2 getBeamPlaneIntersectionRange( vec3 plane_point, vec3 plane_normal, vec3 beam_point, vec3 beam_dir_normalized )
{
	float signed_distance_to_plane= dot( plane_normal, plane_point - beam_point ); 
	float dirs_dot = dot( plane_normal, beam_dir_normalized );
	if( dirs_dot == 0.0 )
		return vec2( -almost_infinity, +almost_infinity );
		
	float dist= signed_distance_to_plane / dirs_dot;
	if( dirs_dot > 0.0 )
		return vec2( -almost_infinity, dist );
	else
		return vec2( dist, +almost_infinity );
}

vec2 multiplyRanges( vec2 range0, vec2 range1 )
{
	return vec2( max( range0.x, range1.x ), min( range0.y, range1.y ) );
}

// x, y - tex_coord, z - near distance, w - far distance
vec4 getSphereIntersection( vec3 start, vec3 dir_normalized, vec3 sphere_center, float sphere_radius )
{
	vec3 dir_to_center= sphere_center - start;
	float vec_to_perependicualar_len= dot(dir_normalized, dir_to_center);
	vec3 vec_to_perependicualar= vec_to_perependicualar_len * dir_normalized;
	vec3 vec_from_closest_point_to_center= dir_to_center - vec_to_perependicualar;

	float square_dist_to_center= dot( vec_from_closest_point_to_center, vec_from_closest_point_to_center );
	float diff= sphere_radius * sphere_radius - square_dist_to_center;
	if( diff < 0.0 )
		return vec4( 0.0, 0.0, almost_infinity, almost_infinity );
		
	float intersection_offset= sqrt( diff );
	float closest_intersection_dist= vec_to_perependicualar_len - intersection_offset;
	float     far_intersection_dist= vec_to_perependicualar_len + intersection_offset;

	vec3 closest_intersection_pos= start + dir_normalized * closest_intersection_dist;
	vec3 radius_vector= closest_intersection_pos - sphere_center;

	vec3 radius_vector_normalized= radius_vector / sphere_radius;
	vec2 tc= vec2( acos( radius_vector_normalized.y ), atan( radius_vector_normalized.z, radius_vector_normalized.x ) ) * inv_pi;

	return vec4( tc, closest_intersection_dist, far_intersection_dist );
}

vec4 getCubeIntersection( vec3 start, vec3 dir_normalized, vec3 cube_center, float cube_radius )
{
	vec2 x_plus = getBeamPlaneIntersectionRange( cube_center + vec3( +cube_radius, 0.0, 0.0 ), vec3( +1.0, 0.0, 0.0 ), start, dir_normalized );
	vec2 x_minus= getBeamPlaneIntersectionRange( cube_center + vec3( -cube_radius, 0.0, 0.0 ), vec3( -1.0, 0.0, 0.0 ), start, dir_normalized );
	vec2 y_plus = getBeamPlaneIntersectionRange( cube_center + vec3( 0.0, +cube_radius, 0.0 ), vec3( 0.0, +1.0, 0.0 ), start, dir_normalized );
	vec2 y_minus= getBeamPlaneIntersectionRange( cube_center + vec3( 0.0, -cube_radius, 0.0 ), vec3( 0.0, -1.0, 0.0 ), start, dir_normalized );
	vec2 z_plus = getBeamPlaneIntersectionRange( cube_center + vec3( 0.0, 0.0, +cube_radius ), vec3( 0.0, 0.0, +1.0 ), start, dir_normalized );
	vec2 z_minus= getBeamPlaneIntersectionRange( cube_center + vec3( 0.0, 0.0, -cube_radius ), vec3( 0.0, 0.0, -1.0 ), start, dir_normalized );

	vec2 x_range= multiplyRanges( x_plus, x_minus );
	vec2 y_range= multiplyRanges( y_plus, y_minus );
	vec2 z_range= multiplyRanges( z_plus, z_minus );

	vec2 result_range= multiplyRanges( multiplyRanges( x_range, y_range ), z_range );
	result_range= multiplyRanges( result_range, vec2( 0.01, almost_infinity ) );
	return vec4( 0.0, 0.0, result_range );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float pix_size= 2.2 / min(iResolution.x, iResolution.y);
	vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;

	float cube_depth= 2.0;
	float cube_radius= 0.4;
	vec3 cube_center= vec3( cube_depth * ( iMouse.xy - iResolution.xy * 0.5 ) * pix_size , cube_depth );

	vec3 dir_normalized= normalize(vec3(coord, 1.0));

	vec3 cam_pos= vec3( 0.0, 0.0, 0.0 );
	vec4 cube_res= getCubeIntersection( cam_pos, dir_normalized, cube_center, cube_radius );
	vec4 sphere_res= getSphereIntersection( cam_pos, dir_normalized, cube_center, cube_radius * 1.2 );

	vec4 res= vec4( 0.0, 0.0, multiplyRanges( cube_res.zw, sphere_res.zw ) );
	if( sphere_res.z < cube_res.z )
		res.xy= vec2( 0.0, 0.0 );
	else
		res.xy= sphere_res.xy;
		
	if( res.z > res.w )
		fragColor= vec4( 0.0, 0.0, 0.0, 0.0 );
	else
		fragColor = vec4( fract( res.xy * 8.0 ), ( res.w - res.z ) / ( cube_radius * 2.0 ), 1.0);
}