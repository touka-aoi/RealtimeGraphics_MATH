#version 300 es
precision highp float;
out vec4 fragColor;
uniform vec2 u_resolution;
uniform float u_time;


void main () 
{
    vec2 pos = gl_FragCoord.xy / u_resolution.xy;
    pos.x *= 2.0;
    vec3[3] colors = vec3[]
    (
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, 0.0, 1.0),
        vec3(0.0, 1.0, 1.0)
    );
    int ind = int(pos.x);
    vec3 bc = mix(colors[ind], colors[ind+1], fract(pos.x));
    fragColor = vec4(bc, 1);
}