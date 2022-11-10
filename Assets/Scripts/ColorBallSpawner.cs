using System.Collections.Generic;
using UnityEngine;

public class ColorBallSpawner : MonoBehaviour
{
    [SerializeField] private ColorBall _ballPrefab;
    [SerializeField] private int _ballSpawnCount = 100;
    [SerializeField] private int _splashingBallsPerFrame = 4;

    private Stack<ColorBall> _ballStack;
    private List<ColorBall> _activeBalls;
    public List<ColorBall> ActiveBalls => _activeBalls;
    private Queue<ColorBall> _splashQueue;

    private void Start()
    {
        _ballStack = new Stack<ColorBall>(_ballSpawnCount);
        _activeBalls = new List<ColorBall>(_ballSpawnCount);
        _splashQueue = new Queue<ColorBall>(20);

        for(int i = 0; i < _ballSpawnCount; i++)
        {
            ColorBall ball = CreateBall(transform);
            ball.gameObject.SetActive(false);
            _ballStack.Push(ball);
        }
    }

    private void Update()
    {
        if(_splashQueue.Count > 0)
        {
            for(int i = 0; i < _splashingBallsPerFrame; i++)
            {
                ColorBall ball = _splashQueue.Dequeue();
                ball.Splash();

                if (_splashQueue.Count <= 0) break;
            }
        }
    }

    private ColorBall CreateBall(Transform parent = null)
    {
        ColorBall ball = Instantiate(_ballPrefab, parent);
        ball.Init(this);

        return ball;
    }

    public ColorBall GetBall()
    {
        ColorBall ball;

        if (_ballStack.Count <= 0)
        {
            ball = CreateBall();
        }
        else
        {
            ball = _ballStack.Pop();
            ball.transform.SetParent(null);
        }

        ball.OnSplashed += OnBallSplashed;
        _activeBalls.Add(ball);

        return ball;
    }

    public void ReturnToStack(ColorBall ball)
    {
        ball.transform.SetParent(transform);
        ball.gameObject.SetActive(false);
        _ballStack.Push(ball);
    }

    private void OnBallSplashed(ColorBall ball)
    {
        ball.OnSplashed -= OnBallSplashed;
        _activeBalls.Remove(ball);
    }

    public void AddBallInQueue(ColorBall ball)
    {
        _splashQueue.Enqueue(ball);
    }
}
