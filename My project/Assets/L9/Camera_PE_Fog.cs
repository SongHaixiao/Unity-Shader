using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Camera_PE_Fog : MonoBehaviour
{
    private Camera cam;
    public Material mat;

    // Start is called before the first frame update
    void Start()
    {
        // Shader LOD
        //Shader.globalMaximumLOD = 200; // Blue
        //Shader.globalMaximumLOD = 400; // Green
        Shader.globalMaximumLOD = 600; // Redn
        cam = gameObject.GetComponent<Camera>();
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, mat);
    }

    private void OnPreRender()
    {
        
    }
}
