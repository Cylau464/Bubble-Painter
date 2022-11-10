using engine.camera;
using UnityEngine;

namespace examples
{
    public class SwitchCamerasExample : MonoBehaviour
    {
        public VirtualCamerasManager virtualCamerasManager;

        public string _startViewTag = "OnStart";
        public CameraView _loseView;

        void OnEnable()
        {
            GameDelegate.onStart += SwitchToStart;
            GameDelegate.onLose += SwitchToLose;
        }

        void OnDisable()
        {
            GameDelegate.onStart -= SwitchToStart;
            GameDelegate.onLose -= SwitchToLose;
        }

        public void SwitchToStart()
        {
            virtualCamerasManager.SwitchTo(_startViewTag);
        }

        public void SwitchToLose()
        {
            virtualCamerasManager.AddCameraViewAndSwitch(_loseView);
        }
    }
}
