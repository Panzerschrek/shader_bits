void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	ivec2 uv = ivec2(fragCoord);
	vec4 sum = 
		texelFetch( iChannel0, uv + ivec2(-1, -1), 0 ) +
		texelFetch( iChannel0, uv + ivec2( 0, -1), 0 ) +
		texelFetch( iChannel0, uv + ivec2( 1, -1), 0 ) +
		texelFetch( iChannel0, uv + ivec2( 0, -2), 0 );

	fragColor= max(sum / 4.0 - vec4(2.0 / 255.0), vec4(0.0));

	if( iMouse.zw != vec2(0.0, 0.0) )
	{
		vec2 mouse_vec = fragCoord - iMouse.xy + vec2(sin(iTime * 7.0), sin(iTime * 11.0) ) * 16.0;
		if( dot(mouse_vec, mouse_vec) < 100.0 )
		{
			fragColor = vec4( 1.0, 1.0, 1.0, 1.0);
		}
	}
}