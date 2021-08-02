Shader "Unlit/L5_3"
{
	// 属性
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}  // 白色 材质属性
	}

		SubShader
	{
		Pass
		{

			// 材质 处理
			Material
			{
				Emission(0.5,0.5,0.5,0.5)	// 自发光颜色
				Diffuse(1,1,1,1)			// 设置为漫反射
			}
			
			ZWrite On     // 打开 Z-Buffer
			Lighting On  // 打开灯光
			Cull OFF    // 裁剪关闭
			SetTexture[_MainTex]{ combine texture } // SetTexture Method : 将 材质 _MainTex 与上面效果混合
		}
	}
}