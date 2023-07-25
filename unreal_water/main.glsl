void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	ivec2 uv = ivec2(fragCoord);
	vec4 val = texelFetch( iChannel0, uv, 0 );
	vec4 dx = texelFetch( iChannel0, uv + ivec2(-1,  0), 0 ) - texelFetch( iChannel0, uv + ivec2( 1,  0), 0 );
	vec4 dy = texelFetch( iChannel0, uv + ivec2( 0, -1), 0 ) - texelFetch( iChannel0, uv + ivec2( 0,  1), 0 );

	vec3 normal = normalize(vec3(dx.x, dy.x, 1.0));
	// fragColor = vec4( normal.xyz * 0.5 + vec3(0.5, 0.5, 0.5), 1.0);

	vec3 sun_dir = normalize(vec3(0.3333, 0.25, 0.5));
	float sun_dot = max(0.0, dot(sun_dir, normal));
	float sun_specular = pow(max(0.1, reflect(-normal, sun_dir).z), 32.0) * 32.0;

	vec3 sun_light = vec3(0.6, 0.6, 0.4);
	vec3 ambient_ligh = vec3(0.1, 0.1, 0.3);

	fragColor= vec4( ambient_ligh + sun_light * (sun_dot + sun_specular), 1.0 );
}
