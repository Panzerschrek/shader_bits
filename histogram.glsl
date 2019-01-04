void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float c_pin_size= 8.0;
	const float c_pin_border= 1.0;
	const float c_base_period= 64.0;
	const float c_seq_step= 1.8;
	const float c_scale_step= 2.2;
	const float c_freq_step= 1.7;
	const int c_iterations= 5;
	const float c_time_scale= 2.0;

	float x_rounded= floor( fragCoord.x / c_pin_size ) * c_pin_size;
	float f= 0.0;
	for( int i= 0; i < c_iterations; ++i )
	{
		float i_f= float(i);
		f+= sin( iTime * c_time_scale * pow( c_freq_step, i_f ) ) * sin( x_rounded / ( c_base_period / pow( c_seq_step, i_f ) ) ) / pow( c_scale_step, i_f );
	}
	f= f * 0.25 + 0.25;

	float color_factor= smoothstep( fragCoord.y / iResolution.y, ( fragCoord.y + 2.0 ) / iResolution.y, f  );
	float border_factor= smoothstep( ( fragCoord.y + 2.0 ) / iResolution.y, ( fragCoord.y + 4.0 ) / iResolution.y, f );

	float pin_border_factor= smoothstep( c_pin_border, c_pin_border + 1.0, fragCoord.x - x_rounded );

	vec3 color= vec3(
		sin( x_rounded / 31.0 - iTime * 3.0 ) * 0.45 + 0.55,
		sin( x_rounded / 29.0 - iTime * 4.0 ) * 0.45 + 0.55,
		sin( x_rounded / 27.0 - iTime * 5.0 ) * 0.45 + 0.55 );

	vec3 border_color= ( vec3( 1.0, 1.0, 1.0 ) - color * 0.5 );

	fragColor=  pin_border_factor * color_factor * vec4( mix( border_color, color, border_factor ), 1.0 );
}
