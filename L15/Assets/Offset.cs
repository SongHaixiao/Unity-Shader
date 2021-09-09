using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Offset : MonoBehaviour
{
    public float OffsetAmount;
    MeshRenderer meshRenderer;

    // Start is called before the first frame update
    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        // 偏移量，随时间进行插值计算
        OffsetAmount = Mathf.Lerp(OffsetAmount, 0, Time.deltaTime);

        // 对 Shader Grah 中 Reference 为 _Amount 的节点传递 OffsetAmount 参数
        meshRenderer.material.SetFloat("_Amount", OffsetAmount);

        // 当点击空格时，偏移量自增 1.0f
        if (Input.GetButtonDown("Jump"))
        {
            OffsetAmount += 1.0f;
        }
    }
}
 