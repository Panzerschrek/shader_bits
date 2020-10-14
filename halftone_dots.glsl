float GetBrightness( vec4 color )
{
	// TODO - perform gamma correction (if needed)
	return dot( color.rgb, vec3( 0.299, 0.587, 0.114 ) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 tex_size= vec2( 512, 512 );
	vec2 tex_coord = fragCoord / iResolution.xy;
	tex_coord.x *= iResolution.x / iResolution.y;

	const float dot_scale= 64.0;
	vec2 pattern_coord= fract( tex_coord * dot_scale );

	vec2 tex_coord_discret= floor( tex_coord * dot_scale ) / dot_scale;

	float lod= log2( max( tex_size.x, tex_size.y ) / dot_scale );
	float b00 = GetBrightness( textureLod( iChannel0, tex_coord_discret + vec2( 0.0, 0.0 ) / dot_scale, lod ) );
	float b10 = GetBrightness( textureLod( iChannel0, tex_coord_discret + vec2( 1.0, 0.0 ) / dot_scale, lod ) );
	float b01 = GetBrightness( textureLod( iChannel0, tex_coord_discret + vec2( 0.0, 1.0 ) / dot_scale, lod ) );
	float b11 = GetBrightness( textureLod( iChannel0, tex_coord_discret + vec2( 1.0, 1.0 ) / dot_scale, lod ) );

	vec2 v00= pattern_coord.xy;
	vec2 v10= vec2( 1.0 - pattern_coord.x, pattern_coord.y );
	vec2 v01= vec2( pattern_coord.x, 1.0 - pattern_coord.y );
	vec2 v11= vec2( 1.0, 1.0 ) - pattern_coord.xy;

	float factor= 1.0 / 4.0;
	float a00= step( dot( v00, v00 ), b00 * factor );
	float a10= step( dot( v10, v10 ), b10 * factor );
	float a01= step( dot( v01, v01 ), b01 * factor );
	float a11= step( dot( v11, v11 ), b11 * factor );

	fragColor= vec4( max( max(a00, a01), max(a10, a11) ) );
	// fragColor= vec4( ( b00 + b10 + b01 + b11 ) / 4.0 );
}
