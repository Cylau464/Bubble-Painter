using engine;
using UnityEngine;

namespace data
{
    [CreateAssetMenu(fileName = "New LevelsData", menuName = "Add/More/LevelsData", order = 7)]
    public class LevelsData : ScriptableAsset, IAwake,  IResetData, IData
    {
        [SerializeField] private Data _data;
        [SerializeField] private GameSettings _gameSettings;

        #region gets sets
        public GameSettings gameSettings => _gameSettings;
        public int playerLevel => _data.playerLevel;
        public int idLevel => GetIDLevel();

        public int GetIDLevel()
        {
            /// If the game in testing mode.
            if (_gameSettings.isTestingMode)
                return _gameSettings.indexTestLevel;
            else
                return _data.idLevel;
        }
        #endregion

        #region inits
        public void Awake()
        {
            Initialize();
        }

        public void Initialize()
        {
            _data = ES3.Load(GetKey(), ObjectSaver.GetSavingPathFile<Data>(GetKey()), _data);
        }
        #endregion

        #region progress
        /// <summary>
        /// This function execute when the anylevel completed .
        /// </summary>
        public void OnWin()
        {
            if (_data.randomLevels)
            {
                _data.idLevel = _gameSettings.GetRandomLevelID(_data.idLevel);
            }
            else
            {
                if (_gameSettings.totalLevels - 1 <= _data.idLevel)
                {
                    _data.randomLevels = true;
                    _data.idLevel = _gameSettings.GetRandomLevelID(_data.idLevel);
                }
                else
                {
                    _data.idLevel++;
                }
            }

            _data.playerLevel++;
            Save();
        }

        /// <summary>
        /// This function call on the anylevel failed.
        /// </summary>
        public void OnLost()
        {

        }
        #endregion

        #region data management
        public void Save()
        {
            ES3.Save(GetKey(), _data, ObjectSaver.GetSavingPathFile<Data>(GetKey()));
        }

        public string GetKey()
        {
            return "LevelsData.json";
        }

        public void ResetData()
        {
            _data.Reset();
        }
        #endregion
    }
}