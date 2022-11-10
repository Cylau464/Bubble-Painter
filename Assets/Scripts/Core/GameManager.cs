using UnityEngine;
using input;
using data;
#if Support_SDK
using app;
#endif
#if Support_UnityEvents
using UnityEngine.Events;
#endif
using System;

public class GameManager : MonoBehaviour, engine.IValidate
{
#if Support_Instance
    public static GameManager instance { get; private set; }
#endif

#if Support_UnityEvents
    [SerializeField] private UnityEvent _onStart;
    [SerializeField] private UnityEvent _onLost;
    [SerializeField] private UnityEvent _onWin;
#endif

    #region gets
    public static bool isStarted { get; private set; }
    public static bool isWin { get; private set; }
    public static bool isLost { get; private set; }
    public static bool isFinished { get { return isLost || isWin; } }
    public static bool isPlaying { get { return !isFinished && isStarted; } }
    public static float defaultScale { get; private set; }

    public LevelsData levelsData => _levelsData;
    #endregion

    #region objects
    [SerializeField] private LevelsData _levelsData;
    #endregion

    #region engine
    protected void Awake()
    {
#if Support_Instance
        instance = this;
#endif
#if Support_SDK
        AppsManager.ShowBanner();
#endif
        Initialize();
    }

    private void Initialize()
    {
        defaultScale = Time.timeScale = 1;
        Screen.sleepTimeout = SleepTimeout.NeverSleep;
    }

    protected void OnDestroy()
    {
        isStarted = false;
        isWin = false;
        isLost = false;
    }
#endregion

    #region desitions
    public void StartGame()
    {
        isStarted = true;
        ControllerInputs.enableInputs = true;
#if Support_SDK
        ProgressEvents.OnLevelStarted(_levelsData.playerLevel, _levelsData.idLevel);
#endif
#if Support_UnityEvents
        if (_onStart != null)
            _onStart.Invoke();
#endif
        GameDelegate.InvokeOnStart();
    }

    public void MakeWin()
    {
        if (isFinished)
            return;


        isWin = true;

        int playerLevel = _levelsData.playerLevel;
        int idLevel = _levelsData.idLevel;
        _levelsData.OnWin();
#if Support_SDK
        ProgressEvents.OnLevelCompleted(playerLevel, idLevel);
#endif
        ControllerInputs.enableInputs = false;
#if Support_UnityEvents
        if (_onWin != null)
            _onWin.Invoke();
#endif
        GameDelegate.InvokeOnWin();
    }

    public void MakeLost()
    {
        if (isFinished)
            return;

        isLost = true;
        int playerLevel = _levelsData.playerLevel;
        int idLevel = _levelsData.idLevel;
        _levelsData.OnLost();
#if Support_SDK
        ProgressEvents.OnLevelFieled(playerLevel, idLevel);
#endif
        ControllerInputs.enableInputs = false;
#if Support_UnityEvents
        if (_onLost != null)
            _onLost.Invoke();
#endif
        GameDelegate.InvokeOnLose();
    }

    public static void PauseGame()
    {
        if (!isFinished)
        {
            Time.timeScale = 0;
        }
    }

    public static void PauseSlow01()
    {
        if (!isFinished)
        {
            Time.timeScale = 0.0001f;
        }
    }

    public static void SetTimeScale(float scale)
    {
        if (!isFinished)
        {
            Time.timeScale = scale;
        }
    }

    public static void ContinueGame()
    {
        Time.timeScale = defaultScale;
    }
    #endregion

    #region editor
    public void Validate()
    {
        transform.SetAsLastSibling();
    }
    #endregion
}