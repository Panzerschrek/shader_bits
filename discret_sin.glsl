void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;

    float  x= uv.x - 0.5;
    x = floor(x * 64.0) / 64.0;

    float y= uv.y * 2.0 - 1.0;
    float sin_value= sin(x  * 2.0 * 3.1415926535);
    float c= step(y, sin_value);

    fragColor = vec4(c, c, c, 1.0);
}