#version 300 es
precision highp float;
out vec4 fragColor;
uniform vec2 u_resolution;
uniform float u_time;
int channel;

vec2 rot2(vec2 p, float t)
{
    return vec2(p.x * cos(t) - p.y * sin(t), p.x * sin(t) + p.y * cos(t));
}

vec3 rotX(vec3 p, float t)
{
    p.yz = rot2(p.yz, t);
    return p;
}

vec3 rotY(vec3 p, float t) 
{
    p.xz = rot2(p.xz, t);
    return p;
}

vec3 rotZ(vec3 p, float t)
{
    p.xy = rot2(p.xy, t);
    return p;
}

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

float rotNoise21(vec2 p, float ang) 
{
    vec2 n = floor(p);
    vec2 f = fract(p);
    float[4] v;
    for (int i = 0; i < 2; i++) 
    {
        for (int k = 0; k < 2; k++)
        {
            vec2 g = normalize(hash22(n + vec2(k, i)) - vec2(0.5));
            g = rot2(g, ang);
            v[k+2*i] = dot(g, f - vec2(k, i));

        }
    }
    f = f * f * f * (10.0 - 15. * f + 6. * f * f);
    return .5 * mix(mix(v[0], v[1], f[0]), mix(v[2], v[3], f[0]), f[1]) + .5;
}

float rotNoise31(vec3 p, float ang)
{
    vec3 n = floor(p);
    vec3 f = fract(p);
    float[8] v;
    for(int i = 0; i < 2; i++)
    {
        for(int k = 0; k < 2; k++) 
        {
            for(int j = 0; j < 2; j++)
            {
                vec3 g = normalize(hash33(n + vec3(j, k, i)) - vec3(0.5));
                //表示は2次元だからZで回せばよい
                g = rotZ(g, ang);
                v[j+2*k+4*i] = dot(g, f - vec3(j,k,i));
            }
        }
    }
    f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);
    float[2] w;
    for (int i = 0; i < 2; i++)
    {
        w[i] = mix(mix(v[4*i], v[4*i+1], f[0]), mix(v[4*i+2], v[4*i+3], f[0]), f[1]);
    }
    return 0.5 * mix(w[0], w[1], f[2]) + 0.5;
    
}

void main ()
{
    vec2 pos = gl_FragCoord.xy / min(u_resolution.x, u_resolution.y);
    int channel = int(2.0 * gl_FragCoord.xy / u_resolution.xy);
    pos = 10. * pos + u_time;
    if (channel == 0) 
    {
        fragColor = vec4(vec3(rotNoise21(pos, u_time)), 1.0);
    }
    else 
    {
        fragColor = vec4(vec3(rotNoise31(vec3(pos, u_time), u_time)), 1.0);
    }
}