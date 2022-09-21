#version 300 es
precision highp float;
out vec4 fragColor;
uniform vec2 u_resolution;
uniform float u_time;

float fractSin1(float x)
{
    return fract(1000.0 * sin(x));
}

float fractSin2(vec2 xy) 
{
    return fract(sin(dot(xy, vec2(12.9, 34.3)))* 4242.434);
}

void main ()
{
    
    vec2 pos = gl_FragCoord.xy;
    pos += floor(60.0 * u_time);
    int channel = int(2.0 * gl_FragCoord.x / u_resolution.x);
    
    if (channel == 0 ) 
    {
        fragColor = vec4(fractSin1(pos.x));
    }
    else
    {
        fragColor = vec4(fractSin2(pos.xy / u_resolution.xy));
    }
}