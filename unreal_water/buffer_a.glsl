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

	vec2 mouse_vec = fragCoord - iMouse.zw;
	float dist = length(mouse_vec);
	float radius = 8.0;
	if( dist <= radius )
	{
		fragColor = vec4(cos(dist * (3.1415926 * 0.5 / radius)) * 4.0);
	}
}