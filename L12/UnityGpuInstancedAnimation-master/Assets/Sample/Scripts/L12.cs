using UnityEngine;

public class L12 : MonoBehaviour
{
    [SerializeField]
    MaterialPropertyBlockController BodyPropertyBlockController;
    [SerializeField]
    AnimatedMeshAnimator BodyMeshAnimator;

    private readonly static string[] RandomAnimationNames = new string[]
    {
        "Victory",
        "Attack01",
        "Attack02",
        "Idle"
    };

    private void Awake()
    {
        var randomColor = new Color(Random.Range(0.00f, 1.00f), Random.Range(0.00f, 1.00f), Random.Range(0.00f, 1.00f), 1);
        BodyPropertyBlockController.SetColor("_Color", randomColor);
        BodyPropertyBlockController.Apply();

        var offsetSeconds = Random.Range(0.0f, 3.0f);
        var randomIndex = Random.Range(0, RandomAnimationNames.Length);
        var randomAnimationNames = RandomAnimationNames[randomIndex];

        BodyMeshAnimator.Play(randomAnimationNames, offsetSeconds);
    }
}
