using System.Collections;
using UnityEngine;

public class LightController : MonoBehaviour
{
    [SerializeField] private Vector3 _paintLightDirection;
    [SerializeField] private Vector3 _stickLightDirection;
    [SerializeField] private float _rotateDuration = .5f;

    private void Start()
    {
        StickerMetaSystem.Instance.OnStartStickProcess += RotateToStickLight;
        //StickerMetaSystem.Instance.OnFinishStickProcess += RotateToPaintLight;
    }

    private void OnDestroy()
    {
        StickerMetaSystem.Instance.OnStartStickProcess -= RotateToStickLight;
        //StickerMetaSystem.Instance.OnFinishStickProcess -= RotateToPaintLight;
    }

    private void RotateToStickLight(Sticker sticker)
    {
        StopAllCoroutines();
        StartCoroutine(Rotate(_stickLightDirection));
    }

    private void RotateToPaintLight()
    {
        StopAllCoroutines();
        StartCoroutine(Rotate(_paintLightDirection));
    }

    private IEnumerator Rotate(Vector3 targetDir)
    {
        float t = 0f;
        Vector3 startDir = transform.rotation.eulerAngles;

        while(t < 1f)
        {
            t += Time.deltaTime / _rotateDuration;
            transform.eulerAngles = Vector3.Lerp(startDir, targetDir, t);
            yield return null;
        }
    }
}
