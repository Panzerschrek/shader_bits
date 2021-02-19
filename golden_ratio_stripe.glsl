const float golden_ratio= (1.0 + sqrt(5.0)) / 2.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float n= log( fragCoord.x + 1.0 ) / log(golden_ratio);
	float b= floor(n) * (golden_ratio * 3.0);

	vec3 c= vec3( sin(b), sin(b + golden_ratio), sin(b + 2.0 * golden_ratio) ) * 0.5 + vec3( 0.5, 0.5, 0.5 );
	fragColor = vec4(c, 1.0);
}