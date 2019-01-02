vec3 Circle( vec2 frag_coord, vec2 center, float radius )
{
	float d= distance( frag_coord, center );

	float outer_radius_scale= 0.9375 + 0.0625 * sin(iTime + radius);
	float inner_radius_scale= 0.75 + 0.0625 * sin(iTime * 5.0 / 4.0 + 2.0 * radius);

	float radius_plus= radius * outer_radius_scale + 0.5;
	float radius_minus= radius * outer_radius_scale - 0.5;
	float inner_radius_plus = radius * inner_radius_scale + 0.5;
	float inner_radius_minus = radius * inner_radius_scale - 0.5;

	vec3 color= vec3( 0.5 + 0.5 * sin( iTime * 7.0 / 8.0 + radius ), 0.5 + 0.5 * sin( iTime  * 11.0 / 8.0 + radius ), 0.5 + 0.5 * sin( iTime * 13.0 / 8.0 + radius ) );

	return
		color *
		smoothstep( radius_plus, radius_minus , d ) *
		smoothstep( inner_radius_minus, inner_radius_plus , d );
}

vec3 Cell( float cell_size, vec2 center, vec2 frag_coord )
{
	bool step= false;
	while( cell_size > 1.0 )
	{
		vec2 pos= frag_coord - center;
		if( step )
		{
			if( pos.x <= 0.0 && pos.y <= 0.0 )
				return Circle( frag_coord, center - vec2( cell_size * 0.25, cell_size * 0.25 ), cell_size * 0.25 );
			if( pos.x > 0.0 && pos.y > 0.0 )
				return Circle( frag_coord, center + vec2( cell_size * 0.25, cell_size * 0.25 ), cell_size * 0.25 );

			if( pos.x <= 0.0 )
				center+= vec2( -cell_size * 0.25, +cell_size * 0.25 );
			else
				center+= vec2( +cell_size * 0.25, -cell_size * 0.25 );
		}
		else
		{
			if( pos.x <= 0.0 && pos.y > 0.0 )
				return Circle( frag_coord, center + vec2( -cell_size * 0.25, +cell_size * 0.25 ), cell_size * 0.25 );
			if( pos.x > 0.0 && pos.y <= 0.0 )
				return Circle( frag_coord, center + vec2( +cell_size * 0.25, -cell_size * 0.25 ), cell_size * 0.25 );

			if( pos.x >= 0.0 )
				center+= vec2( +cell_size * 0.25, +cell_size * 0.25 );
			else
				center+= vec2( -cell_size * 0.25, -cell_size * 0.25 );
		}
		cell_size*= 0.5;
		step= !step;
	}
	return vec3( 0.0, 0.0, 0.0 );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 center= iResolution.xy * 0.5;
	fragColor = vec4( Cell( min( iResolution.x, iResolution.y ), center, fragCoord ) ,1.0);
}
