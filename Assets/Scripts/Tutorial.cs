using UnityEngine;

public class Tutorial : MonoBehaviour
{
    [SerializeField] private GameSettings _gameSetting;
    [SerializeField] private TubuleController _tubuleController;
    [Space]
    [SerializeField] private GameObject _spawnBubblesTutor;
    [SerializeField] private GameObject _splashBubbleTutor;
    [SerializeField] private GameObject _moveStickerTutor;

    public static Tutorial Instance;

    private void Awake()
    {
        if(Instance != null && Instance != this)
        {
            Destroy(this);
            return;
        }

        Instance = this;

        _tubuleController.OnBubbleSpawned += SplashBubble;

        if (_gameSetting.tutorialCompleted == true)
            gameObject.SetActive(false);
        else
            _spawnBubblesTutor.SetActive(true);
    }

    private void OnDestroy()
    {
        _tubuleController.OnBubbleSpawned -= SplashBubble;
    }

    private void SplashBubble(ColorBall bubble)
    {
        if (_spawnBubblesTutor.activeSelf == true)
            _spawnBubblesTutor.SetActive(false);

        _splashBubbleTutor.SetActive(true);
        _splashBubbleTutor.transform.GetChild(0).position = Camera.main.WorldToScreenPoint(bubble.transform.position); ;
        _tubuleController.OnBubbleSpawned -= SplashBubble;
        bubble.OnSplashed += OnSplashed;
    }

    private void OnSplashed(ColorBall bubble)
    {
        _splashBubbleTutor.SetActive(false);
        bubble.OnSplashed -= OnSplashed;
    }

    public void StickerMovable()
    {
        _moveStickerTutor.SetActive(true);
    }
    
    public void CompleteTutorial()
    {
        _gameSetting.tutorialCompleted = true;
        gameObject.SetActive(false);
    }
}
