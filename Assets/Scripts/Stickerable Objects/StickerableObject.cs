using System.Collections;
using UnityEngine;
using Cinemachine;
using input;
using UnityEngine.EventSystems;

public class StickerableObject : MonoBehaviour
{
    [SerializeField] private float _rotationDuration = 1f;
    [SerializeField] private Vector3 _rotationVector = new Vector3(0f, .5f, 1f);
    [SerializeField] private float _rotationAngle = 480f;
    [SerializeField] private AnimationCurve _rotationCurve;

    [SerializeField] private DrawWithSticker _drawWithSticker;
    [SerializeField] private Transform _stickerSpawnPoint;
    [SerializeField] private float _stickerSize = 15f;

    private Sticker _sticker;
    private bool _isActive;
    private bool _isInit;
    private bool _isSticking;
    private Ray _drawRay;

    private CinemachineBrain _brain;
    private Camera _camera;

    private void Start()
    {
        StickerMetaSystem.Instance.OnFinishStickProcess += Stick;
    }

    private void OnDestroy()
    {
        StickerMetaSystem.Instance.OnFinishStickProcess -= Stick;

        if (_sticker != null)
            _sticker.OnSticking -= OnSticking;
    }

    private void Update()
    {
        bool overGameObject;
#if UNITY_EDITOR
        overGameObject = EventSystem.current.IsPointerOverGameObject();
#elif UNITY_ANDROID || UNITY_IOS
        overGameObject = EventSystem.current.IsPointerOverGameObject(0);
#endif
        if (overGameObject == false &&
            _isActive == true && _isSticking == false)
        {
            if(ControllerInputs.OnMouse(MouseType.Down) || ControllerInputs.OnMouse(MouseType.Non))
            {
                if(ControllerInputs.OnMouse(MouseType.Down))
                    _sticker.StickPossible(false);

                Ray ray = _camera.ScreenPointToRay(Input.mousePosition);
                
                if(Physics.Raycast(ray, out RaycastHit hit))
                {
                    if(hit.collider.gameObject == gameObject)
                    {
                        _sticker.transform.position = hit.point + transform.up * 0.1f;
                        _drawRay = ray;
                    }
                }
            }
            else if(ControllerInputs.OnMouse(MouseType.Up))
            {
                Ray ray = _camera.ScreenPointToRay(Input.mousePosition);

                if (Physics.Raycast(ray, out RaycastHit hit))
                {
                    if (hit.collider.gameObject == gameObject)
                    {
                        //_sticker.GetTextures(out Texture sticker, out Texture stickerColor);
                        //float rotation = _sticker.GetUVRotation();
                        //_drawWithSticker.Draw(ray, sticker, stickerColor, _sticker.transform.localScale.x, rotation);
                        _drawRay = ray;
                        _sticker.StickPossible(true);
                        //_sticker.Stick();
                        //_isSticking = true;
                    }
                }
            }
        }
    }

    private void OnSticking()
    {
        _isSticking = true;
    }

    private void Stick()
    {
        Vector3 sizeS = _sticker.GetComponent<Renderer>().bounds.size;
        Vector3 sizeM = GetComponent<Renderer>().bounds.size;
        sizeM.y = 0f;
        _sticker.GetTextures(out Texture sticker, out Texture stickerColor);
        float rotation = _sticker.GetUVRotation();
        _drawWithSticker.Draw(_drawRay, sticker, stickerColor, sizeS.magnitude / sizeM.magnitude, rotation);

        _isSticking = false;
        _isActive = false;
        StartCoroutine(Rotate(false));
    }

    //private void OnMouseEnter()
    //{
    //    if(_isActive == true && _sticker.gameObject.activeSelf == false)
    //    {
    //        _sticker.gameObject.SetActive(true);
    //    }
    //}

    //private void OnMouseExit()
    //{
    //    if (_isActive == true && _sticker.gameObject.activeSelf == true)
    //    {
    //        _sticker.gameObject.SetActive(false);
    //    }
    //}

    private bool Initialize(Sticker sticker)
    {
        if (_isInit == true) return false;

        _isInit = true;
        _camera = Camera.main;
        _brain = _camera.GetComponent<CinemachineBrain>();
        _sticker = sticker;
        _sticker.OnSticking += OnSticking;
        StartCoroutine(Rotate(true));

        return true;
    }

    public void Initialize(Sticker sticker, int id)
    {
        if (Initialize(sticker) == false) return;

        _drawWithSticker.Initialize(id);
    }

    public void Initialize(Sticker sticker, int id, Texture2D texture)
    {
        if(Initialize(sticker) == false) return;

        _drawWithSticker.Initialize(id, texture);
    }

    private IEnumerator Rotate(bool active)
    {
        float t = 0f;
        Vector3 startRotation = transform.rotation.eulerAngles;
        Vector3 targetRotation = startRotation + _rotationVector * _rotationAngle;

        while(t < 1f)
        {
            while (_brain.IsBlending == true)
                yield return null;

            t += Time.deltaTime / _rotationDuration;
            transform.eulerAngles = Vector3.Lerp(startRotation, targetRotation, _rotationCurve.Evaluate(t));
            yield return null;
        }

        if(active == true)
        {
            _isActive = true;
            _sticker.ResetRoll();
            _sticker.transform.localScale = Vector3.one * _stickerSize;
            _sticker.transform.eulerAngles = transform.eulerAngles;
            _sticker.transform.position = _stickerSpawnPoint.position;
            
            Tutorial.Instance.StickerMovable();
        }
        else
        {
            GameManager.instance.MakeWin();
        }
    }
}
