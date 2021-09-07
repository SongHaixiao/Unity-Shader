// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "AnimationGpuInstancing/Standard" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0

		[NoScaleOffset] _AnimTex("Animation Texture", 2D) = "white" {}
		[HideInInspector] [PerRendererData] _StartFrame("", Int) = 0				// 开始帧
		[HideInInspector] [PerRendererData] _EndFrame("", Int) = 0					// 结束帧
		[HideInInspector] [PerRendererData] _FrameCount("", Int) = 1				// 当前到的帧
		[HideInInspector] [PerRendererData] _OffsetSeconds("", Float) = 0			// 帧时间偏移（并不是每一帧都是从0开始的）
		[HideInInspector] _PixelCountPerFrame("", Int) = 0
	}

	SubShader{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert
		#include "UnityCG.cginc"

		#pragma multi_compile_instancing
		#pragma target 4.5

		sampler2D _MainTex;
		sampler2D _AnimTex;
		float4 _AnimTex_TexelSize;

		struct Input {
			float2 uv_MainTex;
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		half _Glossiness;
		half _Metallic;

		int _PixelCountPerFrame;

		UNITY_INSTANCING_BUFFER_START(Props)
			UNITY_DEFINE_INSTANCED_PROP(int, _StartFrame)
#define _StartFrame_arr Props
			UNITY_DEFINE_INSTANCED_PROP(int, _EndFrame)
#define _EndFrame_arr Props
			UNITY_DEFINE_INSTANCED_PROP(int, _FrameCount)
#define _FrameCount_arr Props
			UNITY_DEFINE_INSTANCED_PROP(float, _OffsetSeconds)
#define _OffsetSeconds_arr Props

			UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
#define _Color_arr Props
		UNITY_INSTANCING_BUFFER_END(Props)
		
		float4 GetUV(int index)
		{
			int row = index / (int)_AnimTex_TexelSize.z;
			int col = index % (int)_AnimTex_TexelSize.z;

			return float4(col / _AnimTex_TexelSize.z, row / _AnimTex_TexelSize.w, 0, 0);
		}
		
		// 计算每一帧骨骼在贴图上对应的 uv 坐标
		float4x4 GetMatrix(int startIndex, float boneIndex)
		{
			int matrixIndex = startIndex + boneIndex * 3;

			float4 row0 = tex2Dlod(_AnimTex, GetUV(matrixIndex));
			float4 row1 = tex2Dlod(_AnimTex, GetUV(matrixIndex + 1));
			float4 row2 = tex2Dlod(_AnimTex, GetUV(matrixIndex + 2));
			float4 row3 = float4(0, 0, 0, 1);

			return float4x4(row0, row1, row2, row3);
		}

		struct appdata {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
			float4 texcoord1 : TEXCOORD1;
			half4 boneIndex : TEXCOORD2;
			fixed4 boneWeight : TEXCOORD3;
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		// 顶点着色器
		void vert(inout appdata v, out Input o) {
			UNITY_SETUP_INSTANCE_ID(v);
			UNITY_TRANSFER_INSTANCE_ID(v, o);
			UNITY_INITIALIZE_OUTPUT(Input, o);

			int startFrame = UNITY_ACCESS_INSTANCED_PROP(_StartFrame_arr, _StartFrame);				// 开始帧
			int endFrame = UNITY_ACCESS_INSTANCED_PROP(_EndFrame_arr, _EndFrame);					// 结束帧
			int frameCount = UNITY_ACCESS_INSTANCED_PROP(_FrameCount_arr, _FrameCount);				// 当前播放帧
			float offsetSeconds = UNITY_ACCESS_INSTANCED_PROP(_OffsetSeconds_arr, _OffsetSeconds);	// 偏移时间

			int offsetFrame = (int)((_Time.y + offsetSeconds) * 30);								// 偏移帧
			int currentFrame = startFrame + offsetFrame % frameCount;								// 当前帧
			
			int clampedIndex = currentFrame * _PixelCountPerFrame;								    
			
			// 骨骼对应的变化矩阵
			float4x4 bone1Matrix = GetMatrix(clampedIndex, v.boneIndex.x);
			float4x4 bone2Matrix = GetMatrix(clampedIndex, v.boneIndex.y);
			float4x4 bone3Matrix = GetMatrix(clampedIndex, v.boneIndex.z);
			float4x4 bone4Matrix = GetMatrix(clampedIndex, v.boneIndex.w);

			// 计算顶点被绘制的位置
			// 计算方法 ：
			// 	1. 当前顶点位置 * 骨骼对应的变化矩阵 * 骨骼对应的影响权重
			//	2. 求对应骨骼的和
			float4 pos =
				mul(bone1Matrix, v.vertex) * v.boneWeight.x +
				mul(bone2Matrix, v.vertex) * v.boneWeight.y +
				mul(bone3Matrix, v.vertex) * v.boneWeight.z +
				mul(bone4Matrix, v.vertex) * v.boneWeight.w;

			// 计算法线
			float4 normal =
				mul(bone1Matrix, v.normal) * v.boneWeight.x +
				mul(bone2Matrix, v.normal) * v.boneWeight.y +
				mul(bone3Matrix, v.normal) * v.boneWeight.z +
				mul(bone4Matrix, v.normal) * v.boneWeight.w;

			v.vertex = pos;
			v.normal = normal;
		}

		// surface sahder
		void surf(Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * UNITY_ACCESS_INSTANCED_PROP(_Color_arr, _Color);
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
