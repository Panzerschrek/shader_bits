const float c_pi= 3.1415926535;
const float c_two_pi= 2.0 * c_pi;

const float c_beat_period= 64.0;
const float c_base_freq= 220.0;

const float time_scale= c_base_freq / c_beat_period;

const float c_first_planet_num= 2.0;
const float c_last_planet_num= 9.0;
const float c_num_panets= c_last_planet_num;

const float c_planet_base_radius= 0.012;
const float c_star_radius= 0.1;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	float pix_size= 2.2 / min(iResolution.x, iResolution.y);
	vec2 coord= (fragCoord.xy - iResolution.xy * 0.5) * pix_size;
	float square_radius= dot(coord, coord);
	float radius= sqrt(square_radius);

	float orbit_number= round(square_radius * c_num_panets);
	float orbit_radius= sqrt(orbit_number / c_num_panets);
	float planet_radius= c_planet_base_radius / orbit_radius;

	float period= orbit_number;

	float current_planet_angle= fract(time_scale * iTime / period) * c_two_pi;
	vec2 current_planet_pos= vec2(cos(current_planet_angle), sin(current_planet_angle)) * -orbit_radius;

	vec2 vec_to_planet= current_planet_pos - coord;
	float distance_to_planet= length(vec_to_planet);

	float beat_factor= 1.0 + step(c_pi * 7.0 / 8.0, abs(current_planet_angle - c_pi));
	float final_planet_radius= beat_factor * planet_radius;

	float planet_factor= smoothstep(distance_to_planet - pix_size, distance_to_planet + pix_size, final_planet_radius);
	float planet_range_factor= step(c_first_planet_num, orbit_number) * step(orbit_number, c_last_planet_num);

	float sun_factor= 1.0 - smoothstep(c_star_radius - pix_size, c_star_radius + pix_size, radius);

	vec3 planet_color= vec3(sin(orbit_number * 2.0), sin(orbit_number * 3.0), sin(orbit_number * 4.0)) * 0.5 + vec3(0.5, 0.5, 0.5);
	const vec3 sun_color= vec3(1.0, 0.95, 0.8);

	fragColor= vec4(mix(planet_factor * planet_range_factor * planet_color, sun_color, sun_factor), 1.0);
}