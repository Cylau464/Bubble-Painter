using System.Collections;
using UnityEngine;
using input;
using System;
using UnityEngine.EventSystems;
using Random = UnityEngine.Random;

public class TubuleController : MonoBehaviour
{
    [SerializeField] private LayerMask _targetLayer;
    [SerializeField] private LayerMask _ballLayer;

    [Header("Bubble Spawn")]
    [SerializeField] private ColorBallSpawner _ballSpawner;
    [SerializeField] private float _ballInflateTime = .2f;
    [SerializeField] private float _ballSpawnDelay = .05f;
    [SerializeField] private float _minballSize = 2f;
    [SerializeField] private float _maxballSize = 5f;
    [SerializeField] private Transform _spawnPoint;

    [Header("Movement")]
    [SerializeField] private float _activationTime = .2f;
    //[SerializeField] private float _targetHeightOffset = 1f;
    [SerializeField] private AnimationCurve _parabolaCurve;
    [SerializeField] private float _moveParabolaHeight = 4f;
    [SerializeField] private Vector3 _paintPosOffset = new Vector3(1.75f, 0f, 0f);
    [SerializeField] private Vector3 _moveOffset = new Vector3(0f, 1f, .2f);
    [SerializeField] private float _moveDelay = .1f;
    [SerializeField] private float _moveSpeed = 2f;
    //[SerializeField] private float _minDistanceToTarget = .1f;
    [SerializeField] private float _minDistanceForDecreaseSize = .1f;
    [SerializeField] private float _maxDistanceForDecreaseSize = 2f;

    private enum State { DelayActivate, Activate, Move, Deactivate, Deactivated, Inflates }
    private State _state;

    private Camera _camera;
    private Vector3 _moveTarget;
    private Paint _pickedPaint;

    public Action<ColorBall> OnBubbleSpawned;

    private void Awake()
    {
        ColorPicker.OnColorPick += OnColorPick;
    }

    private void OnDestroy()
    {
        ColorPicker.OnColorPick -= OnColorPick;
    }

    private void Start()
    {
        _camera = Camera.main;
        SwitchState(State.Deactivated);
    }

    private void Update()
    {
        if (GameManager.isStarted == false) return;

        bool overGameObject;
#if UNITY_EDITOR
        overGameObject = EventSystem.current.IsPointerOverGameObject();
#elif UNITY_ANDROID || UNITY_IOS
        overGameObject = EventSystem.current.IsPointerOverGameObject(0);
#endif

        if(overGameObject == false)
        {
            if (ControllerInputs.OnMouse(MouseType.Down) && _state == State.Deactivated)
            {
                Ray ray = _camera.ScreenPointToRay(Input.mousePosition);

                if (Physics.Raycast(ray, out RaycastHit hit, 100f) == true)
                {
                    Activate(ray, hit);
                }
            }
            else if (ControllerInputs.OnMouse(MouseType.Non) && (_state == State.Move || _state == State.Deactivated))
            {
                Ray ray = _camera.ScreenPointToRay(Input.mousePosition);

                if (Physics.Raycast(ray, out RaycastHit hit, 100f, _targetLayer) == true)
                {
                    if(_state == State.Deactivated)
                    {
                        Activate(ray, hit);
                    }
                    else
                    {
                        _moveTarget = hit.point + _moveOffset;
                        _moveTarget.x = Mathf.Clamp(_moveTarget.x, -hit.collider.bounds.size.x / 2f, hit.collider.bounds.size.x / 2f);
                        _moveTarget.z = Mathf.Clamp(_moveTarget.z, -hit.collider.bounds.size.z / 2f, hit.collider.bounds.size.z / 2f);
                        transform.position = Vector3.MoveTowards(transform.position, _moveTarget, Time.deltaTime * _moveSpeed);
                    }
                }
            }
        }
        
        if(ControllerInputs.OnMouse(MouseType.Up))
        {
            if (_state == State.Move || _state == State.DelayActivate)
            {
                _moveTarget = _pickedPaint.transform.position + _paintPosOffset;
                StopAllCoroutines();
                StartCoroutine(Move(false));
                SwitchState(State.Deactivated);
            }
            else if(_state != State.Deactivated)
            {
                SwitchState(State.Deactivate);
            }
        }
    }

