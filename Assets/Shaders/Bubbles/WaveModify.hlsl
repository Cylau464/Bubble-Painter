// Transformation structs and functions
struct dataBuff
{
    float _StartTime;
    float _Force;
    float _Namida;
    float3 _ForceDir;
    float4 _WorldForcePos;
};

dataBuff getData(int i)
{
    dataBuff o;
    o._StartTime = _dAts[i].w;
    o._Force = _pAfs[i].w;

    o._ForceDir = mul((float3x3)unity_WorldToObject, _dAts[i].xyz);
    o._WorldForcePos = mul(unity_WorldToObject, float4(_pAfs[i].xyz, 1));
    o._Namida = _Namida;
    return o;
}

void WaveModify_float(float4 pos, float3 normal, out float4 Out)
{
    float3 v;
    float3 n = normal;

    for (int i = 0; i < _Count; i++)
    {
        dataBuff data = getData(i);
        float3 dir = pos.xyz - data._WorldForcePos.xyz;
        float3 wdir = mul((float3x3)unity_ObjectToWorld, dir);
        float distance = dot(dir, dir);
        float time = _Time.y - data._StartTime;
        float singleForce = data._Force / (1 + distance * 5);
        float A = lerp(singleForce, 0, saturate(((_Damping) * time) / abs(singleForce)));
        float x = time - distance / data._Namida;
        float speed = data._Namida * (4 * 3.14 * 3.14) / _Spring;
        A = (speed * speed * time * time) > distance ? A : 0;
        float h = -A * (cos(_Spring * (x))) * 0.1;
        v += h * normal;
        float3 binormal = cross(normal, wdir);
        float3 tangent = cross(binormal, normal);
        n += h * tangent * 20;
    }

    Out = float4(pos.xyz + v, 1);
    n = normalize(n);
}