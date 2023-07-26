void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float two_pi= 2.0 * 3.1415926535;
	const float deg_to_rad = two_pi / 360.0;
	const float golden_ratio= ( sqrt(5.0) - 1.0 ) / 2.0;

	float pix_size=  2.0 / min(iResolution.x, iResolution.y);
	vec2 coord= (fragCoord - 0.5 * iResolution.xy) * pix_size;

	float angle5= fract( atan( coord.y, coord.x ) * ( 5.0 / two_pi ) );
	float radius= length(coord);

	float angle10= 1.0 - abs( angle5 - 0.5 ) * 2.0;

	float c= cos(angle5 / ( 5.0 / two_pi ));
	float s= sin(angle5 / ( 5.0 / two_pi ));
	vec2 coord_transformed= 4.0 * vec2( c * radius, s * radius );

	float k0= tan( -36.0 * deg_to_rad );
	float offset0= -1.0 * k0;

	float k1= tan( -72.0 * deg_to_rad );
	float offset1= -golden_ratio * k1;

	float tile=
	step( coord_transformed.y, k0 * coord_transformed.x + offset0 ) +
	step( coord_transformed.y, k1 * coord_transformed.x + offset1 );

	//float chess= abs( step( 0.5, fract( coord_transformed.x ) ) - step( 0.5, fract( coord_transformed.y ) ) );

	fragColor = vec4(angle5, angle10, tile, 1.0);
}