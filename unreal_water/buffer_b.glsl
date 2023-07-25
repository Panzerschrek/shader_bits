void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	ivec2 uv = ivec2(fragCoord);
	vec4 val = texelFetch( iChannel1, uv, 0 );
	vec4 sum = 
		texelFetch( iChannel0, uv + ivec2(-1,  0), 0 ) +
		texelFetch( iChannel0, uv + ivec2( 1,  0), 0 ) +
		texelFetch( iChannel0, uv + ivec2( 0, -1), 0 ) +
		texelFetch( iChannel0, uv + ivec2( 0,  1), 0 );

	fragColor = (sum * 0.5 - val) * 0.995;
}