void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv= fragCoord / iResolution.y * 2.0;
	float x_fract= fract(uv.x);
	float x_ceil= ceil(uv.x);

	const float radius= sqrt(0.5);
	const float ring_inv_size= 12.0;
	const float tau= 2.0 * 3.1415926535;
	const float sectors= ceil(tau * radius * ring_inv_size / 8.0) * 8.0;

	float x= x_fract - 0.5;
	float y_offset= sqrt( max( 0.0, radius * radius - x * x ) );

	float y= ( uv.y - y_offset ) * ring_inv_size;
	float y_fract= fract( y );
	float ring= ceil(y);
	float y_corrected= y_fract / ring_inv_size + y_offset;

	vec2 radius_vec= vec2( x, y_corrected - 1.0 / ring_inv_size );
	float angle= atan( radius_vec.x, radius_vec.y );

	float angle_pattern= angle / tau * sectors;
	float sector_fract= fract(angle_pattern);
	float sector= ceil(angle_pattern);

	const float mortal_angular_size= 0.1;
	float mortar_left= step( mortal_angular_size, sector_fract );
	float mortar_right= step( sector_fract, 1.0 - mortal_angular_size );
	float mortar_angular= mortar_left * mortar_right;

	const float mortar_radial_size= 0.1;
	float mortar_down= step( mortar_radial_size, y_fract );
	float mortar_up= step( y_fract, 1.0 - mortar_radial_size );
	float mortar_radial= mortar_down * mortar_up;

	float mortar= mortar_angular * mortar_radial;

	vec3 c= textureLod( iChannel0, vec2( sector + (sectors / 4.0 + 1.0) * x_ceil, ring ) / 64.0, 0.0 ).rgb;

	fragColor = mortar * vec4( c, 1.0 );
}