using UnityEngine;

namespace core.loading
{
    public class LoadingView : MonoBehaviour
    {
        [SerializeField] protected LoaderManager _loaderManager;

        protected void Start()
        {
            _loaderManager.LoadMainScene();
        }

#if UNITY_EDITOR
        protected void OnValidate()
        {
            if (_loaderManager == null)
                _loaderManager = FindObjectOfType<LoaderManager>();
        }
#endif
    }
}
