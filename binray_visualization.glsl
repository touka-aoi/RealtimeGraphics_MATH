#version 300 es
precision highp float;
out vec4 fragColor;
uniform vec2 u_resolution;
uniform float u_time;

void main ()
{
    vec2 pos = gl_FragCoord.xy / u_resolution.xy;
    pos *= vec2(32.0, 9.0); //32ビット 9列
    uint[9] a = uint[]
    (
    uint(u_time),
    0xbu, //unsigned 0x(16) B (11)
    9u,
    0xbu ^ 9u,
    0xffffffffu,
    0xffffffffu + uint(u_time),
    floatBitsToUint(floor(u_time)),
    floatBitsToUint(-floor(u_time)),
    floatBitsToUint(11.5524)
    );
    if (fract(pos.x) < 0.1) 
    //数字は1ずつあがるからなんでもいい
    //線の太さを決定している
    {
        if (floor(pos.x) == 1.0)
        {
            fragColor = vec4(1, 0, 0, 1);
        }
        else if (floor(pos.x) == 9.0)
        {
            fragColor = vec4(0, 1, 0 ,1 );
        }
        else
        {
            fragColor = vec4(0.5);
        }
    }
    else if(fract(pos.y) < 0.01)
    {
        fragColor = vec4(0.5);
    }
    
    else 
    {
        uint b = a[int(pos.y)];
        b = (b << uint(pos.x)) >> 31; //桁を1.の形に
        fragColor = vec4(vec3(b) ,1.0);
    }

    
}