Shader "Unlit/L11_2 Instance Unlit"
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
            #pragma multi_compile_fog
            #pragma multi_compile_instancing // 1. 启用 instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID // 2. 调用 UNITY_VERTEX_INPUT_INSTANCE_ID 宏
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID // 2. 调用 UNITY_VERTEX_INPUT_INSTANCE_ID 宏
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            // 3. 将属性定义到 UNITY_INSTANCING_BUFFER_START/END 这两个宏当中
            UNITY_INSTANCING_BUFFER_START(Props) 
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color) // 4. 定义颜色属性
            UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert (appdata v)
            {
                v2f o;
                // 5. 使用 GPU instance 的时候，每个 Mesh 有可能是一样的，但 ID 是不一样的，所以需要访问，INSTANCE 的 ID
                UNITY_SETUP_INSTANCE_ID(v); 
                UNITY_TRANSFER_INSTANCE_ID(v,o); // 6 . 将 instance ID 转化后 传给 fragment shader
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i)

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return UNITY_ACCESS_INSTANCED_PROP(Props, _Color); // 7. 访问 属性中的每个因素的 _Color
            }
            ENDCG
        }
    }
}
