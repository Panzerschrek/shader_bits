void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 coord= ( fragCoord.xy - iResolution.xy * 0.5 ) / ( 0.5 * iResolution.y );
	float angle= iTime;
	vec2 cs= vec2( cos(angle), sin(angle) ) * 1.125;
	vec2 coord_transformed= vec2( coord.x * cs.x - coord.y * cs.y, coord.x * cs.y + coord.y * cs.x );

	float pix_size= 2.0 / min(iResolution.x, iResolution.y);

	vec2 inner_circle_coord= vec2( -coord_transformed.x * sign(coord_transformed.y), abs( coord_transformed.y ) - 0.5 );
	float l= length( inner_circle_coord );

	float medium_circle_factor= smoothstep( 0.5 - pix_size, 0.5 + pix_size, l );
	float medium_circle_factor2= medium_circle_factor * step( inner_circle_coord.x, 0.0 );

	float top_bottom_factor= step( 0.0, coord_transformed.y );
	float inverted_factor= abs( top_bottom_factor - medium_circle_factor2 );

	float small_circle_factor= smoothstep( l - pix_size, l + pix_size, 0.125 );
	float inner_color_factor= abs( inverted_factor - small_circle_factor );

	float large_circle_factor= smoothstep( 1.0 - pix_size, 1.0 + pix_size, length( coord_transformed ) );

	vec3 circle_color= mix( vec3( 0.0, 0.0, 0.0 ), vec3( 1.0, 1.0, 1.0 ), inner_color_factor );
	vec3 total_color= mix( circle_color, vec3( 1.0, 0.0, 0.0 ), large_circle_factor );

	fragColor = vec4( total_color ,1.0);
}