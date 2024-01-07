const float tau= 2.0 * 3.1415926535;

const float radius= sqrt(0.5);
const float ring_inv_size= 12.0;
const float sectors= ceil(tau * radius * ring_inv_size / 8.0) * 8.0;
const float mortal_angular_size= 0.07;
const float mortar_radial_size= 0.07;

const vec3 mortar_color= vec3( 0.16, 0.15, 0.14 );
const float saturation= 0.3;

const vec2 scroll_speed= vec2( 0.06, 0.12 );
const float pattern_scale= 2.0;

const int ss_factor= 3;

vec3 Pavement( vec2 uv )
{
	float x_fract= fract(uv.x);
	float x_ceil= ceil(uv.x);

	float x= x_fract - 0.5;
	float y_offset= sqrt( max( 0.0, radius * radius - x * x ) );

	float y= ( uv.y - y_offset ) * ring_inv_size;
	float y_fract= fract(y);
	float ring= ceil(y);
	float y_corrected= y_fract / ring_inv_size + y_offset;

	vec2 radius_vec= vec2( x, y_corrected - 1.0 / ring_inv_size );
	float angle= atan( radius_vec.x, radius_vec.y );

	float angle_pattern= angle / tau * sectors;
	float sector_fract= fract(angle_pattern);
	float sector= ceil(angle_pattern);

	float mortar_left= step( mortal_angular_size, sector_fract );
	float mortar_right= step( sector_fract, 1.0 - mortal_angular_size );
	float mortar_angular= mortar_left * mortar_right;

	float mortar_down= step( mortar_radial_size, y_fract );
	float mortar_up= step( y_fract, 1.0 - mortar_radial_size );
	float mortar_radial= mortar_down * mortar_up;

	float mortar= mortar_angular * mortar_radial;

	vec2 tc= vec2( sector + (sectors / 4.0 + 1.0) * x_ceil, ring ) + vec2( 0.5, 0.5 );

	vec3 tex_color= textureLod( iChannel0, tc / 64.0, 0.0 ).rgb;

	float tex_brightness= dot( tex_color, vec3( 0.299, 0.587, 0.114 ) );
	vec3 tex_color_desaturated= mix( vec3( tex_brightness ), tex_color, saturation );

	vec3 result_color= mix( mortar_color, tex_color_desaturated, mortar );

	return result_color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 coord_shift= iTime * scroll_speed;
	float scale_factor= pattern_scale / max( iResolution.y, iResolution.x );

	vec3 result_color= vec3( 0.0, 0.0, 0.0 );
	for( int dx= 0; dx < ss_factor; ++dx )
	for( int dy= 0; dy < ss_factor; ++dy )
	{
		vec2 uv= ( fragCoord + vec2( float(dx), float(dy) ) / float(ss_factor) ) * scale_factor;
		result_color+= Pavement( uv + coord_shift );
	}

	fragColor = vec4( result_color / float( ss_factor * ss_factor ), 1.0 );
}