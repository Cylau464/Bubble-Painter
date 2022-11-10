using core.loading;
using UnityEngine;

namespace core.ui
{
    public class MainCanvasManager : MonoBehaviour
    {
        [SerializeField] private GameManager _gameManager;
        [SerializeField] private LoaderManager _loaderManager;
        [SerializeField] private GameSettings _settings;

        [Header("Panels")]
        [SerializeField] private Panel _menuPanel;
        [SerializeField] private Panel _playPanel;
        [SerializeField] private Panel _losePanel;
        [SerializeField] private Panel _winPanel;

        public Panel activatePanel { get; private set; }

        // Start is called before the first frame update
        protected void OnEnable()
        {
            GameDelegate.onWin += OnWin;
            GameDelegate.onLose += OnLose;

            _menuPanel.Initialize(this);
            _playPanel.Initialize(this);
            _losePanel.Initialize(this);
            _winPanel.Initialize(this);

            SwitchPanel(_menuPanel);
        }

        protected void OnDestroy()
        {
            GameDelegate.onWin -= OnWin;
            GameDelegate.onLose -= OnLose;
        }

        private void OnStart()
        {
            SwitchPanel(_playPanel);
        }

        private void OnWin()
        {
            StartCoroutine(WaitAndShowWin());
        }

        private void OnLose()
        {
            StartCoroutine(WaitAndShowLose());
        }

        #region coroutine
        private System.Collections.IEnumerator WaitAndShowLose()
        {
            yield return new WaitForSeconds(_settings.timeAndShowWinLosePanel);
            SwitchPanel(_losePanel);
        }

        private System.Collections.IEnumerator WaitAndShowWin()
        {
            yield return new WaitForSeconds(_settings.timeAndShowWinLosePanel);
            SwitchPanel(_winPanel);
        }
        #endregion

        public void SwitchPanel(Panel nextPanel)
        {
            activatePanel?.Hide();
            nextPanel.Show();
            activatePanel = nextPanel;
        }

        public void Next()
        {
            ReloadScene();
        }

        public void ReloadScene()
        {
            _loaderManager.LoadMainScene();
        }

        public void StartGame()
        {
            _gameManager.StartGame();
            OnStart();
        }
    }
}
