void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float pix_size= 2.2 / min(iResolution.x, iResolution.y);
	vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) * pix_size;

	vec2 s= sin(coord * 10.0);

	float sin_product= s.x * s.y;

	float step_border= cos(iTime * 0.2);

	float b= step(step_border, sin_product);

	fragColor = vec4(b, b, b, 1.0);
}