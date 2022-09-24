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

float gtable3(vec3 lattice, vec3 p)
{
    uvec3 n = floatBitsToUint(lattice);
    uint ind = uhash33(n).x >> 28; //16桁
    //8以上だったらx, それ以外y
    float u = ind < 8u ? p.x : p.y; 
    //4以下p.y, 4以上 12or14以外 p.z, else p.x
    float v = ind < 4u ? p.y : ind == 12u || ind == 14u ? p.x : p.z; 
    //01だったら+, 10だったら+
    return ((ind & 1u) == 0u ? u : -u) + ((ind & 2u) == 0u ? v : -v);
}

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

float pnose21(vec2 p)
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

float pnoise31(vec3 p)
{
    vec3 n = floor(p);
    vec3 f = fract(p);
    float v[8];
    for(int i = 0; i < 2; i++){
        for(int j = 0; j < 2; j++){
            for(int k = 0; k < 2; k++){
                v[k+2*j+i*4] = gtable3(n + vec3(k, j, i), f - vec3(k, j, i)) * 0.70710678;
            }
        }
    }
    f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);
    float[2] w;
    for (int i = 0; i < 2; i++)
    {
        w[i] = mix(mix(v[4*i], v[4*i+1],f[0]), mix(v[4*i+2], v[4*i+3], f[0]), f[1]);
    }
    return 0.5 * mix(w[0], w[1], f[2]) + 0.5;
}

void main ()
{
    vec2 pos = gl_FragCoord.xy / min(u_resolution.x, u_resolution.y);
    pos = 10. * pos + u_time;
    channel = int(2. * gl_FragCoord.x / u_resolution.x);
    if (channel == 0) 
    {
        fragColor.rgb = vec3(pnoise31(vec3(pos, u_time)));
    }
    else
    {
        fragColor.rgb = vec3(pnose21(vec2(pos)));
    }
    fragColor.a = 1.0;
}