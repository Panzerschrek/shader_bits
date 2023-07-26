const float pi= 3.1515926535;
const float half_pi= 0.5 * pi;
const float two_pi= 2.0 * pi;
const float inv_two_pi= 1.0 / two_pi;

const float spiral_step_base= 0.69;
const float spiral_width_ratio= 0.3;

const vec3 color_phase_scale= vec3( 11.0, 13.0, 17.0 );
const vec3 color_change_speed= vec3( 6.0, 8.0, 10.0 );

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float screen_scale= min( iResolution.x, iResolution.x ) / 1024.0;

	vec2 center= iResolution.xy * 0.5;
	vec2 radius_vector= fragCoord - center;
	float radius_vector_length= length( radius_vector );

	fragColor= vec4( radius_vector, 1.0, 1.0 );

	float spiral_step= spiral_step_base;
	float spiral_width= spiral_width_ratio * spiral_step;

	float spiral_phase= ( atan( radius_vector.y, radius_vector.x ) + pi ) * inv_two_pi;

	float r= log( radius_vector_length ) + spiral_step * ( -iTime + spiral_phase );
	float mod_r=  fract( r / spiral_step );
    float radial_color_factor= cos( fract( r / spiral_step ) * two_pi ) * 0.5 + 0.5;
    
    float azimuthal_color_factor= fract( spiral_phase * 4.01 + iTime + 0.5 * log(radius_vector_length) + 0.005 * sin(r * 50.0) );
    float border_k= fract( r / spiral_step + 0.004 * sin(spiral_phase * 500.0)  );
    float border_factor=
        smoothstep( 0.0, 1.0 / radius_vector_length, border_k ) * 
        ( 1.0 - smoothstep( 6.0 / radius_vector_length, 7.0 / radius_vector_length, border_k ) );
        
    float split_factor= step( 3.0 / radius_vector_length, azimuthal_color_factor );
        
    vec4 spiral_color= mix( vec4( 0.8, 0.7, 0.6, 1.0 ), vec4( 0.7, 0.6, 0.5, 1.0 ), radial_color_factor );
    vec4 border_color= vec4( 0.35, 0.25, 0.15, 1.0 );
    vec4 split_color= vec4( 0.3, 0.2, 0.1, 1.0 );
    
	fragColor=
		mix( spiral_color, border_color, border_factor );
    
    fragColor= mix( split_color, fragColor, split_factor );
}
