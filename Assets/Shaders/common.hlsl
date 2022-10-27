struct AudienceInfo
{
    float3 position;
    float4 color;
    // float4x4 parentRotationMatrix;
    float4x4 rotation;
};

// 0.0 <= result < 1.0
float rand(float2 pos) 
{
    return frac(sin(dot(pos.xy, float2(12.9898, 78.233))) * 43758.5453);
}

float4 quaternion(float rad, float3 axis)
{
    return float4(normalize(axis) * sin(rad * 0.5), cos(rad * 0.5));
}

float4x4 rotationMatrix(float4 q)
{
    float qyqy = 2 * q.y * q.y;
    float qzqz = 2 * q.z * q.z;
    float qxqy = 2 * q.x * q.y;
    float qzqw = 2 * q.z * q.w;
    float qxqz = 2 * q.x * q.z;
    float qyqw = 2 * q.y * q.w;
    float qxqx = 2 * q.x * q.x;
    float qyqz = 2 * q.y * q.z;
    float qxqw = 2 * q.x * q.w;
    float4x4 mat = {
        1 - qyqy - qzqz, qxqy - qzqw, qxqz + qyqw, 0,
        qxqy + qzqw, 1 - qxqx - qzqz, qyqz - qxqw, 0,
        qxqz - qyqw, qyqz + qxqw, 1 - qxqx - qyqy, 0,
        0, 0, 0, 1,
    };
    return mat;
}

float2 mod289(float2 x)
{
    return x - floor(x * (1.0f / 289.0f)) * 289.0f;
}

float3 mod289(float3 x)
{
    return x - floor(x * (1.0f / 289.0f)) * 289.0f;
}

float3 permute(float3 x)
{
    return mod289((34.0f * x + 1.0f) * x);
}

// https://github.com/Unity-Technologies/Unity.Mathematics/blob/master/src/Unity.Mathematics/Noise/noise3D.cs#L24
float snoise(float2 v)
{
    float4 C = float4(0.211324865405187f,  // (3.0-math.sqrt(3.0))/6.0
                          0.366025403784439f,  // 0.5*(math.sqrt(3.0)-1.0)
                         -0.577350269189626f,  // -1.0 + 2.0 * C.x
                          0.024390243902439f); // 1.0 / 41.0
    // First corner
    float2 i = floor(v + dot(v, C.yy));
    float2 x0 = v - i + dot(i, C.xx);

    // Other corners
    float2 i1;
    //i1.x = math.step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
    //i1.y = 1.0 - i1.x;
    i1 = (x0.x > x0.y) ? float2(1.0f, 0.0f) : float2(0.0f, 1.0f);
    // x0 = x0 - 0.0 + 0.0 * C.xx ;
    // x1 = x0 - i1 + 1.0 * C.xx ;
    // x2 = x0 - 1.0 + 2.0 * C.xx ;
    float4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;

    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    float3 p = permute(permute(i.y + float3(0.0f, i1.y, 1.0f)) + i.x + float3(0.0f, i1.x, 1.0f));

    float3 m = max(0.5f - float3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0f);
    m = m * m;
    m = m * m;

    // Gradients: 41 points uniformly over a line, mapped onto a diamond.
    // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

    float3 x = 2.0f * frac(p * C.www) - 1.0f;
    float3 h = abs(x) - 0.5f;
    float3 ox = floor(x + 0.5f);
    float3 a0 = x - ox;

    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversemath.sqrt( a0*a0 + h*h );
    m *= 1.79284291400159f - 0.85373472095314f * (a0 * a0 + h * h);

    // Compute final noise value at P

    float  gx = a0.x * x0.x + h.x * x0.y;
    float2 gyz = a0.yz * x12.xz + h.yz * x12.yw;
    float3 g = float3(gx,gyz);

    return 130.0f * dot(m, g);
}

