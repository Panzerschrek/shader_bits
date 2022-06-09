void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float pix_size= 4.0 / min(iResolution.x, iResolution.y);
	vec2 coord= (fragCoord.xy - iResolution.xy * 0.5) * pix_size;

	float coord_square = dot(coord, coord);
	vec3 cube_coord = vec3(sqrt(max(0.0, 1.0 - coord_square * 0.25)) * coord.xy, coord_square * 0.5 - 1.0);

	fragColor = texture(iChannel0, cube_coord);
}
