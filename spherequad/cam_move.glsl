void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor=vec4( 0.0 );

    if( fragCoord.x >= 0.0 && fragCoord.x < 1.0 )
    {
        vec3 delta= vec3( 0.0 );
        delta.x-= texelFetch( iChannel0, ivec2( 0x41, 0 ), 0 ).x;
        delta.x+= texelFetch( iChannel0, ivec2( 0x44, 0 ), 0 ).x;
        delta.z+= texelFetch( iChannel0, ivec2( 0x57, 0 ), 0 ).x;
        delta.z-= texelFetch( iChannel0, ivec2( 0x53, 0 ), 0 ).x;
        delta.y+= texelFetch( iChannel0, ivec2( 0x20, 0 ), 0 ).x;
        delta.y-= texelFetch( iChannel0, ivec2( 0x43, 0 ), 0 ).x;

        fragColor = texelFetch( iChannel1, ivec2( fragCoord.xy ), 0 ) + vec4( delta.xyz, 1.0 ) * iTimeDelta;
    }
    else if( fragCoord.x >= 1.0 && fragCoord.x < 2.0 )
    {
    }
}