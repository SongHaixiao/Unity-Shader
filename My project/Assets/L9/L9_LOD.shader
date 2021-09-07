Shader "Custom/L9_LOD"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 600     // LOD = 600

        CGPROGRAM
        #pragma surface surf Lambert
        fixed4 _Color;
        struct Input{
            float4 uv_Tex;  
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = float3(1,0,0); // red color
            o.Alpha = _Color.w;
        }
        ENDCG
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 400     // LOD = 400

        CGPROGRAM
        #pragma surface surf Lambert
        fixed4 _Color;
        struct Input{
            float4 uv_Tex;  
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = float3(0,1,0); // green color
            o.Alpha = _Color.w;
        }
        ENDCG
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200     // LOD = 200
 
        CGPROGRAM
        #pragma surface surf Lambert
        fixed4 _Color;
        struct Input{
            float4 uv_Tex;  
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = float3(0,0,1); // blue color
            o.Alpha = _Color.w;
        }
        ENDCG
    }

    FallBack "Diffuse"
}
