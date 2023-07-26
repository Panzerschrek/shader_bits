const float step1= 0.004;
const float z_near= 0.2;
const float z_far= 8.0;
const float cube_size= 1.0;
const vec3 sun_light= vec3( -0.2, 1.0, -0.5 );

const float ONE3= 1.0f / 3.0f;
const float TWO3= 2.0f/ 3.0f;


bool inCube( vec3 pos )
{
	if( pos.x < -cube_size || pos.x > cube_size ||
		pos.y < -cube_size || pos.y > cube_size ||
		pos.z < -cube_size || pos.z > cube_size )
	return false;
	float r= pos.x * pos.x + pos.y * pos.y + pos.z * pos.z;
	return r > cube_size * 1.5;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 cam_pos= texelFetch( iChannel1, ivec2( 0, 0 ), 0 ).xyz;
    vec2 angle= texelFetch( iChannel1, ivec2( 1, 0 ), 0 ).xy;
    
    vec3 dir= vec3( ( fragCoord.xy / iResolution.xy ) * 2.0 - vec2( 1.0, 1.0 ), 1.0 );
    dir.x*= iResolution.x / iResolution.y;
    
  
	dir= normalize( dir );
	vec3 pos= cam_pos + z_near * dir;
	float z;
	float step= step1 * z_near;
	for( z= z_near; z< z_far; z+= step )
	{
		if( inCube( pos ) )
		{
			fragColor= vec4( 0.5, 0.5, 0.5, 1.0 ) + vec4( pos.xyz, 0.0 );
			break;
		}
		pos+= dir * step;
		step = z * step1;
	} 
	if( z >= z_far )
		fragColor= vec4( 0.0, 0.0, 0.0, 0.0 );
}