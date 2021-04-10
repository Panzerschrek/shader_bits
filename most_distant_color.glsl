void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord/iResolution.xy;

	vec3 c= texture(iChannel0, uv).rgb;
	vec3 vec_to_center= vec3( 0.5, 0.5, 0.5 ) - c;

	float k= 10.0;

	if(vec_to_center.r < 0.0)
		k= min(k, (0.0 - c.r) / vec_to_center.r);
	else if(vec_to_center.r > 0.0)
		k= max(k, (1.0 - c.r) / vec_to_center.r);
	if(vec_to_center.g < 0.0)
		k= min(k, (0.0 - c.g) / vec_to_center.g);
	else if(vec_to_center.g > 0.0)
		k= max(k, (1.0 - c.g) / vec_to_center.g);
	if(vec_to_center.b < 0.0)
		k= min(k, (0.0 - c.b) / vec_to_center.b);
	else if(vec_to_center.b > 0.0)
		k= max(k, (1.0 - c.b) / vec_to_center.b);

	vec3 pos_shifted= c + vec_to_center * k;

	float distance_to_cursor= distance(fragCoord.xy, iMouse.xy);
	float inverse_factor= smoothstep(20.0, 22.0, distance_to_cursor);

	fragColor = vec4( mix(pos_shifted, c, inverse_factor), 1.0 );
}