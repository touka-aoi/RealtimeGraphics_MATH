#version 300 es
precision highp float;
out vec4 fragColor;
uniform vec2 u_resolution;
uniform float u_time;
int channel;

//hashStart
const uint UINT_MAX = 0xffffffffu;

uvec3 k = uvec3(0x456789abu, 0x6789ab45u, 0x89ab4567u);
uvec3 u = uvec3(1, 2, 3);

uvec2 uhash22(uvec2 n)
{
    n ^= (n.yx << u.xy);
    n ^= (n.yx >> u.xy);
    n *= k.xy;
    n ^= (n.yx << u.xy);
    return n * k.xy;
}

uvec3 uhash33(uvec3 n)
{
    n ^= (n.yzx << u);
    n ^= (n.yzx >> u);
    n *= k;
    n ^= (n.yzx << u);
    return n * k;
}

vec2 hash22(vec2 p) 
{
    uvec2 n = floatBitsToUint(p);
    return vec2(uhash22(n)) / vec2(UINT_MAX);
}

float hash21(vec2 p) 
{
    uvec2 n = floatBitsToUint(p);
    return float(uhash22(n).x) / float(UINT_MAX);
}

float hash31(vec3 p)
{
    uvec3 n = floatBitsToUint(p);
    return float(uhash33(n).x) / float(UINT_MAX);
}
//hashEnd

float gnoise21(vec2 p)
{
    vec2 n = floor(p); //格子点
    vec2 f = fract(p); //小数部分
    float[4] v; // x+1, x-1, y+1, y-1
    for (int j = 0; j < 2; j++) 
    {
        for (int i = 0; i < 2; i++) 
        {
            //上下左右4箇所でハッシュ値を作成
            //正規化する
            vec2 g = normalize(hash22(n + vec2(i,j)) - vec2(0.5));
            //gが係数これはなんでもいいのかな...
            v[i+2*j] = dot(g, f - vec2(i,j)); //窓関数
        }
    }
    //5次エルミート
    f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);
    return 0.5 * mix(mix(v[0], v[1], f[0]), mix(v[2], v[3], f[0]), f[1]) + 0.5;
}

void main ()
{
    vec2 pos = gl_FragCoord.xy / min(u_resolution.x, u_resolution.y);
    pos = 10.0 * pos + u_time; //0~10の範囲で動く
    //なるほど
    fragColor = vec4(gnoise21(pos));
}