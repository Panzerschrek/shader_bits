void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 xy = fragCoord/iResolution.xy;
	float x = 4.0 * (fragCoord.x / iResolution.x * 2.0 - 1.0);
	float y = fragCoord.y / iResolution.y;

	float inv_sqrt_two_pi = 1.0 / sqrt(2.0 * 3.1415926545);
	float f = exp(-0.5 * x * x) * inv_sqrt_two_pi;


	float x2= x * x;
	float f_approx = inv_sqrt_two_pi * ( 1.0 + x2 * ( -1.0 / 2.0 + x2 * ( 1.0 / 8.0 - x2 / 48.0 ) ) );

	float r = step( y, f );
	float g = step( y, f_approx );
	fragColor = vec4(r, g, 0.0, 1.0);
}