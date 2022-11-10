using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.EventSystems;

public class StickerControllerUI : MonoBehaviour
{
    [SerializeField] private Button _stickBtn;

    [SerializeField] private Slider _slider;
    [SerializeField] private TMP_Text _minValue;
    [SerializeField] private TMP_Text _maxValue;

    [SerializeField] private float _turnAngle = 5f;

    private float _curAngle;
    private Sticker _sticker;

    private void Awake()
    {
        _stickBtn.gameObject.SetActive(false);
        _stickBtn.onClick.AddListener(Stick);
    }

    private void OnDestroy()
    {
        StickerMetaSystem.Instance.OnStartStickProcess -= SetSticker;

        if(_sticker != null)
            _sticker.OnStickPossible += StickBtnActive;
    }

    private void Update()
    {
        if(_sticker != null)
            _sticker.Rotate(_curAngle);
    }

    public void Initialize(float minSize, float maxSize)
    {
        gameObject.SetActive(true);
        StickerMetaSystem.Instance.OnStartStickProcess += SetSticker;
        _stickBtn.gameObject.SetActive(false);
        _slider.minValue = minSize;
        _slider.maxValue = maxSize;
        _slider.onValueChanged.AddListener(ChangeSize);
        _minValue.text = minSize.ToString();
        _maxValue.text = maxSize.ToString();
    }

    private void SetSticker(Sticker sticker)
    {
        _sticker = sticker;
        _sticker.OnStickPossible += StickBtnActive;
    }

    private void StickBtnActive(bool active)
    {
        _stickBtn.gameObject.SetActive(active);
    }

    private void Stick()
    {
        _sticker.Stick();
        _stickBtn.gameObject.SetActive(false);
    }

    private void ChangeSize(float size)
    {
        _sticker.transform.localScale = Vector3.one * size;
    }

    public void StartLeftTurn()
    {
        _curAngle -= _turnAngle;
    }

    public void StopLeftTurn()
    {
        _curAngle += _turnAngle;
    }

    public void StartRightTurn()
    {
        _curAngle += _turnAngle;
    }


    public void StopRightTurn()
    {
        _curAngle -= _turnAngle;
    }
}
