#version 300 es
precision mediump float;
out vec4 fragColor; 
uniform vec2 u_resolution;

void main () {
    vec2 pos = gl_FragCoord.xy / u_resolution.xy; //座標正規化
    fragColor = vec4(1.0, pos, 1.0);
}