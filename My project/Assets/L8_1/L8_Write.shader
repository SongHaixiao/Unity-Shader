Shader "Custom/L8_Write"
{
    
    SubShader
    {
        Tags { 
            "RenderType"="Opaque" 
        }
        ColorMask RGB
        //ZTest Always  // Always Less Greater
        //Zwrite Off    // 不希望重新写 Z - Buffer 中的值
        //Zwrite On     // 默认值，重写 Z - Buffer 的值，既重写 depth 的值，也会重写 color 的值

        Pass
        {
            Stencil{
                Ref 1
                Comp Equal
            }

        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata{
                float4 vertex:POSITION;
            };

            struct v2f{
                float4 pos:SV_POSITION;
            };

            v2f vert(appdata v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag(v2f i):SV_Target{
                return half4(0,0,1,1); // blue color
            }

        ENDCG
        }   
    }
}
