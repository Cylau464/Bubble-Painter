using UnityEngine;
using System.Collections;
using System;
using Random = UnityEngine.Random;

public class Sticker : MonoBehaviour
{
    [SerializeField] private Renderer _renderer;
    [SerializeField] private float _startScrollValue = 2f;
    [SerializeField] private float _targetScrollValue = -.5f;
    [SerializeField] private float _stickDuration = 1f;
    [SerializeField] private Vector3[] _rollDirections;

    private MaterialPropertyBlock _propertyBlock;

    private float _curRotation;

    private const string mainTexProperty = "_MainTex";
    private const string paintTexProperty = "_PaintTex";
    private const string rollProperty = "_PointY";
    private const string upDirProperty = "_UpDir";

    public Action OnSticking;
    public Action<bool> OnStickPossible;

    public void SetTexture(Texture paintTexture, Texture picture)
    {
        Vector3 rollDirection = _rollDirections[Random.Range(0, _rollDirections.Length)];

        _propertyBlock = new MaterialPropertyBlock();
        _renderer.GetPropertyBlock(_propertyBlock);
        _propertyBlock.SetTexture(mainTexProperty, picture);
        _propertyBlock.SetTexture(paintTexProperty, paintTexture);
        _propertyBlock.SetFloat(rollProperty, _startScrollValue);
        _propertyBlock.SetVector(upDirProperty, rollDirection);
        _renderer.SetPropertyBlock(_propertyBlock);
    }

    public void ResetRoll()
    {
        _renderer.GetPropertyBlock(_propertyBlock);
        _propertyBlock.SetFloat(rollProperty, _startScrollValue);
        _renderer.SetPropertyBlock(_propertyBlock);
    }

    public void Unstick()
    {
        StopAllCoroutines();
        StartCoroutine(Roll(false));
    }

    public void Stick()
    {
        OnSticking?.Invoke();
        _renderer.GetPropertyBlock(_propertyBlock);
        _propertyBlock.SetFloat(rollProperty, _targetScrollValue);
        _renderer.SetPropertyBlock(_propertyBlock);

        StopAllCoroutines();
        StartCoroutine(Roll(true));
    }

    public void StickPossible(bool possible)
    {
        OnStickPossible?.Invoke(possible);
    }

    private IEnumerator Roll(bool stick)
    {
        float t = 0f;
        float targetRoll = stick == true ? _startScrollValue : _targetScrollValue;
        _renderer.GetPropertyBlock(_propertyBlock);
        float startRoll = _propertyBlock.GetFloat(rollProperty);
        _renderer.SetPropertyBlock(_propertyBlock);

        while(t < 1f)
        {
            t += Time.deltaTime / _stickDuration;

            _renderer.GetPropertyBlock(_propertyBlock);
            _propertyBlock.SetFloat(rollProperty, Mathf.Lerp(startRoll, targetRoll, t));
            _renderer.SetPropertyBlock(_propertyBlock);

            yield return null;
        }

        if (stick == false)
        {
            StickerMetaSystem.Instance.StartStickProcess(this);
        }
        else
        {
            StickerMetaSystem.Instance.FinishStickProcess();
            Destroy(gameObject);
        }
    }

    public void GetTextures(out Texture sticker, out Texture stickerColor)
    {
        _renderer.GetPropertyBlock(_propertyBlock);
        sticker = _propertyBlock.GetTexture(mainTexProperty);
        stickerColor = _propertyBlock.GetTexture(paintTexProperty);
        _renderer.SetPropertyBlock(_propertyBlock);
    }

    public float GetUVRotation()
    {
        return _curRotation;
    }

    public void Rotate(float angle)
    {
        _curRotation -= angle;
        transform.Rotate(Vector3.up, angle, Space.Self);
    }
}