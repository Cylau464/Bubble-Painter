using MPUIKIT;
using UnityEngine;

namespace core.ui
{
    public class LevelsProgress : MonoBehaviour
    {
        [SerializeField] private data.LevelsData _levelsData;
        [SerializeField] private GameObject _levelsImagesPrefab;
        [SerializeField] private Transform _contents;
        [SerializeField] private MPImage _progressImage;
        [SerializeField] private int _levelsLenght = 5;

        private bool isInited = false;

        public void Initialize()
        {
            if (isInited == true)
                return;

            int currentLevel = _levelsData.playerLevel;
            int startFrom = (Mathf.FloorToInt((currentLevel - 1) / (float)_levelsLenght)) * _levelsLenght + 1;
            LevelInfoUI levelInfo = null;
            for (int i = 0; i < _levelsLenght; i++)
            {
                int index = startFrom + i;
                levelInfo = Instantiate(_levelsImagesPrefab, _contents).GetComponent<LevelInfoUI>();
                levelInfo.levelText.text = index.ToString();

                if (index < currentLevel)
                    levelInfo.previousObject?.SetActive(true);
                else
                if (currentLevel == index)
                    levelInfo.currentObject?.SetActive(true);
            }

            _progressImage.fillAmount = (currentLevel - startFrom) / (float)_levelsLenght + 0.1f;
            isInited = true;
        }
    }
}