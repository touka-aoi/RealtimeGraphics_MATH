#version 300 es
precision mediump float;
out vec4 fragColor; 
uniform vec2 u_resolution; //ビューポート解像度

void main () {
    vec2 pos = gl_FragCoord.xy / u_resolution.xy; //座標正規化
    vec3 red = vec3(1.0, 0.0, 0.0);
    vec3 blue = vec3(0.0, 0.0, 1.0);
    vec3 baseColor = red * (1.0 - pos.x) + pos.x * blue;
    fragColor = vec4(baseColor, 1.0);
}