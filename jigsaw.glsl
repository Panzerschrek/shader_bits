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

	vec4 line_offset_x= textureLod( iChannel0, cell_coord.yx * 0.5 / texture_size, 0.0 );
	vec4 line_offset_y= textureLod( iChannel0, cell_coord.xy * 0.5 / texture_size, 0.0 );

	cell_coord+= 0.25 * vec2( line_offset_x.a, line_offset_y.a );

	vec2 cell_coord_integer_centered= floor( cell_coord ) + vec2( 0.5, 0.5 );
	vec2 coord_within_cell= fract( cell_coord );

	vec2 cell_coord_tweaked= cell_coord_integer_centered;

	vec4 border_rand_x_plus = textureLod( iChannel0, ( cell_coord_integer_centered + vec2( 1.0, 0.0 ) ) / texture_size, 0.0 );
	vec4 border_rand_x_minus= textureLod( iChannel0, ( cell_coord_integer_centered + vec2( 0.0, 0.0 ) ) / texture_size, 0.0 );
	vec4 border_rand_y_plus = textureLod( iChannel0, ( cell_coord_integer_centered + vec2( 0.0, 1.0 ) ) / texture_size, 0.0 );
	vec4 border_rand_y_minus= textureLod( iChannel0, ( cell_coord_integer_centered + vec2( 0.0, 0.0 ) ) / texture_size, 0.0 );

	float border_size= 0.05;

	float border_factor_x_plus = 1.0 - smoothstep( 1.0 - border_size, 1.0, coord_within_cell.x );
	float border_factor_x_minus= smoothstep( 0.0, border_size, coord_within_cell.x );
	float border_factor_y_plus = 1.0 - smoothstep( 1.0 - border_size, 1.0, coord_within_cell.y );
	float border_factor_y_minus= smoothstep( 0.0, border_size, coord_within_cell.y );

	if( border_rand_x_plus .a >  0.5 )
	{
		vec3 params= GetCircleParams( border_rand_x_plus .xyz );
		float l= length( coord_within_cell - vec2( 1.0 - params.y, params.x ) );
		float s= step( l, params.z );
		cell_coord_tweaked.x+= s;
		border_factor_x_plus = min( border_factor_x_plus , smoothstep( params.z, params.z + border_size, l ) );
		border_factor_x_plus = mix( border_factor_x_plus , 1.0 - smoothstep( params.z - border_size, params.z, l ), s );
	}
	if( border_rand_x_minus.a <= 0.5 )
	{
		vec3 params= GetCircleParams( border_rand_x_minus.xyz );
		float l= length( coord_within_cell - params.yx );
		float s= step( l, params.z );
		cell_coord_tweaked.x-= s;
		border_factor_x_minus= min( border_factor_x_minus, smoothstep( params.z, params.z + border_size, l ) );
		border_factor_x_minus= mix( border_factor_x_minus, 1.0 - smoothstep( params.z - border_size, params.z, l ), s );
	}
	if( border_rand_y_plus. a >  0.5 )
	{
		vec3 params= GetCircleParams( border_rand_y_plus .xyz );
		float l= length( coord_within_cell - vec2( params.x, 1.0 - params.y ) );
		float s= step( l, params.z );
		cell_coord_tweaked.y+= s;
		border_factor_y_plus = min( border_factor_y_plus , smoothstep( params.z, params.z + border_size, l ) );
		border_factor_y_plus = mix( border_factor_y_plus , 1.0 - smoothstep( params.z - border_size, params.z, l ), s );
	}
	if( border_rand_y_minus.a <= 0.5 )
	{
		vec3 params= GetCircleParams( border_rand_y_minus.xyz );
		float l= length( coord_within_cell - params.xy );
		float s= step( l, params.z );
		cell_coord_tweaked.y-= s;
		border_factor_y_minus= min( border_factor_y_minus, smoothstep( params.z, params.z + border_size, l ) );
		border_factor_y_minus= mix( border_factor_y_minus, 1.0 - smoothstep( params.z - border_size, params.z, l ), s );
	}

	float border_factor=
		0.5 + 0.5 *
			border_factor_x_plus * border_factor_x_minus *
			border_factor_y_plus * border_factor_y_minus;

	frag_color= border_factor * textureLod( iChannel0, cell_coord_tweaked / texture_size, 0.0 );
}
