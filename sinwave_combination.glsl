void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 coord = 2.0 * fragCoord / iResolution.xy - vec2(1.0, 1.0);

	const float c_pi= 3.1415926535;

	float sin_value= 0.0;

	int iterations= max(1, min(int(exp(iTime * 0.5)), 512));
	for(int i= 0; i < iterations; ++i)
	{
		float f= 1.0 + float(i);
		sin_value+= sin(coord.x * c_pi * f) / f;
	}
	sin_value*= 0.5;

	float s= step(coord.y, sin_value);


	fragColor = vec4(s, s, s, 1.0);
}