using UnityEngine;
using UnityEngine.Rendering;
using System;
using Random = UnityEngine.Random;

public class DrawOnTexture : MonoBehaviour
{
    [SerializeField] private LayerMask _targetLayer;
    [SerializeField] private float _sizeMult = .1f;
    [SerializeField] private int _textureSize = 1024;
    [Space]
    [SerializeField] private Renderer _renderer;
    [SerializeField] private Texture[] _brushTextures;
    [SerializeField] private Texture _blankTexture;
    [SerializeField] private Material _brushMaterial;
    [SerializeField] private PicturesContainer _picturesContainer;
    [Space]
    [SerializeField] private Sticker _stickerPrefab;
    [SerializeField] private float _stickerSpawnOffset = 2.04f;
    [SerializeField] private Vector3 _stickerSize = new Vector3(27f, 27f, 29.4f);

    private Sticker _sticker;
    private Texture _picture;
    private RenderTexture _rt;
    private MaterialPropertyBlock _propertyBlock;
    private Camera _camera;

    public Action OnDraw;

    private const string oneMinusProperty = "_OneMinus";
    private const float oneMinusValue = 0;

    private void Start()
    {
        _camera = Camera.main;
        _propertyBlock = new MaterialPropertyBlock();
        _rt = RenderTexture.GetTemporary(_textureSize, _textureSize, 0, RenderTextureFormat.ARGB32);
        _brushMaterial = new Material(_brushMaterial);
        _picture = _picturesContainer.Pictures[GameManager.instance.levelsData.idLevel];

        _renderer.GetPropertyBlock(_propertyBlock);
        _propertyBlock.SetTexture("_MainTex", _picture);
        _propertyBlock.SetTexture("_RenderTex", _rt);
        _renderer.SetPropertyBlock(_propertyBlock);
        DrawBlank();

        _sticker = Instantiate(_stickerPrefab, transform.position + Vector3.up * _stickerSpawnOffset, transform.rotation);
        _sticker.transform.localScale = _stickerSize;
        _sticker.gameObject.SetActive(false);
    }

    // Initialization RenderTexture
    private void DrawBlank()
    {
        //  Activate _rt
        RenderTexture.active = _rt;
        //  Save current state 
        GL.PushMatrix();
        //  Set up the matrix 
        GL.LoadPixelMatrix(0, _rt.width, _rt.height, 0);

        //  Draw maps 
        Rect rect = new Rect(0, 0, _rt.width, _rt.height);
        Graphics.DrawTexture(rect, _blankTexture);

        //  Pop up changes 
        GL.PopMatrix();

        RenderTexture.active = null;
    }

    // Stay RenderTexture Of (x,y) Draw brush patterns at coordinates 
    private void Draw(int x, int y, float splashSize, Color color)
    {
        RenderTexture temp = RenderTexture.GetTemporary(_rt.width, _rt.height, 0, RenderTextureFormat.ARGB32);

        if (SystemInfo.copyTextureSupport != CopyTextureSupport.None)
            Graphics.CopyTexture(_rt, temp);
        else
            Graphics.Blit(_rt, temp);

        RenderTexture.active = _rt;
        GL.PushMatrix();
        GL.LoadPixelMatrix(0, _rt.width, _rt.height, 0);

        int size = Mathf.FloorToInt(_sizeMult * _textureSize * splashSize);
        x -= (int)(size * 0.5f);
        y -= (int)(size * 0.5f);
        Rect rect = new Rect(x, y, size, size);

        Texture brushTexture = _brushTextures[Random.Range(0, _brushTextures.Length)];
        _brushMaterial.SetColor("_Color", color);
        _brushMaterial.SetTexture("_MainTex", brushTexture);
        _brushMaterial.SetTexture("_RenderTex", temp);
        Graphics.DrawTexture(rect, brushTexture, _brushMaterial);

        GL.PopMatrix();

        RenderTexture.active = null;
        RenderTexture.ReleaseTemporary(temp);

        OnDraw?.Invoke();
    }

    //private void Update()
    //{
    //    if (Input.GetMouseButton(0))
    //    {
    //        Ray ray = _camera.ScreenPointToRay(Input.mousePosition);
    //        RaycastDraw(ray);
    //    }
    //}

    public void RaycastDraw(Ray ray, float size, Color color)
    {
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit, Mathf.Infinity, _targetLayer))
        {
            var x = (int)(hit.textureCoord.x * _rt.width);
            var y = (int)(_rt.height - hit.textureCoord.y * _rt.height);
            Draw(x, y, size, color);
        }
    }

    public void DrawBySplash(Vector3 splashPos, float size, Color color)
    {
        Ray ray = new Ray(_camera.transform.position, (splashPos - _camera.transform.position).normalized);
        RaycastDraw(ray, size, color);
    }

    public void CreateSticker()
    {
        Texture2D stickerTex = new Texture2D(_rt.width, _rt.height, TextureFormat.ARGB32, false);
        Rect rect = new Rect(0, 0, _rt.width, _rt.height); //new Rect(_rt.width / 2 - _picture.width / 2, _rt.height / 2 - _picture.height / 2, _picture.width, _picture.height);

        RenderTexture.active = _rt;

        stickerTex.ReadPixels(rect, 0, 0);
        stickerTex.Apply();
        _sticker.gameObject.SetActive(true);
        _sticker.SetTexture(stickerTex, _picture);
        _sticker.Unstick();

        RenderTexture.active = null;

        _renderer.GetPropertyBlock(_propertyBlock);
        _propertyBlock.SetFloat(oneMinusProperty, oneMinusValue);
        _renderer.SetPropertyBlock(_propertyBlock);
    }

    private void OnDestroy()
    {
        _rt.Release();
    }
}