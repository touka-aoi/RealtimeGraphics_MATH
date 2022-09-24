#version 300 es
precision highp float;
out vec4 fragColor;
uniform vec2 u_resolution;
uniform float u_time;


vec3 hsv2rgb(in vec3 c){
    vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    return c.z * mix(vec3(1.0), rgb, c.y);
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

float vnoise21(vec2 p) 
{
    vec2 n = floor(p); //座標
    float[4] v;
    for (int j = 0; j < 2; j++) // 0, 1
    {
        for (int i = 0; i < 2; i++) // 0, 1
        {
            //(x, y), (x+1, y), (x, y+1), (x+1, y+1)
            v[i+2*j] = hash21(n +  vec2(i, j));
        }
    }
    vec2 f = fract(p); //小数部分

    f = f * f * (3.0 - 2.0 * f);

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


float gnoise31(vec3 p)
{
    vec3 n = floor(p); //格子点
    vec3 f = fract(p); //小数部分
    float[8] v; // x+1, x-1, y+1, y-1
    for (int k = 0; k < 2; k++)
    {
        for (int j = 0; j < 2; j++) 
        {
            for (int i = 0; i < 2; i++) 
            {
                //上下左右4箇所でハッシュ値を作成
                //正規化する
                vec3 g = normalize(hash33(n + vec3(i,j, k)) - vec3(0.5));
                //gが係数これはなんでもいいのかな...
                v[i+2*j+4*k] = dot(g, f - vec3(i, j, k)); //窓関数
            }
        }
    }
    //5次エルミート
    f = f * f * f * (10.0 - 15.0 * f + 6.0 * f * f);
    float w[2];
    for (int i = 0; i < 2; i++)
    {
        w[i] = mix(mix(v[4*i], v[4*i+1], f[0]), mix(v[4*i+2], v[4*i+3], f[0]), f[1]);

    }
    return 0.5 * mix(w[0], w[1], f[2]) + 0.5;
}

void main ()
{
    vec2 pos = gl_FragCoord.xy / min(u_resolution.x, u_resolution.y);
    pos = 20.0 * pos + u_time; //0~10の範囲で動く
    ivec2 channel = ivec2(2.0 * gl_FragCoord.xy / u_resolution.xy);
    float v;
    if (channel[0] == 0) 
    {
        if(channel[1] == 1)
        {
            v = vnoise21(pos);
        }
        else 
        {
            v = vnoise31(vec3(pos, u_time), 1.0);
        }
    }
    else 
    {
        if(channel[1] == 1)
        {
            v = gnoise21(pos);
        }
        else 
        {
            v = gnoise31(vec3(pos, u_time));
        }
    }
    //なるほど
    fragColor.rgb = hsv2rgb(vec3(v, 1.0, 1.));
    fragColor.a = 1.0;
}