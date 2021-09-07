Shader "Custom/L10_CelShading1"
{
    Properties
    {
        
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _RampTex("Ramp", 2D) = "white"{}
        _Color ("Color", Color) = (1,1,1,1)
        
    }

    SubShader
    {
        // Regular Color & Lighting Pass & 接收阴影
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase" // 1. allows shadow rec/cast , 告诉 Unity 使用 主光源 来投射阴影
                                            // 若使用多重光源，需要在另一个 Pass 中 将 LightMode 设置为 ForwardAt 
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase   // 2. shadows 的编译开关, 若使用多重光源，也需要将 fwdbas 改为 atbase
            #include "AutoLight.cginc"      // shadows 宏函数文件
            #include "UnityCG.cginc"        // shadows

            // Properties
            sampler2D _MainTex;
            sampler2D _RampTex;
            float4 _Color;
            float4 _LightColor0;    // provided by Unity

            struct vertexInput 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 texCoord : TEXCOORD0;
            };

            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float3 texCoord : TEXCOORD0;
                LIGHTING_COORDS(1,2)   // 3. 添加定义在 AutoLight 中的 LIGHTING_COORDS () 宏 

                /***************************************************
                *   3. LIGHTING_COORDS() 宏 
                *   
                *   LIGHTING_COORDS(1,2);
                *       上面参数 TEXCOORD0，因为被用掉的是 0, 所以传入 1,2;
                *       但如果 0、1、2 都被占用掉了， 则传入 3,4.
                *
                *   LIGHTING_COORDS(1st.参数, 2nd.参数)
                *   参数说明：
                *       1st. 参数：将 TEXCOORD1st.参数 作为光照贴图
                *       2nd. 参数：将 TEXCOORD2nd.参数 作为阴影贴图
                ****************************************************/
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
                TRANSFER_VERTEX_TO_FRAGMENT(output); // 4. shaows
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

                // 5. shadow value, 得到阴影的衰减因子
                float attenuation = LIGHT_ATTENUATION(input); 

                // _LightColor0 provided by Unity
                float3 rgb = albedo.rgb * _LightColor0.rgb * lighting * _Color.rgb * attenuation; // 5. 将阴影的衰减因子 attenuation 加入 最终颜色 rgb 的运算
                return float4(rgb,1.0);
 
                // rgb : 最终颜色
                // albedo.rgb : 漫反射颜色
                // _LightColor0.rgb ： 灯光颜色
                // lighting : 灯光的强度
                // lightDir : 灯光的方向
                // _Color.rgb : 物体本身的颜色
                // attenuation :  阴影的衰减因子
            } 

            ENDCG
        }

        // Cast Shadow Pass 投射阴影
        // Pass
        // {
        //     Tags
        //     {
        //         "LightMode" = "ShadowCaster"
        //     }

        //     CGPROGRAM
        //     #pragma vertex vert
        //     #pragma fragment frag
        //     #pragma multi_compile_shadowcaster
        //     #include "UnityCG.cginc"

        //     struct v2f
        //     {
        //         V2F_SHADOW_CASTER;
        //     }; 

        //     v2f vert(appdata_base v)
        //     {
        //         v2f o;
        //         TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
        //         return o;
        //     }

        //     float4 frag(v2f i):SV_Target
        //     {
        //         SHADOW_CASTER_FRAGMENT(1)
        //     }
        //     ENDCG
        // }

        // Shadow Casting Support 投射阴影
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
