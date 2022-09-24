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

vec2[4] diag = vec2[]
(
    vec2(0.70710678,0.70710678),
    vec2(-0.70710678,0.70710678),
    vec2(0.70710678,-0.70710678),
    vec2(-0.70710678,-0.70710678)
);

vec2[4] axis = vec2[]
(
    vec2(1, 0),
    vec2(-1, 0),
    vec2(0, 1),
    vec2(0, -1)
);

float gNoise21(vec2 p) 
{
    vec2 n = floor(p);
    vec2 f = fract(p);
    float[4] v;
    for (int i = 0; i < 2; i++) 
    {
        for (int k = 0; k < 2; k++)
        {
            uvec2 m = floatBitsToUint(n + vec2(k, i));
            uint ind = (uhash22(m).x >> 30); //2bitは4通り
            if (channel == 0)
            {
                v[k+i*2] = dot(diag[ind], f - vec2(k, i));
            }
            else 
            {
                v[k+i*2] = dot(axis[ind], f - vec2(k, i));
            }
        }
    }
    f = f * f * f * (10.0 - 15. * f + 6. * f * f);
    return .5 * mix(mix(v[0], v[1], f[0]), mix(v[2], v[3], f[0]), f[1]) + .5;
}

void main ()
{
    vec2 pos = gl_FragCoord.xy / min(u_resolution.x, u_resolution.y);
    channel = int(2.0 * gl_FragCoord.x / u_resolution.x);
    pos = 10. * pos + u_time;
    float v = gNoise21(pos);
    if (v > 0.85 || v < 0.15)
    {
        fragColor.rgb = vec3(1.,0.,0.);
    }   
    else 
    {
        fragColor.rgb = vec3(v);
    }
    fragColor.rgb = vec3(v);
    fragColor.a = 1.0;
}
