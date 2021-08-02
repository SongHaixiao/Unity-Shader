Shader "Unlit/L4"
{
    Properties      // 定义在显示面板上可以添加的属性
    {
        _MainTex1 ("Texture1", 2D) = "white" {}
        _MainTex2 ("Texture2 ", 2D) = "black" {}
        _Color ("Color", Color) = (0,0,1,1) // Blue
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass    // 进行处理部分
        {
            CGPROGRAM
            #pragma vertex vert    // 定义名为 vert 的 vertex 函数 ： 做 vertex shader 处理， 即，顶点处理
            #pragma fragment frag  // 定义名为 frag 的 fragment 函数 ：做 fragment shader 处理，即，片段处理
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            // appdata : 从应用程序录入给 vertex shader 哪些数据 
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv  : TEXCOORD0;     // 第一套纹理坐标 for Texture1
                float2 uv1 : TEXCOORD1;     // 第二套纹理坐标 for Texture2
            };

            // v2f : vertex shader to fragment shader,从顶点着色器到片段着色器
            // 即，vertex shader 的输出 是 fragment shader 的 输入
            struct v2f
            {
                float2 uv  : TEXCOORD0;     // 第一套纹理坐标 for Texture1
                float2 uv1 : TEXCOORD1;     // 第二套纹理坐标 for Texture2
                float4 vertex : SV_POSITION;
            };

            // sampler2D _MainTex: 2D 采样器，从 2D 纹理图片上去采样的工具
            sampler2D _MainTex1; // for Texture1
            sampler2D _MainTex2; // for Texture2

            // float4 _MainTex_ST : 采样器所需用到的变量, 与 采样器 对应
            float4 _MainTex1_ST; // 采样器变量1 for _MainTex1 采样器 for Texture1
            float4 _MainTex2_ST; // 采样器变量2 for _MainTex2 采样器 for Texture2

            // 声明 Color 变量, 保持变量名字与属性名称一致
            fixed4 _Color;


            // 顶点处理
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                /********************************************************************** 
                 * Sampler Texture ：对 Texture 进行采样操作, 下面两个 方式相同            *
                 * Way 1 : o.uv = TRANSFORM_TEX(v.uv, _MainTex);                      *
                 * Way 2 : o.uv = v.texcoord.xy * _MainTex1_ST.xy + _MainTex1_ST.zw;  *
                 * ********************************************************************/

                // Sampler Texture
                o.uv = TRANSFORM_TEX(v.uv, _MainTex1);      // Sampler for _MainTex1
                o.uv1 = TRANSFORM_TEX(v.uv, _MainTex2);     // Sampler for _MainTex2

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            // 片段处理，决定每个片段的颜色
            // 输出： 见 fragment shader Input & Output
            //      1. SV_Target - 每个目标片源目标像素的颜色
            //      2. SV_Depth - 每个目标片源的深度

            // 此例子中，只输出 颜色信息
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col1 = tex2D(_MainTex1,i.uv); 
                fixed4 col2 = tex2D(_MainTex2, i.uv1);

                fixed4 col = col1 * col2;
                return col;
            }
            ENDCG
        }
    }
}
