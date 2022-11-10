using UnityEngine;

namespace engine.audio
{
    [System.Serializable]
    public struct AudioData
    {
        [Tooltip("In true case the on audio.")]
        public bool enableAudio;

        [Tooltip("In true case the on vibrate.")]
        public bool enableVibrate;

        /// <summary>
        /// Restore the data to the default values.
        /// </summary>
        public void Reset()
        {
            enableAudio = true;
            enableVibrate = true;
        }
    }
}
