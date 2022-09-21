#version 300 es
precision highp float;
out vec4 fragColor;
uniform vec2 u_resolution;
uniform float u_time;
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


void main ()
{
    ivec2 channel = ivec2(2.0 * gl_FragCoord.xy / u_resolution.xy);
    

    float time = floor(60.0 * u_time);
    vec2 pos = gl_FragCoord.xy + time;

    if (channel.x == 0 && channel.y == 0)
    {
        vec3 bc = vec3(hash21(pos.xy));
        fragColor = vec4(bc, 1);
    }    

    else if (channel.x == 0 && channel.y == 1)
    {
        vec3 bc =  vec3(hash22(pos.xy), 1);
        fragColor = vec4(bc, 1);
    }

    else if (channel.x == 1 && channel.y == 0)
    {
        
    }

    else if (channel.x == 1 && channel.y == 1)
    {
        
    }
    
}