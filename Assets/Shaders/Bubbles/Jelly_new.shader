Shader "Bubble"
{
    Properties
    {
        _TintColor("Color", Color) = (0.8679245, 0, 0, 0)
        _AlphaPower("AlphaPower", Float) = 0.5
        _Smoothness("Smoothness", Float) = 0.8
        _Metallic("Metallic", Float) = 0
        _NoiseScale("NoiseScale", Float) = 1.5
        _NoiseSubtraction("NoiseSubtraction", Float) = 0.65
        _BlendSharpness("BlendSharpness", Float) = 0.5
        _EmissionPower("EmissionPower", Float) = 10

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
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
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

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
            float3 positionOS : POSITION;
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
            float3 WorldSpacePosition;
            float3 TimeParameters;
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

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
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
        Varyings UnpackVaryings (PackedVaryings input)
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
        float4 _TintColor;
        float _AlphaPower;
        float _Smoothness;
        float _Metallic;
        float _NoiseScale;
        float _NoiseSubtraction;
        float _BlendSharpness;
        float _EmissionPower;
        CBUFFER_END

        // Object and Global properties
        Gradient _EmissionGradient_Definition()
        {
            Gradient g;
            g.type = 0;
            g.colorsLength = 5;
            g.alphasLength = 2;
            g.colors[0] = float4(0.2189393, 0.8396226, 0.07524917, 0);
            g.colors[1] = float4(0.1135636, 0.8212867, 0.8301887, 0.123537);
            g.colors[2] = float4(0.1135636, 0.1249385, 0.8301887, 0.3705959);
            g.colors[3] = float4(0.8301887, 0.1057316, 0.1057316, 0.7088273);
            g.colors[4] = float4(0.8679245, 0.7082965, 0.1023496, 0.8558785);
            g.colors[5] = float4(0, 0, 0, 0);
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
        float _Count;
        float _Spring;
        float _Damping;
        float _Namida;
        float4 _pAfs[10];
        float4 _dAts[10];

            // Graph Functions
            
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
            Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
            Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
            Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }

        void Unity_Multiply_float(float3x3 A, float3 B, out float3 Out)
        {
            Out = mul(A, B);
        }

        // cb1be5f5a203498458c775f5477a077e
        #include "Assets/Shaders/Bubbles/WaveModify.hlsl"

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }

        void Unity_Power_float3(float3 A, float3 B, out float3 Out)
        {
            Out = pow(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_SampleGradient_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < 8; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c-1].w) / (Gradient.colors[c].w - Gradient.colors[c-1].w)) * step(c, Gradient.colorsLength-1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifndef UNITY_COLORSPACE_GAMMA
            color = SRGBToLinear(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < 8; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a-1].y) / (Gradient.alphas[a].y - Gradient.alphas[a-1].y)) * step(a, Gradient.alphasLength-1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
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
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1 = UNITY_MATRIX_M[0];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2 = UNITY_MATRIX_M[1];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3 = UNITY_MATRIX_M[2];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M3_4 = UNITY_MATRIX_M[3];
            float4x4 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4;
            float3x3 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5;
            float2x2 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6;
            Unity_MatrixConstruction_Row_float(_MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3, float4 (0, 0, 0, 0), _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6);
            float3 _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2;
            Unity_Multiply_float(_MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, IN.ObjectSpaceNormal, _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2);
            float4 _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2;
            WaveModify_float((float4(IN.ObjectSpacePosition, 1.0)), _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2, _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2);
            description.Position = (_WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2.xyz);
            description.Normal = IN.ObjectSpaceNormal;
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
            float4 _Property_16c48420616843768bb9647b4ffc177c_Out_0 = _TintColor;
            Gradient _Property_7da875de7ed845c1b347a72b6a8c6769_Out_0 = _EmissionGradient;
            float _FresnelEffect_65387cadbd2544dfa90e64487edf01f0_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, 0.3, _FresnelEffect_65387cadbd2544dfa90e64487edf01f0_Out_3);
            float _Split_066869d3770f45c8a92cec39b399f095_R_1 = IN.WorldSpacePosition[0];
            float _Split_066869d3770f45c8a92cec39b399f095_G_2 = IN.WorldSpacePosition[1];
            float _Split_066869d3770f45c8a92cec39b399f095_B_3 = IN.WorldSpacePosition[2];
            float _Split_066869d3770f45c8a92cec39b399f095_A_4 = 0;
            float2 _Vector2_93509cf0a81442b7bb575be7510c8a05_Out_0 = float2(_Split_066869d3770f45c8a92cec39b399f095_R_1, _Split_066869d3770f45c8a92cec39b399f095_G_2);
            float _Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, 0.1, _Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2);
            float2 _TilingAndOffset_a8bb8eae23ad45629aea2b88f06988cc_Out_3;
            Unity_TilingAndOffset_float(_Vector2_93509cf0a81442b7bb575be7510c8a05_Out_0, float2 (1, 1), (_Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2.xx), _TilingAndOffset_a8bb8eae23ad45629aea2b88f06988cc_Out_3);
            float _Property_5a7a9017492641be9ac25f944c8f6829_Out_0 = _NoiseScale;
            float _GradientNoise_2058c27d35914069a1ca97d0f7d8f680_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a8bb8eae23ad45629aea2b88f06988cc_Out_3, _Property_5a7a9017492641be9ac25f944c8f6829_Out_0, _GradientNoise_2058c27d35914069a1ca97d0f7d8f680_Out_2);
            float _Property_fe54568bada549df9217787389235abb_Out_0 = _NoiseSubtraction;
            float _Subtract_b37900824de84af3a6d2e60faec4969d_Out_2;
            Unity_Subtract_float(_GradientNoise_2058c27d35914069a1ca97d0f7d8f680_Out_2, _Property_fe54568bada549df9217787389235abb_Out_0, _Subtract_b37900824de84af3a6d2e60faec4969d_Out_2);
            float3 _Absolute_797c87bde05541aea4d975ceda1a3aeb_Out_1;
            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_797c87bde05541aea4d975ceda1a3aeb_Out_1);
            float _Property_c3fef34a9d2f43f6ab03d925c48731a2_Out_0 = _BlendSharpness;
            float3 _Power_1c97f31919d6442cb40af69f8ac3336e_Out_2;
            Unity_Power_float3(_Absolute_797c87bde05541aea4d975ceda1a3aeb_Out_1, (_Property_c3fef34a9d2f43f6ab03d925c48731a2_Out_0.xxx), _Power_1c97f31919d6442cb40af69f8ac3336e_Out_2);
            float3 _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1;
            Unity_Normalize_float3(_Power_1c97f31919d6442cb40af69f8ac3336e_Out_2, _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1);
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_R_1 = _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1[0];
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_G_2 = _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1[1];
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_B_3 = _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1[2];
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_A_4 = 0;
            float _Multiply_0dec24b7fa6b47cab3e50b0e2d5ca1e5_Out_2;
            Unity_Multiply_float(_Subtract_b37900824de84af3a6d2e60faec4969d_Out_2, _Split_92dc20aeb54f4b0b928267e1a42187d6_B_3, _Multiply_0dec24b7fa6b47cab3e50b0e2d5ca1e5_Out_2);
            float2 _Vector2_14f8cea02eec4bedbe1542402647b958_Out_0 = float2(_Split_066869d3770f45c8a92cec39b399f095_R_1, _Split_066869d3770f45c8a92cec39b399f095_B_3);
            float2 _TilingAndOffset_5e527e8a66624ddfa80e19ac11b215cd_Out_3;
            Unity_TilingAndOffset_float(_Vector2_14f8cea02eec4bedbe1542402647b958_Out_0, float2 (1, 1), (_Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2.xx), _TilingAndOffset_5e527e8a66624ddfa80e19ac11b215cd_Out_3);
            float _GradientNoise_5ff8b4dfe59d484ea281d534f56dc321_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5e527e8a66624ddfa80e19ac11b215cd_Out_3, _Property_5a7a9017492641be9ac25f944c8f6829_Out_0, _GradientNoise_5ff8b4dfe59d484ea281d534f56dc321_Out_2);
            float _Subtract_b7b4bdd0d6014e6aae580d41569ae1c4_Out_2;
            Unity_Subtract_float(_GradientNoise_5ff8b4dfe59d484ea281d534f56dc321_Out_2, _Property_fe54568bada549df9217787389235abb_Out_0, _Subtract_b7b4bdd0d6014e6aae580d41569ae1c4_Out_2);
            float _Multiply_1bf8f1f8f1084396966ac6bf20e22798_Out_2;
            Unity_Multiply_float(_Subtract_b7b4bdd0d6014e6aae580d41569ae1c4_Out_2, _Split_92dc20aeb54f4b0b928267e1a42187d6_G_2, _Multiply_1bf8f1f8f1084396966ac6bf20e22798_Out_2);
            float _Add_1dd72b043e5d4bcfa59095bfefbca009_Out_2;
            Unity_Add_float(_Multiply_0dec24b7fa6b47cab3e50b0e2d5ca1e5_Out_2, _Multiply_1bf8f1f8f1084396966ac6bf20e22798_Out_2, _Add_1dd72b043e5d4bcfa59095bfefbca009_Out_2);
            float2 _Vector2_fa9631173a1a472897504f00df74776a_Out_0 = float2(_Split_066869d3770f45c8a92cec39b399f095_G_2, _Split_066869d3770f45c8a92cec39b399f095_B_3);
            float2 _TilingAndOffset_51b07fac754d408898803fc3a063e492_Out_3;
            Unity_TilingAndOffset_float(_Vector2_fa9631173a1a472897504f00df74776a_Out_0, float2 (1, 1), (_Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2.xx), _TilingAndOffset_51b07fac754d408898803fc3a063e492_Out_3);
            float _GradientNoise_9e3beec85934435bbb899abae5ca2f75_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_51b07fac754d408898803fc3a063e492_Out_3, _Property_5a7a9017492641be9ac25f944c8f6829_Out_0, _GradientNoise_9e3beec85934435bbb899abae5ca2f75_Out_2);
            float _Subtract_70c45514b16041be9377ba62c53bbf52_Out_2;
            Unity_Subtract_float(_GradientNoise_9e3beec85934435bbb899abae5ca2f75_Out_2, _Property_fe54568bada549df9217787389235abb_Out_0, _Subtract_70c45514b16041be9377ba62c53bbf52_Out_2);
            float _Multiply_e0a012c3af9845c2ac7cd660ba8aa8a2_Out_2;
            Unity_Multiply_float(_Subtract_70c45514b16041be9377ba62c53bbf52_Out_2, _Split_92dc20aeb54f4b0b928267e1a42187d6_R_1, _Multiply_e0a012c3af9845c2ac7cd660ba8aa8a2_Out_2);
            float _Add_112bd27952054267aff87a35030e33e0_Out_2;
            Unity_Add_float(_Add_1dd72b043e5d4bcfa59095bfefbca009_Out_2, _Multiply_e0a012c3af9845c2ac7cd660ba8aa8a2_Out_2, _Add_112bd27952054267aff87a35030e33e0_Out_2);
            float _Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3;
            Unity_Clamp_float(_Add_112bd27952054267aff87a35030e33e0_Out_2, 0, 1, _Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3);
            float _Subtract_2f5244b1136b4ddeaf7ccc9a65ef1bca_Out_2;
            Unity_Subtract_float(_FresnelEffect_65387cadbd2544dfa90e64487edf01f0_Out_3, _Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3, _Subtract_2f5244b1136b4ddeaf7ccc9a65ef1bca_Out_2);
            float4 _SampleGradient_a553dbc03418426d9d4f991cd3009782_Out_2;
            Unity_SampleGradient_float(_Property_7da875de7ed845c1b347a72b6a8c6769_Out_0, _Subtract_2f5244b1136b4ddeaf7ccc9a65ef1bca_Out_2, _SampleGradient_a553dbc03418426d9d4f991cd3009782_Out_2);
            float4 _Multiply_a3f13f0f0f0b403eafaaca9fc77606f1_Out_2;
            Unity_Multiply_float(_SampleGradient_a553dbc03418426d9d4f991cd3009782_Out_2, (_Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3.xxxx), _Multiply_a3f13f0f0f0b403eafaaca9fc77606f1_Out_2);
            float _Property_6a98ee0f69514bd4be062252c829da82_Out_0 = _EmissionPower;
            float4 _Multiply_66fcb2d896db4f6d9034504497ede84a_Out_2;
            Unity_Multiply_float(_Multiply_a3f13f0f0f0b403eafaaca9fc77606f1_Out_2, (_Property_6a98ee0f69514bd4be062252c829da82_Out_0.xxxx), _Multiply_66fcb2d896db4f6d9034504497ede84a_Out_2);
            float _Property_97873980abaa4b1fa9ea0cbfca993d10_Out_0 = _Metallic;
            float _Property_ff7903218df24bbe88610ff82fc0ae0c_Out_0 = _Smoothness;
            float _Property_da1611847bfd48c48e316dd883405ee0_Out_0 = _AlphaPower;
            float _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_da1611847bfd48c48e316dd883405ee0_Out_0, _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3);
            surface.BaseColor = (_Property_16c48420616843768bb9647b4ffc177c_Out_0.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_66fcb2d896db4f6d9034504497ede84a_Out_2.xyz);
            surface.Metallic = _Property_97873980abaa4b1fa9ea0cbfca993d10_Out_0;
            surface.Smoothness = _Property_ff7903218df24bbe88610ff82fc0ae0c_Out_0;
            surface.Occlusion = 1;
            surface.Alpha = _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
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
            #define SHADERPASS SHADERPASS_GBUFFER
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
            float3 positionOS : POSITION;
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
            float3 WorldSpacePosition;
            float3 TimeParameters;
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

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
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
        Varyings UnpackVaryings (PackedVaryings input)
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
        float4 _TintColor;
        float _AlphaPower;
        float _Smoothness;
        float _Metallic;
        float _NoiseScale;
        float _NoiseSubtraction;
        float _BlendSharpness;
        float _EmissionPower;
        CBUFFER_END

        // Object and Global properties
        Gradient _EmissionGradient_Definition()
        {
            Gradient g;
            g.type = 0;
            g.colorsLength = 5;
            g.alphasLength = 2;
            g.colors[0] = float4(0.2189393, 0.8396226, 0.07524917, 0);
            g.colors[1] = float4(0.1135636, 0.8212867, 0.8301887, 0.123537);
            g.colors[2] = float4(0.1135636, 0.1249385, 0.8301887, 0.3705959);
            g.colors[3] = float4(0.8301887, 0.1057316, 0.1057316, 0.7088273);
            g.colors[4] = float4(0.8679245, 0.7082965, 0.1023496, 0.8558785);
            g.colors[5] = float4(0, 0, 0, 0);
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
        float _Count;
        float _Spring;
        float _Damping;
        float _Namida;
        float4 _pAfs[10];
        float4 _dAts[10];

            // Graph Functions
            
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
            Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
            Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
            Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }

        void Unity_Multiply_float(float3x3 A, float3 B, out float3 Out)
        {
            Out = mul(A, B);
        }

        // cb1be5f5a203498458c775f5477a077e
        #include "Assets/Shaders/Bubbles/WaveModify.hlsl"

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }

        void Unity_Power_float3(float3 A, float3 B, out float3 Out)
        {
            Out = pow(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_SampleGradient_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < 8; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c-1].w) / (Gradient.colors[c].w - Gradient.colors[c-1].w)) * step(c, Gradient.colorsLength-1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifndef UNITY_COLORSPACE_GAMMA
            color = SRGBToLinear(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < 8; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a-1].y) / (Gradient.alphas[a].y - Gradient.alphas[a-1].y)) * step(a, Gradient.alphasLength-1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
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
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1 = UNITY_MATRIX_M[0];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2 = UNITY_MATRIX_M[1];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3 = UNITY_MATRIX_M[2];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M3_4 = UNITY_MATRIX_M[3];
            float4x4 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4;
            float3x3 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5;
            float2x2 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6;
            Unity_MatrixConstruction_Row_float(_MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3, float4 (0, 0, 0, 0), _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6);
            float3 _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2;
            Unity_Multiply_float(_MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, IN.ObjectSpaceNormal, _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2);
            float4 _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2;
            WaveModify_float((float4(IN.ObjectSpacePosition, 1.0)), _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2, _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2);
            description.Position = (_WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2.xyz);
            description.Normal = IN.ObjectSpaceNormal;
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
            float4 _Property_16c48420616843768bb9647b4ffc177c_Out_0 = _TintColor;
            Gradient _Property_7da875de7ed845c1b347a72b6a8c6769_Out_0 = _EmissionGradient;
            float _FresnelEffect_65387cadbd2544dfa90e64487edf01f0_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, 0.3, _FresnelEffect_65387cadbd2544dfa90e64487edf01f0_Out_3);
            float _Split_066869d3770f45c8a92cec39b399f095_R_1 = IN.WorldSpacePosition[0];
            float _Split_066869d3770f45c8a92cec39b399f095_G_2 = IN.WorldSpacePosition[1];
            float _Split_066869d3770f45c8a92cec39b399f095_B_3 = IN.WorldSpacePosition[2];
            float _Split_066869d3770f45c8a92cec39b399f095_A_4 = 0;
            float2 _Vector2_93509cf0a81442b7bb575be7510c8a05_Out_0 = float2(_Split_066869d3770f45c8a92cec39b399f095_R_1, _Split_066869d3770f45c8a92cec39b399f095_G_2);
            float _Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, 0.1, _Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2);
            float2 _TilingAndOffset_a8bb8eae23ad45629aea2b88f06988cc_Out_3;
            Unity_TilingAndOffset_float(_Vector2_93509cf0a81442b7bb575be7510c8a05_Out_0, float2 (1, 1), (_Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2.xx), _TilingAndOffset_a8bb8eae23ad45629aea2b88f06988cc_Out_3);
            float _Property_5a7a9017492641be9ac25f944c8f6829_Out_0 = _NoiseScale;
            float _GradientNoise_2058c27d35914069a1ca97d0f7d8f680_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a8bb8eae23ad45629aea2b88f06988cc_Out_3, _Property_5a7a9017492641be9ac25f944c8f6829_Out_0, _GradientNoise_2058c27d35914069a1ca97d0f7d8f680_Out_2);
            float _Property_fe54568bada549df9217787389235abb_Out_0 = _NoiseSubtraction;
            float _Subtract_b37900824de84af3a6d2e60faec4969d_Out_2;
            Unity_Subtract_float(_GradientNoise_2058c27d35914069a1ca97d0f7d8f680_Out_2, _Property_fe54568bada549df9217787389235abb_Out_0, _Subtract_b37900824de84af3a6d2e60faec4969d_Out_2);
            float3 _Absolute_797c87bde05541aea4d975ceda1a3aeb_Out_1;
            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_797c87bde05541aea4d975ceda1a3aeb_Out_1);
            float _Property_c3fef34a9d2f43f6ab03d925c48731a2_Out_0 = _BlendSharpness;
            float3 _Power_1c97f31919d6442cb40af69f8ac3336e_Out_2;
            Unity_Power_float3(_Absolute_797c87bde05541aea4d975ceda1a3aeb_Out_1, (_Property_c3fef34a9d2f43f6ab03d925c48731a2_Out_0.xxx), _Power_1c97f31919d6442cb40af69f8ac3336e_Out_2);
            float3 _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1;
            Unity_Normalize_float3(_Power_1c97f31919d6442cb40af69f8ac3336e_Out_2, _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1);
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_R_1 = _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1[0];
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_G_2 = _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1[1];
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_B_3 = _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1[2];
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_A_4 = 0;
            float _Multiply_0dec24b7fa6b47cab3e50b0e2d5ca1e5_Out_2;
            Unity_Multiply_float(_Subtract_b37900824de84af3a6d2e60faec4969d_Out_2, _Split_92dc20aeb54f4b0b928267e1a42187d6_B_3, _Multiply_0dec24b7fa6b47cab3e50b0e2d5ca1e5_Out_2);
            float2 _Vector2_14f8cea02eec4bedbe1542402647b958_Out_0 = float2(_Split_066869d3770f45c8a92cec39b399f095_R_1, _Split_066869d3770f45c8a92cec39b399f095_B_3);
            float2 _TilingAndOffset_5e527e8a66624ddfa80e19ac11b215cd_Out_3;
            Unity_TilingAndOffset_float(_Vector2_14f8cea02eec4bedbe1542402647b958_Out_0, float2 (1, 1), (_Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2.xx), _TilingAndOffset_5e527e8a66624ddfa80e19ac11b215cd_Out_3);
            float _GradientNoise_5ff8b4dfe59d484ea281d534f56dc321_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5e527e8a66624ddfa80e19ac11b215cd_Out_3, _Property_5a7a9017492641be9ac25f944c8f6829_Out_0, _GradientNoise_5ff8b4dfe59d484ea281d534f56dc321_Out_2);
            float _Subtract_b7b4bdd0d6014e6aae580d41569ae1c4_Out_2;
            Unity_Subtract_float(_GradientNoise_5ff8b4dfe59d484ea281d534f56dc321_Out_2, _Property_fe54568bada549df9217787389235abb_Out_0, _Subtract_b7b4bdd0d6014e6aae580d41569ae1c4_Out_2);
            float _Multiply_1bf8f1f8f1084396966ac6bf20e22798_Out_2;
            Unity_Multiply_float(_Subtract_b7b4bdd0d6014e6aae580d41569ae1c4_Out_2, _Split_92dc20aeb54f4b0b928267e1a42187d6_G_2, _Multiply_1bf8f1f8f1084396966ac6bf20e22798_Out_2);
            float _Add_1dd72b043e5d4bcfa59095bfefbca009_Out_2;
            Unity_Add_float(_Multiply_0dec24b7fa6b47cab3e50b0e2d5ca1e5_Out_2, _Multiply_1bf8f1f8f1084396966ac6bf20e22798_Out_2, _Add_1dd72b043e5d4bcfa59095bfefbca009_Out_2);
            float2 _Vector2_fa9631173a1a472897504f00df74776a_Out_0 = float2(_Split_066869d3770f45c8a92cec39b399f095_G_2, _Split_066869d3770f45c8a92cec39b399f095_B_3);
            float2 _TilingAndOffset_51b07fac754d408898803fc3a063e492_Out_3;
            Unity_TilingAndOffset_float(_Vector2_fa9631173a1a472897504f00df74776a_Out_0, float2 (1, 1), (_Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2.xx), _TilingAndOffset_51b07fac754d408898803fc3a063e492_Out_3);
            float _GradientNoise_9e3beec85934435bbb899abae5ca2f75_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_51b07fac754d408898803fc3a063e492_Out_3, _Property_5a7a9017492641be9ac25f944c8f6829_Out_0, _GradientNoise_9e3beec85934435bbb899abae5ca2f75_Out_2);
            float _Subtract_70c45514b16041be9377ba62c53bbf52_Out_2;
            Unity_Subtract_float(_GradientNoise_9e3beec85934435bbb899abae5ca2f75_Out_2, _Property_fe54568bada549df9217787389235abb_Out_0, _Subtract_70c45514b16041be9377ba62c53bbf52_Out_2);
            float _Multiply_e0a012c3af9845c2ac7cd660ba8aa8a2_Out_2;
            Unity_Multiply_float(_Subtract_70c45514b16041be9377ba62c53bbf52_Out_2, _Split_92dc20aeb54f4b0b928267e1a42187d6_R_1, _Multiply_e0a012c3af9845c2ac7cd660ba8aa8a2_Out_2);
            float _Add_112bd27952054267aff87a35030e33e0_Out_2;
            Unity_Add_float(_Add_1dd72b043e5d4bcfa59095bfefbca009_Out_2, _Multiply_e0a012c3af9845c2ac7cd660ba8aa8a2_Out_2, _Add_112bd27952054267aff87a35030e33e0_Out_2);
            float _Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3;
            Unity_Clamp_float(_Add_112bd27952054267aff87a35030e33e0_Out_2, 0, 1, _Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3);
            float _Subtract_2f5244b1136b4ddeaf7ccc9a65ef1bca_Out_2;
            Unity_Subtract_float(_FresnelEffect_65387cadbd2544dfa90e64487edf01f0_Out_3, _Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3, _Subtract_2f5244b1136b4ddeaf7ccc9a65ef1bca_Out_2);
            float4 _SampleGradient_a553dbc03418426d9d4f991cd3009782_Out_2;
            Unity_SampleGradient_float(_Property_7da875de7ed845c1b347a72b6a8c6769_Out_0, _Subtract_2f5244b1136b4ddeaf7ccc9a65ef1bca_Out_2, _SampleGradient_a553dbc03418426d9d4f991cd3009782_Out_2);
            float4 _Multiply_a3f13f0f0f0b403eafaaca9fc77606f1_Out_2;
            Unity_Multiply_float(_SampleGradient_a553dbc03418426d9d4f991cd3009782_Out_2, (_Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3.xxxx), _Multiply_a3f13f0f0f0b403eafaaca9fc77606f1_Out_2);
            float _Property_6a98ee0f69514bd4be062252c829da82_Out_0 = _EmissionPower;
            float4 _Multiply_66fcb2d896db4f6d9034504497ede84a_Out_2;
            Unity_Multiply_float(_Multiply_a3f13f0f0f0b403eafaaca9fc77606f1_Out_2, (_Property_6a98ee0f69514bd4be062252c829da82_Out_0.xxxx), _Multiply_66fcb2d896db4f6d9034504497ede84a_Out_2);
            float _Property_97873980abaa4b1fa9ea0cbfca993d10_Out_0 = _Metallic;
            float _Property_ff7903218df24bbe88610ff82fc0ae0c_Out_0 = _Smoothness;
            float _Property_da1611847bfd48c48e316dd883405ee0_Out_0 = _AlphaPower;
            float _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_da1611847bfd48c48e316dd883405ee0_Out_0, _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3);
            surface.BaseColor = (_Property_16c48420616843768bb9647b4ffc177c_Out_0.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_66fcb2d896db4f6d9034504497ede84a_Out_2.xyz);
            surface.Metallic = _Property_97873980abaa4b1fa9ea0cbfca993d10_Out_0;
            surface.Smoothness = _Property_ff7903218df24bbe88610ff82fc0ae0c_Out_0;
            surface.Occlusion = 1;
            surface.Alpha = _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

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
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
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

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyz =  input.viewDirectionWS;
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
        Varyings UnpackVaryings (PackedVaryings input)
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
        float _Metallic;
        float _NoiseScale;
        float _NoiseSubtraction;
        float _BlendSharpness;
        float _EmissionPower;
        CBUFFER_END

        // Object and Global properties
        Gradient _EmissionGradient_Definition()
        {
            Gradient g;
            g.type = 0;
            g.colorsLength = 5;
            g.alphasLength = 2;
            g.colors[0] = float4(0.2189393, 0.8396226, 0.07524917, 0);
            g.colors[1] = float4(0.1135636, 0.8212867, 0.8301887, 0.123537);
            g.colors[2] = float4(0.1135636, 0.1249385, 0.8301887, 0.3705959);
            g.colors[3] = float4(0.8301887, 0.1057316, 0.1057316, 0.7088273);
            g.colors[4] = float4(0.8679245, 0.7082965, 0.1023496, 0.8558785);
            g.colors[5] = float4(0, 0, 0, 0);
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
        float _Count;
        float _Spring;
        float _Damping;
        float _Namida;
        float4 _pAfs[10];
        float4 _dAts[10];

            // Graph Functions
            
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
            Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
            Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
            Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }

        void Unity_Multiply_float(float3x3 A, float3 B, out float3 Out)
        {
            Out = mul(A, B);
        }

        // cb1be5f5a203498458c775f5477a077e
        #include "Assets/Shaders/Bubbles/WaveModify.hlsl"

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
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
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1 = UNITY_MATRIX_M[0];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2 = UNITY_MATRIX_M[1];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3 = UNITY_MATRIX_M[2];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M3_4 = UNITY_MATRIX_M[3];
            float4x4 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4;
            float3x3 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5;
            float2x2 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6;
            Unity_MatrixConstruction_Row_float(_MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3, float4 (0, 0, 0, 0), _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6);
            float3 _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2;
            Unity_Multiply_float(_MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, IN.ObjectSpaceNormal, _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2);
            float4 _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2;
            WaveModify_float((float4(IN.ObjectSpacePosition, 1.0)), _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2, _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2);
            description.Position = (_WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2.xyz);
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
            float _Property_da1611847bfd48c48e316dd883405ee0_Out_0 = _AlphaPower;
            float _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_da1611847bfd48c48e316dd883405ee0_Out_0, _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3);
            surface.Alpha = _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
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
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
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
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
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
            #define SHADERPASS SHADERPASS_DEPTHONLY
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

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyz =  input.viewDirectionWS;
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
        Varyings UnpackVaryings (PackedVaryings input)
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
        float _Metallic;
        float _NoiseScale;
        float _NoiseSubtraction;
        float _BlendSharpness;
        float _EmissionPower;
        CBUFFER_END

        // Object and Global properties
        Gradient _EmissionGradient_Definition()
        {
            Gradient g;
            g.type = 0;
            g.colorsLength = 5;
            g.alphasLength = 2;
            g.colors[0] = float4(0.2189393, 0.8396226, 0.07524917, 0);
            g.colors[1] = float4(0.1135636, 0.8212867, 0.8301887, 0.123537);
            g.colors[2] = float4(0.1135636, 0.1249385, 0.8301887, 0.3705959);
            g.colors[3] = float4(0.8301887, 0.1057316, 0.1057316, 0.7088273);
            g.colors[4] = float4(0.8679245, 0.7082965, 0.1023496, 0.8558785);
            g.colors[5] = float4(0, 0, 0, 0);
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
        float _Count;
        float _Spring;
        float _Damping;
        float _Namida;
        float4 _pAfs[10];
        float4 _dAts[10];

            // Graph Functions
            
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
            Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
            Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
            Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }

        void Unity_Multiply_float(float3x3 A, float3 B, out float3 Out)
        {
            Out = mul(A, B);
        }

        // cb1be5f5a203498458c775f5477a077e
        #include "Assets/Shaders/Bubbles/WaveModify.hlsl"

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
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
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1 = UNITY_MATRIX_M[0];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2 = UNITY_MATRIX_M[1];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3 = UNITY_MATRIX_M[2];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M3_4 = UNITY_MATRIX_M[3];
            float4x4 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4;
            float3x3 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5;
            float2x2 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6;
            Unity_MatrixConstruction_Row_float(_MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3, float4 (0, 0, 0, 0), _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6);
            float3 _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2;
            Unity_Multiply_float(_MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, IN.ObjectSpaceNormal, _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2);
            float4 _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2;
            WaveModify_float((float4(IN.ObjectSpacePosition, 1.0)), _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2, _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2);
            description.Position = (_WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2.xyz);
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
            float _Property_da1611847bfd48c48e316dd883405ee0_Out_0 = _AlphaPower;
            float _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_da1611847bfd48c48e316dd883405ee0_Out_0, _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3);
            surface.Alpha = _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
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
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
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
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 normalWS;
            float4 tangentWS;
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
            float3 TangentSpaceNormal;
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
            float4 interp1 : TEXCOORD1;
            float3 interp2 : TEXCOORD2;
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

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyz =  input.viewDirectionWS;
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
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.viewDirectionWS = input.interp2.xyz;
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
        float _Metallic;
        float _NoiseScale;
        float _NoiseSubtraction;
        float _BlendSharpness;
        float _EmissionPower;
        CBUFFER_END

        // Object and Global properties
        Gradient _EmissionGradient_Definition()
        {
            Gradient g;
            g.type = 0;
            g.colorsLength = 5;
            g.alphasLength = 2;
            g.colors[0] = float4(0.2189393, 0.8396226, 0.07524917, 0);
            g.colors[1] = float4(0.1135636, 0.8212867, 0.8301887, 0.123537);
            g.colors[2] = float4(0.1135636, 0.1249385, 0.8301887, 0.3705959);
            g.colors[3] = float4(0.8301887, 0.1057316, 0.1057316, 0.7088273);
            g.colors[4] = float4(0.8679245, 0.7082965, 0.1023496, 0.8558785);
            g.colors[5] = float4(0, 0, 0, 0);
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
        float _Count;
        float _Spring;
        float _Damping;
        float _Namida;
        float4 _pAfs[10];
        float4 _dAts[10];

            // Graph Functions
            
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
            Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
            Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
            Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }

        void Unity_Multiply_float(float3x3 A, float3 B, out float3 Out)
        {
            Out = mul(A, B);
        }

        // cb1be5f5a203498458c775f5477a077e
        #include "Assets/Shaders/Bubbles/WaveModify.hlsl"

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
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
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1 = UNITY_MATRIX_M[0];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2 = UNITY_MATRIX_M[1];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3 = UNITY_MATRIX_M[2];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M3_4 = UNITY_MATRIX_M[3];
            float4x4 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4;
            float3x3 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5;
            float2x2 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6;
            Unity_MatrixConstruction_Row_float(_MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3, float4 (0, 0, 0, 0), _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6);
            float3 _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2;
            Unity_Multiply_float(_MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, IN.ObjectSpaceNormal, _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2);
            float4 _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2;
            WaveModify_float((float4(IN.ObjectSpacePosition, 1.0)), _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2, _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2);
            description.Position = (_WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2.xyz);
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_da1611847bfd48c48e316dd883405ee0_Out_0 = _AlphaPower;
            float _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_da1611847bfd48c48e316dd883405ee0_Out_0, _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
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
            float3 WorldSpacePosition;
            float3 TimeParameters;
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
            float3 interp2 : TEXCOORD2;
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

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
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
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
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
        float _Metallic;
        float _NoiseScale;
        float _NoiseSubtraction;
        float _BlendSharpness;
        float _EmissionPower;
        CBUFFER_END

        // Object and Global properties
        Gradient _EmissionGradient_Definition()
        {
            Gradient g;
            g.type = 0;
            g.colorsLength = 5;
            g.alphasLength = 2;
            g.colors[0] = float4(0.2189393, 0.8396226, 0.07524917, 0);
            g.colors[1] = float4(0.1135636, 0.8212867, 0.8301887, 0.123537);
            g.colors[2] = float4(0.1135636, 0.1249385, 0.8301887, 0.3705959);
            g.colors[3] = float4(0.8301887, 0.1057316, 0.1057316, 0.7088273);
            g.colors[4] = float4(0.8679245, 0.7082965, 0.1023496, 0.8558785);
            g.colors[5] = float4(0, 0, 0, 0);
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
        float _Count;
        float _Spring;
        float _Damping;
        float _Namida;
        float4 _pAfs[10];
        float4 _dAts[10];

            // Graph Functions
            
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
            Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
            Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
            Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }

        void Unity_Multiply_float(float3x3 A, float3 B, out float3 Out)
        {
            Out = mul(A, B);
        }

        // cb1be5f5a203498458c775f5477a077e
        #include "Assets/Shaders/Bubbles/WaveModify.hlsl"

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }

        void Unity_Power_float3(float3 A, float3 B, out float3 Out)
        {
            Out = pow(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_SampleGradient_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < 8; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c-1].w) / (Gradient.colors[c].w - Gradient.colors[c-1].w)) * step(c, Gradient.colorsLength-1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifndef UNITY_COLORSPACE_GAMMA
            color = SRGBToLinear(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < 8; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a-1].y) / (Gradient.alphas[a].y - Gradient.alphas[a-1].y)) * step(a, Gradient.alphasLength-1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
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
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1 = UNITY_MATRIX_M[0];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2 = UNITY_MATRIX_M[1];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3 = UNITY_MATRIX_M[2];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M3_4 = UNITY_MATRIX_M[3];
            float4x4 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4;
            float3x3 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5;
            float2x2 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6;
            Unity_MatrixConstruction_Row_float(_MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3, float4 (0, 0, 0, 0), _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6);
            float3 _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2;
            Unity_Multiply_float(_MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, IN.ObjectSpaceNormal, _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2);
            float4 _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2;
            WaveModify_float((float4(IN.ObjectSpacePosition, 1.0)), _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2, _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2);
            description.Position = (_WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2.xyz);
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_16c48420616843768bb9647b4ffc177c_Out_0 = _TintColor;
            Gradient _Property_7da875de7ed845c1b347a72b6a8c6769_Out_0 = _EmissionGradient;
            float _FresnelEffect_65387cadbd2544dfa90e64487edf01f0_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, 0.3, _FresnelEffect_65387cadbd2544dfa90e64487edf01f0_Out_3);
            float _Split_066869d3770f45c8a92cec39b399f095_R_1 = IN.WorldSpacePosition[0];
            float _Split_066869d3770f45c8a92cec39b399f095_G_2 = IN.WorldSpacePosition[1];
            float _Split_066869d3770f45c8a92cec39b399f095_B_3 = IN.WorldSpacePosition[2];
            float _Split_066869d3770f45c8a92cec39b399f095_A_4 = 0;
            float2 _Vector2_93509cf0a81442b7bb575be7510c8a05_Out_0 = float2(_Split_066869d3770f45c8a92cec39b399f095_R_1, _Split_066869d3770f45c8a92cec39b399f095_G_2);
            float _Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, 0.1, _Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2);
            float2 _TilingAndOffset_a8bb8eae23ad45629aea2b88f06988cc_Out_3;
            Unity_TilingAndOffset_float(_Vector2_93509cf0a81442b7bb575be7510c8a05_Out_0, float2 (1, 1), (_Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2.xx), _TilingAndOffset_a8bb8eae23ad45629aea2b88f06988cc_Out_3);
            float _Property_5a7a9017492641be9ac25f944c8f6829_Out_0 = _NoiseScale;
            float _GradientNoise_2058c27d35914069a1ca97d0f7d8f680_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a8bb8eae23ad45629aea2b88f06988cc_Out_3, _Property_5a7a9017492641be9ac25f944c8f6829_Out_0, _GradientNoise_2058c27d35914069a1ca97d0f7d8f680_Out_2);
            float _Property_fe54568bada549df9217787389235abb_Out_0 = _NoiseSubtraction;
            float _Subtract_b37900824de84af3a6d2e60faec4969d_Out_2;
            Unity_Subtract_float(_GradientNoise_2058c27d35914069a1ca97d0f7d8f680_Out_2, _Property_fe54568bada549df9217787389235abb_Out_0, _Subtract_b37900824de84af3a6d2e60faec4969d_Out_2);
            float3 _Absolute_797c87bde05541aea4d975ceda1a3aeb_Out_1;
            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_797c87bde05541aea4d975ceda1a3aeb_Out_1);
            float _Property_c3fef34a9d2f43f6ab03d925c48731a2_Out_0 = _BlendSharpness;
            float3 _Power_1c97f31919d6442cb40af69f8ac3336e_Out_2;
            Unity_Power_float3(_Absolute_797c87bde05541aea4d975ceda1a3aeb_Out_1, (_Property_c3fef34a9d2f43f6ab03d925c48731a2_Out_0.xxx), _Power_1c97f31919d6442cb40af69f8ac3336e_Out_2);
            float3 _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1;
            Unity_Normalize_float3(_Power_1c97f31919d6442cb40af69f8ac3336e_Out_2, _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1);
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_R_1 = _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1[0];
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_G_2 = _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1[1];
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_B_3 = _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1[2];
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_A_4 = 0;
            float _Multiply_0dec24b7fa6b47cab3e50b0e2d5ca1e5_Out_2;
            Unity_Multiply_float(_Subtract_b37900824de84af3a6d2e60faec4969d_Out_2, _Split_92dc20aeb54f4b0b928267e1a42187d6_B_3, _Multiply_0dec24b7fa6b47cab3e50b0e2d5ca1e5_Out_2);
            float2 _Vector2_14f8cea02eec4bedbe1542402647b958_Out_0 = float2(_Split_066869d3770f45c8a92cec39b399f095_R_1, _Split_066869d3770f45c8a92cec39b399f095_B_3);
            float2 _TilingAndOffset_5e527e8a66624ddfa80e19ac11b215cd_Out_3;
            Unity_TilingAndOffset_float(_Vector2_14f8cea02eec4bedbe1542402647b958_Out_0, float2 (1, 1), (_Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2.xx), _TilingAndOffset_5e527e8a66624ddfa80e19ac11b215cd_Out_3);
            float _GradientNoise_5ff8b4dfe59d484ea281d534f56dc321_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5e527e8a66624ddfa80e19ac11b215cd_Out_3, _Property_5a7a9017492641be9ac25f944c8f6829_Out_0, _GradientNoise_5ff8b4dfe59d484ea281d534f56dc321_Out_2);
            float _Subtract_b7b4bdd0d6014e6aae580d41569ae1c4_Out_2;
            Unity_Subtract_float(_GradientNoise_5ff8b4dfe59d484ea281d534f56dc321_Out_2, _Property_fe54568bada549df9217787389235abb_Out_0, _Subtract_b7b4bdd0d6014e6aae580d41569ae1c4_Out_2);
            float _Multiply_1bf8f1f8f1084396966ac6bf20e22798_Out_2;
            Unity_Multiply_float(_Subtract_b7b4bdd0d6014e6aae580d41569ae1c4_Out_2, _Split_92dc20aeb54f4b0b928267e1a42187d6_G_2, _Multiply_1bf8f1f8f1084396966ac6bf20e22798_Out_2);
            float _Add_1dd72b043e5d4bcfa59095bfefbca009_Out_2;
            Unity_Add_float(_Multiply_0dec24b7fa6b47cab3e50b0e2d5ca1e5_Out_2, _Multiply_1bf8f1f8f1084396966ac6bf20e22798_Out_2, _Add_1dd72b043e5d4bcfa59095bfefbca009_Out_2);
            float2 _Vector2_fa9631173a1a472897504f00df74776a_Out_0 = float2(_Split_066869d3770f45c8a92cec39b399f095_G_2, _Split_066869d3770f45c8a92cec39b399f095_B_3);
            float2 _TilingAndOffset_51b07fac754d408898803fc3a063e492_Out_3;
            Unity_TilingAndOffset_float(_Vector2_fa9631173a1a472897504f00df74776a_Out_0, float2 (1, 1), (_Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2.xx), _TilingAndOffset_51b07fac754d408898803fc3a063e492_Out_3);
            float _GradientNoise_9e3beec85934435bbb899abae5ca2f75_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_51b07fac754d408898803fc3a063e492_Out_3, _Property_5a7a9017492641be9ac25f944c8f6829_Out_0, _GradientNoise_9e3beec85934435bbb899abae5ca2f75_Out_2);
            float _Subtract_70c45514b16041be9377ba62c53bbf52_Out_2;
            Unity_Subtract_float(_GradientNoise_9e3beec85934435bbb899abae5ca2f75_Out_2, _Property_fe54568bada549df9217787389235abb_Out_0, _Subtract_70c45514b16041be9377ba62c53bbf52_Out_2);
            float _Multiply_e0a012c3af9845c2ac7cd660ba8aa8a2_Out_2;
            Unity_Multiply_float(_Subtract_70c45514b16041be9377ba62c53bbf52_Out_2, _Split_92dc20aeb54f4b0b928267e1a42187d6_R_1, _Multiply_e0a012c3af9845c2ac7cd660ba8aa8a2_Out_2);
            float _Add_112bd27952054267aff87a35030e33e0_Out_2;
            Unity_Add_float(_Add_1dd72b043e5d4bcfa59095bfefbca009_Out_2, _Multiply_e0a012c3af9845c2ac7cd660ba8aa8a2_Out_2, _Add_112bd27952054267aff87a35030e33e0_Out_2);
            float _Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3;
            Unity_Clamp_float(_Add_112bd27952054267aff87a35030e33e0_Out_2, 0, 1, _Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3);
            float _Subtract_2f5244b1136b4ddeaf7ccc9a65ef1bca_Out_2;
            Unity_Subtract_float(_FresnelEffect_65387cadbd2544dfa90e64487edf01f0_Out_3, _Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3, _Subtract_2f5244b1136b4ddeaf7ccc9a65ef1bca_Out_2);
            float4 _SampleGradient_a553dbc03418426d9d4f991cd3009782_Out_2;
            Unity_SampleGradient_float(_Property_7da875de7ed845c1b347a72b6a8c6769_Out_0, _Subtract_2f5244b1136b4ddeaf7ccc9a65ef1bca_Out_2, _SampleGradient_a553dbc03418426d9d4f991cd3009782_Out_2);
            float4 _Multiply_a3f13f0f0f0b403eafaaca9fc77606f1_Out_2;
            Unity_Multiply_float(_SampleGradient_a553dbc03418426d9d4f991cd3009782_Out_2, (_Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3.xxxx), _Multiply_a3f13f0f0f0b403eafaaca9fc77606f1_Out_2);
            float _Property_6a98ee0f69514bd4be062252c829da82_Out_0 = _EmissionPower;
            float4 _Multiply_66fcb2d896db4f6d9034504497ede84a_Out_2;
            Unity_Multiply_float(_Multiply_a3f13f0f0f0b403eafaaca9fc77606f1_Out_2, (_Property_6a98ee0f69514bd4be062252c829da82_Out_0.xxxx), _Multiply_66fcb2d896db4f6d9034504497ede84a_Out_2);
            float _Property_da1611847bfd48c48e316dd883405ee0_Out_0 = _AlphaPower;
            float _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_da1611847bfd48c48e316dd883405ee0_Out_0, _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3);
            surface.BaseColor = (_Property_16c48420616843768bb9647b4ffc177c_Out_0.xyz);
            surface.Emission = (_Multiply_66fcb2d896db4f6d9034504497ede84a_Out_2.xyz);
            surface.Alpha = _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
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
            #define SHADERPASS SHADERPASS_2D
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

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyz =  input.viewDirectionWS;
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
        Varyings UnpackVaryings (PackedVaryings input)
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
        float _Metallic;
        float _NoiseScale;
        float _NoiseSubtraction;
        float _BlendSharpness;
        float _EmissionPower;
        CBUFFER_END

        // Object and Global properties
        Gradient _EmissionGradient_Definition()
        {
            Gradient g;
            g.type = 0;
            g.colorsLength = 5;
            g.alphasLength = 2;
            g.colors[0] = float4(0.2189393, 0.8396226, 0.07524917, 0);
            g.colors[1] = float4(0.1135636, 0.8212867, 0.8301887, 0.123537);
            g.colors[2] = float4(0.1135636, 0.1249385, 0.8301887, 0.3705959);
            g.colors[3] = float4(0.8301887, 0.1057316, 0.1057316, 0.7088273);
            g.colors[4] = float4(0.8679245, 0.7082965, 0.1023496, 0.8558785);
            g.colors[5] = float4(0, 0, 0, 0);
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
        float _Count;
        float _Spring;
        float _Damping;
        float _Namida;
        float4 _pAfs[10];
        float4 _dAts[10];

            // Graph Functions
            
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
            Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
            Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
            Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }

        void Unity_Multiply_float(float3x3 A, float3 B, out float3 Out)
        {
            Out = mul(A, B);
        }

        // cb1be5f5a203498458c775f5477a077e
        #include "Assets/Shaders/Bubbles/WaveModify.hlsl"

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
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
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1 = UNITY_MATRIX_M[0];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2 = UNITY_MATRIX_M[1];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3 = UNITY_MATRIX_M[2];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M3_4 = UNITY_MATRIX_M[3];
            float4x4 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4;
            float3x3 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5;
            float2x2 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6;
            Unity_MatrixConstruction_Row_float(_MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3, float4 (0, 0, 0, 0), _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6);
            float3 _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2;
            Unity_Multiply_float(_MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, IN.ObjectSpaceNormal, _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2);
            float4 _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2;
            WaveModify_float((float4(IN.ObjectSpacePosition, 1.0)), _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2, _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2);
            description.Position = (_WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2.xyz);
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_16c48420616843768bb9647b4ffc177c_Out_0 = _TintColor;
            float _Property_da1611847bfd48c48e316dd883405ee0_Out_0 = _AlphaPower;
            float _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_da1611847bfd48c48e316dd883405ee0_Out_0, _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3);
            surface.BaseColor = (_Property_16c48420616843768bb9647b4ffc177c_Out_0.xyz);
            surface.Alpha = _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
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
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

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
            float3 positionOS : POSITION;
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
            float3 WorldSpacePosition;
            float3 TimeParameters;
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

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
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
        Varyings UnpackVaryings (PackedVaryings input)
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
        float4 _TintColor;
        float _AlphaPower;
        float _Smoothness;
        float _Metallic;
        float _NoiseScale;
        float _NoiseSubtraction;
        float _BlendSharpness;
        float _EmissionPower;
        CBUFFER_END

        // Object and Global properties
        Gradient _EmissionGradient_Definition()
        {
            Gradient g;
            g.type = 0;
            g.colorsLength = 5;
            g.alphasLength = 2;
            g.colors[0] = float4(0.2189393, 0.8396226, 0.07524917, 0);
            g.colors[1] = float4(0.1135636, 0.8212867, 0.8301887, 0.123537);
            g.colors[2] = float4(0.1135636, 0.1249385, 0.8301887, 0.3705959);
            g.colors[3] = float4(0.8301887, 0.1057316, 0.1057316, 0.7088273);
            g.colors[4] = float4(0.8679245, 0.7082965, 0.1023496, 0.8558785);
            g.colors[5] = float4(0, 0, 0, 0);
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
        float _Count;
        float _Spring;
        float _Damping;
        float _Namida;
        float4 _pAfs[10];
        float4 _dAts[10];

            // Graph Functions
            
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
            Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
            Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
            Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }

        void Unity_Multiply_float(float3x3 A, float3 B, out float3 Out)
        {
            Out = mul(A, B);
        }

        // cb1be5f5a203498458c775f5477a077e
        #include "Assets/Shaders/Bubbles/WaveModify.hlsl"

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }

        void Unity_Power_float3(float3 A, float3 B, out float3 Out)
        {
            Out = pow(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_SampleGradient_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < 8; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c-1].w) / (Gradient.colors[c].w - Gradient.colors[c-1].w)) * step(c, Gradient.colorsLength-1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifndef UNITY_COLORSPACE_GAMMA
            color = SRGBToLinear(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < 8; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a-1].y) / (Gradient.alphas[a].y - Gradient.alphas[a-1].y)) * step(a, Gradient.alphasLength-1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
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
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1 = UNITY_MATRIX_M[0];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2 = UNITY_MATRIX_M[1];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3 = UNITY_MATRIX_M[2];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M3_4 = UNITY_MATRIX_M[3];
            float4x4 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4;
            float3x3 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5;
            float2x2 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6;
            Unity_MatrixConstruction_Row_float(_MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3, float4 (0, 0, 0, 0), _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6);
            float3 _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2;
            Unity_Multiply_float(_MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, IN.ObjectSpaceNormal, _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2);
            float4 _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2;
            WaveModify_float((float4(IN.ObjectSpacePosition, 1.0)), _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2, _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2);
            description.Position = (_WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2.xyz);
            description.Normal = IN.ObjectSpaceNormal;
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
            float4 _Property_16c48420616843768bb9647b4ffc177c_Out_0 = _TintColor;
            Gradient _Property_7da875de7ed845c1b347a72b6a8c6769_Out_0 = _EmissionGradient;
            float _FresnelEffect_65387cadbd2544dfa90e64487edf01f0_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, 0.3, _FresnelEffect_65387cadbd2544dfa90e64487edf01f0_Out_3);
            float _Split_066869d3770f45c8a92cec39b399f095_R_1 = IN.WorldSpacePosition[0];
            float _Split_066869d3770f45c8a92cec39b399f095_G_2 = IN.WorldSpacePosition[1];
            float _Split_066869d3770f45c8a92cec39b399f095_B_3 = IN.WorldSpacePosition[2];
            float _Split_066869d3770f45c8a92cec39b399f095_A_4 = 0;
            float2 _Vector2_93509cf0a81442b7bb575be7510c8a05_Out_0 = float2(_Split_066869d3770f45c8a92cec39b399f095_R_1, _Split_066869d3770f45c8a92cec39b399f095_G_2);
            float _Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, 0.1, _Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2);
            float2 _TilingAndOffset_a8bb8eae23ad45629aea2b88f06988cc_Out_3;
            Unity_TilingAndOffset_float(_Vector2_93509cf0a81442b7bb575be7510c8a05_Out_0, float2 (1, 1), (_Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2.xx), _TilingAndOffset_a8bb8eae23ad45629aea2b88f06988cc_Out_3);
            float _Property_5a7a9017492641be9ac25f944c8f6829_Out_0 = _NoiseScale;
            float _GradientNoise_2058c27d35914069a1ca97d0f7d8f680_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a8bb8eae23ad45629aea2b88f06988cc_Out_3, _Property_5a7a9017492641be9ac25f944c8f6829_Out_0, _GradientNoise_2058c27d35914069a1ca97d0f7d8f680_Out_2);
            float _Property_fe54568bada549df9217787389235abb_Out_0 = _NoiseSubtraction;
            float _Subtract_b37900824de84af3a6d2e60faec4969d_Out_2;
            Unity_Subtract_float(_GradientNoise_2058c27d35914069a1ca97d0f7d8f680_Out_2, _Property_fe54568bada549df9217787389235abb_Out_0, _Subtract_b37900824de84af3a6d2e60faec4969d_Out_2);
            float3 _Absolute_797c87bde05541aea4d975ceda1a3aeb_Out_1;
            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_797c87bde05541aea4d975ceda1a3aeb_Out_1);
            float _Property_c3fef34a9d2f43f6ab03d925c48731a2_Out_0 = _BlendSharpness;
            float3 _Power_1c97f31919d6442cb40af69f8ac3336e_Out_2;
            Unity_Power_float3(_Absolute_797c87bde05541aea4d975ceda1a3aeb_Out_1, (_Property_c3fef34a9d2f43f6ab03d925c48731a2_Out_0.xxx), _Power_1c97f31919d6442cb40af69f8ac3336e_Out_2);
            float3 _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1;
            Unity_Normalize_float3(_Power_1c97f31919d6442cb40af69f8ac3336e_Out_2, _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1);
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_R_1 = _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1[0];
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_G_2 = _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1[1];
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_B_3 = _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1[2];
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_A_4 = 0;
            float _Multiply_0dec24b7fa6b47cab3e50b0e2d5ca1e5_Out_2;
            Unity_Multiply_float(_Subtract_b37900824de84af3a6d2e60faec4969d_Out_2, _Split_92dc20aeb54f4b0b928267e1a42187d6_B_3, _Multiply_0dec24b7fa6b47cab3e50b0e2d5ca1e5_Out_2);
            float2 _Vector2_14f8cea02eec4bedbe1542402647b958_Out_0 = float2(_Split_066869d3770f45c8a92cec39b399f095_R_1, _Split_066869d3770f45c8a92cec39b399f095_B_3);
            float2 _TilingAndOffset_5e527e8a66624ddfa80e19ac11b215cd_Out_3;
            Unity_TilingAndOffset_float(_Vector2_14f8cea02eec4bedbe1542402647b958_Out_0, float2 (1, 1), (_Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2.xx), _TilingAndOffset_5e527e8a66624ddfa80e19ac11b215cd_Out_3);
            float _GradientNoise_5ff8b4dfe59d484ea281d534f56dc321_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5e527e8a66624ddfa80e19ac11b215cd_Out_3, _Property_5a7a9017492641be9ac25f944c8f6829_Out_0, _GradientNoise_5ff8b4dfe59d484ea281d534f56dc321_Out_2);
            float _Subtract_b7b4bdd0d6014e6aae580d41569ae1c4_Out_2;
            Unity_Subtract_float(_GradientNoise_5ff8b4dfe59d484ea281d534f56dc321_Out_2, _Property_fe54568bada549df9217787389235abb_Out_0, _Subtract_b7b4bdd0d6014e6aae580d41569ae1c4_Out_2);
            float _Multiply_1bf8f1f8f1084396966ac6bf20e22798_Out_2;
            Unity_Multiply_float(_Subtract_b7b4bdd0d6014e6aae580d41569ae1c4_Out_2, _Split_92dc20aeb54f4b0b928267e1a42187d6_G_2, _Multiply_1bf8f1f8f1084396966ac6bf20e22798_Out_2);
            float _Add_1dd72b043e5d4bcfa59095bfefbca009_Out_2;
            Unity_Add_float(_Multiply_0dec24b7fa6b47cab3e50b0e2d5ca1e5_Out_2, _Multiply_1bf8f1f8f1084396966ac6bf20e22798_Out_2, _Add_1dd72b043e5d4bcfa59095bfefbca009_Out_2);
            float2 _Vector2_fa9631173a1a472897504f00df74776a_Out_0 = float2(_Split_066869d3770f45c8a92cec39b399f095_G_2, _Split_066869d3770f45c8a92cec39b399f095_B_3);
            float2 _TilingAndOffset_51b07fac754d408898803fc3a063e492_Out_3;
            Unity_TilingAndOffset_float(_Vector2_fa9631173a1a472897504f00df74776a_Out_0, float2 (1, 1), (_Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2.xx), _TilingAndOffset_51b07fac754d408898803fc3a063e492_Out_3);
            float _GradientNoise_9e3beec85934435bbb899abae5ca2f75_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_51b07fac754d408898803fc3a063e492_Out_3, _Property_5a7a9017492641be9ac25f944c8f6829_Out_0, _GradientNoise_9e3beec85934435bbb899abae5ca2f75_Out_2);
            float _Subtract_70c45514b16041be9377ba62c53bbf52_Out_2;
            Unity_Subtract_float(_GradientNoise_9e3beec85934435bbb899abae5ca2f75_Out_2, _Property_fe54568bada549df9217787389235abb_Out_0, _Subtract_70c45514b16041be9377ba62c53bbf52_Out_2);
            float _Multiply_e0a012c3af9845c2ac7cd660ba8aa8a2_Out_2;
            Unity_Multiply_float(_Subtract_70c45514b16041be9377ba62c53bbf52_Out_2, _Split_92dc20aeb54f4b0b928267e1a42187d6_R_1, _Multiply_e0a012c3af9845c2ac7cd660ba8aa8a2_Out_2);
            float _Add_112bd27952054267aff87a35030e33e0_Out_2;
            Unity_Add_float(_Add_1dd72b043e5d4bcfa59095bfefbca009_Out_2, _Multiply_e0a012c3af9845c2ac7cd660ba8aa8a2_Out_2, _Add_112bd27952054267aff87a35030e33e0_Out_2);
            float _Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3;
            Unity_Clamp_float(_Add_112bd27952054267aff87a35030e33e0_Out_2, 0, 1, _Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3);
            float _Subtract_2f5244b1136b4ddeaf7ccc9a65ef1bca_Out_2;
            Unity_Subtract_float(_FresnelEffect_65387cadbd2544dfa90e64487edf01f0_Out_3, _Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3, _Subtract_2f5244b1136b4ddeaf7ccc9a65ef1bca_Out_2);
            float4 _SampleGradient_a553dbc03418426d9d4f991cd3009782_Out_2;
            Unity_SampleGradient_float(_Property_7da875de7ed845c1b347a72b6a8c6769_Out_0, _Subtract_2f5244b1136b4ddeaf7ccc9a65ef1bca_Out_2, _SampleGradient_a553dbc03418426d9d4f991cd3009782_Out_2);
            float4 _Multiply_a3f13f0f0f0b403eafaaca9fc77606f1_Out_2;
            Unity_Multiply_float(_SampleGradient_a553dbc03418426d9d4f991cd3009782_Out_2, (_Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3.xxxx), _Multiply_a3f13f0f0f0b403eafaaca9fc77606f1_Out_2);
            float _Property_6a98ee0f69514bd4be062252c829da82_Out_0 = _EmissionPower;
            float4 _Multiply_66fcb2d896db4f6d9034504497ede84a_Out_2;
            Unity_Multiply_float(_Multiply_a3f13f0f0f0b403eafaaca9fc77606f1_Out_2, (_Property_6a98ee0f69514bd4be062252c829da82_Out_0.xxxx), _Multiply_66fcb2d896db4f6d9034504497ede84a_Out_2);
            float _Property_97873980abaa4b1fa9ea0cbfca993d10_Out_0 = _Metallic;
            float _Property_ff7903218df24bbe88610ff82fc0ae0c_Out_0 = _Smoothness;
            float _Property_da1611847bfd48c48e316dd883405ee0_Out_0 = _AlphaPower;
            float _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_da1611847bfd48c48e316dd883405ee0_Out_0, _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3);
            surface.BaseColor = (_Property_16c48420616843768bb9647b4ffc177c_Out_0.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_66fcb2d896db4f6d9034504497ede84a_Out_2.xyz);
            surface.Metallic = _Property_97873980abaa4b1fa9ea0cbfca993d10_Out_0;
            surface.Smoothness = _Property_ff7903218df24bbe88610ff82fc0ae0c_Out_0;
            surface.Occlusion = 1;
            surface.Alpha = _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyz =  input.viewDirectionWS;
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
        Varyings UnpackVaryings (PackedVaryings input)
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
        float _Metallic;
        float _NoiseScale;
        float _NoiseSubtraction;
        float _BlendSharpness;
        float _EmissionPower;
        CBUFFER_END

        // Object and Global properties
        Gradient _EmissionGradient_Definition()
        {
            Gradient g;
            g.type = 0;
            g.colorsLength = 5;
            g.alphasLength = 2;
            g.colors[0] = float4(0.2189393, 0.8396226, 0.07524917, 0);
            g.colors[1] = float4(0.1135636, 0.8212867, 0.8301887, 0.123537);
            g.colors[2] = float4(0.1135636, 0.1249385, 0.8301887, 0.3705959);
            g.colors[3] = float4(0.8301887, 0.1057316, 0.1057316, 0.7088273);
            g.colors[4] = float4(0.8679245, 0.7082965, 0.1023496, 0.8558785);
            g.colors[5] = float4(0, 0, 0, 0);
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
        float _Count;
        float _Spring;
        float _Damping;
        float _Namida;
        float4 _pAfs[10];
        float4 _dAts[10];

            // Graph Functions
            
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
            Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
            Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
            Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }

        void Unity_Multiply_float(float3x3 A, float3 B, out float3 Out)
        {
            Out = mul(A, B);
        }

        // cb1be5f5a203498458c775f5477a077e
        #include "Assets/Shaders/Bubbles/WaveModify.hlsl"

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
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
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1 = UNITY_MATRIX_M[0];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2 = UNITY_MATRIX_M[1];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3 = UNITY_MATRIX_M[2];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M3_4 = UNITY_MATRIX_M[3];
            float4x4 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4;
            float3x3 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5;
            float2x2 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6;
            Unity_MatrixConstruction_Row_float(_MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3, float4 (0, 0, 0, 0), _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6);
            float3 _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2;
            Unity_Multiply_float(_MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, IN.ObjectSpaceNormal, _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2);
            float4 _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2;
            WaveModify_float((float4(IN.ObjectSpacePosition, 1.0)), _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2, _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2);
            description.Position = (_WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2.xyz);
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
            float _Property_da1611847bfd48c48e316dd883405ee0_Out_0 = _AlphaPower;
            float _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_da1611847bfd48c48e316dd883405ee0_Out_0, _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3);
            surface.Alpha = _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
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
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
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
            #define SHADERPASS SHADERPASS_DEPTHONLY
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

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyz =  input.viewDirectionWS;
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
        Varyings UnpackVaryings (PackedVaryings input)
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
        float _Metallic;
        float _NoiseScale;
        float _NoiseSubtraction;
        float _BlendSharpness;
        float _EmissionPower;
        CBUFFER_END

        // Object and Global properties
        Gradient _EmissionGradient_Definition()
        {
            Gradient g;
            g.type = 0;
            g.colorsLength = 5;
            g.alphasLength = 2;
            g.colors[0] = float4(0.2189393, 0.8396226, 0.07524917, 0);
            g.colors[1] = float4(0.1135636, 0.8212867, 0.8301887, 0.123537);
            g.colors[2] = float4(0.1135636, 0.1249385, 0.8301887, 0.3705959);
            g.colors[3] = float4(0.8301887, 0.1057316, 0.1057316, 0.7088273);
            g.colors[4] = float4(0.8679245, 0.7082965, 0.1023496, 0.8558785);
            g.colors[5] = float4(0, 0, 0, 0);
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
        float _Count;
        float _Spring;
        float _Damping;
        float _Namida;
        float4 _pAfs[10];
        float4 _dAts[10];

            // Graph Functions
            
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
            Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
            Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
            Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }

        void Unity_Multiply_float(float3x3 A, float3 B, out float3 Out)
        {
            Out = mul(A, B);
        }

        // cb1be5f5a203498458c775f5477a077e
        #include "Assets/Shaders/Bubbles/WaveModify.hlsl"

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
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
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1 = UNITY_MATRIX_M[0];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2 = UNITY_MATRIX_M[1];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3 = UNITY_MATRIX_M[2];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M3_4 = UNITY_MATRIX_M[3];
            float4x4 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4;
            float3x3 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5;
            float2x2 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6;
            Unity_MatrixConstruction_Row_float(_MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3, float4 (0, 0, 0, 0), _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6);
            float3 _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2;
            Unity_Multiply_float(_MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, IN.ObjectSpaceNormal, _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2);
            float4 _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2;
            WaveModify_float((float4(IN.ObjectSpacePosition, 1.0)), _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2, _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2);
            description.Position = (_WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2.xyz);
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
            float _Property_da1611847bfd48c48e316dd883405ee0_Out_0 = _AlphaPower;
            float _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_da1611847bfd48c48e316dd883405ee0_Out_0, _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3);
            surface.Alpha = _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

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
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
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
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 normalWS;
            float4 tangentWS;
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
            float3 TangentSpaceNormal;
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
            float4 interp1 : TEXCOORD1;
            float3 interp2 : TEXCOORD2;
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

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyz =  input.viewDirectionWS;
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
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.viewDirectionWS = input.interp2.xyz;
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
        float _Metallic;
        float _NoiseScale;
        float _NoiseSubtraction;
        float _BlendSharpness;
        float _EmissionPower;
        CBUFFER_END

        // Object and Global properties
        Gradient _EmissionGradient_Definition()
        {
            Gradient g;
            g.type = 0;
            g.colorsLength = 5;
            g.alphasLength = 2;
            g.colors[0] = float4(0.2189393, 0.8396226, 0.07524917, 0);
            g.colors[1] = float4(0.1135636, 0.8212867, 0.8301887, 0.123537);
            g.colors[2] = float4(0.1135636, 0.1249385, 0.8301887, 0.3705959);
            g.colors[3] = float4(0.8301887, 0.1057316, 0.1057316, 0.7088273);
            g.colors[4] = float4(0.8679245, 0.7082965, 0.1023496, 0.8558785);
            g.colors[5] = float4(0, 0, 0, 0);
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
        float _Count;
        float _Spring;
        float _Damping;
        float _Namida;
        float4 _pAfs[10];
        float4 _dAts[10];

            // Graph Functions
            
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
            Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
            Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
            Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }

        void Unity_Multiply_float(float3x3 A, float3 B, out float3 Out)
        {
            Out = mul(A, B);
        }

        // cb1be5f5a203498458c775f5477a077e
        #include "Assets/Shaders/Bubbles/WaveModify.hlsl"

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
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
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1 = UNITY_MATRIX_M[0];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2 = UNITY_MATRIX_M[1];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3 = UNITY_MATRIX_M[2];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M3_4 = UNITY_MATRIX_M[3];
            float4x4 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4;
            float3x3 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5;
            float2x2 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6;
            Unity_MatrixConstruction_Row_float(_MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3, float4 (0, 0, 0, 0), _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6);
            float3 _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2;
            Unity_Multiply_float(_MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, IN.ObjectSpaceNormal, _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2);
            float4 _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2;
            WaveModify_float((float4(IN.ObjectSpacePosition, 1.0)), _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2, _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2);
            description.Position = (_WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2.xyz);
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_da1611847bfd48c48e316dd883405ee0_Out_0 = _AlphaPower;
            float _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_da1611847bfd48c48e316dd883405ee0_Out_0, _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
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
            float3 WorldSpacePosition;
            float3 TimeParameters;
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
            float3 interp2 : TEXCOORD2;
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

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
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
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
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
        float _Metallic;
        float _NoiseScale;
        float _NoiseSubtraction;
        float _BlendSharpness;
        float _EmissionPower;
        CBUFFER_END

        // Object and Global properties
        Gradient _EmissionGradient_Definition()
        {
            Gradient g;
            g.type = 0;
            g.colorsLength = 5;
            g.alphasLength = 2;
            g.colors[0] = float4(0.2189393, 0.8396226, 0.07524917, 0);
            g.colors[1] = float4(0.1135636, 0.8212867, 0.8301887, 0.123537);
            g.colors[2] = float4(0.1135636, 0.1249385, 0.8301887, 0.3705959);
            g.colors[3] = float4(0.8301887, 0.1057316, 0.1057316, 0.7088273);
            g.colors[4] = float4(0.8679245, 0.7082965, 0.1023496, 0.8558785);
            g.colors[5] = float4(0, 0, 0, 0);
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
        float _Count;
        float _Spring;
        float _Damping;
        float _Namida;
        float4 _pAfs[10];
        float4 _dAts[10];

            // Graph Functions
            
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
            Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
            Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
            Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }

        void Unity_Multiply_float(float3x3 A, float3 B, out float3 Out)
        {
            Out = mul(A, B);
        }

        // cb1be5f5a203498458c775f5477a077e
        #include "Assets/Shaders/Bubbles/WaveModify.hlsl"

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }

        void Unity_Power_float3(float3 A, float3 B, out float3 Out)
        {
            Out = pow(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_SampleGradient_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < 8; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c-1].w) / (Gradient.colors[c].w - Gradient.colors[c-1].w)) * step(c, Gradient.colorsLength-1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifndef UNITY_COLORSPACE_GAMMA
            color = SRGBToLinear(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < 8; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a-1].y) / (Gradient.alphas[a].y - Gradient.alphas[a-1].y)) * step(a, Gradient.alphasLength-1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
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
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1 = UNITY_MATRIX_M[0];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2 = UNITY_MATRIX_M[1];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3 = UNITY_MATRIX_M[2];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M3_4 = UNITY_MATRIX_M[3];
            float4x4 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4;
            float3x3 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5;
            float2x2 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6;
            Unity_MatrixConstruction_Row_float(_MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3, float4 (0, 0, 0, 0), _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6);
            float3 _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2;
            Unity_Multiply_float(_MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, IN.ObjectSpaceNormal, _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2);
            float4 _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2;
            WaveModify_float((float4(IN.ObjectSpacePosition, 1.0)), _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2, _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2);
            description.Position = (_WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2.xyz);
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_16c48420616843768bb9647b4ffc177c_Out_0 = _TintColor;
            Gradient _Property_7da875de7ed845c1b347a72b6a8c6769_Out_0 = _EmissionGradient;
            float _FresnelEffect_65387cadbd2544dfa90e64487edf01f0_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, 0.3, _FresnelEffect_65387cadbd2544dfa90e64487edf01f0_Out_3);
            float _Split_066869d3770f45c8a92cec39b399f095_R_1 = IN.WorldSpacePosition[0];
            float _Split_066869d3770f45c8a92cec39b399f095_G_2 = IN.WorldSpacePosition[1];
            float _Split_066869d3770f45c8a92cec39b399f095_B_3 = IN.WorldSpacePosition[2];
            float _Split_066869d3770f45c8a92cec39b399f095_A_4 = 0;
            float2 _Vector2_93509cf0a81442b7bb575be7510c8a05_Out_0 = float2(_Split_066869d3770f45c8a92cec39b399f095_R_1, _Split_066869d3770f45c8a92cec39b399f095_G_2);
            float _Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, 0.1, _Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2);
            float2 _TilingAndOffset_a8bb8eae23ad45629aea2b88f06988cc_Out_3;
            Unity_TilingAndOffset_float(_Vector2_93509cf0a81442b7bb575be7510c8a05_Out_0, float2 (1, 1), (_Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2.xx), _TilingAndOffset_a8bb8eae23ad45629aea2b88f06988cc_Out_3);
            float _Property_5a7a9017492641be9ac25f944c8f6829_Out_0 = _NoiseScale;
            float _GradientNoise_2058c27d35914069a1ca97d0f7d8f680_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_a8bb8eae23ad45629aea2b88f06988cc_Out_3, _Property_5a7a9017492641be9ac25f944c8f6829_Out_0, _GradientNoise_2058c27d35914069a1ca97d0f7d8f680_Out_2);
            float _Property_fe54568bada549df9217787389235abb_Out_0 = _NoiseSubtraction;
            float _Subtract_b37900824de84af3a6d2e60faec4969d_Out_2;
            Unity_Subtract_float(_GradientNoise_2058c27d35914069a1ca97d0f7d8f680_Out_2, _Property_fe54568bada549df9217787389235abb_Out_0, _Subtract_b37900824de84af3a6d2e60faec4969d_Out_2);
            float3 _Absolute_797c87bde05541aea4d975ceda1a3aeb_Out_1;
            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_797c87bde05541aea4d975ceda1a3aeb_Out_1);
            float _Property_c3fef34a9d2f43f6ab03d925c48731a2_Out_0 = _BlendSharpness;
            float3 _Power_1c97f31919d6442cb40af69f8ac3336e_Out_2;
            Unity_Power_float3(_Absolute_797c87bde05541aea4d975ceda1a3aeb_Out_1, (_Property_c3fef34a9d2f43f6ab03d925c48731a2_Out_0.xxx), _Power_1c97f31919d6442cb40af69f8ac3336e_Out_2);
            float3 _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1;
            Unity_Normalize_float3(_Power_1c97f31919d6442cb40af69f8ac3336e_Out_2, _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1);
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_R_1 = _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1[0];
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_G_2 = _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1[1];
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_B_3 = _Normalize_2c90681d13054a51abaec2bd64c04730_Out_1[2];
            float _Split_92dc20aeb54f4b0b928267e1a42187d6_A_4 = 0;
            float _Multiply_0dec24b7fa6b47cab3e50b0e2d5ca1e5_Out_2;
            Unity_Multiply_float(_Subtract_b37900824de84af3a6d2e60faec4969d_Out_2, _Split_92dc20aeb54f4b0b928267e1a42187d6_B_3, _Multiply_0dec24b7fa6b47cab3e50b0e2d5ca1e5_Out_2);
            float2 _Vector2_14f8cea02eec4bedbe1542402647b958_Out_0 = float2(_Split_066869d3770f45c8a92cec39b399f095_R_1, _Split_066869d3770f45c8a92cec39b399f095_B_3);
            float2 _TilingAndOffset_5e527e8a66624ddfa80e19ac11b215cd_Out_3;
            Unity_TilingAndOffset_float(_Vector2_14f8cea02eec4bedbe1542402647b958_Out_0, float2 (1, 1), (_Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2.xx), _TilingAndOffset_5e527e8a66624ddfa80e19ac11b215cd_Out_3);
            float _GradientNoise_5ff8b4dfe59d484ea281d534f56dc321_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5e527e8a66624ddfa80e19ac11b215cd_Out_3, _Property_5a7a9017492641be9ac25f944c8f6829_Out_0, _GradientNoise_5ff8b4dfe59d484ea281d534f56dc321_Out_2);
            float _Subtract_b7b4bdd0d6014e6aae580d41569ae1c4_Out_2;
            Unity_Subtract_float(_GradientNoise_5ff8b4dfe59d484ea281d534f56dc321_Out_2, _Property_fe54568bada549df9217787389235abb_Out_0, _Subtract_b7b4bdd0d6014e6aae580d41569ae1c4_Out_2);
            float _Multiply_1bf8f1f8f1084396966ac6bf20e22798_Out_2;
            Unity_Multiply_float(_Subtract_b7b4bdd0d6014e6aae580d41569ae1c4_Out_2, _Split_92dc20aeb54f4b0b928267e1a42187d6_G_2, _Multiply_1bf8f1f8f1084396966ac6bf20e22798_Out_2);
            float _Add_1dd72b043e5d4bcfa59095bfefbca009_Out_2;
            Unity_Add_float(_Multiply_0dec24b7fa6b47cab3e50b0e2d5ca1e5_Out_2, _Multiply_1bf8f1f8f1084396966ac6bf20e22798_Out_2, _Add_1dd72b043e5d4bcfa59095bfefbca009_Out_2);
            float2 _Vector2_fa9631173a1a472897504f00df74776a_Out_0 = float2(_Split_066869d3770f45c8a92cec39b399f095_G_2, _Split_066869d3770f45c8a92cec39b399f095_B_3);
            float2 _TilingAndOffset_51b07fac754d408898803fc3a063e492_Out_3;
            Unity_TilingAndOffset_float(_Vector2_fa9631173a1a472897504f00df74776a_Out_0, float2 (1, 1), (_Multiply_c36fef2e847b4cc885ef94c6456d84e4_Out_2.xx), _TilingAndOffset_51b07fac754d408898803fc3a063e492_Out_3);
            float _GradientNoise_9e3beec85934435bbb899abae5ca2f75_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_51b07fac754d408898803fc3a063e492_Out_3, _Property_5a7a9017492641be9ac25f944c8f6829_Out_0, _GradientNoise_9e3beec85934435bbb899abae5ca2f75_Out_2);
            float _Subtract_70c45514b16041be9377ba62c53bbf52_Out_2;
            Unity_Subtract_float(_GradientNoise_9e3beec85934435bbb899abae5ca2f75_Out_2, _Property_fe54568bada549df9217787389235abb_Out_0, _Subtract_70c45514b16041be9377ba62c53bbf52_Out_2);
            float _Multiply_e0a012c3af9845c2ac7cd660ba8aa8a2_Out_2;
            Unity_Multiply_float(_Subtract_70c45514b16041be9377ba62c53bbf52_Out_2, _Split_92dc20aeb54f4b0b928267e1a42187d6_R_1, _Multiply_e0a012c3af9845c2ac7cd660ba8aa8a2_Out_2);
            float _Add_112bd27952054267aff87a35030e33e0_Out_2;
            Unity_Add_float(_Add_1dd72b043e5d4bcfa59095bfefbca009_Out_2, _Multiply_e0a012c3af9845c2ac7cd660ba8aa8a2_Out_2, _Add_112bd27952054267aff87a35030e33e0_Out_2);
            float _Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3;
            Unity_Clamp_float(_Add_112bd27952054267aff87a35030e33e0_Out_2, 0, 1, _Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3);
            float _Subtract_2f5244b1136b4ddeaf7ccc9a65ef1bca_Out_2;
            Unity_Subtract_float(_FresnelEffect_65387cadbd2544dfa90e64487edf01f0_Out_3, _Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3, _Subtract_2f5244b1136b4ddeaf7ccc9a65ef1bca_Out_2);
            float4 _SampleGradient_a553dbc03418426d9d4f991cd3009782_Out_2;
            Unity_SampleGradient_float(_Property_7da875de7ed845c1b347a72b6a8c6769_Out_0, _Subtract_2f5244b1136b4ddeaf7ccc9a65ef1bca_Out_2, _SampleGradient_a553dbc03418426d9d4f991cd3009782_Out_2);
            float4 _Multiply_a3f13f0f0f0b403eafaaca9fc77606f1_Out_2;
            Unity_Multiply_float(_SampleGradient_a553dbc03418426d9d4f991cd3009782_Out_2, (_Clamp_7d789359a4a24a7698a71c65c786ba0f_Out_3.xxxx), _Multiply_a3f13f0f0f0b403eafaaca9fc77606f1_Out_2);
            float _Property_6a98ee0f69514bd4be062252c829da82_Out_0 = _EmissionPower;
            float4 _Multiply_66fcb2d896db4f6d9034504497ede84a_Out_2;
            Unity_Multiply_float(_Multiply_a3f13f0f0f0b403eafaaca9fc77606f1_Out_2, (_Property_6a98ee0f69514bd4be062252c829da82_Out_0.xxxx), _Multiply_66fcb2d896db4f6d9034504497ede84a_Out_2);
            float _Property_da1611847bfd48c48e316dd883405ee0_Out_0 = _AlphaPower;
            float _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_da1611847bfd48c48e316dd883405ee0_Out_0, _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3);
            surface.BaseColor = (_Property_16c48420616843768bb9647b4ffc177c_Out_0.xyz);
            surface.Emission = (_Multiply_66fcb2d896db4f6d9034504497ede84a_Out_2.xyz);
            surface.Alpha = _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

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
            #define SHADERPASS SHADERPASS_2D
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

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyz =  input.viewDirectionWS;
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
        Varyings UnpackVaryings (PackedVaryings input)
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
        float _Metallic;
        float _NoiseScale;
        float _NoiseSubtraction;
        float _BlendSharpness;
        float _EmissionPower;
        CBUFFER_END

        // Object and Global properties
        Gradient _EmissionGradient_Definition()
        {
            Gradient g;
            g.type = 0;
            g.colorsLength = 5;
            g.alphasLength = 2;
            g.colors[0] = float4(0.2189393, 0.8396226, 0.07524917, 0);
            g.colors[1] = float4(0.1135636, 0.8212867, 0.8301887, 0.123537);
            g.colors[2] = float4(0.1135636, 0.1249385, 0.8301887, 0.3705959);
            g.colors[3] = float4(0.8301887, 0.1057316, 0.1057316, 0.7088273);
            g.colors[4] = float4(0.8679245, 0.7082965, 0.1023496, 0.8558785);
            g.colors[5] = float4(0, 0, 0, 0);
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
        float _Count;
        float _Spring;
        float _Damping;
        float _Namida;
        float4 _pAfs[10];
        float4 _dAts[10];

            // Graph Functions
            
        void Unity_MatrixConstruction_Row_float (float4 M0, float4 M1, float4 M2, float4 M3, out float4x4 Out4x4, out float3x3 Out3x3, out float2x2 Out2x2)
        {
            Out4x4 = float4x4(M0.x, M0.y, M0.z, M0.w, M1.x, M1.y, M1.z, M1.w, M2.x, M2.y, M2.z, M2.w, M3.x, M3.y, M3.z, M3.w);
            Out3x3 = float3x3(M0.x, M0.y, M0.z, M1.x, M1.y, M1.z, M2.x, M2.y, M2.z);
            Out2x2 = float2x2(M0.x, M0.y, M1.x, M1.y);
        }

        void Unity_Multiply_float(float3x3 A, float3 B, out float3 Out)
        {
            Out = mul(A, B);
        }

        // cb1be5f5a203498458c775f5477a077e
        #include "Assets/Shaders/Bubbles/WaveModify.hlsl"

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
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
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1 = UNITY_MATRIX_M[0];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2 = UNITY_MATRIX_M[1];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3 = UNITY_MATRIX_M[2];
            float4 _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M3_4 = UNITY_MATRIX_M[3];
            float4x4 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4;
            float3x3 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5;
            float2x2 _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6;
            Unity_MatrixConstruction_Row_float(_MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M0_1, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M1_2, _MatrixSplit_89a8ca6bd681499f908c6b36e4034397_M2_3, float4 (0, 0, 0, 0), _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var4x4_4, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, _MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var2x2_6);
            float3 _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2;
            Unity_Multiply_float(_MatrixConstruction_477ec3c7650b4ca3bff056b38fe2e989_var3x3_5, IN.ObjectSpaceNormal, _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2);
            float4 _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2;
            WaveModify_float((float4(IN.ObjectSpacePosition, 1.0)), _Multiply_392ffad6215e430eb63ad6b02ac23c2a_Out_2, _WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2);
            description.Position = (_WaveModifyCustomFunction_816190c716604ee6915fee6e56ff7ded_Out_2.xyz);
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_16c48420616843768bb9647b4ffc177c_Out_0 = _TintColor;
            float _Property_da1611847bfd48c48e316dd883405ee0_Out_0 = _AlphaPower;
            float _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_da1611847bfd48c48e316dd883405ee0_Out_0, _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3);
            surface.BaseColor = (_Property_16c48420616843768bb9647b4ffc177c_Out_0.xyz);
            surface.Alpha = _FresnelEffect_d191eda00acf491593182a80647bcd90_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "ShaderGraph.PBRMasterGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}