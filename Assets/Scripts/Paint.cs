using UnityEngine;
using UnityEngine.EventSystems;

public class Paint : MonoBehaviour, engine.IValidate//, IPointerClickHandler
{
    [SerializeField] private Renderer _paintRenderer;
    [SerializeField] private ParticleSystem _splashParticle;

    public Color Color { get; private set; }

    private MaterialPropertyBlock _propertyBlock;
    private bool _isPicked;

    private const string colorPropertyName = "_BaseColor";

    private void Start()
    {
        ColorPicker.OnColorPick += OnColorPick;
    }

    private void OnDestroy()
    {
        ColorPicker.OnColorPick -= OnColorPick;
    }

    public void SetColor(Color color)
    {
        Color = color;
        _paintRenderer.GetPropertyBlock(_propertyBlock);
        _propertyBlock.SetColor(colorPropertyName, color);
        _paintRenderer.SetPropertyBlock(_propertyBlock);
        ParticleSystem.MainModule main = _splashParticle.main;
        main.startColor = color;
    }

    public void Validate()
    {
        _propertyBlock = new MaterialPropertyBlock();
    }

    //public void OnPointerClick(PointerEventData eventData)
    //{
    //    if (_isPicked == true) return;

    //    ColorPicker.OnColorPick.Invoke(this);
    //    _isPicked = true;
    //}

    private void OnMouseUpAsButton()
    {
        if (_isPicked == true) return;

        ColorPicker.OnColorPick.Invoke(this);
        _isPicked = true;
    }

    private void OnColorPick(Paint paint)
    {
        if (paint != this)
            _isPicked = false;
    }

    private void OnTriggerEnter(Collider other)
    {
        if(_isPicked == true)
        {
            _splashParticle.gameObject.SetActive(true);
            _splashParticle.Play();
        }
    }
}
