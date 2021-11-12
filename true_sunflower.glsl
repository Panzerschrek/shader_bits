const float c_golden_angle= 2.39996322972865332;
const float c_pi= 3.1415926535;
const float c_two_pi= 2.0 * c_pi;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float pix_size= 32.0 / min(iResolution.x, iResolution.y);
	float smoothstep_center= 0.15;
	float smoothstep_start= smoothstep_center - pix_size;
	float smoothstep_end= smoothstep_center + pix_size;
	vec2 coord= (fragCoord.xy - iResolution.xy * 0.5) * pix_size;
	float angle= atan(coord.x, coord.y) + c_pi;
	float square_radius= dot(coord, coord);
	float radius= sqrt(square_radius);

	int i= int(round(square_radius));

	float c= 0.0;

	float max_cur_i= iTime * iTime * 0.5;
	for(int di= -25; di <= 25; ++di)
	{
		if(abs(di) > i )
			continue;

		float cur_i= float(i + di);
		if(cur_i > max_cur_i)
			continue;

		float theta= cur_i * c_golden_angle;
		float theta_corrected= mod(theta, c_two_pi);
		float target_r= sqrt(cur_i);

		float angle_dist= theta_corrected - angle;
		float radius_dist= target_r - radius;
		vec2 dir_to_center= vec2(angle_dist * target_r, radius_dist);
		float square_dist= dot(dir_to_center, dir_to_center);

		c+= 1.0 - smoothstep(smoothstep_start, smoothstep_end, square_dist);
	}

	fragColor= vec4(c, c, c, 1.0);
}