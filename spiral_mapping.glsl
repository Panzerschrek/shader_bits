// Inspired by https://www.youtube.com/watch?v=ldxFjLJ3rVY.
// How (and why) to take a logarithm of an image

const float tau= 6.283185307;

float spiral_scale= 4.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float pix_size= 2.2 / min( iResolution.x, iResolution.y );
	vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;

	float angle= atan( coord.y, coord.x );
	float radius= length( coord );

	float scaled_radius= radius * exp( ( log( spiral_scale ) / tau ) * angle );

	vec2 grid_coord= vec2( cos( angle ), sin( angle ) ) * scaled_radius;

	vec2 grid2d= step( fract( grid_coord * 8.0 ), vec2( 0.15, 0.15 ) );

	float global_bounds=
		step( -0.5, coord.x ) *
		step( coord.x, 0.5 ) *
		step( -0.5, coord.y ) *
		step( coord.y, 0.5 ) * 0.5 + 0.5;

	float tc_bounds=
		step( -1.0, grid_coord.x ) *
		step( grid_coord.x, 1.0 ) *
		step( -1.0, grid_coord.y ) *
		step( grid_coord.y, 1.0 );

	vec4 tex_value=
		texture( iChannel0, grid_coord * 0.5 + vec2( 0.5, 0.5 ) );

	fragColor= vec4( grid2d * 0.5, 0.0, 1.0 ) + tex_value * tc_bounds;

	float center_circle= smoothstep( radius - pix_size, radius + pix_size, 0.015 );
	fragColor= mix( fragColor, vec4( 0.0, 0.0, 1.0, 0.0 ), center_circle );

	fragColor= mix( vec4( 0.0, 0.0, 0.0, 0.0 ), fragColor, global_bounds );
}
