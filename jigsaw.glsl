float c_scale= 16.0;

vec3 GetCircleParams( vec3 rand )
{
	return
		vec3(
			0.4 + 0.2 * rand.y,
			0.08 + 0.04 * rand.z,
			0.15 * ( 0.9 + rand.x * 0.2 ) );
}

void mainImage( out vec4 frag_color, in vec2 frag_coord )
{
	vec2 texture_size= vec2( textureSize( iChannel0, 0 ) );

	vec2 cell_coord= c_scale * frag_coord / max( iResolution.x, iResolution.y );

	vec4 line_offset_x= textureLod( iChannel0, vec2( cell_coord.y * 0.5, 0.0 ) / texture_size, 0.0 );
	vec4 line_offset_y= textureLod( iChannel0, vec2( 0.0, cell_coord.x * 0.5 ) / texture_size, 0.0 );

	cell_coord+= 0.25 * vec2( line_offset_x.a, line_offset_y.a );

	vec2 cell_coord_integer_centered= floor( cell_coord ) + vec2( 0.5, 0.5 );
	vec2 coord_within_cell= fract( cell_coord );

	vec2 cell_coord_tweaked= cell_coord_integer_centered;

	vec4 border_rand_x_plus = textureLod( iChannel0, ( cell_coord_integer_centered + vec2( 1.0, 0.0 ) ) / texture_size, 0.0 );
	vec4 border_rand_x_minus= textureLod( iChannel0, ( cell_coord_integer_centered + vec2( 0.0, 0.0 ) ) / texture_size, 0.0 );
	vec4 border_rand_y_plus = textureLod( iChannel0, ( cell_coord_integer_centered + vec2( 0.0, 1.0 ) ) / texture_size, 0.0 );
	vec4 border_rand_y_minus= textureLod( iChannel0, ( cell_coord_integer_centered + vec2( 0.0, 0.0 ) ) / texture_size, 0.0 );

	if( border_rand_x_plus .a >  0.5 )
	{
		vec3 params= GetCircleParams( border_rand_x_plus .xyz );
		vec2 vec_to_circle_center= coord_within_cell - vec2( 1.0 - params.y, params.x );
		cell_coord_tweaked.x+= step( length( vec_to_circle_center ), params.z );
	}
	if( border_rand_x_minus.a <= 0.5 )
	{
		vec3 params= GetCircleParams( border_rand_x_minus.xyz );
		vec2 vec_to_circle_center= coord_within_cell - params.yx;
		cell_coord_tweaked.x-= step( length( vec_to_circle_center ), params.z );
	}
	if( border_rand_y_plus. a >  0.5 )
	{
		vec3 params= GetCircleParams( border_rand_y_plus .xyz );
		vec2 vec_to_circle_center= coord_within_cell - vec2( params.x, 1.0 - params.y );
		cell_coord_tweaked.y+= step( length( vec_to_circle_center ), params.z );
	}
	if( border_rand_y_minus.a <= 0.5 )
	{
		vec3 params= GetCircleParams( border_rand_y_minus.xyz );
		vec2 vec_to_circle_center= coord_within_cell - params.xy;
		cell_coord_tweaked.y-= step( length( vec_to_circle_center ), params.z );
	}

	frag_color= textureLod( iChannel0, cell_coord_tweaked / texture_size, 0.0 );
}
