#version 300 es
precision highp float;
out vec4 fragColor; 
uniform vec2 u_resolution; //ビューポート解像度

void main () {
    vec2 pos = gl_FragCoord.xy / u_resolution.xy; //座標正規化

    vec3[4] col4 = vec3[] 
    (
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, 0.0, 1.0),
        vec3(0.0, 1.0, 0.0),
        vec3(1.0, 0.0, 1.0)
    );

    pos.x *= 2.0;
    int ind = int(pos.x);
    //vec3 baseColor = col3[ind] * (1.0 - fract(pos.x)) + fract(pos.x) * col3[ind+1];
    //Xで線形補間したもの同士をyで線形補完する
    vec3 baseColor = mix( mix(col4[0], col4[1], pos.x), mix(col4[2], col4[3], pos.x), pos.y);
    fragColor = vec4(baseColor, 1.0);
}