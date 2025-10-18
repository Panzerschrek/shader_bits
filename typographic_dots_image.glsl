void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float pi= 3.1415926535;
	const float rot_angle= pi / 6.0;
	const vec2 rot_sincos = vec2(sin(rot_angle), cos(rot_angle));
	const vec2 rot2_sincos= vec2(sin(rot_angle * 2.0), cos(rot_angle * 2.0));

	const int ss_factor= 3;

	 float pix_size= 2.0 / min(iResolution.x, iResolution.y);

	float grid_scale= 0.25 * pi / pix_size;

	vec3 res= vec3(0.0, 0.0, 0.0);

	for(int dy= 0; dy < ss_factor; ++dy)
	for(int dx= 0; dx < ss_factor; ++dx)
	{
		vec2 coord= ( fragCoord.xy + vec2(float(dx), float(dy)) / float(ss_factor) - iResolution.xy * 0.5 ) * pix_size;

		vec2 coord_r= coord;
		vec2 coord_g= vec2(coord.x * rot_sincos .x - coord.y * rot_sincos .y, coord.x * rot_sincos .y + coord.y * rot_sincos .x );
		vec2 coord_b= vec2(coord.x * rot2_sincos.x - coord.y * rot2_sincos.y, coord.x * rot2_sincos.y + coord.y * rot2_sincos.x );

		vec2 sin_r= sin(coord_r * grid_scale);
		vec2 sin_g= sin(coord_g * grid_scale);
		vec2 sin_b= sin(coord_b * grid_scale);

		vec3 sin_product=
			vec3(
				sin_r.x * sin_r.y,
				sin_g.x * sin_g.y,
				sin_b.x * sin_b.y );

		vec3 brightness_func= (abs(sin_product) * sin_product) * 0.5 + vec3( 0.5, 0.5, 0.5 );

		vec4 tex_value= texture( iChannel0, coord * 0.5 + vec2( 0.5, 0.5 ) );
		tex_value= tex_value * tex_value;

		res+=
			vec3(
				step(brightness_func.r, tex_value.r),
				step(brightness_func.g, tex_value.g),
				step(brightness_func.b, tex_value.b) );
	}

	res/= float(ss_factor * ss_factor);
		            
	fragColor = vec4(res, 1.0);
}