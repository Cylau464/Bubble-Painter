using System.Collections.Generic;
using UnityEngine;

namespace engine.camera
{
    public class ControllerVirtualCameras : MonoBehaviour, IValidate
    {
        [SerializeField] private VirtualCamerasManager _camerasInfo;
        [SerializeField] private string _defaultSwitch = "Default";
        [SerializeField] private List<CameraView> _views;


        protected void OnEnable()
        {
            Initialize();
        }

        private void Initialize()
        {
            _camerasInfo.AddCameraView(_views);
            _camerasInfo.SwitchTo(_defaultSwitch);
        }

        protected void OnDisable()
        {
            _camerasInfo.Deinitialize();
        }

        public void Validate()
        {
            foreach (var item in _views)
            {
                item.Off();
            }

            _views.Find(x => x.tag == _defaultSwitch).On();
        }
    }
}
