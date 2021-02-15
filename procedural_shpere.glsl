const float pi= 3.1415926535;
const float inv_pi= 1.0 / pi;
const float almost_infitiny= 1.0e16;

// TODO - provide also tex_coord for far point
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
		return vec4( 0.0, 0.0, almost_infitiny, almost_infitiny );
		
	float intersection_offset= sqrt( diff );
	float closest_intersection_dist= vec_to_perependicualar_len - intersection_offset;
	float     far_intersection_dist= vec_to_perependicualar_len + intersection_offset;

	vec3 closest_intersection_pos= start + dir_normalized * closest_intersection_dist;
	vec3 radius_vector= closest_intersection_pos - sphere_center;

	vec3 radius_vector_normalized= radius_vector / sphere_radius;
	vec2 tc= vec2( acos( radius_vector_normalized.y ), atan( radius_vector_normalized.z, radius_vector_normalized.x ) ) * inv_pi;

	return vec4( tc, closest_intersection_dist, far_intersection_dist );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float pix_size= 2.2 / min(iResolution.x, iResolution.y);
	vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;

	float sphere_depth= 2.0;
	float sphere_radius= 0.4;
	vec3 sphere_center= vec3( sphere_depth * ( iMouse.xy - iResolution.xy * 0.5 ) * pix_size , sphere_depth );

	vec3 dir_normalized= normalize(vec3(coord, 1.0));

	vec4 res= getSphereIntersection( vec3( 0.0, 0.0, 0.0 ), dir_normalized, sphere_center, sphere_radius );
	if( res.z >= almost_infitiny )
		fragColor = vec4( 0.0, 0.0, 0.0, 1.0);
	else
		fragColor = vec4( fract( res.xy * 8.0 ), ( res.w - res.z ) / ( sphere_radius * 2.0 ), 1.0);
}