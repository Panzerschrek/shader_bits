// Configuable params

const int ss_scale= 3;
const int num_iterations= 6;

const float circle_half_width= 0.07;
const float border_half_size= 0.03;

const vec3 background_color= vec3( 0.0, 0.0, 0.0 );
const vec3 border_color= vec3( 0.2, 0.2, 0.2 );
const vec3 long_tile_color= vec3(0.5, 0.8, 0.8);
const vec3 short_tile_color= vec3(0.8, 0.8, 0.5);
const vec3 red_circle_color= vec3(1.0, 0.3, 0.3);
const vec3 green_circle_color= vec3(0.3, 1.0, 0.3);

// Common constants

const float two_pi= 2.0 * 3.1415926535;
const float deg_to_rad = two_pi / 360.0;
const float golden_ratio= ( sqrt(5.0) + 1.0 ) / 2.0;

// Code itself

vec2 transformPoint( vec2 coord, vec2 new_center, float rotate_angle_deg, float scale )
{
	float rot_c= scale * cos( rotate_angle_deg * deg_to_rad );
	float rot_s= scale * sin( rotate_angle_deg * deg_to_rad );
	vec2 coord_shifted = coord - new_center;
	return vec2( coord_shifted.x * rot_c - coord_shifted.y * rot_s, coord_shifted.x * rot_s + coord_shifted.y * rot_c );
}

