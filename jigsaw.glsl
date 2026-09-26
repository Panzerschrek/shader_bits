float c_scale= 16.0;
float c_border_size= 0.035;

vec3 GetCircleParams( vec3 rand )
{
	return
		vec3(
			0.4 + 0.2 * rand.y,
			0.05 + 0.02 * rand.z,
			0.15 * ( 0.9 + rand.x * 0.2 ) );
}

void mainImage( out vec4 frag_color, in vec2 frag_coord )
{
	vec2 base_coord= frag_coord / max( iResolution.x, iResolution.y );
	vec2 cell_coord= c_scale * base_coord;

	vec2 texture_size= vec2( textureSize( iChannel0, 0 ) );



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

	bool has_knob_x_plus = border_rand_x_plus .a >  0.5;
	bool has_knob_x_minus= border_rand_x_minus.a <= 0.5;
	bool has_knob_y_plus = border_rand_y_plus. a >  0.5;
	bool has_knob_y_minus= border_rand_y_minus.a <= 0.5;

	float border_factor_x_plus = 1.0 - smoothstep( 1.0 - c_border_size, 1.0, coord_within_cell.x );
	float border_factor_x_minus= smoothstep( 0.0, c_border_size, coord_within_cell.x );
	float border_factor_y_plus = 1.0 - smoothstep( 1.0 - c_border_size, 1.0, coord_within_cell.y );
	float border_factor_y_minus= smoothstep( 0.0, c_border_size, coord_within_cell.y );

	{
		vec3 params= GetCircleParams( border_rand_x_plus .xyz );
		if( !has_knob_x_plus  )
			params.y = -params.y;
		float l= length( coord_within_cell - vec2( 1.0 - params.y, params.x ) );
		float s= step( l, params.z );
		if( has_knob_x_plus )
		{
			cell_coord_tweaked.x+= s;
			border_factor_x_plus = min( border_factor_x_plus , smoothstep( params.z, params.z + c_border_size, l ) );
			border_factor_x_plus = mix( border_factor_x_plus , 1.0 - smoothstep( params.z - c_border_size, params.z, l ), s );
		}
		else
			border_factor_x_plus = max( border_factor_x_plus , 1.0 - smoothstep( params.z - c_border_size, params.z, l ) );
	}
	{
		vec3 params= GetCircleParams( border_rand_x_minus.xyz );
		if( !has_knob_x_minus )
			params.y = -params.y;
		float l= length( coord_within_cell - params.yx );
		float s= step( l, params.z );
		if( has_knob_x_minus )
		{
			cell_coord_tweaked.x-= s;
			border_factor_x_minus= min( border_factor_x_minus, smoothstep( params.z, params.z + c_border_size, l ) );
			border_factor_x_minus= mix( border_factor_x_minus, 1.0 - smoothstep( params.z - c_border_size, params.z, l ), s );
		}
		else
			border_factor_x_minus= max( border_factor_x_minus, 1.0 - smoothstep( params.z - c_border_size, params.z, l ) );
	}
	{
		vec3 params= GetCircleParams( border_rand_y_plus .xyz );
		if( !has_knob_y_plus  )
			params.y= -params.y;
		float l= length( coord_within_cell - vec2( params.x, 1.0 - params.y ) );
		float s= step( l, params.z );
		if( has_knob_y_plus  )
		{
			cell_coord_tweaked.y+= s;
			border_factor_y_plus = min( border_factor_y_plus , smoothstep( params.z, params.z + c_border_size, l ) );
			border_factor_y_plus = mix( border_factor_y_plus , 1.0 - smoothstep( params.z - c_border_size, params.z, l ), s );
		}
		else
			border_factor_y_plus = max( border_factor_y_plus , 1.0 - smoothstep( params.z - c_border_size, params.z, l ) );
	}
	{
		vec3 params= GetCircleParams( border_rand_y_minus.xyz );
		if( !has_knob_y_minus )
			params.y = -params.y;
		float l= length( coord_within_cell - params.xy );
		float s= step( l, params.z );
		if( has_knob_y_minus )
		{
			cell_coord_tweaked.y-= s;
			border_factor_y_minus= min( border_factor_y_minus, smoothstep( params.z, params.z + c_border_size, l ) );
			border_factor_y_minus= mix( border_factor_y_minus, 1.0 - smoothstep( params.z - c_border_size, params.z, l ), s );
		}
		else
			border_factor_y_minus= max( border_factor_y_minus, 1.0 - smoothstep( params.z - c_border_size, params.z, l ) );
	}

	float border_factor=
		0.5 + 0.5 * min(
			min( border_factor_x_plus, border_factor_x_minus ),
			min( border_factor_y_plus, border_factor_y_minus ) );

	frag_color=
		border_factor *
		textureLod( iChannel0, cell_coord_tweaked / texture_size, 0.0 );
}