    private void Activate(Ray ray, RaycastHit hit)
    {
        float moveDelay = 0f;
        bool move = false;
        Collider targetCollider = null;

        if ((1 << hit.collider.gameObject.layer & _targetLayer) != 0)
        {
            moveDelay = 0f;
            move = true;
            targetCollider = hit.collider;
            SwitchState(State.Activate);
        }
        else if ((1 << hit.collider.gameObject.layer & _ballLayer) != 0)
        {
            if (Physics.Raycast(ray, out RaycastHit hit2, 100f, _targetLayer) == true)
            {
                hit.point = hit2.point;
                targetCollider = hit2.collider;
            }
            else
            {
                targetCollider = hit.collider;
            }

            move = true;
            moveDelay = _moveDelay;
            SwitchState(State.DelayActivate);
        }

        if (move == true)
        {
            _moveTarget = hit.point + _moveOffset;
            float xClamp = targetCollider.bounds.size.x / 2f;
            float zClamp = targetCollider.bounds.size.z / 2f;
            _moveTarget.x = Mathf.Clamp(_moveTarget.x, -xClamp, xClamp);
            _moveTarget.z = Mathf.Clamp(_moveTarget.z, -zClamp, zClamp);
            StopAllCoroutines();
            StartCoroutine(Move(true, moveDelay));
        }
    }

    private void SwitchState(State newState)
    {
        _state = newState;
    }

    private void OnColorPick(Paint paint)
    {
        if (_pickedPaint == null)
            transform.position = paint.transform.position + _paintPosOffset;

        _pickedPaint = paint;
        _moveTarget = paint.transform.position + _paintPosOffset;
        StopAllCoroutines();
        StartCoroutine(Move(false));
    }

    private IEnumerator Move(bool spawnBalls, float delay = 0f)
    {
        if (delay > 0f)
            yield return new WaitForSeconds(delay);

        Vector3 startPos = transform.position;
        Vector3 targetPos;
        float t = startPos == _moveTarget ? 1f : 0f;

        while (t < 1f)
        {
            t += Time.deltaTime / _activationTime;
            targetPos = _moveTarget;
            targetPos.y += _parabolaCurve.Evaluate(t) * _moveParabolaHeight;
            transform.position = Vector3.Lerp(startPos, targetPos, t); //Parabola(startPos, targetPos, _moveParabolaHeight, t);

            yield return null;
        }

        if (spawnBalls == true)
            StartCoroutine(SpawnBalls());
    }

    private IEnumerator SpawnBalls()
    {
        float t = 0f;
        ColorBall ball;
        Vector3 startSize = Vector3.zero;
        Vector3 targetSize;
        float distanceToTarget;

        while (true)
        {
            t = 0f;
            ball = _ballSpawner.GetBall();
            ball.SetColor(_pickedPaint.Color);
            ball.gameObject.SetActive(true);
            ball.transform.position = _spawnPoint.position;
            distanceToTarget = Vector3.Distance(transform.position, _moveTarget) / _maxDistanceForDecreaseSize;

            if (distanceToTarget <= _minDistanceForDecreaseSize)
                targetSize = Vector3.one * Random.Range(_minballSize, _maxballSize);
            else
                targetSize = Vector3.one * Mathf.Lerp(_maxballSize, _minballSize, Mathf.Min(1f, distanceToTarget));

            if(_state != State.Deactivate)
                SwitchState(State.Inflates);

            while(t < 1f)
            {
                t += Time.deltaTime / _ballInflateTime;
                ball.transform.localScale = Vector3.Lerp(startSize, targetSize, t);
                yield return null;
            }

            OnBubbleSpawned?.Invoke(ball);

            if (_state == State.Deactivate)
            {
                _moveTarget = _pickedPaint.transform.position + _paintPosOffset;
                StartCoroutine(Move(false));
                SwitchState(State.Deactivated);
                yield break;
            }
            else
            {
                SwitchState(State.Move);
            }

            yield return new WaitForSeconds(_ballSpawnDelay);
        }
    }

    private Vector3 Parabola(Vector3 start, Vector3 end, float height, float t)
    {
        Func<float, float> f = x => -4 * height * x * x + 4 * height * x;

        var mid = Vector3.Lerp(start, end, t);

        return new Vector3(mid.x, f(t) + Mathf.Lerp(start.y, end.y, t), mid.z);
    }
}
