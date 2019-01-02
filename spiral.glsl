const float pi= 3.1515926535;
const float half_pi= 0.5 * pi;
const float two_pi= 2.0 * pi;
const float inv_two_pi= 1.0 / two_pi;

const float spiral_step_base= 45.0;
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

	float spiral_step= spiral_step_base * screen_scale;
	float spiral_width= spiral_width_ratio * spiral_step;

	float spiral_phase= ( atan( radius_vector.y, radius_vector.x ) + pi ) * inv_two_pi;

	float r= radius_vector_length + spiral_step * ( -iTime + spiral_phase );
	float mod_r=  mod( r, spiral_step );

	vec3 color= vec3(
		0.5 * sin( ( spiral_phase * color_phase_scale.r + ( radius_vector_length / spiral_step ) * 0.3 ) * two_pi + color_change_speed.r * iTime ) + 0.5,
		0.5 * sin( ( spiral_phase * color_phase_scale.g + ( radius_vector_length / spiral_step ) * 0.3 ) * two_pi + color_change_speed.g * iTime ) + 0.5,
		0.5 * sin( ( spiral_phase * color_phase_scale.b + ( radius_vector_length / spiral_step ) * 0.3 ) * two_pi + color_change_speed.b * iTime ) + 0.5 );

	color= round( color * 4.0 ) / 4.0;

	fragColor=
		vec4( color, 1.0 ) *
		smoothstep( 0.0, 1.0, mod_r ) *
		( 1.0 - smoothstep( spiral_width - 1.0, spiral_width, mod_r ) );
}
