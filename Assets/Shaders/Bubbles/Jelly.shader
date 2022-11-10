Shader "Custom/Jelly"
{
    Properties
    {
        [Header(UniversalRP Default Shader code)]
        [Space(20)]
        _TintColor("Tint Color", Color) = (1, 1, 1, 1)
        _MainTex("Texture", 2D) = "white" {}

        _FresnelPower("Fresnel Power", float) = 1
        _AlphaPower("Alpha Fresnel Power", float) = 1

        _Smoothness("Smoothness", float) = 0.8
        _NoiseSubtraction("_NoiseSubtraction", Float) = 0.65
        _NoiseScale("_NoiseScale", Float) = 0.65
        _NoiseSpeed("_NoiseSpeed", Float) = 0.1
        _BlendSharpness("_BlendSharpness", Float) = 0.5
        _EmissionPower("_EmissionPower", Float) = 10

        // Toggle control opaque to TransparentCutout
        [Toggle]_AlphaTest("Alpha Test", float) = 0
        _Alpha("AlphaClip", Range(0,1)) = 0.5
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull Mode", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite On

            // Pass
            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _IsWave _Explore

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

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

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv1 : TEXCOORD1;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                float3 normalWS;
                float4 tangentWS;
                float3 viewDirectionWS;
                #if defined(LIGHTMAP_ON)
                float2 lightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                float3 sh;
                #endif
                float4 fogFactorAndVertexLight;
                float4 shadowCoord;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };

            struct SurfaceDescriptionInputs
            {
                float3 WorldSpaceNormal;
                float3 TangentSpaceNormal;
                float3 WorldSpaceViewDirection;
                float3 ObjectSpacePosition;
                float3 TimeParameters;
            };

            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float4 ObjectSpacePosition;
            };

            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                float3 interp0 : TEXCOORD0;
                float3 interp1 : TEXCOORD1;
                float4 interp2 : TEXCOORD2;
                float3 interp3 : TEXCOORD3;
                #if defined(LIGHTMAP_ON)
                float2 interp4 : TEXCOORD4;
                #endif
                #if !defined(LIGHTMAP_ON)
                float3 interp5 : TEXCOORD5;
                #endif
                float4 interp6 : TEXCOORD6;
                float4 interp7 : TEXCOORD7;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                output.positionCS = input.positionCS;
                output.interp0.xyz = input.positionWS;
                output.interp1.xyz = input.normalWS;
                output.interp2.xyzw = input.tangentWS;
                output.interp3.xyz = input.viewDirectionWS;
                #if defined(LIGHTMAP_ON)
                output.interp4.xy = input.lightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.interp5.xyz = input.sh;
                #endif
                output.interp6.xyzw = input.fogFactorAndVertexLight;
                output.interp7.xyzw = input.shadowCoord;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp0.xyz;
                output.normalWS = input.interp1.xyz;
                output.tangentWS = input.interp2.xyzw;
                output.viewDirectionWS = input.interp3.xyz;
                #if defined(LIGHTMAP_ON)
                output.lightmapUV = input.interp4.xy;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.sh = input.interp5.xyz;
                #endif
                output.fogFactorAndVertexLight = input.interp6.xyzw;
                output.shadowCoord = input.interp7.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            half4 _TintColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Alpha;
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

            float _Smoothness;
            float _NoiseSubtraction;
            float _NoiseScale;
            float _NoiseSpeed;
            float _BlendSharpness;
            float _EmissionPower;
            CBUFFER_END

            // Object and Global properties
            Gradient _EmissionGradient_Definition()
            {
                Gradient g;
                g.type = 0;
                g.colorsLength = 6;
                g.alphasLength = 2;
                g.colors[0] = float4(0.2189393, 0.8396226, 0.07524917, 0);
                g.colors[1] = float4(0.1135636, 0.8212867, 0.8301887, 0.2);
                g.colors[2] = float4(0.1135636, 0.1249385, 0.8301887, 0.4);
                g.colors[3] = float4(0.7946188, 0.1093361, 0.8584906, 0.6);
                g.colors[4] = float4(0.8301887, 0.1057316, 0.1057316, 0.8);
                g.colors[5] = float4(0.8679245, 0.7082965, 0.1023496, 1);
                g.colors[6] = float4(0, 0, 0, 0);
                g.colors[7] = float4(0, 0, 0, 0);
                g.alphas[0] = float2(1, 0);
                g.alphas[1] = float2(1, 1);
                g.alphas[2] = float2(0, 0);
                g.alphas[3] = float2(0, 0);
                g.alphas[4] = float2(0, 0);
                g.alphas[5] = float2(0, 0);
                g.alphas[6] = float2(0, 0);
                g.alphas[7] = float2(0, 0);
                return g;
            }
            #define _EmissionGradient _EmissionGradient_Definition()

            // Transformation structs and functions
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

                r.resPos = float4(pos.xyz + v, 1);
                r.resNormal = normalize(n);
                return r;
            }

            // Graph Functions

            float Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power)
            {
                return pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
            }

            float2 Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset)
            {
                return UV * Tiling + Offset;
            }


            float2 Unity_GradientNoise_Dir_float(float2 p)
            {
                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                p = p % 289;
                // need full precision, otherwise half overflows when p > 1
                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                x = (34 * x + 1) * x % 289;
                x = frac(x / 41) * 2 - 1;
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }

            float Unity_GradientNoise_float(float2 UV, float Scale)
            {
                float2 p = UV * Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
            }

            float4 Unity_SampleGradient_float(Gradient Gradient, float Time)
            {
                float3 color = Gradient.colors[0].rgb;
                [unroll]
                for (int c = 1; c < 8; c++)
                {
                    float colorPos = saturate((Time - Gradient.colors[c - 1].w) / (Gradient.colors[c].w - Gradient.colors[c - 1].w)) * step(c, Gradient.colorsLength - 1);
                    color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
                }
                #ifndef UNITY_COLORSPACE_GAMMA
                color = SRGBToLinear(color);
                #endif
                float alpha = Gradient.alphas[0].x;
                [unroll]
                for (int a = 1; a < 8; a++)
                {
                    float alphaPos = saturate((Time - Gradient.alphas[a - 1].y) / (Gradient.alphas[a].y - Gradient.alphas[a - 1].y)) * step(a, Gradient.alphasLength - 1);
                    alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
                }
                return float4(color, alpha);
            }

            // Graph Vertex
            struct VertexDescription
            {
                float4 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;

                float3 normal = mul((float3x3)UNITY_MATRIX_M, IN.ObjectSpaceNormal);
                //#ifdef _IsWave
                result w = WaveModify(IN.ObjectSpacePosition, normal);
                //#elif _Explore
                //result w = ModifyPos(IN.ObjectSpacePosition, normal;
                //#else
                //result w = ModifyPos(IN.ObjectSpacePosition, normal);
                //#endif
                description.Position = w.resPos;
                description.Normal = IN.ObjectSpaceNormal;// normalize(mul(w.resNormal, (float3x3)UNITY_MATRIX_I_M));//normalize(mul(IN.ObjectSpaceNormal, (float3x3)UNITY_MATRIX_I_M));

                //description.Position = IN.ObjectSpacePosition;
                //description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;

                return description;
            }

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
                float Alpha;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;

                float time = IN.TimeParameters.x * _NoiseSpeed;

                float2 posXY = float2(IN.ObjectSpacePosition.x, IN.ObjectSpacePosition.y);
                float2 uvOffset1 = Unity_TilingAndOffset_float(posXY, float2 (1, 1), time.xx);
                float2 posXZ = float2(IN.ObjectSpacePosition.x, IN.ObjectSpacePosition.z);
                float2 uvOffset2 = Unity_TilingAndOffset_float(posXZ, float2 (1, 1), time.xx);
                float2 posYZ = float2(IN.ObjectSpacePosition.y, IN.ObjectSpacePosition.z);
                float2 uvOffset3 = Unity_TilingAndOffset_float(posYZ, float2 (1, 1), time.xx);

                float noise1 = Unity_GradientNoise_float(uvOffset1, _NoiseScale) - _NoiseSubtraction;
                float noise2 = Unity_GradientNoise_float(uvOffset2, _NoiseScale) - _NoiseSubtraction;
                float noise3 = Unity_GradientNoise_float(uvOffset3, _NoiseScale) - _NoiseSubtraction;

                half3 normalVec = normalize(pow(abs(IN.WorldSpaceNormal), _BlendSharpness));

                noise1 *= normalVec.z;
                noise2 *= normalVec.y;
                noise3 *= normalVec.x;

                float noise = clamp(noise1 + noise2 + noise3, 0, 1);
                float fresnelEffect = Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, 0.3);
                float4 sampleGradient = Unity_SampleGradient_float(_EmissionGradient, (fresnelEffect - noise));
                float4 finalNoise = sampleGradient * noise * _EmissionPower;
                float alpha = Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _AlphaPower);
                alpha = smoothstep(0, 1, alpha);

                surface.BaseColor = _TintColor.xyz;
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Emission = finalNoise.xyz;
                surface.Metallic = 0;
                surface.Smoothness = _Smoothness;
                surface.Occlusion = 1;
                surface.Alpha = alpha;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }

            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                float3 unnormalizedNormalWS = input.normalWS;
                const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                output.WorldSpaceViewDirection = input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
                output.ObjectSpacePosition = (input.positionWS);
                output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite On
            ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS;
                float3 viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };

            struct SurfaceDescriptionInputs
            {
                float3 WorldSpaceNormal;
                float3 WorldSpaceViewDirection;
            };

            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };

            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                float3 interp0 : TEXCOORD0;
                float3 interp1 : TEXCOORD1;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                output.positionCS = input.positionCS;
                output.interp0.xyz = input.normalWS;
                output.interp1.xyz = input.viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.normalWS = input.interp0.xyz;
                output.viewDirectionWS = input.interp1.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _TintColor;
            float _AlphaPower;
            float _Smoothness;
            float _NoiseSubtraction;
            float _BlendSharpness;
            float _EmissionPower;
            CBUFFER_END

            // Object and Global properties
            Gradient _EmissionGradient_Definition()
            {
                Gradient g;
                g.type = 0;
                g.colorsLength = 6;
                g.alphasLength = 2;
                g.colors[0] = float4(0.2189393, 0.8396226, 0.07524917, 0);
                g.colors[1] = float4(0.1135636, 0.8212867, 0.8301887, 0.2);
                g.colors[2] = float4(0.1135636, 0.1249385, 0.8301887, 0.4);
                g.colors[3] = float4(0.7946188, 0.1093361, 0.8584906, 0.6);
                g.colors[4] = float4(0.8301887, 0.1057316, 0.1057316, 0.8);
                g.colors[5] = float4(0.8679245, 0.7082965, 0.1023496, 1);
                g.colors[6] = float4(0, 0, 0, 0);
                g.colors[7] = float4(0, 0, 0, 0);
                g.alphas[0] = float2(1, 0);
                g.alphas[1] = float2(1, 1);
                g.alphas[2] = float2(0, 0);
                g.alphas[3] = float2(0, 0);
                g.alphas[4] = float2(0, 0);
                g.alphas[5] = float2(0, 0);
                g.alphas[6] = float2(0, 0);
                g.alphas[7] = float2(0, 0);
                return g;
            }
            #define _EmissionGradient _EmissionGradient_Definition()

            // Graph Functions

            float Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power)
            {
                return pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
            }

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float fresnel = Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _AlphaPower);
                surface.Alpha = fresnel;

                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                float3 unnormalizedNormalWS = input.normalWS;
                const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


                output.WorldSpaceViewDirection = input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                return output;
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
    }
}