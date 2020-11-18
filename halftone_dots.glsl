
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 tex_size= vec2( 512, 512 );
	vec2 tex_coord = fragCoord / iResolution.xy;
	tex_coord.x *= iResolution.x / iResolution.y;

	const float dot_scale= 96.0;
	float d= dot_scale / iResolution.y;

	float lod= log2( max( tex_size.x, tex_size.y ) / dot_scale );
	vec4 tex_value= textureLod( iChannel0, tex_coord, lod );
	tex_value.rgb= sqrt( tex_value.rgb );

	float k= 1.0 - max( max( tex_value.r, tex_value.g ), tex_value.b );
	k= min( k, 0.333 ); // Do not add too much black
	vec3 cmy= vec3( 1.0 - tex_value.r - k, 1.0 - tex_value.g - k, 1.0 - tex_value.b - k );
		
	vec2 pattern_coord_r= fract( tex_coord * dot_scale + vec2( 0.0, 0.5 ) );
	vec2 pattern_coord_g= fract( tex_coord * dot_scale + vec2( +sqrt(3.0) * 0.25, -0.25 ) );
	vec2 pattern_coord_b= fract( tex_coord * dot_scale + vec2( -sqrt(3.0) * 0.25, -0.25 ) );
	vec2 pattern_coord_k= fract( tex_coord * dot_scale );

	vec2 v_r= pattern_coord_r.xy - vec2( 0.5, 0.5 );
	vec2 v_g= pattern_coord_g.xy - vec2( 0.5, 0.5 );
	vec2 v_b= pattern_coord_b.xy - vec2( 0.5, 0.5 );
	vec2 v_k= pattern_coord_k.xy - vec2( 0.5, 0.5 );

	float radius_r= sqrt(cmy.r / 2.0);
	float radius_g= sqrt(cmy.g / 2.0);
	float radius_b= sqrt(cmy.b / 2.0);
	float radius_k= sqrt(k / 2.0);

	float facror_r= smoothstep( max( radius_r - d, 0.0 ), min( radius_r + d, 1.0 ), length(v_r) );
	float facror_g= smoothstep( max( radius_g - d, 0.0 ), min( radius_g + d, 1.0 ), length(v_g) );
	float facror_b= smoothstep( max( radius_b - d, 0.0 ), min( radius_b + d, 1.0 ), length(v_b) );
	float facror_k= smoothstep( max( radius_k - d, 0.0 ), min( radius_k + d, 1.0 ), length(v_k) );

	fragColor= vec4( facror_r * facror_k, facror_g * facror_k, facror_b * facror_k, 0.0 );
}
