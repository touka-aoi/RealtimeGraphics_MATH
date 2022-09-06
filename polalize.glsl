#version 300 es
precision highp float;
out vec4 fragColor; 
uniform vec2 u_resolution; //ビューポート解像度
uniform float u_time; //時間
const float PI = 3.1415926;

float atan2(float x, float y)
{
    if (x == 0.0)
    {
        //signは-のとき-1, +のとき1を返す関数
        //0の時は90°を返す
        return sign(y) * PI / 2.0;
    }
    else 
    {
        return atan(y, x);
    }
}

vec2 xy2pol(vec2 xy) 
{
    //polを動径, 長さで定義する
    return vec2(atan2(xy.x, xy.y), length(xy));
}

vec2 pol2xy(vec2 pol) 
{
    return pol.y * vec2(cos(pol.x), sin(pol.x));
}

//テクスチャを定義
vec3 tex(vec2 st) //極座標
{
    float time = 0.2 * u_time;
    //色を作る
    vec3 cric = vec3(pol2xy(vec2(time, 0.5)) + 0.5, 1.0);
    //0の時(0.5, 0)からスタートするそれに0.5を加えるので(1, 0.5, 1.0)スタート
    //それからくるくるまわるtimeがどれだけ大きくなろうとcos,sinされるので-1,1
    vec3[3] col3 = vec3[] 
    (
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, 0.0, 1.0),
        vec3(1.0)
    );

    col3 = vec3[]
    (
        cric.rgb, cric.gbr, cric.brg
    );

    //180°までの角度を拡張
    st.s = st.s / PI + 1.0;

    //インデックスにする
    int ind = int(st.s);

    //角度によって補完する%2で割ることで2色にする
    vec3 col = mix(col3[ind % 2], col3[(ind + 1) % 2], fract(st.s));


    //長さによって白を入れる
    return mix(col3[2], col, st.t); 
}

void main () {

    vec2 pos = gl_FragCoord.xy / u_resolution.xy;
    pos = 2.0 * pos.xy - vec2(1.0); // 2倍して引くこで-1, 1 にする
    pos = xy2pol(pos);
    vec3 baseColor = tex(pos);
    fragColor = vec4(baseColor, 1.0);
}
