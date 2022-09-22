#version 300 es
precision highp float;
out vec4 fragColor;
uniform vec2 u_resolution;
uniform float u_time;
const uint UINT_MAX = 0xffffffffu;
int channel;

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

float vnoise21(vec2 p, float l) 
{
    vec2 n = floor(p); //座標
    float[4] v;
    for (int j = 0; j < 2; j++) // 0, 1
    {
        for (int i = 0; i < 2; i++) // 0, 1
        {
            //(x, y), (x+1, y), (x, y+1), (x+1, y+1)
            v[i+2*j] = hash21(n + l +  vec2(i, j));
        }
    }
    vec2 f = fract(p); //小数部分
    if (channel == 1) 
    {
        f = f * f * (3.0 - 2.0 * f);
    }
    return mix(mix(v[0], v[1], f[0]), mix(v[2], v[3], f[0]), f[1]);
}

float vnoise31(vec3 p, float l)
{
    vec3 n = floor(p);
    float[8] v;
    for (int k = 0; k < 2; k++) //x
    {
        for (int j = 0; j < 2; j++)  //y
        {
            for (int i = 0; i < 2; i++) //z
            {
                //(x, y, z), (x+1, y, z), (x+1, y+1, z) ...
                v[i+2*j+4*k] = hash31(n + l +  vec3(i, j ,k));
            }
        }
    }
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float[2] w;
    for (int i = 0; i < 2; i++)
    {
        w[i] = mix(mix(v[4*i], v[4*i+1],f[0]), mix(v[4*i+2], v[4*i+3], f[0]), f[1]);
    }
    return mix(w[0], w[1], f[2]);

}

vec3 vnoise23(vec2 p) 
{
    return vec3(vnoise21(p, 34.0), vnoise21(p, 42.0), vnoise21(p, 98.0));
}

vec3 vnoise33(vec3 p)
{
    return vec3(vnoise31(p, 34.0), vnoise31(p, 341.0), vnoise31(p, 98.0));
}

void main ()
{
    vec2 pos = gl_FragCoord.xy / min(u_resolution.x, u_resolution.y); //小さいほうに合わせる(正規化)
    channel = int(gl_FragCoord.x * 3.0 / u_resolution.x); //3チャンネル
    pos = 10.0 * pos + u_time; //0~10の範囲で動く
    if (channel < 2) 
    {
        fragColor = vec4(vnoise21(pos, 1.0));
        fragColor = vec4(vnoise23(pos), 1.0);
    }
    else 
    {
        fragColor = vec4(vnoise31(vec3(pos, u_time), 1.0));
        fragColor = vec4(vnoise33(vec3(pos, u_time)), 1.0);
    }

    
    
}
