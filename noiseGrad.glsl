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
    if (channel == 1) 
    {
        f = f * f * (3.0 - 2.0 * f);
    }
    else 
    {
        f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);
    }
    return mix(mix(v[0], v[1], f[0]), mix(v[2], v[3], f[0]), f[1]);
}

vec2 grad(vec2 p)
{
    float eps = 0.001; 
    //0.5はしらん
    return 0.5 * (vec2(
        //
        vnoise21(p + vec2(eps, 0.0)) - vnoise21(p - vec2(eps, 0.0)),
        vnoise21(p + vec2(0.0, eps)) - vnoise21(p - vec2(0.0, eps)) 
    )) / eps;
}

void main ()
{
    vec2 pos = gl_FragCoord.xy / min(u_resolution.x, u_resolution.y);
    channel = int(gl_FragCoord.x * 2.0 / u_resolution.x);
    pos = 3.0 * pos+u_time;
    fragColor.xyz = vec3(dot(vec2(1), grad(pos)));
    fragColor.a = 1.0;
    
}