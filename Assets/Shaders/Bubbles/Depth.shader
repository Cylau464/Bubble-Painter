Shader "DepthOnly"
{
    SubShader
    {
       Tags
        {
            "Queue" = "Transparent-1"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }

        CGINCLUDE
        #pragma vertex vert
        #pragma fragment frag

        #include "UnityCG.cginc"

        int _Count;
        float4 _pAfs[10];
        float4 _dAts[10];
        float4 _MainColor;
        float _MaxForce;
        float _Spring;
        float _Damping;
        float _Namida;
        ENDCG

        ColorMask 0

        Pass
        {
            CGPROGRAM

            struct result
            {
                float4 resPos;
                float3 resNormal;
            };

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

            result WaveModify(float4 pos, in float3 normal)
            {
                result r;
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
                    float A = lerp(singleForce, 0, saturate(((_Damping)*time) / abs(singleForce)));
                    float x = time - distance / data._Namida;
                    float speed = data._Namida * (4 * 3.14 * 3.14) / _Spring;
                    A = (speed * speed * time * time) > distance ? A : 0;
                    float h = -A * (cos(_Spring * (x))) * 0.1;
                    v += h * normal;
                    float3 binormal = cross(normal, wdir);
                    float3 tangent = cross(binormal, normal);
                    n += h * tangent * 20;
                }

                n = normalize(n);
                r.resPos = float4(pos.xyz + v, 1);
                r.resNormal = n;
                return r;
            }

            struct VInput
            {
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;

            };

            float4 vert(VInput v) : SV_POSITION
            {
                float3 normal = mul((float3x3)unity_ObjectToWorld, v.normal);
                result w = WaveModify(v.pos, normal);

                return UnityObjectToClipPos(w.resPos);
            }

            fixed4 frag() : SV_Target
            {
                return 0;
            }

            ENDCG
        }
    }
}