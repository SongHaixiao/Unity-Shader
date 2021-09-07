Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog   // 1. fog 开关 ：启用并编译有关雾的变量

            #include "UnityCG.cginc"    // 2. Unity CG.cginc 宏文件：定义 Fog 宏 1、2、3 的具体作用

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f  // 顶点着色器
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)     // 3. Fog 宏 : Declares the fog data interpolater.
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex); // 4. Fog宏 : Ouputs fog factor data from the vertes shader
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);   // 5. Fog 宏 : Applies fog to color "col". Automatically applies black fog when in forward-additive pass.
                return col;
            }
            ENDCG
        }
    }
}
