using Cinemachine;
using System.Collections.Generic;
using UnityEngine;

namespace engine.camera
{
    [CreateAssetMenu(fileName = "Virtual Cameras Info", menuName = "Add/More/Virtual Cameras Manager", order = 549)]
    public class VirtualCamerasManager : ScriptableAsset
    {
        #region varialbles
#if UNITY_EDITOR
        [SerializeField]
#endif
        protected List<CameraView> _camerasViews = new List<CameraView>();
        private CameraView _currentView;
        #endregion

        #region list
        public void AddCameraView(CameraView view)
        {
            _camerasViews.Add(view);
        }

        public void AddCameraView(List<CameraView> views)
        {
            _camerasViews.AddRange(views);
        }

        public CameraView FindCameraView(string tag)
        {
            return _camerasViews.Find(x => x.tag.CompareTo(tag) == 0);
        }

        public void AddCameraViewAndSwitch(CameraView view)
        {
            _camerasViews.Add(view);
            SwitchTo(view);
        }
        #endregion

        #region switch
        public bool SwitchTo(CameraView view)
        {
            if (_currentView != null && _currentView.isEnable)
                _currentView.Off();

            _currentView = view;
            if (_currentView == null || !_currentView.isEnable)
                return false;
            else
            {
                _currentView.On();
                return true;
            }
        }

        public bool SwitchTo(string tag)
        {
            if (_currentView != null && _currentView.isEnable)
                _currentView.Off();

            _currentView = FindCameraView(tag);
            if (_currentView == null || !_currentView.isEnable)
                return false;
            else
            {
                _currentView.On();
                return true;
            }
        }
        #endregion

        #region Follow and LookAt
        public static bool SetFollow(Transform follow, CameraView view)
        {
            if (view != null && view.isEnable)
            {
                view.SetFollow(follow);
                return true;
            }
            return false;
        }

        public static bool SetLookAt(Transform lookAt, CameraView view)
        {
            if (view != null && view.isEnable)
            {
                view.SetLookAt(lookAt);
                return true;
            }
            return false;
        }

        public bool SetFollow(Transform follow)
        {
            return SetFollow(follow, _currentView);
        }

        public bool SetLookAt(Transform lookAt)
        {
            return SetLookAt(lookAt, _currentView);
        }

        public bool SetFollow(Transform follow, string tag)
        {
            return SetFollow(follow, FindCameraView(tag));
        }

        public bool SetLookAt(Transform lookAt, string tag)
        {
            return SetLookAt(lookAt, FindCameraView(tag));
        }
        #endregion

        #region info
        public CinemachineVirtualCamera GetVirtualCamera()
        {
            if (_currentView != null && _currentView.isEnable)
                return _currentView.virtualCamera;
            else
                return null;
        }

        public CameraView GetCurrentCameraView()
        {
            return _currentView;
        }
        #endregion

        #region Deinit
        public void Deinitialize()
        {
            _currentView = null;
            _camerasViews.Clear();
        }
        #endregion
    }
}
