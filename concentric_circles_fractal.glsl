vec3 Circle( float radius, vec2 center, vec2 frag_coord )
{
	float initial_radius= radius;
	vec3 color= vec3( 0.0, 0.0, 0.0 );

	while( radius > 0.5 )
	{
		{
			vec3 c= vec3( 0.5 + 0.5 * sin( iTime * 7.0 / 8.0 + radius ), 0.5 + 0.5 * sin( iTime  * 11.0 / 8.0 + radius ), 0.5 + 0.5 * sin( iTime * 13.0 / 8.0 + radius ) );
			float r_plus= radius + 0.5;
			float r_minus= radius - 0.5;
			float r= distance( center, frag_coord );
			color= mix( color, c, smoothstep( r_plus, r_minus, r ) );
		}

		float phase= iTime * 0.25 * initial_radius / radius;
		vec2 v= vec2( cos( phase ), sin( phase ) );
		vec2 c0= center + v * ( radius * 0.5 );
		vec2 c1= center - v * ( radius * 0.5 );

		vec2 v0= c0 - frag_coord;
		vec2 v1= c1 - frag_coord;
		float half_radius_plus= radius * 0.5 + 0.5;
		if( dot( v0, v0 ) < half_radius_plus * half_radius_plus )
			center= c0;
		else if( dot( v1, v1 ) < half_radius_plus * half_radius_plus )
			center= c1;
		else
			break;

		radius*= 0.5;
	}

	return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 center= iResolution.xy * 0.5;
	fragColor = vec4( Circle( min( iResolution.x, iResolution.y ) * 0.5, center, fragCoord ) ,1.0);
}
