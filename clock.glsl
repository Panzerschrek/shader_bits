float fetchDigitTexture( vec2 coord, int digit, float s )
{
	vec2 tc= coord / 16.0 + vec2( float(digit) / 16.0, 12.0 / 16.0 );
	float dist= texture( iChannel0, tc ).a;
	return 1.0 - smoothstep( 0.5 - s, 0.5 + s, dist );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float two_pi= 2.0 * 3.1415926535;

	float pix_size= 2.2 / min(iResolution.x, iResolution.y);
	vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;
	float angle= atan( coord.x, coord.y ) / two_pi + 0.5;
	float radius= length(coord);
	float inv_radius= 1.0 / max(radius, 0.001);
	float pix_size_r= pix_size * inv_radius / two_pi;
	float pix_size_r60= pix_size_r * 60.0;

	float sector4 = fract( angle *  4.0 + 0.5 );
	float sector12= fract( angle * 12.0 + 0.5 );
	float sector60= fract( angle * 60.0 + 0.5 );

	float sector_factor_4 = step( 0.5 - 1.0 / 30.0, sector4  ) * step( sector4 , 0.5 + 1.0 / 30.0 );
	float sector_factor_12= step( 0.5 - 1.0 / 10.0, sector12 ) * step( sector12, 0.5 + 1.0 / 10.0 );

	float mark_width_sector_factor=
		0.05 + 
		0.05 * sector_factor_12 +
		0.05 * sector_factor_4;
		
	float mark_length=
		0.9 -
		0.06 * sector_factor_12 -
		0.04 * sector_factor_4;

	float half_mark_width= mark_width_sector_factor * inv_radius;
	float mark= smoothstep( 0.5 - half_mark_width - pix_size_r60, 0.5 - half_mark_width + pix_size_r60, sector60 ) - smoothstep( 0.5 + half_mark_width - pix_size_r60, 0.5 + half_mark_width + pix_size_r60, sector60 );
	mark*= smoothstep( mark_length - pix_size, mark_length + pix_size, radius ) * step( radius, 0.99 );

	float circle= smoothstep( 0.95 - pix_size, 0.95 + pix_size, radius ) - smoothstep( 1.0 - pix_size, 1.0 + pix_size, radius );

	float time= iTime;

	float handle_angle_second= fract( angle - time / 60.0 );
	float half_handle_width_second= 0.002 * inv_radius;
	float handle_factor_second= smoothstep( 0.5 - half_handle_width_second - pix_size_r, 0.5 - half_handle_width_second + pix_size_r, handle_angle_second ) - smoothstep( 0.5 + half_handle_width_second - pix_size_r, 0.5 + half_handle_width_second + pix_size_r, handle_angle_second );
	handle_factor_second*= smoothstep( radius - pix_size, radius + pix_size, 0.85 );

	float handle_angle_minute= fract( angle - time / ( 60.0 * 60.0 ) );
	float half_handle_width_minute= 0.005 * inv_radius;
	float handle_factor_minute= smoothstep( 0.5 - half_handle_width_minute - pix_size_r, 0.5 - half_handle_width_minute + pix_size_r, handle_angle_minute ) - smoothstep( 0.5 + half_handle_width_minute - pix_size_r, 0.5 + half_handle_width_minute + pix_size_r, handle_angle_minute );
	handle_factor_minute*= smoothstep( radius - pix_size, radius + pix_size, 0.7 );

	float handle_angle_hour= fract( angle - time / ( 60.0 * 60.0 * 12.0 ) );
	float half_handle_width_hour= 0.008 * inv_radius;
	float handle_factor_hour= smoothstep( 0.5 - half_handle_width_hour - pix_size_r, 0.5 - half_handle_width_hour + pix_size_r, handle_angle_hour ) - smoothstep( 0.5 + half_handle_width_hour - pix_size_r, 0.5 + half_handle_width_hour + pix_size_r, handle_angle_hour );
	handle_factor_hour*= smoothstep( radius - pix_size, radius + pix_size, 0.5 );

	float digit_angle= floor( fract( angle + 1.0 / 24.0 ) * 12.0 ) / 12.0;
	vec2 digit_coord= vec2( 0.5, 0.5 ) + coord * 4.0  + 2.7 * vec2( sin(digit_angle * two_pi), cos(digit_angle * two_pi) );
	float digit_clamp= step( digit_coord.x, 1.0 ) * step( 0.0, digit_coord.x ) * step( digit_coord.y, 1.0 ) * step( 0.0, digit_coord.y );

	float tex_smooth= 3.5 * pix_size;

	int digit_value= int( digit_angle * 12.0 ) + 6;
	if( digit_value > 12 )
	{
		digit_value-= 12;
	}
	float digit;
	if( digit_value < 10 )
	{
		digit= fetchDigitTexture( digit_coord, digit_value, tex_smooth );
	}
	else
	{
		digit= 
			fetchDigitTexture( digit_coord - vec2( 0.25, 0.0 ), digit_value - 10, tex_smooth ) + 
			fetchDigitTexture( digit_coord + vec2( 0.25, 0.0 ), digit_value / 10, tex_smooth );
	}
	float b= mark + circle + handle_factor_second + handle_factor_minute + handle_factor_hour + digit_clamp * digit;
	b= 1.0 - b;
	fragColor = vec4( b, b, b, 1.0);
}