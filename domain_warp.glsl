#version 300 es
precision highp float;
out vec4 fragColor;
uniform vec2 u_resolution;
uniform float u_time;
int channel;
float PI = 3.14159265359;

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
    float u = 0.92387953 * (ind < 4u ? p.x : p.y);  //0.92387953 = cos(pi/8)
    float v = 0.38268343 * (ind < 4u ? p.y : p.x);  //0.38268343 = sin(pi/8)
    return ((ind & 1u) == 0u ? u : -u) + ((ind & 2u) == 0u ? v : -v);
}

float pnoise21(vec2 p)
{
    vec2 n = floor(p);
    vec2 f = fract(p);
    float v[4];
    for(int i = 0; i < 2; i++){
        for(int j = 0; j < 2; j++){
            v[j+2*i] = gtable2(n + vec2(j,i), f - vec2(j,i));
        }
    }
    f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);
    return 0.5 * mix(mix(v[0], v[1], f[0]), mix(v[2], v[3],f[0]), f[1]) + 0.5;
}

float vnoise21(vec2 p) 
{
    vec2 n = floor(p); //座標
    float[4] v;
    for (int j = 0; j < 2; j++) // 0, 1
    {
        for (int i = 0; i < 2; i++) // 0, 1
        {
            //(x, y), (x+1, y), (x, y+1), (x+1, y+1)
            v[i+2*j] = hash21(n  +  vec2(i, j));
        }
    }
    vec2 f = fract(p); //小数部分
    f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);
    return mix(mix(v[0], v[1], f[0]), mix(v[2], v[3], f[0]), f[1]);
}

float base21(vec2 p)
{
    //値ノイズ パーリンノイズ
    return channel == 0 ? vnoise21(p) - 0.5 : pnoise21(p) - 0.5;
}

float fbm21(vec2 p, float g)
{
    float val = 0.0; //値
    float amp = 1.0; //振幅
    float freq = 1.0; //重み
    for (int i = 0; i < 4; i++) 
    {
        //周波数方程式
        val += amp  * base21(freq * p);
        amp *= g; //振幅をG倍
        freq *= 2.01; //周波数を倍増
    }
    return 0.5 * val + .5;
}


float base21_2(vec2 p) 
{
    return channel == 0 ? fbm21(p, 0.5) : pnoise21(p);
}

float warp21(vec2 p, float g)
{
    float val = 0.0;
    for(int i = 0; i < 4; i++)
    {
        val = base21_2(p + g * vec2(cos(2.0 * PI * val), sin(2.0 * PI * val)));
    }
    return val;
}

void main ()
{  
    vec2 pos = gl_FragCoord.xy/min(u_resolution.x, u_resolution.y);
    channel = int(2.0 * gl_FragCoord.x / u_resolution.x);
    pos = 10.0 * pos + u_time;
    //Gを動かす
    //Mod2なので、[0,1]区間として吐き出される
    float g = abs(mod(0.2 * u_time, 2.0) - 1.0);
    //g = .1;
    fragColor = vec4(vec3(warp21(pos, g)), .3);
}