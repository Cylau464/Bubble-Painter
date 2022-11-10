using UnityEngine;

#if Support_UnityEvents
using UnityEngine.Events;
#endif

namespace core.ui
{
    public abstract class Panel : MonoBehaviour, IPanel
    {
        protected MainCanvasManager _mainCanvasManager;
#if Support_UnityEvents
        [SerializeField] protected UnityEvent _onShow;
        [SerializeField] protected UnityEvent _onHide;
#endif

        public virtual void Initialize(MainCanvasManager mainCanvas)
        {
            _mainCanvasManager = mainCanvas;
        }

        public void Show()
        {
            gameObject.SetActive(true);
            OnShowed();
#if Support_UnityEvents
            if (_onShow != null)
                _onShow.Invoke();
#endif
        }

        protected virtual void OnShowed()
        {

        }

        public void Hide()
        {
            gameObject.SetActive(false);
            OnHided();
#if Support_UnityEvents
            if (_onHide != null)
                _onHide.Invoke();
#endif
        }

        protected virtual void OnHided()
        {

        }
    }
}