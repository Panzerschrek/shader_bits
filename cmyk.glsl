

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 tex_size= vec2( textureSize( iChannel0, 0 ) );
	vec2 tex_coord = fragCoord / iResolution.xy;
	tex_coord.x *= iResolution.x / iResolution.y * tex_size.y / tex_size.x;
    
    vec3 rgb= texture( iChannel0, tex_coord ).rgb;
    float gray= 1.0 - max( max( rgb.r, rgb.g ), rgb.b );
    vec3 cmy= vec3( 1.0, 1.0, 1.0 ) - rgb - vec3( gray, gray, gray );


    vec3 composite_color= vec3( 1.0, 1.0, 1.0 ) - cmy - vec3( gray, gray, gray );
    vec3 color= mix( rgb, composite_color, step( fragCoord.x, iResolution.x * 0.5 ) );
	fragColor= vec4( color, 0.0 );
}
