void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	ivec2 uv = ivec2(fragCoord);
	vec4 sum = 
		texelFetch( iChannel0, uv + ivec2(-1, -1), 0 ) +
		texelFetch( iChannel0, uv + ivec2( 0, -1), 0 ) +
		texelFetch( iChannel0, uv + ivec2( 1, -1), 0 ) +
		texelFetch( iChannel0, uv + ivec2( 0, -2), 0 );

	fragColor= sum / 4.0 - vec4(2.0 / 255.0);
}