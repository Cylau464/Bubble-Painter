using core.loading;
using UnityEngine;
using System;

namespace core.level
{
    [System.Serializable]
    public struct SceneContainer
    {
        public GameManager gameManager;

        public void OnValidate()
        {
            if (gameManager == null)
                gameManager = GameObject.FindObjectOfType<GameManager>();
        }
    }

    public class LevelsManager : MonoBehaviour
    {
        [Header("Settings")]
        [SerializeField] protected LoaderManager _levelLoader;
        [SerializeField] protected GameSettings _settings;
        [SerializeField] protected Transform _levelsContents;

        [Header("Container")]
        [SerializeField] protected SceneContainer _sceneContainer;

        public LevelContainer levelContainer { get; private set; }

        public int totalLevels { get { return _levelLoader.totalLevels; } }
        public static GameLevel currentLevel { get; private set; }
        public static bool isLevelLoaded { get; private set; } = false;
        
        public static Action<GameLevel> OnLevelLoaded;

        public void OnEnable()
        {
            if (_settings.isTestingMode)
            {
                currentLevel = FindObjectOfType<GameLevel>();
                if (currentLevel == null)
                    MakeLoadLevel();
                else
                    DefineCurrentLevel(currentLevel);
            }
            else
            {
                MakeLoadLevel();
            }
        }

        private void MakeLoadLevel()
        {
            DefineCurrentLevel(_levelLoader.LoadLevel(_levelsContents));
        }

        protected void DefineCurrentLevel(GameLevel level)
        {
            if (level == null)
            {
                Debug.LogError("The level not found it.");
                return;
            }

            isLevelLoaded = true;
            currentLevel = level;
            OnLevelLoaded?.Invoke(level);

            if (currentLevel != null)
            {
                levelContainer = currentLevel.Initialize(this, _sceneContainer);
                GameDelegate.InvokeOnLevelInited(currentLevel.levelContainer, _sceneContainer);
            }
            else
                Debug.Log("Level Prefab not found!!");
        }

        protected void OnDestroy()
        {
            currentLevel = null;
            isLevelLoaded = false;
        }

        protected void OnValidate()
        {
            _sceneContainer.OnValidate();
        }
    }
}
