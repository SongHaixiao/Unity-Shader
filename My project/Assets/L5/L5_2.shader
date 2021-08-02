Shader "Unlit/L5_2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff("Alpha Cutoff", Range(0,1)) = 0.5 // 1 添加 Alpha Cutoff 属性
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull OFF      // 2 Render both front and back facing polygons.
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Cutoff;      // 3 添加 Cutoff 变量

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                // 手动实现 Cull OFF 效果
                
                // Way 1 : clip method Alpha Test 
                //   1. clo.a - _Cutoff < 0 没有通过测试，丢弃，不进行后续混合
                //   2. clo.a - _Cutoff > 0 通过测试，进行混合
                clip(col.a - _Cutoff);  // 4 
                
                // Way 2 : Alpha Test 详见官方文档 
                // AlphaTest Greater[_Cutoff]; // 4

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
