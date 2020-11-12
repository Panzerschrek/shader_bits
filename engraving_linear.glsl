float GetBrightness( vec4 color )
{
	// TODO - perform gamma correction (if needed)
	return dot( color.rgb, vec3( 0.299, 0.587, 0.114 ) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 tex_size= vec2( textureSize( iChannel0, 0 ) );
	vec2 tex_coord = fragCoord / iResolution.xy;
	tex_coord.x *= iResolution.x / iResolution.y * tex_size.y / tex_size.x;

	const float dot_scale= 128.0;
	float pattern_coord_y= fract( tex_coord.y * dot_scale );

	vec2 tex_coord_discret= vec2( tex_coord.x, floor( tex_coord.y * dot_scale ) / dot_scale );

	float lod= log2( max( tex_size.x, tex_size.y ) / dot_scale );
	vec4 color= textureLod( iChannel0, tex_coord_discret, lod );
	float brightness= GetBrightness( color );

	float pattern_coord_y_fixed= abs( 0.5 - pattern_coord_y ) * 2.0;
	float d= 1.0 * dot_scale / tex_size.y;
	float b= smoothstep( pattern_coord_y_fixed - d, pattern_coord_y_fixed + d, brightness );
	fragColor= vec4(b);
}
