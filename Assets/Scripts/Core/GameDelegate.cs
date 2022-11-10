using core.level;
using System;

public static class GameDelegate
{
    private static event Action<LevelContainer, SceneContainer> _onLevelInited;
    public static event Action<LevelContainer, SceneContainer> onLevelInited
    {
        add
        {
            _onLevelInited += value;
        }
        remove
        {
            _onLevelInited -= value;
        }
    }

    private static event Action _onStart;
    public static event Action onStart
    {
        add
        {
            _onStart += value;
        }
        remove
        {
            _onStart -= value;
        }
    }

    private static event Action _onLose;
    public static event Action onLose
    {
        add
        {
            _onLose += value;
        }
        remove
        {
            _onLose -= value;
        }
    }

    private static event Action _onWin;
    public static event Action onWin
    {
        add
        {
            _onWin += value;
        }
        remove
        {
            _onWin -= value;
        }
    }

    public static void InvokeOnLevelInited(LevelContainer levelContainer, SceneContainer sceneContainer)
    {
        if (_onLevelInited != null)
            _onLevelInited.Invoke(levelContainer, sceneContainer);
    }

    public static void InvokeOnWin()
    {
        if (_onWin != null)
            _onWin.Invoke();
    }

    public static void InvokeOnLose()
    {
        if (_onLose != null)
            _onLose.Invoke();
    }

    public static void InvokeOnStart()
    {
        if (_onStart != null)
            _onStart.Invoke();
    }
}
