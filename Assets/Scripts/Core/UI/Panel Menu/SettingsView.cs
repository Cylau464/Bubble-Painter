using UnityEngine;
using UnityEngine.UI;

namespace core.ui
{
    public class SettingsView : MonoBehaviour, IPanel
    {
        #region variables
        [Header("Manager")]
        [SerializeField] private engine.audio.AudioVibrationManager _audioManager;
        [SerializeField] private GameObject _settingPanel;
        [SerializeField] private GameObject _settingHead;

        [Header("Audio")]
        [SerializeField] private Button  _audioOn;
        [SerializeField] private Button _audioOff;

        [Header("Vibration")]
        [SerializeField] private Button _vibrateOn;
        [SerializeField] private Button _vibrateOff;

        public bool isShowed { get; private set; }
        #endregion

        protected void Start()
        {
            _audioOn.onClick.AddListener(() => SwitchAudio());
            _audioOff.onClick.AddListener(() => SwitchAudio());

            _vibrateOn.onClick.AddListener(() => SwitchVibrate());
            _vibrateOff.onClick.AddListener(() => SwitchVibrate());
        }

        #region panel
        public void SwitchPanel()
        {
            if (!isShowed)
                Show();
            else
                Hide();
        }

        public void Show()
        {
            isShowed = true;
            _settingHead.SetActive(!isShowed);
            _settingPanel.SetActive(isShowed);
            OnSwitchedAudio(_audioManager.enableAudio);
            OnSwitchedVibrate(_audioManager.enableVibrate);
        }

        public void Hide()
        {
            isShowed = false;
            _settingPanel.SetActive(isShowed);
            _settingHead.SetActive(!isShowed);
        }
        #endregion

        #region switchs
        public void SwitchAudio()
        {
            _audioManager.SwitchEnableAudio();
            OnSwitchedAudio(_audioManager.enableAudio);
        }

        public void SwitchVibrate()
        {
            _audioManager.SwitchEnableVibrate();
            OnSwitchedVibrate(_audioManager.enableVibrate);
        }
        #endregion

        #region OnSwitched
        public void OnSwitchedAudio(bool enable)
        {
            _audioOn.gameObject.SetActive(enable);
            _audioOff.gameObject.SetActive(!enable);
        }

        public void OnSwitchedVibrate(bool enable)
        {
            _vibrateOn.gameObject.SetActive(enable);
            _vibrateOff.gameObject.SetActive(!enable);
        }
        #endregion
    }
}