vec3 calculateColor( vec2 coord )
{
	const float cos18= cos( 18.0 * deg_to_rad );
	const float cos36= cos( 36.0 * deg_to_rad );
	const float sin18= sin( 18.0 * deg_to_rad );
	const float sin36= sin( 36.0 * deg_to_rad );
	const float tan18 = tan(  18.0 * deg_to_rad );
	const float tan36 = tan(  36.0 * deg_to_rad );
	const float tan54 = tan(  54.0 * deg_to_rad );
	const float tan72 = tan(  72.0 * deg_to_rad );
	const float tan126= tan( 126.0 * deg_to_rad );
	const float tan144= tan( 144.0 * deg_to_rad );
	const float tan162= tan( 162.0 * deg_to_rad );

	if(	coord.y >=  coord.x * tan36  + sin36 ||
		coord.y >=  coord.x * tan144 + sin36 ||
		coord.y <= -coord.x * tan36  - sin36 ||
		coord.y <  -coord.x * tan144 - sin36)
	{
		return background_color;
	}

	bool is_long_tile= false;
	for( int i= 0; i < num_iterations; ++i )
	{
		if( is_long_tile )
		{
			if( coord.y < coord.x * tan126 - sin18 )
			{
				coord= transformPoint( coord, vec2(-cos18 * 0.5, -sin18 * 0.5), 18.0, golden_ratio );
				is_long_tile= false;
			}
			else if( coord.y < coord.x * tan54 - sin18 )
			{
				coord= transformPoint( coord, vec2(cos18 * 0.5, -sin18 * 0.5), 162.0, golden_ratio );
				is_long_tile= false;
			}
			else if( coord.x <= 0.0 )
			{
				coord= transformPoint( coord, vec2(-cos18 * (3.0 - sqrt(5.0)) / 4.0, sin18 - sin18 * (3.0 - sqrt(5.0)) / 4.0 ), -108.0, golden_ratio );
				is_long_tile= true;
			}
			else // if( coord.x > 0.0 )
			{
				coord= transformPoint( coord, vec2(cos18 * (3.0 - sqrt(5.0)) / 4.0, sin18 - sin18 * (3.0 - sqrt(5.0)) / 4.0 ), 108.0, golden_ratio );
				is_long_tile= true;
			}
		}
		else
		{
			if( coord.y >= 0.0 )
			{
				if( coord.y >= coord.x * tan72 + sin36 )
				{
					coord= transformPoint( coord, vec2(-cos36 * 0.5, sin36 * 0.5), 144.0, golden_ratio );
					is_long_tile= false;
					continue;
				}
				if( coord.y > coord.x * tan36 + sin36 / tan72 * tan36 )
				{
					coord= transformPoint( coord, vec2(cos36 * 0.5 - 0.25, sin36 * 0.5 + sin36 / (sqrt(5.0) + 1.0)), 126.0, golden_ratio );
					is_long_tile= true;
					continue;
				}
			}
			else
			{
				if( coord.y < -coord.x * tan72 - sin36 )
				{
					coord= transformPoint( coord, vec2(-cos36 * 0.5, -sin36 * 0.5), -144.0, golden_ratio );
					is_long_tile= false;
					continue;
				}
				else if( coord.y < -coord.x * tan36 - sin36 / tan72 * tan36 )
				{
					coord= transformPoint( coord, vec2(cos36 * 0.5 - 0.25, -sin36 * 0.5 - sin36 / (sqrt(5.0) + 1.0)), 54.0, golden_ratio );
					is_long_tile= true;
					continue;
				}
			}

			coord= transformPoint( coord, vec2(cos36 - 0.5, 0.0), 180.0, golden_ratio );
		}
	}


	vec3 c= vec3( 0.0, 0.0, 0.0 );
	const float green_circle_radius= 0.2;
	const float red_circle_radius_small= 0.2;
	const float red_circle_radius_big= 1.0 - 0.2;

	if( is_long_tile )
	{
		if(	coord.y + border_half_size >=  coord.x * tan18  + sin18 ||
			coord.y + border_half_size >=  coord.x * tan162 + sin18 ||
			coord.y - border_half_size <= -coord.x * tan18  - sin18 ||
			coord.y - border_half_size <= -coord.x * tan162 - sin18)
		{
			c= border_color;
		}
		else
		{
			vec2 green_center= vec2( 0.0, -sin18 );
			float l_green= length( coord - green_center );
			float green_factor= step( green_circle_radius - circle_half_width, l_green ) * step( l_green, green_circle_radius + circle_half_width );

			vec2 red_center= vec2( 0.0, sin18 );
			float l_red= length( coord - red_center );
			float red_factor= step( red_circle_radius_small - circle_half_width, l_red ) * step( l_red, red_circle_radius_small + circle_half_width );

			c= mix( mix( long_tile_color, green_circle_color, green_factor ), red_circle_color, red_factor );
		}
	}
	else
	{
		if(	coord.y + border_half_size >=  coord.x * tan36  + sin36||
			coord.y + border_half_size >=  coord.x * tan144 + sin36 ||
			coord.y - border_half_size <= -coord.x * tan36  - sin36 ||
			coord.y - border_half_size <= -coord.x * tan144 - sin36)
		{
			c= border_color;
		}
		else
		{
			vec2 green_center= vec2( -cos36, 0.0 );
			float l_green= length( coord - green_center );
			float green_factor= step( green_circle_radius - circle_half_width, l_green ) * step( l_green, green_circle_radius + circle_half_width );

			vec2 red_center= vec2( cos36, 0.0 );
			float l_red= length( coord - red_center );
			float red_factor= step( red_circle_radius_big - circle_half_width, l_red ) * step( l_red, red_circle_radius_big + circle_half_width );

			c= mix( mix( short_tile_color, green_circle_color, green_factor ), red_circle_color, red_factor );
		}
	}

	return c;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 c= vec3(0.0, 0.0, 0.0);
	for( int dx= 0; dx < ss_scale; ++dx )
	{
		for( int dy= 0; dy < ss_scale; ++dy )
		{
			float pix_size= 1.2 / min(iResolution.x, iResolution.y);
			vec2 coord= (fragCoord + vec2(float(dx), float(dy)) / float(ss_scale) - 0.5 * iResolution.xy) * pix_size;
			c+= calculateColor(coord);
		}
	}
	c /= float(ss_scale * ss_scale);
	fragColor = vec4(c, 1.0);
}