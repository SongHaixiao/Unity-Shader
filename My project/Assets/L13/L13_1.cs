using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class L13_1 : MonoBehaviour
{
    [HideInInspector]
    public RenderTexture rgbRenderTex; // 修改每个像素的信息

    [HideInInspector]
    public Texture2D rgbTex;    // 读写图片像素信息

    [HideInInspector]
    public Color[] rawRgbData; // 2维数组用于存储像素颜色信息

    private int width;  // 目标区域的宽
    private int height; // 目标区域的高

    void Start()
    {
        // 指定目标区域的宽、高
        width = 1280; 
        height = 720;

        // 实例化一个 Texture2D
        rgbTex = new Texture2D(width, height, TextureFormat.RGBA32, false);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        // src  : 原 Texture
        // dest : 目标 Texture

        // 2. CPU 处理

        // ReadPixes : 从 RenderTexture.active （ 激活的 RenderTexture ） 中读取 Rect 定义的矩形区域
        // Rect(0,0,width,height) : 从（ 0, 0 ） 开始到 （ width, height ）
        // 读完之后，放到 rgbTex 当中
        rgbTex.ReadPixels(new Rect(0,0, width, height),0,0);

        // 调用 Apply 才能取读取
        rgbTex.Apply();

        // 将 矩形区域的的像素信息赋值给 rawRgbData
        rawRgbData = rgbTex.GetPixels();

        // 按照 width, height 遍历每一个像素
        // 修改每个像素的 r 通道的值
        for(int x = 0; x < rgbTex.width; x++)
        {
            for(int y = 0; y < rgbTex.height; y++)
            {
                // 修改每个像素的 r 通道改为 0.0f
                rawRgbData[x + rgbTex.width * y].r = 0.0f; 
                // Mathf.Sin(0.7f); 
                // Math.Pow(1.2f, 3);
            }
        }

        // 将 修改完后 2维数组中的颜色信息 放入到 rgbTex 中
        rgbTex.SetPixels(rawRgbData);
        rgbTex.Apply();

        // 将 rgbTex 绘制到 目标区域 dest 中
        Graphics.Blit(rgbTex,dest);
    }
}