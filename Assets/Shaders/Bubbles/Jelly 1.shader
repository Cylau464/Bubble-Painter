Shader "Custom/Jelly 1"
{
    Properties
    {
        [Header(UniversalRP Default Shader code)]
        [Space(20)]
        _TintColor("Tint Color", Color) = (1, 1, 1, 1)
        _OutlineColor("Outline Color", Color) = (1, 1, 1, 1)
        _MainTex("Texture", 2D) = "white" {}

        _FresnelPower("Fresnel Power", float) = 1
        _AlphaPower("Alpha Fresnel Power", float) = 1
        _Smoothness("Smoothness", float) = 0

            // Toggle control opaque to TransparentCutout
            [Toggle]_AlphaTest("Alpha Test", float) = 0
            _Alpha("AlphaClip", Range(0,1)) = 0.5
            [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull Mode", Float) = 0
    }

        SubShader
        {
            Name  "URPDefault"

            Tags
            {
                "RenderPipeline" = "UniversalRenderPipeline"
                "RenderType" = "Transparent"
                "UniversalMaterialType" = "Lit"
                "Queue" = "Transparent"
            }

            LOD 300
            Cull[_Cull]

            Pass
            {
                Tags
                {
                    "LightMode" = "UniversalForward"
                }

            // Render State
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite On

            HLSLPROGRAM
            #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _IsWave _Explore

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED

            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK

            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            #pragma shader_feature _ALPHATEST_ON

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"

            CBUFFER_START(UnityPerMaterial)
            half4 _TintColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float   _Alpha;
            float _FresnelPower;
            float _AlphaPower;

            int _Count;
            float4 _pAfs[10];
            float4 _dAts[10];
            float4 _MainColor;
            float _MaxForce;
            float _Spring;
            float _Damping;
            float _Namida;
            CBUFFER_END

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

            result ModifyPos(float4 pos, in float3 normal)
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
                    float singleForce = data._Force / (1 + distance);
                    float A = lerp(singleForce, 0, saturate((_Damping * time) / abs(singleForce)));
                    //float speed=data._Namida* (4*3.14*3.14)/_Spring;
                    //A=(speed*speed*time*time)>distance?A:0;	
                    float offset = (cos(_Spring * time)) * -A;
                    v += dir * offset;
                    float3 binormal = cross(normal, wdir);
                    float3 tangent = cross(binormal, normal);
                    n += offset * tangent * 5;
                }

                r.resPos = half4(pos.xyz + v, 1);
                r.resNormal = normalize(n);
                return r;
            }

            result WaveModify(float4 pos, in float3 normal)
            {
                result r;
                float3 v;
                float3 n = normal;

                for (int i = 0; i < _Count; i++) {
                    dataBuff data = getData(i);
                    float3 dir = pos.xyz - data._WorldForcePos.xyz;
                    float3 wdir = mul((float3x3)unity_ObjectToWorld, dir);
                    float distance = dot(dir, dir);
                    float time = _Time.y - data._StartTime;
                    float singleForce = data._Force / (1 + distance * 5);
                    float A = lerp(singleForce, 0, saturate(((_Damping)*time) / abs(singleForce)));
                    float x = time - distance / data._Namida;
                    //x=x<0?0:x;
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

            void FresnelEffect(float3 Normal, float3 ViewDir, float Power, out float Out)
            {
                Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
            }

            void Smoothstep(float Edge1, float Edge2, float In, out float Out)
            {
                Out = smoothstep(Edge1, Edge2, In);
            }

            void OneMinus(float In, out float Out)
            {
                Out = 1 - In;
            }

            struct VInput
            {
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 wpos : TEXCOORD1;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct FInput
            {
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 fogCoord : TEXCOORD1;
                float4 pos : SV_POSITION;
                float4 shadowCoord : TEXCOORD2;
                float3 worldNormal : TEXCOORD3;
                float3 worldSpaceViewDir : TEXCOORD4;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            FInput vert(VInput v)
            {
                FInput o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.uv = v.uv;
                o.fogCoord = TransformWorldToView(v.pos);
                v.wpos = mul(unity_ObjectToWorld, v.pos);
                float3 normal = mul((float3x3)unity_ObjectToWorld, v.normal);
                #ifdef _IsWave
                result w = WaveModify(v.pos, normal);
                #elif _Explore
                result w = ModifyPos(v.pos, normal);
                #else
                result w = ModifyPos(v.pos, normal);
                #endif
                o.pos = TransformObjectToHClip(w.resPos);
                //o.normal = w.resNormal;

                //o.pos = TransformObjectToHClip(v.pos.xyz);
                o.normal = normalize(mul(v.normal, (float3x3)UNITY_MATRIX_I_M));

                o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //o.fogCoord = ComputeFogFactor(o.pos.z);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.pos.xyz);
                o.shadowCoord = GetShadowCoord(vertexInput);

                float3 unnormalizedNormalWS = TransformObjectToWorldNormal(v.normal);
                const float renormFactor = 1.0 / length(unnormalizedNormalWS);

                o.worldNormal = renormFactor * unnormalizedNormalWS;
                o.worldSpaceViewDir = GetWorldSpaceViewDir(v.wpos);

                return o;
            }

            half4 frag(FInput i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                SurfaceData surfaceData;
                InitializeStandardLitSurfaceData(i.uv, surfaceData);

                float fresnelOut;
                FresnelEffect(i.worldNormal, i.worldSpaceViewDir, _FresnelPower, fresnelOut);
                float smoothstepOut;
                Smoothstep(0.25, 0.25, fresnelOut, smoothstepOut);
                float oneMinusOut;
                OneMinus(smoothstepOut, oneMinusOut);
                float4 tintColor = oneMinusOut * _TintColor;

                float4 albedo = tex2D(_MainTex, i.uv) * _TintColor;/*(tintColor + outlineColor);*/
                Light mainLight = GetMainLight(i.shadowCoord);

                //Lighting Calculate(Lambert)              
                float NdotL = saturate(dot(normalize(_MainLightPosition.xyz), i.normal));
                float3 ambient = SampleSH(i.normal);

                albedo.rgb *= NdotL * _MainLightColor.rgb * mainLight.shadowAttenuation + ambient;

                float frenselAlpha;
                FresnelEffect(i.worldNormal, i.worldSpaceViewDir, _AlphaPower, frenselAlpha);
                albedo.a = frenselAlpha;

                #if _ALPHATEST_ON
                clip(albedo.a - _Alpha);
                #endif


                //apply fog
                albedo.rgb = MixFog(albedo.rgb, i.fogCoord);

                return albedo;
            }


            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"

            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }


                //Pass
                //{
                //    Name "DepthOnly"
                //    Tags { "LightMode" = "DepthOnly" }

                //    ZWrite On
                //    ColorMask 0
                //    Cull Back

                //    HLSLPROGRAM

                //    #pragma prefer_hlslcc gles
                //    #pragma exclude_renderers d3d11_9x
                //    #pragma target 2.0

                //    // GPU Instancing
                //    #pragma multi_compile_instancing

                //    #pragma vertex vert
                //    #pragma fragment frag

                //    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

                //    CBUFFER_START(UnityPerMaterial)
                //    CBUFFER_END

                //    struct VertexInput
                //    {
                //        float4 vertex : POSITION;
                //        UNITY_VERTEX_INPUT_INSTANCE_ID
                //    };

                //    struct VertexOutput
                //    {
                //    float4 vertex : SV_POSITION;

                //    UNITY_VERTEX_INPUT_INSTANCE_ID
                //    UNITY_VERTEX_OUTPUT_STEREO
                //    };

                //    VertexOutput vert(VertexInput v)
                //    {
                //        VertexOutput o;
                //        UNITY_SETUP_INSTANCE_ID(v);
                //        UNITY_TRANSFER_INSTANCE_ID(v, o);
                //        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                //        o.vertex = TransformObjectToHClip(v.vertex.xyz);

                //        return o;
                //    }

                //    half4 frag(VertexOutput IN) : SV_TARGET
                //    {
                //        return 0;
                //    }
                //    ENDHLSL
                //}
        }
}