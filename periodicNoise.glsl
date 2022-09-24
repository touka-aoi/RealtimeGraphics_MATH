#version 300 es
precision highp float;
out vec4 fragColor;
uniform vec2 u_resolution;
uniform float u_time;
int channel;
float PI = 3.14159265359;

// plialize Start
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
// polalize End

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
vec3 hash33(vec3 p)
{
    uvec3 n = floatBitsToUint(p);
    return vec3(uhash33(n)) / vec3(UINT_MAX);
}
//hashEnd

float gtable2(vec2 lattice, vec2 p)
{
    uvec2 n = floatBitsToUint(lattice);
    uint ind = uhash22(n).x >> 29; //8桁
    //2分1で決める
    //float u = (1. / cos(PI/8.)) * (ind < 4u ? p.x : p.y); ラジアンで計算される
    //float v = (1. / sin(PI/8.)) * (ind < 4u ? p.y : p.x);
    float u = 0.92387953 * (ind < 4u ? p.x : p.y);  //0.92387953 = cos(pi/8)
    float v = 0.38268343 * (ind < 4u ? p.y : p.x);  //0.38268343 = sin(pi/8)
    return ((ind & 1u) == 0u ? u : -u) + ((ind & 2u) == 0u ? v : -v);
}

float periodicNose21(vec2 p, float period)
{
    vec2 n = floor(p);
    vec2 f = fract(p);
    float v[4];
    for(int i = 0; i < 2; i++){
        for(int j = 0; j < 2; j++){
            v[j+2*i] = gtable2(mod(n + vec2(j,i), period), f - vec2(j,i));
        }
    }
    f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);
    return 0.5 * mix(mix(v[0], v[1], f[0]), mix(v[2], v[3],f[0]), f[1]) + 0.5;
}

void main ()
{
    vec2 pos = gl_FragCoord.xy / u_resolution.xy;
    pos = 2.0 * pos.xy - vec2(1.0);
    pos = xy2pol(pos);
    //このテク何かわからん
    //PIするとアーティファクト消えるわ
    //xは動径だから角度を与える必要がある
    //xは回して, ｙはながくする
    pos = vec2(5. / PI , 10.0) * pos + u_time;
    fragColor.rgb = vec3(periodicNose21(pos, 10.));
    fragColor.a = 1.0;
}