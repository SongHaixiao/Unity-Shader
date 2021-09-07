using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class L13_0 : MonoBehaviour
{
    public Material mat;

    // Way 1 : Image Filter
    void OnRenderImage(RenderTexture src, RenderTexture dest) // 更接近原理
    {
        // RenderTexture src : 原 Texture
        // RenderTexture dest : 目标 Texture

        // Graphics 中的 Blit 函数
        // 将 src 原 Texture 静穆哦 mat Material 处理后，赋值给 dest 目标 Texture
        // mat : 可省略，即将 src 直接赋值给 dest
        // dest : 可省略，即将 src 直接绘制到屏幕上
        Graphics.Blit(src,dest,mat);
    }  
}
