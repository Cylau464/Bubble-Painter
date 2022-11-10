using System.Collections;
using UnityEngine;

public class Decal : MonoBehaviour
{
    [SerializeField] private Texture[] _textures;
    [SerializeField] private Renderer _renderer;
    [SerializeField] private float _splashingDuration = .2f;
    [SerializeField] private float _splashingSize = 1.5f;

    private MaterialPropertyBlock _propertyBlock;

    private const string colorPropName = "_Color";
    private const string mainTexPropName = "_MainTex";

    public void Init(Color color)
    {
        _propertyBlock = new MaterialPropertyBlock();

        _renderer.GetPropertyBlock(_propertyBlock);
        _propertyBlock.SetTexture(mainTexPropName, _textures[Random.Range(0, _textures.Length)]);
        _propertyBlock.SetColor(colorPropName, color);
        _renderer.SetPropertyBlock(_propertyBlock);

        StartCoroutine(Splashing());
    }

    private IEnumerator Splashing()
    {
        float t = 0f;
        Vector3 startSize = transform.localScale;
        Vector3 targetSize = startSize * _splashingSize;

        while(t < 1f)
        {
            t += Time.deltaTime / _splashingDuration;
            transform.localScale = Vector3.Lerp(startSize, targetSize, t);
            yield return null;
        }
    }
}
