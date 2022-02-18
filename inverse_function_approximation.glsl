void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord/iResolution.xy;

	float scale= 100.0;
	float x= uv.x * scale;
	float y= uv.y;

	// Exact function
	float f= 1.0 / x;

	float mouse_x= iMouse.x / iResolution.x * scale;

	// Calculate approaximation polynom
	float approx_range= 1.31; // Quadratic optimal
	//float approx_range= 1.1; // Linear optimal
	float x0= mouse_x * approx_range;
	float x1= mouse_x / approx_range;
	float x2= mouse_x;
	float y0= 1.0 / x0;
	float y1= 1.0 / x1;
	float y2= 1.0 / x2;

	mat3 m= mat3(vec3(x0 * x0, x1 * x1, x2 * x2), vec3(x0, x1, x2), vec3(1.0, 1.0, 1.0));
	mat3 m_inverse= inverse(m);
	vec3 abc= m_inverse * vec3( y0, y1, y2 );

	float f_approx2= ( abc.x * x + abc.y ) * x + abc.z;

	// Calculate linear approximation
	vec2 ab= inverse(mat2(vec2(x0, x1), vec2(1.0, 1.0))) * vec2( y0, y1 );
	float f_approx1= ab.x * x + ab.y;

	float f_approx= f_approx2;

	float diff= abs(f - f_approx);
	float accuracy= diff / f;
	float ok_value= step( accuracy, 0.01 ); // 1%

	float in_range_value= step( x, x0 ) * step( x1, x );

	float b= mix( ok_value, in_range_value, step( y, 0.5 ) );

	fragColor = vec4(step(y, f), step(y, f_approx), b, 1.0);
}