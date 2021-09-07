Shader "Custom/L10_CelShading"
{
    Properties
    {
        
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _RampTex("Ramp", 2D) = "white"{}
        _Color ("Color", Color) = (1,1,1,1)
        _SpecularColor("Specular Color",Color) = (0.9,0.9,0.9,1) // 3. Specular Reflection
        _Glossiness("Glossiness",Float) = 32    // 4. Specular Reflection
    }
    SubShader
    {
        // Regular Color & Lighting Pass
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // Properties
            sampler2D _MainTex;
            sampler2D _RampTex;
            float4 _Color;
            float4 _LightColor0;    // provided by Unity
            float _Glossiness;      // 5. Specular Reflection
            float4 _SpecularColor;  // 6. Specular Reflection

            struct vertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 texCoord : TEXCOORD0;
                // float3 viewDir : TEXCOORD1; // 1. Specular Reflection
            };

            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float3 texCoord : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
            };

            // Vertex Shader
            vertexOutput vert(vertexInput input)
            {
                vertexOutput output;

                // convert input to world space
                output.pos = UnityObjectToClipPos(input.vertex);
                float4 normal4 = float4(input.normal, 0.0); // need float4 to mult with matrix
                output.normal = normalize(mul(normal4, unity_WorldToObject).xyz); 

                output.texCoord = input.texCoord;

                output.viewDir = WorldSpaceViewDir(input.vertex);    // 2. Specular Reflection                

                return output;
            }

            // Fragment Shader 进行光照运算
            float4 frag(vertexOutput input) : COLOR
            {
                // convert light direction to world space & normalize
                // _WorldSpaceLightPos0 provided by Unity
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // finds location on ramp texture that we should sample
                // based on angle between surface normal and light direction
                float ramp = clamp(dot(input.normal, lightDir),0.001,1.0);
                // float ramp = dot(input.normal, lightDir) * 0.5 + 0.5;
                float3 lighting = tex2D(_RampTex, float2(ramp, 0.5)).rgb;

                // sample texture for color
                float4 albedo = tex2D(_MainTex,input.texCoord.xy);

                // 6. Specular Reflection above the line sampling
                float3 viewDir = normalize(input.viewDir);

                float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);

                float NdotH = dot(input.normal,halfVector);

                float specularIntensity = pow(NdotH * lighting, _Glossiness * _Glossiness);

                // _LightColor0 provided by Unity
                float3 rgb = albedo.rgb * _LightColor0.rgb * lighting * _Color.rgb * specularIntensity;
                return float4(rgb,1.0);

                // rgb : 最终颜色
                // albedo.rgb : 漫反射颜色
                // _LightColor0.rgb ： 灯光颜色
                // lighting : 灯光的强度
                // lightDir : 灯光的方向
                // _Color.rgb : 物体本身的颜色
            } 

            ENDCG
        }
    }
}
