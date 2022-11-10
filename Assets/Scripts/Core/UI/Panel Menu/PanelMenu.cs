using UnityEngine.UI;
using UnityEngine;

namespace core.ui
{
    public class PanelMenu : Panel
    {
        [SerializeField] private Button _startGameBtn;
        [UnityEngine.SerializeField] protected LevelsProgress _levelsProgress;

        private void Start()
        {
            _startGameBtn.onClick.AddListener(StartGame);
        }

        public void StartGame()
        {
            _mainCanvasManager.StartGame();
            _startGameBtn.gameObject.SetActive(false);
        }

        protected override void OnShowed()
        {
            _levelsProgress.Initialize();
        }
    }
}
