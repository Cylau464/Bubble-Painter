using System.Collections.Generic;
using System.Collections;
using System;
using UnityEngine;
using UnityEngine.EventSystems;
using Random = UnityEngine.Random;

public class ColorBall : MonoBehaviour//, IPointerClickHandler, IPointerDownHandler
{
    [SerializeField] private Rigidbody _rigidBody;
    [SerializeField] private Renderer _renderer;
    public Renderer Renderer => _renderer;
    [SerializeField] private LayerMask _ballLayer;
    [SerializeField] private LayerMask _pictureLayer;
    [SerializeField] private float _splashClickDelay = .2f;
    [SerializeField] private float _splashDelay = .2f;
    [SerializeField] private float _splashSize = 1.5f;
    [Space]
    [SerializeField] private ParticleSystem _splashParticle;
    [SerializeField] private Gradient _colorGradient;

    private ParticleSystem _particle;

    private Renderer _picture;
    private DrawOnTexture _drawTarget;

    private bool _splashed;
    private List<ColorBall> _nearestBalls;
    private Color _color;
    private ColorBallSpawner _spawner;
    private MaterialPropertyBlock _propertyBlock;

    private float _curClickDelay;

    private const string materialColorName = "_TintColor";

    public Action<ColorBall> OnSplashed;
    private void OnEnable()
    {
        if (_particle == null)
        {
            _particle = Instantiate(_splashParticle, transform.position, transform.rotation, transform);
            _particle.gameObject.SetActive(false);
        }
    }

    private void Start()
    {
        _nearestBalls = new List<ColorBall>();
        _renderer.sortingOrder++;
    }

    public void Init(ColorBallSpawner spawner)
    {
        _propertyBlock = new MaterialPropertyBlock();
        SetColor();
        _spawner = spawner;
    }

    public void SetColor()
    {
        Color color = _colorGradient.Evaluate(Random.value);
        SetColor(color);
    }

    public void SetColor(Color color)
    {
        _splashed = false;
        _color = color;
        _renderer.GetPropertyBlock(_propertyBlock);
        _propertyBlock.SetColor(materialColorName, color);
        _renderer.SetPropertyBlock(_propertyBlock);
    }

    //private void OnCollisionEnter(Collision collision)
    //{
    //    if((1 << collision.gameObject.layer & _ballLayer) != 0)
    //    {
    //        if(collision.gameObject.TryGetComponent(out ColorBall ball) == true)
    //        {
    //            if (_nearestBalls.Contains(ball) == false)
    //                _nearestBalls.Add(ball);
    //        }
    //    }
    //    else if((1 << collision.gameObject.layer & _pictureLayer) != 0 && _picture == null)
    //    {
    //        _picture = collision.gameObject.GetComponent<Renderer>();
    //    }
    //}

    //private void OnCollisionExit(Collision collision)
    //{
    //    if ((1 << collision.gameObject.layer & _ballLayer) != 0)
    //    {
    //        if (collision.gameObject.TryGetComponent(out ColorBall ball) == true)
    //        {
    //            if (_nearestBalls.Contains(ball) == true)
    //                _nearestBalls.Remove(ball);
    //        }
    //    }
    //}

    private void OnTriggerEnter(Collider other)
    {
        if ((1 << other.gameObject.layer & _ballLayer) != 0)
        {
            if (other.gameObject.TryGetComponent(out ColorBall ball) == true)
            {
                if (_nearestBalls.Contains(ball) == false)
                    _nearestBalls.Add(ball);
            }
        }
        else if ((1 << other.gameObject.layer & _pictureLayer) != 0 && _picture == null)
        {
            _picture = other.gameObject.GetComponent<Renderer>();
            _drawTarget = _picture.GetComponent<DrawOnTexture>();
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if ((1 << other.gameObject.layer & _ballLayer) != 0)
        {
            if (other.gameObject.TryGetComponent(out ColorBall ball) == true)
            {
                if (_nearestBalls.Contains(ball) == true)
                    _nearestBalls.Remove(ball);
            }
        }
    }

    private void AddToSplashQueue()
    {
        if (_splashed == true)
            return;

        _splashed = true;
        _spawner.AddBallInQueue(this);
    }

    public void Splash()
    {
        StartCoroutine(Splashing());
    }

    private void OnMouseDown()
    {
        _curClickDelay = Time.time + _splashClickDelay;
    }

    private void OnMouseUpAsButton()
    {
        if (_curClickDelay < Time.time) return;

        AddToSplashQueue();
    }

    //public void OnPointerDown(PointerEventData eventData)
    //{
    //    _curClickDelay = Time.time + _splashClickDelay;
    //}

    //public void OnPointerClick(PointerEventData eventData)
    //{
    //    if (_curClickDelay < Time.time) return;

    //    AddToSplashQueue();
    //}

    private IEnumerator Splashing()
    {
        Vector3 startSize = transform.localScale;
        Vector3 targetSize = transform.localScale * _splashSize;
        float t = 0f;

        while (t < 1f)
        {
            t += Time.deltaTime / _splashDelay;
            transform.localScale = Vector3.Lerp(startSize, targetSize, t);
            yield return null;
        }

        if (_spawner != null)
        {
            _spawner.ReturnToStack(this);
        }
        else
        {
            _spawner = FindObjectOfType<ColorBallSpawner>();
            _spawner.ReturnToStack(this);
        }

        OnSplashed?.Invoke(this);

        if (_drawTarget == null)
        {
            if (Physics.Raycast(transform.position, Vector3.down, out RaycastHit hit, 10f, _pictureLayer))
            {
                _picture = hit.collider.GetComponent<Renderer>();
                _drawTarget = _picture.GetComponent<DrawOnTexture>();
            }
        }

        //Debug.Log(_drawTarget.name);
        _drawTarget.DrawBySplash(transform.position, transform.localScale.x, _color);

        transform.localScale = startSize;

        ParticleSystem.MainModule settings = _particle.main;
        settings.startColor = new ParticleSystem.MinMaxGradient(_color);
        _particle.transform.parent = null;
        _particle.transform.localScale = _splashParticle.transform.localScale;
        _particle.gameObject.SetActive(true);
        _particle = null;
        _picture = null;
        _drawTarget = null;

        foreach (ColorBall ball in _nearestBalls.ToArray())
        {
            ball.AddToSplashQueue();
            _nearestBalls.Remove(ball);
        }
    }

    public void AddForce(Vector3 force, ForceMode mode)
    {
        _rigidBody.AddForce(force, mode);
    }
}
