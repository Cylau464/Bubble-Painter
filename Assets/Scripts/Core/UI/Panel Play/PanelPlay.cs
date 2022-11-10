using UnityEngine;
using UnityEngine.UI;

namespace core.ui
{
    public class PanelPlay : Panel
    {
        [Header("Text Level")]
        [SerializeField] private data.LevelsData _levelsData;
        [SerializeField] private Text _textLevel;

        private void Awake()
        {
            gameObject.SetActive(false);
        }

        public override void Initialize(MainCanvasManager mainCanvas)
        {
            base.Initialize(mainCanvas);
            InitializedTextLevel();
        }

        private void InitializedTextLevel()
        {
            int clevel = _levelsData.playerLevel;
            if (clevel < 10)
            {
                _textLevel.text = "LEVEL 0" + clevel;
            }
            else
            {
                _textLevel.text = "LEVEL " + clevel;
            }
        }

        public void ReloadScene()
        {
            _mainCanvasManager.ReloadScene();
        }
    }
}
