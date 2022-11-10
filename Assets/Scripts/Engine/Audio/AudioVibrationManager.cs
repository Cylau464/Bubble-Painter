using data;
using System;
using UnityEngine;

namespace engine.audio
{
    [CreateAssetMenu(fileName = "New AudioManager", menuName = "Add/More/Audio Manager", order = 11)]
    public class AudioVibrationManager : ScriptableAsset, IData, IAwake
    {
        #region delegates
        private event Action<bool> _onSwitchAudio;
        public event Action<bool> onSwitchAudio
        {
            add
            {
                _onSwitchAudio += value;
            }
            remove
            {
                _onSwitchAudio -= value;
            }
        }

        private event Action<bool> _onSwitchVibration;
        public event Action<bool> onSwitchVibration
        {
            add
            {
                _onSwitchVibration += value;
            }
            remove
            {
                _onSwitchVibration -= value;
            }
        }
        #endregion

        #region variables
        [SerializeField] private AudioData _audioData;

        public bool enableAudio => _audioData.enableAudio;
        public bool enableVibrate => _audioData.enableVibrate;
        #endregion

        #region engine funs
        public void Awake()
        {
            Initialize();
        }
        #endregion

        #region data management
        public void Initialize()
        {
            _audioData = ES3.Load(GetKey(), ObjectSaver.GetSavingPathFile<AudioData>(GetKey()), _audioData);
        }

        public void Save()
        {
            ES3.Save(GetKey(), _audioData, ObjectSaver.GetSavingPathFile<AudioData>(GetKey()));
        }

        public string GetKey()
        {
            return "SettingsData.json";
        }

        public void ResetData()
        {
            _audioData.Reset();
        }
        #endregion

        #region audio and vibration
        /// <summary>
        /// Switch the audio enable if the audio was false you can switch it to true and opposite.
        /// </summary>
        public void SwitchEnableAudio()
        {
            _audioData.enableAudio = !_audioData.enableAudio;
            Save();
            _onSwitchAudio?.Invoke(_audioData.enableAudio);
        }

        public void SetEnableAudio(bool enable)
        {
            if (enable != _audioData.enableAudio)
            {
                _audioData.enableAudio = enable;
                Save();
                _onSwitchAudio?.Invoke(enable);
            }
        }

        /// <summary>
        /// Switch the Vibrate enable if the audio was false you can switch it to true and opposite.
        /// </summary>
        public void SwitchEnableVibrate()
        {
            _audioData.enableVibrate = !_audioData.enableVibrate;
            Save();
            _onSwitchVibration?.Invoke(_audioData.enableVibrate);
        }

        public void SetEnableVibrate(bool enable)
        {
            if (enable != _audioData.enableVibrate)
            {
                _audioData.enableVibrate = enable;
                Save();
                _onSwitchVibration?.Invoke(enable);
            }
        }
        #endregion
    }
}
