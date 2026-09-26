float c_scale= 16.0;

float c_base_circle_radius= 0.2;
float c_base_circle_offset= 0.1;

void mainImage( out vec4 frag_color, in vec2 frag_coord )
{
	vec2 texture_size= vec2( textureSize( iChannel0, 0 ) );

	vec2 cell_coord= c_scale * frag_coord / max( iResolution.x, iResolution.y );

	vec2 cell_coord_integer_centered= floor( cell_coord ) + vec2( 0.5, 0.5 );
	vec2 coord_within_cell= fract( cell_coord );

	vec2 cell_coord_tweaked= cell_coord_integer_centered;

	float border_rand_x_plus = texture( iChannel0, ( cell_coord_integer_centered + vec2( 1.0, 0.0 ) ) / texture_size ).a;
	float border_rand_x_minus= texture( iChannel0, ( cell_coord_integer_centered + vec2( 0.0, 0.0 ) ) / texture_size ).a;
	float border_rand_y_plus = texture( iChannel0, ( cell_coord_integer_centered + vec2( 0.0, 1.0 ) ) / texture_size ).a;
	float border_rand_y_minus= texture( iChannel0, ( cell_coord_integer_centered + vec2( 0.0, 0.0 ) ) / texture_size ).a;

	if( border_rand_x_plus  >  0.5 )
	{
		float circle_radius_squared= c_base_circle_radius * c_base_circle_radius;
		float circle_offset= 1.0 - c_base_circle_offset;

		vec2 vec_to_circle_center= coord_within_cell - vec2( circle_offset, 0.5 );

		float circle_step= step( dot( vec_to_circle_center, vec_to_circle_center ), circle_radius_squared );

		cell_coord_tweaked+= vec2( circle_step, 0.0 );
	}
	if( border_rand_x_minus <= 0.5 )
	{
		float circle_radius_squared= c_base_circle_radius * c_base_circle_radius;
		float circle_offset= c_base_circle_offset;

		vec2 vec_to_circle_center= coord_within_cell - vec2( circle_offset, 0.5 );

		float circle_step= step( dot( vec_to_circle_center, vec_to_circle_center ), circle_radius_squared );

		cell_coord_tweaked+= vec2( -circle_step, 0.0 );
	}
	if( border_rand_y_plus  >  0.5 )
	{
		float circle_radius_squared= c_base_circle_radius * c_base_circle_radius;
		float circle_offset= 1.0 - c_base_circle_offset;

		vec2 vec_to_circle_center= coord_within_cell - vec2( 0.5, circle_offset );

		float circle_step= step( dot( vec_to_circle_center, vec_to_circle_center ), circle_radius_squared );

		cell_coord_tweaked+= vec2( 0.0, circle_step );
	}
	if( border_rand_y_minus <= 0.5 )
	{
		float circle_radius_squared= c_base_circle_radius * c_base_circle_radius;
		float circle_offset= c_base_circle_offset;

		vec2 vec_to_circle_center= coord_within_cell - vec2( 0.5, circle_offset );

		float circle_step= step( dot( vec_to_circle_center, vec_to_circle_center ), circle_radius_squared );

		cell_coord_tweaked+= vec2( 0.0, -circle_step );
	}

	frag_color= texture( iChannel0, cell_coord_tweaked / texture_size );
}
