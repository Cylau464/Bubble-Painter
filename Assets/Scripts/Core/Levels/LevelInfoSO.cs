using UnityEngine;

namespace core.level
{
    [CreateAssetMenu(fileName = "LevelInfo", menuName = "Add/LevelInfo", order = 1)]
    public class LevelInfoSO : engine.ScriptableAsset, System.IComparable
    {
        #region variables
        [SerializeField] protected int _idLevel = -1;
        [SerializeField] protected GameLevel _levelPrefab;
        #endregion

        #region gets
        public int idLevel => _idLevel;
        public GameLevel levelPrefab => _levelPrefab;
        #endregion

        #region functions
        public int CompareTo(object obj)
        {
            if (obj == null) return 1;
            try
            {
                 return idLevel - ((LevelInfoSO)obj).idLevel;
            }
            catch
            {
                return 1;
            }
        }
        #endregion

        #region editor
#if UNITY_EDITOR
        protected void OnValidate()
        {
            if (_idLevel < 0)
                _idLevel = editor.ScriptableManager.FindScribtableObjectsOfType<LevelInfoSO>().Length;
        }
#endif
        #endregion
    }
}
