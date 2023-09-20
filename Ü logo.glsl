const float pi = 3.1415926535;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float aspect= iResolution.y / iResolution.x;
	vec2 uv= ( ( (fragCoord - 0.5 * iResolution.xy) * 1.7 * vec2( 1.0, aspect ) ) + 0.5 * iResolution.xy ) / iResolution.xy;
	uv+= vec2( 0.4, 0.0 );
	float right_clamp= 0.95;
	vec2 uv_clamped= clamp( uv, vec2( 0.05, 0.0 ), vec2( right_clamp, 1.0 ) );

	uv_clamped += vec2( 12.0, 2.0 );
	uv_clamped /= 16.0;

	float grad_scale= 12.0;

	vec2 radius_vec= uv - vec2( 0.5, 0.5 );
	float angle= atan( radius_vec.y, radius_vec.x );
	float angle_fract= fract( 16.0 * ( angle + pi ) / (2.0 * pi ) );
	float angle_step= step( 0.25, angle_fract ) * ( 1.0 - step( 0.75, angle_fract ) );
	float invert_factor= angle_step * 2.0 - 1.0;

	vec4 tex_value= texture( iChannel0, uv_clamped );
	float grad_scaled= tex_value.w * grad_scale;

	if( uv.x >= right_clamp )
		grad_scaled+= (uv.x - right_clamp) * grad_scale;

	float grad_corrected= grad_scaled - 0.46 * grad_scale;
	float grad_fract= fract( grad_scaled * invert_factor );
	vec3 background_gradient= mix( vec3( 0.8, 0.4, 0.1 ), vec3( 0.2, 0.6, 1.0 ), grad_fract );
	float neon_factor_base= ( 0.51 - abs( grad_fract - 0.5 ) );
	float neon_factor= 0.2 / neon_factor_base;
	float char_smooth= 1.0 - smoothstep( 0.47, 0.53, min( grad_corrected, 1.0 ) );
	vec3 c= mix( neon_factor * background_gradient, vec3( 0.0, 0.0, 0.0), char_smooth );
	fragColor= vec4( c, 1.0 );
}