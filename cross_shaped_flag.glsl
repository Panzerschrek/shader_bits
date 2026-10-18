const float tau= 6.2831853071795864769;

const float triangle_radius= 0.28;
const float hex_radius= 0.22;
const float small_triangles_ardius= 0.36;

const float ring_offset= 0.04;
const float ring_width= 0.04;
const float ring_outer_radius= hex_radius - ring_offset;
const float ring_inner_radius= ring_outer_radius - ring_width;

const vec4 triangle_color= vec4( 0.8, 0.75, 0.0, 1.0 );
const vec4 hex_color= vec4( 0.05, 0.05, 0.05, 1.0 );
const vec4 cross_color= vec4( 0.9, 0.1, 0.1, 1.0 );
const vec4 background_color= vec4( 1.0, 1.0, 1.0, 0.0 );

const int ss_scale= 4;

vec4 GetColor( vec2 coord )
{
	float angle= atan( coord.y, -coord.x ) + iTime / 16.0;
	float radius= length( coord );

	float hex_tan= tan( mod( angle + tau / 12.0, tau / 6.0 ) - tau / 12.0 );
	float hex_border= sqrt( 1.0 + hex_tan * hex_tan );

	float triangle_angle= mod( angle + tau / 6.0, tau / 3.0 ) - tau / 6.0;
	float triangle_tan= tan( triangle_angle );
	float triangle_border= sqrt( 1.0 + triangle_tan * triangle_tan );

	float triangle_border_rotated= sqrt( 1.0 + 1.0 / ( triangle_tan * triangle_tan ) );

	float ring_outer_factor= step( radius, hex_border * ring_outer_radius );
	float ring_factor=
		step( hex_border * ring_inner_radius, radius ) *
		step( triangle_angle, 0.0 );

	float cross_half_width= ring_width * 0.5;
	float cross_base_factor= step( radius, triangle_border_rotated * cross_half_width );

	float cross_factor_combined= ring_outer_factor * max( ring_factor, cross_base_factor );

	float small_triangles_factor= 1.0 - step( radius, triangle_border * hex_radius ) * step( hex_border * small_triangles_ardius, radius );

	vec4 flag_color= mix( mix( hex_color, cross_color, cross_factor_combined ), triangle_color, min( step( hex_radius * hex_border, radius ), small_triangles_factor ) );

	return mix( flag_color, background_color, step( triangle_radius * triangle_border, radius ) );
}

void mainImage( out vec4 frag_color, in vec2 frag_coord )
{
	vec4 color_sum= vec4( 0.0, 0.0, 0.0, 0.0 );

	float pix_size= triangle_radius * 4.5 / min( iResolution.x, iResolution.y );

	for( int dy= 0; dy < ss_scale; ++dy )
	{
		for( int dx= 0; dx < ss_scale; ++dx )
		{
			vec2 coord= ( frag_coord.xy - iResolution.xy * 0.5 + vec2( float(dx), float(dx) ) / float( ss_scale ) ) * pix_size;
			color_sum+= GetColor( coord );
		}
	}

	frag_color= color_sum / float( ss_scale * ss_scale );
}
