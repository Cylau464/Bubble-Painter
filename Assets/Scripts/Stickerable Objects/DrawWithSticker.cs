using UnityEngine;
using UnityEngine.Rendering;

public class DrawWithSticker : MonoBehaviour
{
    [SerializeField] private LayerMask _targetLayer;
    [SerializeField] private int _textureSize = 1024;
    [SerializeField] private float _sizeMult = .1f;
    [Space]
    [SerializeField] private Renderer _renderer;
    [SerializeField] private Texture _blankTexture;
    [SerializeField] private Material _brushMaterial;

    private Texture _sticker;
    private Texture _stickerColor;
    [SerializeField] private RenderTexture _rt;
    private MaterialPropertyBlock _propertyBlock;

    private int _id;
    private Texture2D _stickersTexture;
    private Texture2D _texture;

    private const string rotationProperty = "_Rotation";
    private const string renderTexProperty = "_RenderTex";

    private void Initialize()
    {
        _propertyBlock = new MaterialPropertyBlock();
        _brushMaterial = new Material(_brushMaterial);
        _rt = RenderTexture.GetTemporary(_textureSize, _textureSize, 0, RenderTextureFormat.ARGB32);
        _texture = new Texture2D(_textureSize, _textureSize, TextureFormat.ARGB32, false);

        if(_stickersTexture != null)
        {
            if (SystemInfo.copyTextureSupport != CopyTextureSupport.None)
            {
                Graphics.CopyTexture(_stickersTexture, 0, 0, _rt, 0, 0);
                Graphics.CopyTexture(_stickersTexture, 0, 0, _texture, 0, 0);
            }
            else
            {
                Graphics.Blit(_stickersTexture, _rt);
                RenderTexture.active = _rt;
                _texture.ReadPixels(new Rect(0, 0, _rt.width, _rt.height), 0, 0);
                _texture.Apply();
                RenderTexture.active = null;
            }
        }
        else
        {
            DrawBlank();
        }

        _renderer.GetPropertyBlock(_propertyBlock);
        _propertyBlock.SetTexture(renderTexProperty, _texture);
        _renderer.SetPropertyBlock(_propertyBlock);
    }

    public void Initialize(int id)
    {
        _id = id;
        Initialize();
    }

    public void Initialize(int id, Texture2D texture)
    {
        _stickersTexture = texture;
        Initialize(id);
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

        _texture.ReadPixels(new Rect(0, 0, _rt.width, _rt.height), 0, 0);
        _texture.Apply();

        RenderTexture.active = null;
    }

    // Stay RenderTexture Of (x,y) Draw brush patterns at coordinates 
    private void Draw(int x, int y, float stickerSize, float rotation)
    {
        RenderTexture temp = RenderTexture.GetTemporary(_rt.width, _rt.height, 0, RenderTextureFormat.ARGB32);

        if (SystemInfo.copyTextureSupport != CopyTextureSupport.None)
            Graphics.CopyTexture(_rt, temp);
        else
            Graphics.Blit(_rt, temp);

        RenderTexture.active = _rt;
        GL.PushMatrix();
        GL.LoadPixelMatrix(0, _rt.width, _rt.height, 0);

        int size = Mathf.FloorToInt(_textureSize * _sizeMult * stickerSize);
        x -= (int)(size * 0.5f);
        y -= (int)(size * 0.5f);
        Rect rect = new Rect(x, y, size, size);

        _brushMaterial.SetTexture("_StickerTex", _sticker);
        _brushMaterial.SetTexture("_StickerColorTex", _stickerColor);
        _brushMaterial.SetTexture("_RenderTex", temp);
        _brushMaterial.SetFloat(rotationProperty, rotation);
        Graphics.DrawTexture(rect, _sticker, _brushMaterial);

        GL.PopMatrix();

        _texture.ReadPixels(new Rect(0, 0, _rt.width, _rt.height), 0, 0);
        _texture.Apply();

        RenderTexture.active = null;
        RenderTexture.ReleaseTemporary(temp);

        StickerMetaSystem.Instance.AddSticker(_id, _texture);
    }

    private void RaycastDraw(Ray ray, float size, float rotation)
    {
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit, Mathf.Infinity, _targetLayer))
        {
            var x = (int)(hit.textureCoord.x * _rt.width);
            var y = (int)(_rt.height - hit.textureCoord.y * _rt.height);
            Draw(x, y, size, rotation);
        }
    }

    public void Draw(Ray ray, Texture sticker, Texture stickerColor, float size, float rotation)
    {
        _sticker = sticker;
        _stickerColor = stickerColor;
        RaycastDraw(ray, size, rotation);
    }

    private void OnDestroy()
    {
        _rt.Release();
    }
}