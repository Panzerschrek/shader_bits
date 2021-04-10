void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float two_pi= 2.0 * 3.1415926535;
	float separation= 0.7 + sin(iTime * 0.25) * 0.5;
	float pix_size= 2.2 / min(iResolution.x, iResolution.y);
	vec2 coord= (fragCoord.xy - iResolution.xy * 0.5) * pix_size;

	float dist0= max(0.01, distance(coord, vec2(-separation, 0.0)));
	float dist1= max(0.01, distance(coord, vec2(+separation, 0.0)));
	float force= 1.0 / dist0 - 1.0 / dist1;

	//float angle= atan( coord.y, coord.x - separation ) - atan( coord.y, coord.x + separation );
	float angle= atan( coord.y, coord.x - separation ) * atan( coord.y, -coord.x - separation );

	float inv_min_dist= 1.0 / min(dist0, dist1);
	float force_smooth= 4.0 * pix_size * inv_min_dist * inv_min_dist;
	float angle_smooth= 4.0 * pix_size * inv_min_dist;
	float force_factor= smoothstep( 0.25 - force_smooth, 0.25 + force_smooth, abs( fract( 4.0 * force ) - 0.5 ) );
	float angle_factor= smoothstep( 0.25 - angle_smooth, 0.25 + angle_smooth, abs( fract( angle * ( 8.0 / two_pi ) ) - 0.5 ) );
	float b= abs( force_factor - angle_factor );
	fragColor= vec4( b, b, b, 1.0 );
}