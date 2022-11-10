using core.level;
using UnityEngine;
using System;
using UnityEngine.SceneManagement;

namespace core.loading
{
    [CreateAssetMenu(fileName = "Loader Assets", menuName = "Add/More/Loader Assets", order = 10)]
    public class LoaderManager : engine.ScriptableAsset, engine.IValidate
    {
        #region vars
        [Header("Settings & Data")]
        [SerializeField] protected GameSettings _settings;
        [SerializeField] protected data.LevelsData _levelsData;

        [Header("Levels")]
        [SerializeField] protected LevelInfoSO[] _levels;
        #endregion

        #region gets
        public int totalLevels => _levels.Length;
        #endregion

        #region load
        public void LoadMainScene()
        {
            SceneManager.LoadSceneAsync(_settings.mainSceneName);
        }

        public GameLevel LoadLevel(Transform parent)
        {
            return Instantiate(_levels[_levelsData.GetIDLevel()].levelPrefab, parent);
        }
        #endregion

        #region editor
        public void Validate()
        {
#if UNITY_EDITOR
            /// Find all levels.
            _levels = editor.ScriptableManager.FindScribtableObjectsOfType<LevelInfoSO>();
            Array.Sort(_levels);
#endif
            /// Update total levels
            _settings.totalLevels = _levels.Length;
        }

        protected void OnValidate()
        {
            Validate();
        }
        #endregion
    }
}
