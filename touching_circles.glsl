void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float pix_size= 1.0 / min(iResolution.x, iResolution.y);
	vec2 coord= (fragCoord.xy - iResolution.xy * 0.5) * pix_size;

	vec2 coord_inverted = coord / dot(coord, coord);

	vec2 grid_fract= fract(coord_inverted);
	vec2 grid_cell_centered= grid_fract - vec2(0.5, 0.5);
	float grid_cell_square_radius= dot(grid_cell_centered, grid_cell_centered);

	vec2 d= vec2(dFdx(grid_cell_square_radius), dFdy(grid_cell_square_radius));
	float smooth_factor= 1.41 * length(d);
	const float smooth_center= 0.245;
	float f= 1.0 - smoothstep(smooth_center - smooth_factor, smooth_center + smooth_factor, grid_cell_square_radius );

	vec2 cell_xy= floor(coord_inverted);
	vec3 c= vec3(sin(cell_xy.x + iTime * 2.0), sin(cell_xy.y + iTime * 3.0), sin(cell_xy.x + cell_xy.y + iTime * 0.5)) * 0.5 + vec3(0.5, 0.5, 0.5);

	fragColor= f * vec4(c, 1.0);
}