 using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class L11_0 : MonoBehaviour
{
    public GameObject[] objs;

    // Start is called before the first frame update
    void Start()
    {
        MaterialPropertyBlock props = new MaterialPropertyBlock();
        MeshRenderer renderer;
        foreach (GameObject obj in objs){
            float r = Random.Range(0.0f, 1.0f);
            float g = Random.Range(0.0f, 1.0f);
            float b = Random.Range(0.0f, 1.0f);

            props.SetColor("_Color", new Color(r,g,b));
            renderer = obj.GetComponent<MeshRenderer>();
            renderer.SetPropertyBlock(props);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
